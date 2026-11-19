import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/logger.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/library/application/add_book.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';

import '../helpers/fake_cover_store.dart';
import '../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;
  late FakeCoverStore covers;
  late AppLogger logger;
  late AddBook addBook;
  var n = 0;

  setUp(() {
    h = RepoHarness();
    covers = FakeCoverStore();
    logger = AppLogger();
    n = 0;
    addBook = AddBook(
      books: h.books,
      covers: covers,
      clock: h.clock,
      logger: logger,
      newId: () => 'id${++n}',
    );
  });
  tearDown(() => h.dispose());

  final isbn = parseIsbn('9780143127550')!;

  Future<Book> saved(BookDraft d, {bool allowDuplicate = false}) async {
    final r = await addBook(d, allowDuplicate: allowDuplicate);
    final added = r.getOrNull()! as BookAdded;
    await added.coverJob;
    return (await h.books.getById(added.book.id)).getOrNull()!;
  }

  group('saving', () {
    test(
      'creates a book with computed key, trimmed text and defaults',
      () async {
        final b = await saved(
          const BookDraft(
            title: '  The Hobbit  ',
            authors: ' J. R. R. Tolkien ',
            genre: ' Fantasy ',
            notes: '   ',
            ownerName: '',
          ),
        );
        expect(b.id, 'id1');
        expect(b.title, 'The Hobbit');
        expect(b.authors, 'J. R. R. Tolkien');
        expect(b.genre, 'Fantasy');
        expect(b.notes, isNull);
        expect(b.ownerName, isNull);
        expect(b.titleKey.value, 'hobbit|tolkien');
        expect(b.ownership, Ownership.owned);
        expect(b.status, ReadStatus.want);
        expect(b.rev, greaterThanOrEqualTo(1));
      },
    );

    test('keeps every field from the draft', () async {
      final loc = await h.addLocation(name: 'Shelf');
      final b = await saved(
        BookDraft(
          title: 'Dune',
          authors: 'Frank Herbert',
          subtitle: 'Book One',
          isbn13: isbn,
          olWorkKey: '/works/W1',
          pages: 412,
          ownership: Ownership.wishlist,
          locationId: loc.id,
          language: 'en',
          ownerName: 'Me',
          notes: 'gift',
        ),
      );
      expect(b.subtitle, 'Book One');
      expect(b.isbn13, isbn);
      expect(b.olWorkKey, '/works/W1');
      expect(b.pages, 412);
      expect(b.ownership, Ownership.wishlist);
      expect(b.locationId, loc.id);
      expect(b.language, 'en');
      expect(b.ownerName, 'Me');
      expect(b.notes, 'gift');
    });

    test(
      'status reading sets the start date; finished sets finish + page',
      () async {
        final reading = await saved(
          const BookDraft(title: 'A', pages: 100, status: ReadStatus.reading),
        );
        expect(reading.startedOn, DateTime(2025, 3, 10));
        expect(reading.currentPage, 0);

        final done = await saved(
          const BookDraft(title: 'B', pages: 250, status: ReadStatus.finished),
        );
        expect(done.finishedOn, DateTime(2025, 3, 10));
        expect(done.currentPage, 250);
      },
    );

    test('BookDraft.fromInfo copies catalogue data', () {
      final d = BookDraft.fromInfo(
        BookInfo(
          title: 'T',
          subtitle: 'S',
          authors: const ['A', 'B'],
          pages: 10,
          isbn13: isbn,
          olWorkKey: '/works/W',
          coverUrl: 'https://c/x.jpg',
        ),
      );
      expect(d.title, 'T');
      expect(d.authors, 'A, B');
      expect(d.subtitle, 'S');
      expect(d.isbn13, isbn);
      expect(d.coverUrl, 'https://c/x.jpg');
      expect(d.pages, 10);
    });
  });

  group('validation', () {
    test('a blank title is rejected and nothing is saved', () async {
      for (final t in <String>['', '   ']) {
        final r = await addBook(BookDraft(title: t));
        final f = r.failureOrNull()! as ValidationFailure;
        expect(f.field, 'title');
      }
      expect(await h.books.watchAll().first, isEmpty);
    });

    test('pages must be positive when given', () async {
      for (final p in <int>[0, -4]) {
        final f =
            (await addBook(BookDraft(title: 'T', pages: p))).failureOrNull()!
                as ValidationFailure;
        expect(f.field, 'pages');
      }
    });
  });

  group('duplicates', () {
    test('same ISBN is reported and nothing is saved', () async {
      final existing = await h.addBook(
        id: 'old',
        title: 'Something',
        tweak: (b) => b.copyWith(isbn13: isbn),
      );
      final r = await addBook(
        BookDraft(title: 'Totally different', isbn13: isbn),
      );
      final dup = r.getOrNull()! as DuplicatesFound;
      expect(dup.books.map((b) => b.id), [existing.id]);
      expect((await h.books.watchAll().first), hasLength(1));
    });

    test('same title without any ISBN is reported', () async {
      await h.addBook(
        id: 'old',
        title: 'The Hobbit',
        authors: 'J.R.R. Tolkien',
      );
      final r = await addBook(
        const BookDraft(title: 'Hobbit', authors: 'Tolkien'),
      );
      expect(r.getOrNull(), isA<DuplicatesFound>());
    });

    test('same work key (another edition) is reported', () async {
      await h.addBook(id: 'old', title: 'Old edition', olWorkKey: '/works/W9');
      final r = await addBook(
        const BookDraft(title: 'New edition title', olWorkKey: '/works/W9'),
      );
      expect((r.getOrNull()! as DuplicatesFound).books.single.id, 'old');
    });

    test('several signals for one book list it once', () async {
      await h.addBook(
        id: 'old',
        title: 'Dune',
        authors: 'Frank Herbert',
        olWorkKey: '/works/W1',
        tweak: (b) => b.copyWith(isbn13: isbn),
      );
      final r = await addBook(
        BookDraft(
          title: 'Dune',
          authors: 'Frank Herbert',
          isbn13: isbn,
          olWorkKey: '/works/W1',
        ),
      );
      expect((r.getOrNull()! as DuplicatesFound).books, hasLength(1));
    });

    test('different books are not duplicates', () async {
      await h.addBook(id: 'old', title: 'Dune', authors: 'Frank Herbert');
      final r = await addBook(
        const BookDraft(title: 'Emma', authors: 'Jane Austen'),
      );
      expect(r.getOrNull(), isA<BookAdded>());
    });

    test('allowDuplicate adds another copy', () async {
      await h.addBook(id: 'old', title: 'Dune', authors: 'Frank Herbert');
      final b = await saved(
        const BookDraft(title: 'Dune', authors: 'Frank Herbert'),
        allowDuplicate: true,
      );
      expect(b.id, 'id1');
      expect(await h.books.watchCount().first, 2);
    });

    test('deleted books are not duplicates', () async {
      await h.addBook(id: 'old', title: 'Dune', authors: 'Frank Herbert');
      await h.books.softDelete('old');
      final r = await addBook(
        const BookDraft(title: 'Dune', authors: 'Frank Herbert'),
      );
      expect(r.getOrNull(), isA<BookAdded>());
    });

    test('findDuplicates is available on its own', () async {
      await h.addBook(id: 'old', title: 'Dune');
      final r = await addBook.findDuplicates(const BookDraft(title: 'Dune'));
      expect(r.getOrNull()!.single.id, 'old');
      expect(
        (await addBook.findDuplicates(const BookDraft(title: ''))).getOrNull(),
        isEmpty,
      );
    });
  });

  group('cover', () {
    test('the catalogue cover is fetched after saving and attached', () async {
      covers.urlResult = 'covers/id1.jpg?v=5';
      final b = await saved(
        const BookDraft(title: 'Dune', coverUrl: 'https://c/x.jpg'),
      );
      expect(covers.urlSaves, ['id1 https://c/x.jpg']);
      expect(b.coverLocalPath, 'covers/id1.jpg?v=5');
      expect(b.coverUrl, 'https://c/x.jpg');
    });

    test('saving does not wait for the cover job', () async {
      final r = await addBook(
        const BookDraft(title: 'Dune', coverUrl: 'https://c/x.jpg'),
      );
      // The book is already stored when call() returns.
      expect((await h.books.getById('id1')).getOrNull(), isNotNull);
      await (r.getOrNull()! as BookAdded).coverJob;
    });

    test('a photo wins over the catalogue URL', () async {
      final b = await saved(
        BookDraft(
          title: 'Dune',
          coverUrl: 'https://c/x.jpg',
          coverPhoto: Uint8List.fromList([1, 2, 3]),
        ),
      );
      expect(covers.photoSaves, ['id1']);
      expect(covers.urlSaves, isEmpty);
      expect(b.coverLocalPath, 'covers/id1.jpg?v=2');
    });

    test('no cover information means the store is not touched', () async {
      await saved(const BookDraft(title: 'Dune'));
      expect(covers.urlSaves, isEmpty);
      expect(covers.photoSaves, isEmpty);
    });

    test('"no real cover" keeps the generated cover', () async {
      covers.urlResult = null;
      final b = await saved(
        const BookDraft(title: 'Dune', coverUrl: 'https://c/placeholder'),
      );
      expect(b.coverLocalPath, isNull);
    });

    test(
      'a failed download leaves the book saved and logs nothing scary',
      () async {
        covers.urlFailure = const NetworkFailure.offline();
        final b = await saved(
          const BookDraft(title: 'Dune', coverUrl: 'https://c/x.jpg'),
        );
        expect(b.title, 'Dune');
        expect(b.coverLocalPath, isNull);
      },
    );

    test('an exception in the cover job is contained and logged', () async {
      covers.throwOnUrl = StateError('disk exploded');
      final r = await addBook(
        const BookDraft(title: 'Dune', coverUrl: 'https://c/x.jpg'),
      );
      await (r.getOrNull()! as BookAdded).coverJob; // must not throw
      expect(logger.lines.any((l) => l.contains('cover job failed')), isTrue);
      expect((await h.books.getById('id1')).getOrNull(), isNotNull);
    });

    test('edits made while the cover downloads are not overwritten', () async {
      final r = await addBook(
        const BookDraft(title: 'Dune', coverUrl: 'https://c/x.jpg'),
      );
      final added = r.getOrNull()! as BookAdded;
      await h.books.update('id1', (b) => b.copyWith(notes: 'edited meanwhile'));
      await added.coverJob;
      final end = (await h.books.getById('id1')).getOrNull()!;
      expect(end.notes, 'edited meanwhile');
      expect(end.coverLocalPath, isNotNull);
    });
  });
}
