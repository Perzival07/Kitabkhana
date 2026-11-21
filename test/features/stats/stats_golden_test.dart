@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/reading/domain/reading_log.dart';

import '../../helpers/add_flow_harness.dart';

void main() {
  final now = DateTime(2025, 3, 10);
  for (final dark in <bool>[false, true]) {
    final mode = dark ? 'dark' : 'light';
    testWidgets('stats tab ($mode)', (t) async {
      final h = AddFlowHarness();
      addTearDown(h.dispose);
      final shelf = <(String, String, String, int, DateTime)>[
        ('Dune', 'Frank Herbert', 'Sci-fi', 612, DateTime(2025, 1, 12)),
        ('Emma', 'Jane Austen', 'Classics', 474, DateTime(2025, 1, 30)),
        ('Piranesi', 'Susanna Clarke', 'Fantasy', 272, DateTime(2025, 2, 9)),
        ('Persuasion', 'Jane Austen', 'Classics', 249, DateTime(2025, 2, 20)),
        ('Hyperion', 'Dan Simmons', 'Sci-fi', 482, DateTime(2025, 3, 2)),
      ];
      for (var i = 0; i < shelf.length; i++) {
        final s = shelf[i];
        await h.repos.books.upsert(
          Book.create(
            id: 'b$i',
            title: s.$1,
            authors: s.$2,
            genre: s.$3,
            pages: s.$4,
            now: now,
            status: ReadStatus.finished,
          ).copyWith(finishedOn: s.$5, startedOn: s.$5, rating: 4),
        );
      }
      await h.repos.goals.setTarget(2025, 12);
      for (var w = 0; w < 12; w++) {
        await h.repos.readings.upsert(
          ReadingLog.create(
            id: 'l$w',
            bookId: 'b0',
            date: DateTime(2025, 3, 10 - 7 * w - 2),
            fromPage: 0,
            toPage: 40 + (w % 5) * 25,
            now: now,
          ),
        );
      }
      final c = await h.pump(
        t,
        start: '/stats',
        size: const Size(360, 1500),
        disableAnimations: true,
      );
      if (dark) {
        c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
        await t.pumpAndSettle();
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/stats_$mode.png'),
      );
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 400));
    });
  }
}
