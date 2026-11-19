import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/shell/adaptive_scaffold.dart';
import 'package:kitabkhana/ui/ui.dart';

import '../../helpers/pump_router_app.dart';

void main() {
  test('layout breakpoints', () {
    expect(shellLayoutFor(599), ShellLayout.compact);
    expect(shellLayoutFor(600), ShellLayout.medium);
    expect(shellLayoutFor(1000), ShellLayout.medium);
    expect(shellLayoutFor(1001), ShellLayout.expanded);
  });

  testWidgets('bottom bar at 400dp', (t) async {
    await pumpRouterApp(t, size: const Size(400, 800));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    for (final l in <String>['Library', 'Scan', 'Reading', 'Stats', 'More']) {
      expect(find.text(l), findsOneWidget);
    }
  });

  testWidgets('bottom bar at 320dp with 200% text without overflow', (t) async {
    await pumpRouterApp(t, size: const Size(320, 640), textScale: 2);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('rail with wordmark at 800dp', (t) async {
    await pumpRouterApp(t, size: const Size(800, 1000));
    final rail = t.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(KWordmark), findsOneWidget);
  });

  testWidgets('extended rail and two-pane on Library at 1200dp', (t) async {
    await pumpRouterApp(t, size: const Size(1200, 900));
    final rail = t.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isTrue);
    expect(find.text('Pick a book'), findsOneWidget);
    // The list pane is fixed at 400dp.
    final list = find.ancestor(
      of: find.text('Your library'),
      matching: find.byType(SizedBox),
    );
    expect(
      list.evaluate().any(
        (e) => (e.widget as SizedBox).width == kListPaneWidth,
      ),
      isTrue,
    );
  });

  testWidgets('two-pane is only used on the Library tab', (t) async {
    final c = await pumpRouterApp(t, size: const Size(1200, 900));
    routerOf(c).go('/stats');
    await t.pumpAndSettle();
    expect(find.text('Pick a book'), findsNothing);
    expect(find.text('Your reading year'), findsOneWidget);
  });

  testWidgets('switching tabs changes the URL', (t) async {
    final c = await pumpRouterApp(t);
    await t.tap(find.text('Stats'));
    await t.pumpAndSettle();
    expect(locationOf(c), '/stats');
    await t.tap(find.text('Scan'));
    await t.pumpAndSettle();
    expect(locationOf(c), '/scan');
  });

  testWidgets('each tab keeps its own stack', (t) async {
    final c = await pumpRouterApp(t);
    routerOf(c).go('/library/add');
    await t.pumpAndSettle();
    expect(find.text('Type ISBN'), findsOneWidget);
    expect(locationOf(c), '/library/add');

    await t.tap(find.text('Stats'));
    await t.pumpAndSettle();
    expect(locationOf(c), '/stats');

    await t.tap(find.text('Library'));
    await t.pumpAndSettle();
    expect(locationOf(c), '/library/add');
  });

  testWidgets('back on another tab returns to the first tab', (t) async {
    final c = await pumpRouterApp(t);
    await t.tap(find.text('Reading'));
    await t.pumpAndSettle();
    expect(locationOf(c), '/reading');
    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(locationOf(c), '/library');
  });

  testWidgets('unknown routes show the friendly 404', (t) async {
    final c = await pumpRouterApp(t);
    routerOf(c).go('/definitely/not/here');
    await t.pumpAndSettle();
    expect(find.text("We can't find that page"), findsOneWidget);
    await t.tap(find.text('Go to your library'));
    await t.pumpAndSettle();
    expect(locationOf(c), '/library');
  });

  testWidgets('secondary routes resolve', (t) async {
    final c = await pumpRouterApp(t);
    for (final p in <String>[
      '/book/abc',
      '/book/abc/edit',
      '/loans',
      '/quotes',
      '/locations',
      '/settings',
      '/onboarding',
      '/dev/gallery',
    ]) {
      routerOf(c).go(p);
      // The gallery's shimmer never settles, so pump fixed durations.
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(find.text("We can't find that page"), findsNothing, reason: p);
      expect(locationOf(c), p);
    }
  });
}
