@Tags(<String>['perf'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/library_providers.dart';
import 'package:kitabkhana/features/library/application/perf_seeder.dart';
import 'package:kitabkhana/features/library/presentation/widgets/book_tiles.dart';

import '../helpers/add_flow_harness.dart';

/// The Library screen over 5,000 books: it must build only what is on (or just
/// off) the screen, and page more in as you scroll, instead of building
/// thousands of tiles.
void main() {
  testWidgets('5,000 books: only a screenful is built, and paging works', (
    t,
  ) async {
    final h = AddFlowHarness();
    addTearDown(h.dispose);
    await t.runAsync(() => PerfSeeder(h.db).seed(today: h.clock.today()));

    final c = await h.pump(
      t,
      start: '/library',
      size: const Size(412, 915),
      disableAnimations: true,
    );
    await t.pumpAndSettle();

    // First page: a screenful of tiles, not thousands.
    final first = find.byType(BookGridTile).evaluate().length;
    expect(first, greaterThan(4));
    expect(first, lessThan(40), reason: 'lazily built');
    expect(c.read(libraryPagesProvider), 1);

    // Scroll a long way: more pages load, still only a screenful is built.
    for (var i = 0; i < 12; i++) {
      await t.fling(
        find.byType(CustomScrollView).first,
        const Offset(0, -2500),
        4000,
      );
      await t.pumpAndSettle();
    }
    expect(c.read(libraryPagesProvider), greaterThan(1), reason: 'loaded more');
    expect(find.byType(BookGridTile).evaluate().length, lessThan(40));

    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  });

  testWidgets('typing in the search box over 5,000 books answers quickly', (
    t,
  ) async {
    final h = AddFlowHarness();
    addTearDown(h.dispose);
    await t.runAsync(() => PerfSeeder(h.db).seed(today: h.clock.today()));
    await h.pump(
      t,
      start: '/library',
      size: const Size(412, 915),
      disableAnimations: true,
    );
    await t.pumpAndSettle();

    final w = Stopwatch()..start();
    await t.enterText(find.byType(TextField).first, 'River');
    await t.pump(const Duration(milliseconds: 400)); // past the debounce
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await t.pumpAndSettle();
    w.stop();
    // ignore: avoid_print
    print(
      'PERF widget: search "River" to results on screen ${w.elapsedMilliseconds} ms',
    );
    expect(find.byType(BookGridTile), findsWidgets);

    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  });
}
