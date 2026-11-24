import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/library/application/store_demo_seeder.dart';
import 'package:kitabkhana/features/reading/domain/reading_log.dart';
import 'package:kitabkhana/features/stats/domain/goal.dart';
import 'package:kitabkhana/features/stats/domain/stats.dart';
import 'package:kitabkhana/features/stats/domain/year_review.dart';

import '../../helpers/add_flow_harness.dart';

ReadingLog log(DateTime day, int pages) => ReadingLog.create(
  id: 'l${day.millisecondsSinceEpoch}',
  bookId: 'b',
  date: day,
  fromPage: 0,
  toPage: pages,
  now: day,
);

void main() {
  group('buildYearReview', () {
    test('counts the year only, with its longest streak', () {
      final r = buildYearReview(
        year: 2026,
        booksFinished: 6,
        perMonth: <int>[1, 0, 2],
        logs: <ReadingLog>[
          log(DateTime(2025, 12, 31), 99),
          log(DateTime(2026, 1, 1), 20),
          log(DateTime(2026, 1, 2), 30),
        ],
        readingDays: <DateTime>[
          DateTime(2025, 12, 30),
          DateTime(2025, 12, 31),
          DateTime(2026, 3, 1),
          DateTime(2026, 3, 2),
          DateTime(2026, 3, 3),
          DateTime(2026, 5, 9),
        ],
        today: DateTime(2026, 11, 24),
        goal: Goal.create(
          id: 'g',
          year: 2026,
          targetBooks: 12,
          now: DateTime(2026),
        ),
        genres: const <LabelCount>[
          LabelCount('', 3),
          LabelCount('Classics', 2),
        ],
        authors: const <LabelCount>[LabelCount('Jane Austen', 2)],
        longest: const LongestBook('Middlemarch', 880),
      );
      expect(r.pagesRead, 50);
      expect(r.perMonth, hasLength(12));
      expect(r.perMonth.take(3), <int>[1, 0, 2]);
      expect(r.longestStreak, 3);
      expect(r.goalTarget, 12);
      expect(r.topGenre, 'Classics', reason: 'a blank genre is skipped');
      expect(r.topAuthor, 'Jane Austen');
      expect(r.isEmpty, isFalse);
    });

    test('a year with nothing is empty', () {
      final r = buildYearReview(
        year: 2026,
        booksFinished: 0,
        perMonth: const <int>[],
        logs: const <ReadingLog>[],
        readingDays: const <DateTime>[],
        today: DateTime(2026, 11, 24),
      );
      expect(r.isEmpty, isTrue);
      expect(r.longestStreak, 0);
    });
  });

  testWidgets('Stats shares the year as a picture', (t) async {
    final h = AddFlowHarness();
    addTearDown(h.dispose);
    h.clock.set(DateTime(2026, 11, 24, 9));
    await t.runAsync(
      () => StoreDemoSeeder(
        books: h.repos.books,
        locations: h.repos.locations,
        loans: h.repos.loans,
        readings: h.repos.readings,
        quotes: h.repos.quotes,
        goals: h.repos.goals,
        tags: h.repos.tags,
        clock: h.clock,
      ).seed(),
    );
    await h.pump(t, start: '/stats');
    await t.tap(find.byTooltip('Share your year'));
    // A spinner shows while the year is read, so step rather than settle.
    for (
      var i = 0;
      i < 40 && find.bySemanticsLabel(RegExp('My 2026')).evaluate().isEmpty;
      i++
    ) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await t.pump(const Duration(milliseconds: 50));
    }
    expect(find.bySemanticsLabel(RegExp('My 2026 in books')), findsOneWidget);
    await t.tap(find.text('Share'));
    // The share button spins while the picture is drawn, so no settling.
    await t.pump();
    await t.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
    await t.pump();
    expect(h.share.images.single.name, 'kitabkhana-2026.png');
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  });
}
