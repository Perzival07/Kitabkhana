import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/application/book_lookup_service.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';
import 'package:kitabkhana/features/library/domain/book_info_source.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';
import 'package:kitabkhana/features/scan_check/application/check_ownership.dart';
import 'package:kitabkhana/features/scan_check/domain/ownership_result.dart';

import '../../helpers/fake_book_info_source.dart';
import '../../helpers/repo_harness.dart';

class _MemoryCache implements LookupCacheStore {
  final Map<String, LookupCacheEntry> map = <String, LookupCacheEntry>{};
  @override
  Future<LookupCacheEntry?> get(String key) async => map[key];
  @override
  Future<void> put(LookupCacheEntry entry) async => map[entry.key] = entry;
}

void main() {
  late RepoHarness h;
  late FakeSource source;
  late _MemoryCache cache;
  late CheckOwnership check;

  const dune = '9780441013593';
  const other = '9780143127550';

  CheckOwnership build({
    Duration timeout = const Duration(milliseconds: 1500),
  }) => CheckOwnership(
    books: h.books,
    loans: h.loans,
    locations: h.locations,
    lookup: BookLookupService(source: source, cache: cache, clock: h.clock),
    lookupTimeout: timeout,
  );

  setUp(() {
    h = RepoHarness();
    source = FakeSource();
    cache = _MemoryCache();
    check = build();
  });
  tearDown(() => h.db.close());

  var n = 0;
  Future<Book> add(
    String title, {
    String authors = '',
    String? isbn,
    String? workKey,
    Ownership ownership = Ownership.owned,
    String? locationId,
  }) async {
    final b = Book.create(
      id: 'b${n++}',
      title: title,
      authors: authors,
      now: h.clock.now(),
      isbn13: isbn == null ? null : parseIsbn(isbn),
      olWorkKey: workKey,
      ownership: ownership,
      locationId: locationId,
    );
    return (await h.books.upsert(b)).getOrNull()!;
  }

  Future<Loan> lend(Book b, LoanDirection d) async => (await h.loans.create(
    Loan.create(
      id: 'l${n++}',
      bookId: b.id,
      direction: d,
      personName: 'Priya',
      startedOn: DateTime(2025, 3, 1),
      now: h.clock.now(),
    ),
  )).getOrNull()!;

  BookInfo info({String title = 'Dune', String? workKey = '/works/OL1W'}) =>
      BookInfo(
        title: title,
        authors: const <String>['Frank Herbert'],
        isbn13: parseIsbn(other),
        olWorkKey: workKey,
      );

  group('states', () {
    test('Owned with a location label', () async {
      await h.locations.upsert(
        Location.create(id: 'p', name: 'Bedroom', now: h.clock.now()),
      );
      await h.locations.upsert(
        Location.create(
          id: 'c',
          name: 'Shelf 2',
          now: h.clock.now(),
          parentId: 'p',
        ),
      );
      await add('Dune', authors: 'Frank Herbert', isbn: dune, locationId: 'c');
      final r = await check(dune);
      expect(r, isA<Owned>());
      expect((r as Owned).locationLabel, 'Bedroom › Shelf 2');
    });

    test('Owned without a location', () async {
      await add('Dune', isbn: dune);
      final r = await check('978-0-441-01359-3');
      expect((r as Owned).locationLabel, isNull);
    });

    test('OnWishlist', () async {
      await add('Dune', isbn: dune, ownership: Ownership.wishlist);
      expect(await check(dune), isA<OnWishlist>());
    });

    test('a copy you own beats a wishlist entry', () async {
      await add('Dune', isbn: dune, ownership: Ownership.wishlist);
      await add('Dune', isbn: dune);
      expect(await check(dune), isA<Owned>());
    });

    test('LentOut carries the loan', () async {
      final b = await add('Dune', isbn: dune);
      await lend(b, LoanDirection.lent);
      final r = await check(dune);
      expect(r, isA<LentOut>());
      expect((r as LentOut).loan.personName, 'Priya');
    });

    test('BorrowedIn from an active borrowed loan', () async {
      final b = await add('Dune', isbn: dune, ownership: Ownership.borrowed);
      await lend(b, LoanDirection.borrowed);
      final r = await check(dune);
      expect(r, isA<BorrowedIn>());
      expect((r as BorrowedIn).loan, isNotNull);
    });

    test('BorrowedIn from ownership alone has no loan', () async {
      await add('Dune', isbn: dune, ownership: Ownership.borrowed);
      final r = await check(dune);
      expect((r as BorrowedIn).loan, isNull);
    });

    test('wishlist wins over a loan', () async {
      final b = await add('Dune', isbn: dune, ownership: Ownership.wishlist);
      await lend(b, LoanDirection.lent);
      expect(await check(dune), isA<OnWishlist>());
    });

    test('NotInLibrary carries the ISBN and the looked-up info', () async {
      source.onIsbn = () => Ok(info(workKey: null));
      final r = await check(other);
      expect(r, isA<NotInLibrary>());
      expect((r as NotInLibrary).isbn?.value, other);
      expect(r.info?.title, 'Dune');
    });
  });

  group('matching', () {
    test('a book with no ISBN is found by title', () async {
      await add('Dune', authors: 'Frank Herbert');
      final r = await check('dune');
      expect(r, isA<Owned>());
    });

    test('title match ignores case, accents and articles', () async {
      await add('The Little Prince', authors: 'Antoine de Saint-Exupéry');
      expect(await check('little prince'), isA<Owned>());
      expect(await check('THE LITTLE PRINCE'), isA<Owned>());
    });

    test('a different edition is found by work key', () async {
      await add(
        'Dune',
        authors: 'Frank Herbert',
        isbn: dune,
        workKey: '/works/OL1W',
      );
      source.onIsbn = () => Ok(info());
      final r = await check(other);
      expect(r, isA<OtherEdition>());
    });

    test('another edition with the same title but no work key', () async {
      await add('Dune', authors: 'Frank Herbert', isbn: dune);
      source.onIsbn = () => Ok(info(workKey: null));
      expect(await check(other), isA<OtherEdition>());
    });

    test('another edition that is lent out shows as lent', () async {
      final b = await add(
        'Dune',
        authors: 'Frank Herbert',
        isbn: dune,
        workKey: '/works/OL1W',
      );
      await lend(b, LoanDirection.lent);
      source.onIsbn = () => Ok(info());
      expect(await check(other), isA<LentOut>());
    });

    test('near-duplicate titles become a possible match', () async {
      await add(
        'The Hitchhiker\'s Guide to the Galaxy',
        authors: 'Douglas Adams',
      );
      final r = await check('hitchhikers guide to the galxy');
      expect(r, isA<PossibleMatch>());
      final m = (r as PossibleMatch).candidates;
      expect(m.length, lessThanOrEqualTo(3));
      expect(m.first.score, greaterThanOrEqualTo(0.8));
    });

    test('dissimilar titles are not a possible match', () async {
      await add('Dune', authors: 'Frank Herbert');
      expect(await check('Pride and Prejudice'), isA<NotInLibrary>());
    });

    test('at most three candidates, best first', () async {
      for (var i = 0; i < 5; i++) {
        await add('Harry Potter and the Chamber of Secrets $i');
      }
      final r = await check('harry potter and the chamber of secret');
      expect(r, isA<PossibleMatch>());
      final m = (r as PossibleMatch).candidates;
      expect(m.length, 3);
      expect(m[0].score, greaterThanOrEqualTo(m[1].score));
    });

    test('soft-deleted books are ignored', () async {
      final b = await add('Dune', isbn: dune);
      await h.books.softDelete(b.id);
      expect(await check(dune), isA<NotInLibrary>());
      expect(await check('Dune'), isA<NotInLibrary>());
    });

    test('empty input is not in the library', () async {
      expect(await check('   '), isA<NotInLibrary>());
    });
  });

  group('offline', () {
    test('exact ISBN and title matches need no network', () async {
      source.onIsbn = () => const Err(NetworkFailure.offline());
      await add('Dune', authors: 'Frank Herbert', isbn: dune);
      expect(await check(dune), isA<Owned>());
      expect(source.isbnCalls, 0);
      expect(await check('dune'), isA<Owned>());
    });

    test('an unknown ISBN offline is NotInLibrary with the ISBN', () async {
      source.onIsbn = () => const Err(NetworkFailure.offline());
      final r = await check(other);
      expect(r, isA<NotInLibrary>());
      expect((r as NotInLibrary).info, isNull);
      expect(r.isbn?.value, other);
    });

    test('cached catalogue data finds another edition offline', () async {
      await add(
        'Dune',
        authors: 'Frank Herbert',
        isbn: dune,
        workKey: '/works/OL1W',
      );
      source.onIsbn = () => Ok(info());
      expect(await check(other), isA<OtherEdition>());
      // Now offline: the cache answers.
      source.onIsbn = () => const Err(NetworkFailure.offline());
      final calls = source.isbnCalls;
      expect(await check(other), isA<OtherEdition>());
      expect(source.isbnCalls, calls);
    });

    test('a slow network is abandoned after the timeout', () async {
      final slow = Completer<Result<BookInfo>>();
      final c = _SlowSource(slow.future);
      final quick = CheckOwnership(
        books: h.books,
        loans: h.loans,
        locations: h.locations,
        lookup: BookLookupService(source: c, cache: cache, clock: h.clock),
        lookupTimeout: const Duration(milliseconds: 50),
      );
      final watch = Stopwatch()..start();
      final r = await quick(other);
      expect(r, isA<NotInLibrary>());
      expect(watch.elapsedMilliseconds, lessThan(500));
    });
  });

  test('5,000 books: a check takes well under 500 ms', () async {
    final base = h.clock.now();
    await h.books.upsert(Book.create(id: 'seed', title: 'Seed', now: base));
    // Bulk insert straight into the table, faster than 5,000 upserts.
    await h.db.batch((batch) {
      // Use raw SQL for speed; the FTS triggers keep the index in step.
      for (var i = 0; i < 5000; i++) {
        batch.customStatement(
          'INSERT INTO books (id, created_at, updated_at, rev, title, '
          'title_key, authors, genre, language, ownership, status, '
          "current_page) VALUES (?, ?, ?, 1, ?, ?, ?, '', '', 'owned', 'want', 0)",
          <Object?>[
            'x$i',
            base.millisecondsSinceEpoch ~/ 1000,
            base.millisecondsSinceEpoch ~/ 1000,
            'Book number $i of the long series',
            'book number $i of long series|author${i % 50}',
            'Author ${i % 50}',
          ],
        );
      }
    });
    await h.books.upsert(
      Book.create(
        id: 'target',
        title: 'The Remains of the Day',
        authors: 'Kazuo Ishiguro',
        now: base,
      ),
    );
    final w = Stopwatch()..start();
    final exact = await check('remains of the day');
    final fuzzy = await check('the remains of the days');
    final none = await check('Something entirely different');
    w.stop();
    expect(exact, isA<Owned>());
    expect(fuzzy, isA<PossibleMatch>());
    expect(none, isA<NotInLibrary>());
    expect(w.elapsedMilliseconds / 3, lessThan(500));
  });
}

class _SlowSource implements BookInfoSource {
  _SlowSource(this._future);
  final Future<Result<BookInfo>> _future;

  @override
  Future<Result<BookInfo>> lookupIsbn(Isbn13 isbn) => _future;

  @override
  Future<Result<List<BookInfo>>> searchTitle(
    String title, {
    String? author,
    int limit = 10,
  }) async => const Ok(<BookInfo>[]);
}
