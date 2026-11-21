import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/library/application/perf_seeder.dart';

import '../helpers/repo_harness.dart';

void main() {
  test('the ISBNs it makes are valid ISBN-13s, and distinct', () {
    final seen = <String>{};
    for (var i = 0; i < 5000; i++) {
      final s = PerfSeeder.isbnFor(i);
      expect(s, hasLength(13));
      expect(parseIsbn(s), isNotNull, reason: s);
      seen.add(s);
    }
    expect(seen, hasLength(5000));
  });

  test(
    'a small seed fills every table, and the same seed gives the same data',
    () async {
      Future<List<Object?>> run() async {
        final h = RepoHarness();
        try {
          final s = await PerfSeeder(h.db).seed(
            books: 200,
            loans: 20,
            readingLogs: 300,
            quotes: 15,
            today: DateTime(2025, 3, 10),
          );
          expect(s.books, 200);
          expect(s.loans, 20);
          expect(s.readingLogs, 300);
          expect(s.quotes, 15);
          Future<int> n(String t) async =>
              (await h.db.customSelect('SELECT COUNT(*) c FROM $t').getSingle())
                  .read<int>('c');
          expect(await n('books'), 200);
          expect(await n('loans'), 20);
          expect(await n('reading_logs'), 300);
          expect(await n('quotes'), 15);
          expect(await n('locations'), 25);
          expect(await n('tags'), 15);
          expect(await n('book_tags'), greaterThan(100));
          expect(
            await n('books WHERE isbn13 IS NOT NULL'),
            allOf(greaterThan(100), lessThan(200)),
          );
          // Hindi and Bengali titles are in there, and searchable.
          final titles =
              (await h.db.customSelect('SELECT title FROM books').get())
                  .map((r) => r.read<String>('title'))
                  .join(' ');
          expect(titles, matches(RegExp('[ऀ-ॿ]')));
          expect(titles, matches(RegExp('[ঀ-৿]')));
          return (await h.db
                  .customSelect(
                    'SELECT title, authors FROM books ORDER BY title, authors',
                  )
                  .get())
              .map(
                (r) =>
                    '${r.read<String>('title')}|${r.read<String>('authors')}',
              )
              .toList();
        } finally {
          await h.db.close();
        }
      }

      expect(await run(), await run());
    },
  );

  test('only one active loan per book', () async {
    final h = RepoHarness();
    addTearDown(h.db.close);
    await PerfSeeder(h.db).seed(
      books: 100,
      loans: 50,
      readingLogs: 50,
      quotes: 5,
      today: DateTime(2025, 3, 10),
    );
    final dup = await h.db
        .customSelect(
          'SELECT book_id FROM loans WHERE returned_on IS NULL '
          'GROUP BY book_id HAVING COUNT(*) > 1',
        )
        .get();
    expect(dup, isEmpty);
  });
}
