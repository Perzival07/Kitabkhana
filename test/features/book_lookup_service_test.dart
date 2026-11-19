import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/clock.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/data/cache/drift_lookup_cache_store.dart';
import 'package:kitabkhana/data/db/app_database.dart';
import 'package:kitabkhana/features/library/application/book_lookup_service.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';
import 'package:kitabkhana/features/library/domain/book_info_source.dart';

import '../helpers/fake_book_info_source.dart';
import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late FakeSource source;
  late DriftLookupCacheStore cache;
  late BookLookupService service;

  final isbn = parseIsbn('9780143127550')!;
  final book = BookInfo(
    title: 'Everything I Never Told You',
    authors: const ['Celeste Ng'],
    isbn13: isbn,
    olWorkKey: '/works/W',
  );

  setUp(() {
    db = createTestDb();
    clock = FakeClock(DateTime(2025, 3, 10, 9));
    source = FakeSource();
    cache = DriftLookupCacheStore(db);
    service = BookLookupService(source: source, cache: cache, clock: clock);
  });
  tearDown(() => db.close());

  test(
    'miss goes to the network, stores the answer, then hits the cache',
    () async {
      source.onIsbn = () => Ok(book);
      expect((await service.lookupIsbn(isbn)).getOrNull(), book);
      expect(source.isbnCalls, 1);
      expect((await service.lookupIsbn(isbn)).getOrNull(), book);
      expect(source.isbnCalls, 1);

      final row = await (db.select(db.lookupCache)).getSingle();
      expect(row.key, 'isbn:9780143127550');
      expect(row.isNotFound, isFalse);
      expect(
        BookInfo.fromJson(jsonDecode(row.payloadJson) as Map<String, Object?>),
        book,
      );
    },
  );

  test('successes are cached for 30 days', () async {
    source.onIsbn = () => Ok(book);
    await service.lookupIsbn(isbn);
    clock.advance(const Duration(days: 29, hours: 23));
    await service.lookupIsbn(isbn);
    expect(source.isbnCalls, 1);
    clock.advance(const Duration(hours: 2));
    await service.lookupIsbn(isbn);
    expect(source.isbnCalls, 2);
  });

  test('not-found is cached for 7 days', () async {
    source.onIsbn = () => const Err<BookInfo>(NotFoundFailure('book'));
    expect(
      (await service.lookupIsbn(isbn)).failureOrNull(),
      isA<NotFoundFailure>(),
    );
    clock.advance(const Duration(days: 6, hours: 23));
    expect(
      (await service.lookupIsbn(isbn)).failureOrNull(),
      isA<NotFoundFailure>(),
    );
    expect(source.isbnCalls, 1);
    clock.advance(const Duration(hours: 2));
    await service.lookupIsbn(isbn);
    expect(source.isbnCalls, 2);
  });

  test('a cached not-found is replaced when the book appears later', () async {
    source.onIsbn = () => const Err<BookInfo>(NotFoundFailure('book'));
    await service.lookupIsbn(isbn);
    clock.advance(const Duration(days: 8));
    source.onIsbn = () => Ok(book);
    expect((await service.lookupIsbn(isbn)).getOrNull(), book);
    expect((await service.cachedIsbn(isbn)), book);
  });

  test('forceRefresh bypasses a fresh entry', () async {
    source.onIsbn = () => Ok(book);
    await service.lookupIsbn(isbn);
    await service.lookupIsbn(isbn, forceRefresh: true);
    expect(source.isbnCalls, 2);
  });

  group('offline behaviour', () {
    test('fresh cache works with no network at all', () async {
      source.onIsbn = () => Ok(book);
      await service.lookupIsbn(isbn);
      source.onIsbn = () => const Err<BookInfo>(NetworkFailure.offline());
      expect((await service.lookupIsbn(isbn)).getOrNull(), book);
      expect(source.isbnCalls, 1);
    });

    test('an expired success is served when the network fails', () async {
      source.onIsbn = () => Ok(book);
      await service.lookupIsbn(isbn);
      clock.advance(const Duration(days: 90));
      source.onIsbn = () => const Err<BookInfo>(NetworkFailure.offline());
      expect((await service.lookupIsbn(isbn)).getOrNull(), book);
      expect(source.isbnCalls, 2);
    });

    test(
      'no cache and no network is an offline failure, and not cached',
      () async {
        source.onIsbn = () => const Err<BookInfo>(NetworkFailure.offline());
        expect(
          (await service.lookupIsbn(isbn)).failureOrNull(),
          const NetworkFailure.offline(),
        );
        expect(await db.select(db.lookupCache).get(), isEmpty);
      },
    );

    test('server errors and timeouts are never cached', () async {
      for (final f in <Failure>[
        const NetworkFailure.server(500),
        const NetworkFailure.timeout(),
        const NetworkFailure.rateLimited(),
      ]) {
        source.onIsbn = () => Err<BookInfo>(f);
        expect((await service.lookupIsbn(isbn)).failureOrNull(), f);
      }
      expect(await db.select(db.lookupCache).get(), isEmpty);
    });
  });

  test('incomplete results are returned but not cached', () async {
    source.onIsbn = () => Ok(book.copyWith(authors: [], isComplete: false));
    final r = await service.lookupIsbn(isbn);
    expect(r.getOrNull()!.isComplete, isFalse);
    expect(await db.select(db.lookupCache).get(), isEmpty);
  });

  group('cachedIsbn', () {
    test('never uses the network and includes expired entries', () async {
      expect(await service.cachedIsbn(isbn), isNull);
      source.onIsbn = () => Ok(book);
      await service.lookupIsbn(isbn);
      clock.advance(const Duration(days: 400));
      expect(await service.cachedIsbn(isbn), book);
      expect(source.isbnCalls, 1);
    });

    test('is null for a cached not-found', () async {
      source.onIsbn = () => const Err<BookInfo>(NotFoundFailure());
      await service.lookupIsbn(isbn);
      expect(await service.cachedIsbn(isbn), isNull);
    });
  });

  test('a corrupt cache entry is treated as a miss', () async {
    await cache.put(
      LookupCacheEntry(
        key: BookLookupService.cacheKey(isbn),
        payloadJson: '{not json',
        fetchedAt: clock.now(),
        isNotFound: false,
      ),
    );
    source.onIsbn = () => Ok(book);
    expect((await service.lookupIsbn(isbn)).getOrNull(), book);
    expect(source.isbnCalls, 1);
    expect(await service.cachedIsbn(isbn), book); // replaced by a good entry
  });

  group('searchTitle', () {
    test('delegates every time (not cached)', () async {
      source.onSearch = () => Ok([book]);
      await service.searchTitle('everything');
      await service.searchTitle('everything');
      expect(source.searchCalls, 2);
    });

    test('a blank title returns nothing without calling out', () async {
      expect((await service.searchTitle('   ')).getOrNull(), isEmpty);
      expect(source.searchCalls, 0);
    });
  });

  test('the cache store upserts by key', () async {
    for (final n in <int>[1, 2]) {
      await cache.put(
        LookupCacheEntry(
          key: 'k',
          payloadJson: '{"n":$n}',
          fetchedAt: clock.now(),
          isNotFound: false,
        ),
      );
    }
    expect((await cache.get('k'))!.payloadJson, '{"n":2}');
    expect(await cache.get('missing'), isNull);
    expect(await db.select(db.lookupCache).get(), hasLength(1));
  });
}
