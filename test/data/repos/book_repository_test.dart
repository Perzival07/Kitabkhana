import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/core/text/title_key.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/library/domain/book_filter.dart';

import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;

  setUp(() => h = RepoHarness());
  tearDown(() => h.dispose());

  Future<List<String>> titles({
    BookFilter filter = const BookFilter(),
    BookSort sort = BookSort.recentlyAdded,
    int limit = 100,
    int offset = 0,
  }) async {
    final list = await h.books
        .watchAll(filter: filter, sort: sort, limit: limit, offset: offset)
        .first;
    return list.map((b) => b.title).toList();
  }

  group('upsert', () {
    test('inserts with timestamps from the clock and rev 1', () async {
      h.tick();
      final now = h.clock.now();
      final saved = (await h.books.upsert(
        Book.create(id: 'a', title: 'Godan', authors: 'Premchand', now: now),
      )).getOrNull()!;
      expect(saved.id, 'a');
      expect(saved.rev, 1);
      expect(saved.createdAt.toUtc(), now.toUtc());
      expect(saved.updatedAt.toUtc(), now.toUtc());
      expect(saved.titleKey.value, 'godan|premchand');
      expect(saved.deletedAt, isNull);
    });

    test(
      'update stamps updatedAt, keeps createdAt and increments rev',
      () async {
        final first = await h.addBook(id: 'a', title: 'Godan');
        h.tick(const Duration(hours: 2));
        final second = (await h.books.upsert(first.copyWith(notes: 'good')))
            .getOrNull()!;
        expect(second.rev, 2);
        expect(second.createdAt, first.createdAt);
        expect(second.updatedAt.isAfter(first.updatedAt), isTrue);
        expect(second.notes, 'good');
        final third = (await h.books.upsert(second.copyWith(notes: null)))
            .getOrNull()!;
        expect(third.rev, 3);
        expect(third.notes, isNull);
      },
    );

    test('round-trips every field', () async {
      final loc = await h.addLocation(name: 'Bedroom');
      final isbn = parseIsbn('9780143127550')!;
      final b = (await h.books.upsert(
        Book(
          id: 'full',
          createdAt: h.clock.now(),
          updatedAt: h.clock.now(),
          deletedAt: null,
          rev: 1,
          isbn13: isbn,
          olWorkKey: '/works/OL1W',
          title: 'Title',
          subtitle: 'Sub',
          authors: 'A. Author',
          titleKey: normalizeTitle('Title', 'A. Author'),
          coverUrl: 'https://x/c.jpg',
          coverLocalPath: '/covers/full.jpg',
          pages: 321,
          genre: 'Fiction',
          language: 'en',
          ownership: Ownership.wishlist,
          status: ReadStatus.reading,
          currentPage: 40,
          rating: 4,
          locationId: loc.id,
          ownerName: 'Me',
          notes: 'n',
          startedOn: DateTime(2025, 3, 1),
          finishedOn: DateTime(2025, 3, 9),
        ),
      )).getOrNull()!;
      final read = (await h.books.getById('full')).getOrNull()!;
      expect(read, b);
      expect(read.isbn13, isbn);
      expect(read.startedOn, DateTime(2025, 3, 1));
      expect(read.finishedOn, DateTime(2025, 3, 9));
      expect(read.ownership, Ownership.wishlist);
      expect(read.status, ReadStatus.reading);
      expect(read.progress, closeTo(40 / 321, 1e-9));
    });

    test('invalid data is rejected as a ValidationFailure', () async {
      final bad = Book.create(
        id: 'x',
        title: 'T',
        now: h.clock.now(),
      ).copyWith(rating: 9);
      final r = await h.books.upsert(bad);
      expect(r.failureOrNull(), isA<ValidationFailure>());
      expect((await h.books.getById('x')).getOrNull(), isNull);

      final badLoc = Book.create(
        id: 'y',
        title: 'T',
        now: h.clock.now(),
      ).copyWith(locationId: 'nope');
      expect(
        (await h.books.upsert(badLoc)).failureOrNull(),
        isA<ValidationFailure>(),
      );
      final badPages = Book.create(
        id: 'z',
        title: 'T',
        now: h.clock.now(),
      ).copyWith(pages: 0);
      expect(
        (await h.books.upsert(badPages)).failureOrNull(),
        isA<ValidationFailure>(),
      );
    });
  });

  group('soft delete', () {
    test('hides the book everywhere and bumps rev', () async {
      final b = await h.addBook(
        id: 'a',
        title: 'Harry Potter',
        authors: 'Rowling',
        olWorkKey: '/works/W1',
        tweak: (b) => b.copyWith(isbn13: parseIsbn('9780143127550')),
      );
      await h.addBook(id: 'keep', title: 'Other');
      h.tick();
      expect((await h.books.softDelete('a')).isOk, isTrue);

      expect(await titles(), ['Other']);
      expect((await h.books.getById('a')).getOrNull(), isNull);
      expect(await h.books.watchById('a').first, isNull);
      expect((await h.books.search('harry')).getOrNull(), isEmpty);
      expect((await h.books.findByIsbn(b.isbn13!)).getOrNull(), isEmpty);
      expect((await h.books.findByWorkKey('/works/W1')).getOrNull(), isEmpty);
      expect((await h.books.findByTitleKey(b.titleKey)).getOrNull(), isEmpty);
      expect(await h.books.watchCount().first, 1);

      final row = await (h.db.select(
        h.db.books,
      )..where((t) => t.id.equals('a'))).getSingle();
      expect(row.deletedAt, isNotNull);
      expect(row.rev, b.rev + 1);
    });

    test('missing or already deleted is NotFound', () async {
      await h.addBook(id: 'a');
      expect(
        (await h.books.softDelete('nope')).failureOrNull(),
        isA<NotFoundFailure>(),
      );
      await h.books.softDelete('a');
      expect(
        (await h.books.softDelete('a')).failureOrNull(),
        isA<NotFoundFailure>(),
      );
    });

    test('restore undoes it (and search works again)', () async {
      await h.addBook(id: 'a', title: 'Dune');
      await h.books.softDelete('a');
      expect((await h.books.restore('a')).isOk, isTrue);
      expect(await titles(), ['Dune']);
      expect((await h.books.search('dun')).getOrNull()!.single.id, 'a');
      expect(
        (await h.books.restore('a')).failureOrNull(),
        isA<NotFoundFailure>(),
      );
      expect(
        (await h.books.restore('nope')).failureOrNull(),
        isA<NotFoundFailure>(),
      );
    });
  });

  group('update (atomic read-modify-write)', () {
    test('applies the change, stamps updatedAt and bumps rev', () async {
      final b = await h.addBook(id: 'a', title: 'One');
      h.tick(const Duration(hours: 1));
      final r = await h.books.update('a', (x) => x.copyWith(notes: 'hi'));
      final u = r.getOrNull()!;
      expect(u.notes, 'hi');
      expect(u.rev, b.rev + 1);
      expect(u.updatedAt.isAfter(b.updatedAt), isTrue);
      expect(u.createdAt, b.createdAt);
    });

    test('the transform sees the latest stored state', () async {
      await h.addBook(id: 'a', title: 'One');
      await h.books.update('a', (x) => x.copyWith(notes: 'first'));
      final seen = <String?>[];
      await h.books.update('a', (x) {
        seen.add(x.notes);
        return x.copyWith(rating: 4);
      });
      expect(seen, ['first']);
      final b = (await h.books.getById('a')).getOrNull()!;
      expect([b.notes, b.rating], ['first', 4]);
    });

    test('concurrent updates to different fields are both kept', () async {
      await h.addBook(id: 'a', title: 'One');
      await Future.wait([
        h.books.update('a', (x) => x.copyWith(notes: 'n')),
        h.books.update('a', (x) => x.copyWith(rating: 5)),
        h.books.update('a', (x) => x.copyWith(genre: 'g')),
      ]);
      final b = (await h.books.getById('a')).getOrNull()!;
      expect([b.notes, b.rating, b.genre], ['n', 5, 'g']);
      expect(b.rev, 4);
    });

    test('missing or deleted books are NotFound', () async {
      expect(
        (await h.books.update('nope', (x) => x)).failureOrNull(),
        isA<NotFoundFailure>(),
      );
      await h.addBook(id: 'a');
      await h.books.softDelete('a');
      expect(
        (await h.books.update('a', (x) => x)).failureOrNull(),
        isA<NotFoundFailure>(),
      );
    });

    test('an invalid change is rejected and nothing is stored', () async {
      await h.addBook(id: 'a');
      final r = await h.books.update('a', (x) => x.copyWith(rating: 9));
      expect(r.failureOrNull(), isA<ValidationFailure>());
      expect((await h.books.getById('a')).getOrNull()!.rating, isNull);
    });
  });

  group('watching', () {
    test('watchAll is live', () async {
      final emissions = <List<String>>[];
      final sub = h.books.watchAll().listen(
        (l) => emissions.add(l.map((b) => b.title).toList()),
      );
      await pumpEventQueue();
      await h.addBook(title: 'One');
      await pumpEventQueue();
      await h.addBook(title: 'Two');
      await pumpEventQueue();
      await sub.cancel();
      expect(emissions.first, isEmpty);
      expect(emissions.last, ['Two', 'One']);
    });

    test('watchById follows updates and deletion', () async {
      final b = await h.addBook(id: 'a', title: 'One');
      final seen = <String?>[];
      final sub = h.books.watchById('a').listen((x) => seen.add(x?.title));
      await pumpEventQueue();
      await h.books.upsert(b.copyWith(title: 'Uno'));
      await pumpEventQueue();
      await h.books.softDelete('a');
      await pumpEventQueue();
      await sub.cancel();
      expect(seen, ['One', 'Uno', null]);
    });

    test(
      'watchAll refreshes when a loan changes the lent-out filter',
      () async {
        await h.addBook(id: 'a', title: 'One');
        final seen = <int>[];
        final sub = h.books
            .watchAll(filter: const BookFilter(lentOut: true))
            .listen((l) => seen.add(l.length));
        await pumpEventQueue();
        await h.addLoan(bookId: 'a');
        await pumpEventQueue();
        await sub.cancel();
        expect(seen.first, 0);
        expect(seen.last, 1);
      },
    );
  });

  group('sorting', () {
    setUp(() async {
      await h.addBook(
        title: 'The Hobbit',
        authors: 'J. R. R. Tolkien',
        rating: 5,
      );
      await h.addBook(title: 'Dune', authors: 'Frank Herbert', rating: 3);
      await h.addBook(title: 'Anna Karenina', authors: 'Leo Tolstoy');
      await h.addBook(title: 'Emma', authors: 'Jane Austen', rating: 3);
    });

    test('recently added is newest first', () async {
      expect(await titles(), ['Emma', 'Anna Karenina', 'Dune', 'The Hobbit']);
    });

    test('title sorts ignoring leading articles', () async {
      expect(await titles(sort: BookSort.title), [
        'Anna Karenina',
        'Dune',
        'Emma',
        'The Hobbit',
      ]);
    });

    test('author sorts by surname', () async {
      // Austen, Herbert, Tolkien, Tolstoy.
      expect(await titles(sort: BookSort.author), [
        'Emma',
        'Dune',
        'The Hobbit',
        'Anna Karenina',
      ]);
    });

    test('books without an author sort last', () async {
      await h.addBook(title: 'Anonymous Tales');
      final result = await titles(sort: BookSort.author);
      expect(result.last, 'Anonymous Tales');
      expect(result.first, 'Emma');
    });

    test('rating sorts highest first, unrated last', () async {
      expect(await titles(sort: BookSort.rating), [
        'The Hobbit',
        'Dune',
        'Emma',
        'Anna Karenina',
      ]);
    });

    test('recently read orders by latest reading log, unread last', () async {
      final all = await h.books.watchAll().first;
      Book byTitle(String t) => all.firstWhere((b) => b.title == t);
      await h.addLog(bookId: byTitle('Dune').id, date: DateTime(2025, 3, 1));
      await h.addLog(bookId: byTitle('Emma').id, date: DateTime(2025, 3, 5));
      await h.addLog(bookId: byTitle('Dune').id, date: DateTime(2025, 3, 8));
      expect(await titles(sort: BookSort.recentlyRead), [
        'Dune',
        'Emma',
        'Anna Karenina',
        'The Hobbit',
      ]);
    });
  });

  group('paging', () {
    test('limit and offset slice the ordered list', () async {
      for (final t in <String>['A', 'B', 'C', 'D', 'E']) {
        await h.addBook(title: t);
      }
      const sort = BookSort.title;
      expect(await titles(sort: sort, limit: 2), ['A', 'B']);
      expect(await titles(sort: sort, limit: 2, offset: 2), ['C', 'D']);
      expect(await titles(sort: sort, limit: 2, offset: 4), ['E']);
      expect(await titles(sort: sort, limit: 2, offset: 6), isEmpty);
    });
  });

  group('filters', () {
    late String shelfId;
    late String boxId;
    late String fictionTagId;

    setUp(() async {
      shelfId = (await h.addLocation(name: 'Shelf')).id;
      boxId = (await h.addLocation(name: 'Box')).id;
      await h.addBook(
        id: 'hp',
        title: 'Harry Potter',
        authors: 'Rowling',
        status: ReadStatus.reading,
        locationId: shelfId,
      );
      await h.addBook(
        id: 'dune',
        title: 'Dune',
        authors: 'Herbert',
        status: ReadStatus.finished,
        locationId: shelfId,
      );
      await h.addBook(
        id: 'wish',
        title: 'Wishful',
        ownership: Ownership.wishlist,
      );
      await h.addBook(
        id: 'bor',
        title: 'Borrowed Book',
        ownership: Ownership.borrowed,
        locationId: boxId,
      );
      await h.addBook(id: 'plain', title: 'Plain', locationId: boxId);
      fictionTagId = (await h.tags.createIfAbsent('Fiction')).getOrNull()!.id;
      await h.tags.attach('hp', fictionTagId);
      await h.tags.attach('wish', fictionTagId);
    });

    test('by status', () async {
      expect(
        await titles(filter: const BookFilter(status: ReadStatus.reading)),
        ['Harry Potter'],
      );
    });

    test('by ownership', () async {
      expect(
        await titles(filter: const BookFilter(ownership: Ownership.wishlist)),
        ['Wishful'],
      );
    });

    test('lent out looks at active lent loans only', () async {
      final loan = await h.addLoan(bookId: 'dune');
      expect(await titles(filter: const BookFilter(lentOut: true)), ['Dune']);
      await h.loans.markReturned(loan.id, h.clock.today());
      expect(await titles(filter: const BookFilter(lentOut: true)), isEmpty);
    });

    test('borrowed includes ownership and active borrowed loans', () async {
      await h.addLoan(bookId: 'plain', direction: LoanDirection.borrowed);
      expect(
        await titles(
          filter: const BookFilter(borrowed: true),
          sort: BookSort.title,
        ),
        ['Borrowed Book', 'Plain'],
      );
    });

    test('by location', () async {
      expect(
        await titles(
          filter: BookFilter(locationId: boxId),
          sort: BookSort.title,
        ),
        ['Borrowed Book', 'Plain'],
      );
    });

    test('by tag, and a deleted tag link drops out', () async {
      expect(
        await titles(
          filter: BookFilter(tagId: fictionTagId),
          sort: BookSort.title,
        ),
        ['Harry Potter', 'Wishful'],
      );
      await h.tags.detach('wish', fictionTagId);
      expect(await titles(filter: BookFilter(tagId: fictionTagId)), [
        'Harry Potter',
      ]);
    });

    test('by text query (prefix, author, accents)', () async {
      expect(await titles(filter: const BookFilter(query: 'harr')), [
        'Harry Potter',
      ]);
      expect(await titles(filter: const BookFilter(query: 'herb')), ['Dune']);
      expect(await titles(filter: const BookFilter(query: '  ')), hasLength(5));
    });

    test('filters combine with AND', () async {
      expect(
        await titles(
          filter: BookFilter(
            status: ReadStatus.reading,
            locationId: shelfId,
            tagId: fictionTagId,
            query: 'potter',
          ),
        ),
        ['Harry Potter'],
      );
      expect(
        await titles(
          filter: BookFilter(
            status: ReadStatus.finished,
            locationId: shelfId,
            tagId: fictionTagId,
          ),
        ),
        isEmpty,
      );
      expect(
        await titles(
          filter: BookFilter(locationId: shelfId, query: 'dune'),
        ),
        ['Dune'],
      );
    });

    test('count follows the filter and ignores deleted books', () async {
      expect(await h.books.watchCount().first, 5);
      expect(
        await h.books.watchCount(filter: BookFilter(locationId: shelfId)).first,
        2,
      );
      await h.books.softDelete('dune');
      expect(
        await h.books.watchCount(filter: BookFilter(locationId: shelfId)).first,
        1,
      );
    });

    test('BookFilter basics', () {
      expect(const BookFilter().isEmpty, isTrue);
      expect(const BookFilter(query: ' ').isEmpty, isTrue);
      expect(const BookFilter(lentOut: true).isEmpty, isFalse);
      const f = BookFilter(status: ReadStatus.reading, locationId: 'x');
      expect(f.copyWith(status: null).status, isNull);
      expect(f.copyWith(query: 'q').locationId, 'x');
      expect(f, const BookFilter(status: ReadStatus.reading, locationId: 'x'));
      expect(
        f.hashCode,
        const BookFilter(status: ReadStatus.reading, locationId: 'x').hashCode,
      );
    });
  });

  group('search', () {
    setUp(() async {
      await h.addBook(
        id: 'hp',
        title: "Harry Potter and the Philosopher's Stone",
        authors: 'J. K. Rowling',
      );
      await h.addBook(
        id: 'gm',
        title: 'Cien años de soledad',
        authors: 'Gabriel García Márquez',
      );
      await h.addBook(id: 'rowl', title: 'Rowling Studies', authors: 'Someone');
    });

    Future<List<String>> ids(String q, {int limit = 20}) async =>
        (await h.books.search(
          q,
          limit: limit,
        )).getOrNull()!.map((b) => b.id).toList();

    test('matches title prefixes and authors', () async {
      expect(await ids('harr'), ['hp']);
      expect(await ids('philos'), ['hp']);
      expect(await ids('gabriel'), ['gm']);
    });

    test('ignores accents and case', () async {
      expect(await ids('GARCIA'), ['gm']);
      expect(await ids('anos'), ['gm']);
    });

    test('a title match outranks an author match', () async {
      expect(await ids('rowling'), ['rowl', 'hp']);
    });

    test('all words must match', () async {
      expect(await ids('harry stone'), ['hp']);
      expect(await ids('harry dune'), isEmpty);
    });

    test('blank and symbol-only queries return nothing', () async {
      expect(await ids(''), isEmpty);
      expect(await ids('   '), isEmpty);
      expect(await ids('"*()'), isEmpty);
    });

    test('FTS syntax in the query cannot break or inject', () async {
      for (final q in <String>[
        'harry OR dune',
        'harry" OR "x',
        'NEAR(harry stone)',
        'title:harry',
        "'; DROP TABLE books; --",
        '*',
      ]) {
        final r = await h.books.search(q);
        expect(r.isOk, isTrue, reason: q);
      }
      expect(await ids('harry OR dune'), isEmpty); // treated as plain words
      expect((await h.books.getById('hp')).getOrNull(), isNotNull);
    });

    test('respects the limit', () async {
      expect(await ids('rowling', limit: 1), hasLength(1));
    });
  });

  group('lookups', () {
    test('findByIsbn returns every live copy, oldest first', () async {
      final isbn = parseIsbn('9780143127550')!;
      await h.addBook(
        id: 'c1',
        title: 'Copy',
        tweak: (b) => b.copyWith(isbn13: isbn),
      );
      await h.addBook(
        id: 'c2',
        title: 'Copy',
        tweak: (b) => b.copyWith(isbn13: isbn),
      );
      await h.addBook(id: 'o', title: 'Other');
      final r = (await h.books.findByIsbn(isbn)).getOrNull()!;
      expect(r.map((b) => b.id), ['c1', 'c2']);
    });

    test('findByWorkKey and findByTitleKey', () async {
      final a = await h.addBook(
        id: 'a',
        title: 'The Hobbit',
        authors: 'Tolkien',
        olWorkKey: '/works/OL1W',
      );
      await h.addBook(id: 'b', title: 'Dune', olWorkKey: '/works/OL2W');
      expect(
        (await h.books.findByWorkKey('/works/OL1W')).getOrNull()!.single.id,
        'a',
      );
      expect((await h.books.findByWorkKey('/works/none')).getOrNull(), isEmpty);
      expect(
        (await h.books.findByTitleKey(
          normalizeTitle('Hobbit', 'J.R.R. Tolkien'),
        )).getOrNull()!.single.id,
        a.id,
      );
    });
  });

  test('getById for a missing id is Ok(null)', () async {
    expect((await h.books.getById('nope')).getOrNull(), isNull);
    expect((await h.books.getById('nope')).isOk, isTrue);
  });
}
