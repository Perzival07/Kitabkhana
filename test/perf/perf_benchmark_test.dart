@Tags(<String>['perf'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/library/application/book_lookup_service.dart';
import 'package:kitabkhana/features/library/application/perf_seeder.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/library/domain/book_filter.dart';
import 'package:kitabkhana/features/library/domain/book_info_source.dart';
import 'package:kitabkhana/features/scan_check/application/check_ownership.dart';
import 'package:kitabkhana/features/scan_check/domain/ownership_result.dart';

import '../helpers/fake_book_info_source.dart';
import '../helpers/repo_harness.dart';

class _MemoryCache implements LookupCacheStore {
  final Map<String, LookupCacheEntry> map = <String, LookupCacheEntry>{};
  @override
  Future<LookupCacheEntry?> get(String key) async => map[key];
  @override
  Future<void> put(LookupCacheEntry entry) async => map[entry.key] = entry;
}

/// Timings on a library of 5,000 books, 300 loans, 20,000 reading logs and
/// 500 quotes. These run on the development machine, which is much faster
/// than a low-end phone, so the budgets here are the spec's budgets (not
/// scaled down); a result near its budget on this machine would be too slow
/// on a phone. The `PERF` lines are the numbers to copy into reports.
void main() {
  late RepoHarness h;
  late PerfSeedSummary seeded;
  final report = <String>[];

  setUpAll(() async {
    h = RepoHarness();
    seeded = await PerfSeeder(h.db).seed(today: h.clock.today());
    // ignore: avoid_print
    print('PERF seed: $seeded');
  });

  tearDownAll(() async {
    // ignore: avoid_print
    print('PERF report\n${report.join('\n')}');
    await h.db.close();
  });

  /// The median of [runs] timed runs of [body], after one warm-up.
  Future<double> median(
    String name,
    Future<void> Function() body, {
    int runs = 9,
  }) async {
    await body();
    final times = <double>[];
    for (var i = 0; i < runs; i++) {
      final w = Stopwatch()..start();
      await body();
      w.stop();
      times.add(w.elapsedMicroseconds / 1000);
    }
    times.sort();
    final m = times[times.length ~/ 2];
    report.add(
      'PERF ${name.padRight(46)} ${m.toStringAsFixed(1).padLeft(7)} ms',
    );
    return m;
  }

  test('the seed is the size promised', () async {
    expect(seeded.books, 5000);
    expect(seeded.loans, 300);
    expect(seeded.readingLogs, 20000);
    expect(seeded.quotes, 500);
    expect((await h.stats.watchFacts(2025).first).totalBooks, 5000);
  });

  group('search (budget 50 ms)', () {
    for (final q in <String>[
      'River',
      'Riv', // a prefix, as typed live
      'Silent Garden',
      'सफ़र',
      'নদী',
      'Sharma', // an author
    ]) {
      test('"$q"', () async {
        final ms = await median('search "$q"', () async {
          final r = (await h.books.search(q)).getOrNull()!;
          expect(r, isNotEmpty);
        });
        expect(ms, lessThan(50));
      });
    }

    test('an ISBN lookup and a title-key lookup use their indexes', () async {
      Future<String> plan(String sql) async =>
          (await h.db.customSelect('EXPLAIN QUERY PLAN $sql').get())
              .map((r) => r.data['detail'])
              .join(' | ');
      expect(
        await plan(
          "SELECT * FROM books WHERE isbn13 = '9780441013593' AND deleted_at IS NULL",
        ),
        contains('idx_books_isbn13'),
      );
      expect(
        await plan(
          "SELECT * FROM books WHERE title_key = 'x' AND deleted_at IS NULL",
        ),
        contains('idx_books_title_key'),
      );
      expect(
        await plan("SELECT * FROM loans WHERE book_id = 'x'"),
        contains('idx_loans_book_id'),
      );
      expect(
        await plan(
          "SELECT * FROM reading_logs WHERE book_id = 'x' AND date = '2025-01-01'",
        ),
        contains('idx_reading_logs_book_date'),
      );
    });
  });

  group('CheckOwnership (budget 500 ms)', () {
    late CheckOwnership check;

    setUp(() {
      check = CheckOwnership(
        books: h.books,
        loans: h.loans,
        locations: h.locations,
        lookup: BookLookupService(
          source: FakeSource(),
          cache: _MemoryCache(),
          clock: h.clock,
        ),
        lookupTimeout: const Duration(milliseconds: 50),
      );
    });

    test('a barcode of a book you own', () async {
      // Any ISBN that is really on a shelf (some books have none).
      final isbn =
          (await h.db
                  .customSelect(
                    'SELECT isbn13 FROM books WHERE isbn13 IS NOT NULL LIMIT 1 OFFSET 777',
                  )
                  .getSingle())
              .read<String>('isbn13');
      final ms = await median('check: owned ISBN', () async {
        final r = await check(isbn);
        expect(r, isNot(isA<NotInLibrary>()));
      });
      expect(ms, lessThan(500));
    });

    test('a barcode that is not in the library', () async {
      final ms = await median('check: unknown ISBN', () async {
        final r = await check('9780306406157');
        expect(r, isA<NotInLibrary>());
      });
      expect(ms, lessThan(500));
    });

    test('a title typed with a slip', () async {
      final ms = await median('check: fuzzy title', () async {
        await check('Silent Garden Memoryy');
      });
      expect(ms, lessThan(500));
    });
  });

  group('library and reading (budget 100 ms)', () {
    for (final sort in BookSort.values) {
      test('first page, sorted by ${sort.name}', () async {
        final ms = await median('library page 1 / ${sort.name}', () async {
          final page = await h.books.watchAll(sort: sort, limit: 60).first;
          expect(page, hasLength(60));
        });
        expect(ms, lessThan(100));
      });
    }

    test('first page filtered by status, place and tag', () async {
      final tag = (await h.tags.watchAll().first).first;
      final loc = (await h.locations.watchAll().first).first;
      final ms = await median('library page 1 / filtered', () async {
        await h.books
            .watchAll(
              filter: BookFilter(
                status: ReadStatus.reading,
                locationId: loc.id,
                tagId: tag.id,
              ),
              limit: 60,
            )
            .first;
      });
      expect(ms, lessThan(100));
    });

    test('counts and the lent-out set', () async {
      final ms = await median('library counts + lent ids', () async {
        await h.books.watchCount().first;
        await h.books
            .watchCount(filter: const BookFilter(status: ReadStatus.reading))
            .first;
        await h.loans.watchActive().first;
      });
      expect(ms, lessThan(100));
    });

    test('the reading tab: books, week, streak', () async {
      final today = h.clock.today();
      final ms = await median('reading tab queries', () async {
        await h.books
            .watchAll(
              filter: const BookFilter(status: ReadStatus.reading),
              sort: BookSort.recentlyRead,
              limit: 20,
            )
            .first;
        await h.readings
            .watchBetween(
              DateTime(today.year, today.month, today.day - 6),
              today,
            )
            .first;
        await h.readings.watchReadingDays().first;
      });
      expect(ms, lessThan(100));
    });

    test('quotes, tags and loans screens', () async {
      final ms = await median('quotes + tags + loans lists', () async {
        await h.quotes.watchWithBooks().first;
        await h.tags.watchWithCounts().first;
        await h.loans.watchHistory().first;
        await h.loans.watchOverdue().first;
      });
      expect(ms, lessThan(100));
    });
  });

  group('statistics (budget 200 ms)', () {
    final year = DateTime(2025).year;
    final today = DateTime(2025, 3, 10);

    final queries = <String, Future<Object?> Function()>{
      'finished count': () => h.stats.watchFinishedCount(year).first,
      'finished per month': () => h.stats.watchFinishedPerMonth(year).first,
      'pages per week': () => h.stats.watchPagesPerWeek(today).first,
      'top genres': () => h.stats.watchTopGenres(year).first,
      'top authors': () => h.stats.watchTopAuthors(year).first,
      'library facts': () => h.stats.watchFacts(year).first,
      'years': () => h.stats.watchFinishedYears().first,
    };
    for (final e in queries.entries) {
      test(e.key, () async {
        final ms = await median('stats: ${e.key}', e.value);
        expect(ms, lessThan(200));
      });
    }

    test('the whole Stats tab at once', () async {
      final ms = await median('stats: all together', () async {
        await Future.wait(<Future<Object?>>[
          for (final q in queries.values) q(),
        ]);
      });
      expect(ms, lessThan(200));
    });
  });
}
