@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/reading/domain/reading_log.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

void main() {
  final today = DateTime(2025, 3, 10);
  for (final dark in <bool>[false, true]) {
    final mode = dark ? 'dark' : 'light';
    testWidgets('reading tab ($mode)', (t) async {
      final h = AddFlowHarness();
      addTearDown(h.dispose);
      await h.repos.books.upsert(
        Book.create(
          id: 'a',
          title: 'Middlemarch',
          authors: 'George Eliot',
          now: today,
          pages: 880,
          status: ReadStatus.reading,
        ).copyWith(currentPage: 312, startedOn: DateTime(2025, 3, 1)),
      );
      await h.repos.books.upsert(
        Book.create(
          id: 'w',
          title: 'Piranesi',
          authors: 'Susanna Clarke',
          now: today,
        ),
      );
      for (var i = 0; i < 6; i++) {
        await h.repos.readings.upsert(
          ReadingLog.create(
            id: 'l$i',
            bookId: 'a',
            date: DateTime(2025, 3, 10 - i),
            fromPage: 0,
            toPage: 20 + i * 7,
            now: today,
          ),
        );
      }
      final c = await h.pump(
        t,
        start: '/reading',
        size: const Size(360, 780),
        disableAnimations: true,
      );
      if (dark) {
        c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
        await t.pumpAndSettle();
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/reading_$mode.png'),
      );
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 400));
    });
  }

  testWidgets('no overflow at 320dp and 200% text', (t) async {
    final h = AddFlowHarness();
    addTearDown(h.dispose);
    for (var i = 0; i < 2; i++) {
      await h.repos.books.upsert(
        Book.create(
          id: 'a$i',
          title: 'A rather long title that wraps $i',
          authors: 'Someone With A Long Name',
          now: today,
          pages: 400,
          status: ReadStatus.reading,
        ).copyWith(currentPage: 100, startedOn: today),
      );
    }
    await pumpRouterApp(
      t,
      size: const Size(320, 640),
      textScale: 2,
      overrides: h.overrides,
    ).then((c) async {
      routerOf(c).go('/reading');
      await t.pumpAndSettle();
    });
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  });
}
