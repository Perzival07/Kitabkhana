import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/library_providers.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/features/settings/domain/app_settings.dart'
    show LibraryView;

import '../helpers/add_flow_harness.dart';
import '../helpers/seed_library.dart';

/// Flutter's accessibility guidelines, run on every main screen in both
/// themes: tap targets of at least 48dp (Android) and 44pt (iOS), every tap
/// target labelled, and text contrast.
void main() {
  final screens = <String, String>{
    'library': '/library',
    'add': '/library/add',
    'book detail': '/book/b1',
    'scan': '/scan',
    'reading': '/reading',
    'stats': '/stats',
    'more': '/more',
    'quotes': '/quotes',
    'loans': '/loans',
    'locations': '/locations',
    'settings': '/settings',
    'tags': '/tags',
    'about': '/about',
    'onboarding': '/onboarding',
    'quote capture': '/book/b1/quote',
  };

  for (final dark in <bool>[false, true]) {
    final mode = dark ? 'dark' : 'light';
    for (final e in screens.entries) {
      testWidgets('${e.key} ($mode) meets the guidelines', (t) async {
        final h = AddFlowHarness();
        addTearDown(h.dispose);
        await t.runAsync(() => seedDemoLibrary(h));
        final handle = t.ensureSemantics();
        final c = await h.pump(
          t,
          start: e.value,
          size: const Size(360, 800),
          disableAnimations: true,
        );
        if (dark) {
          c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
          await t.pumpAndSettle();
        }
        await t.pumpAndSettle();
        await expectLater(t, meetsGuideline(androidTapTargetGuideline));
        await expectLater(t, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(t, meetsGuideline(textContrastGuideline));
        handle.dispose();
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(milliseconds: 400));
      });
    }
  }

  Future<void> guidelines(WidgetTester t) async {
    await expectLater(t, meetsGuideline(androidTapTargetGuideline));
    await expectLater(t, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(t, meetsGuideline(textContrastGuideline));
  }

  Future<void> finish(WidgetTester t, SemanticsHandle handle) async {
    handle.dispose();
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  for (final dark in <bool>[false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('library as a list ($mode) meets the guidelines', (t) async {
      final h = AddFlowHarness();
      addTearDown(h.dispose);
      await t.runAsync(() => seedDemoLibrary(h));
      final handle = t.ensureSemantics();
      final c = await h.pump(
        t,
        start: '/library',
        size: const Size(360, 800),
        disableAnimations: true,
      );
      await c
          .read(libraryViewControllerProvider.notifier)
          .set(LibraryView.list);
      if (dark) {
        c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
      }
      await t.pumpAndSettle();
      await guidelines(t);
      await finish(t, handle);
    });

    for (final (name, label) in <(String, String)>[
      ('update page sheet', 'Update page'),
      ('lend sheet', 'Lend'),
    ]) {
      testWidgets('$name ($mode) meets the guidelines', (t) async {
        final h = AddFlowHarness();
        addTearDown(h.dispose);
        await t.runAsync(() => seedDemoLibrary(h));
        final handle = t.ensureSemantics();
        final c = await h.pump(
          t,
          start: name == 'lend sheet' ? '/book/b3' : '/book/b1',
          size: const Size(360, 800),
          disableAnimations: true,
        );
        if (dark) {
          c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
        }
        await t.pumpAndSettle();
        await t.ensureVisible(find.text(label));
        await t.pumpAndSettle();
        await t.tap(find.text(label));
        await t.pumpAndSettle();
        await guidelines(t);
        await finish(t, handle);
      });
    }
  }

  group('large text', () {
    for (final e in screens.entries) {
      testWidgets('${e.key}: nothing overflows at 320dp and 200% text', (
        t,
      ) async {
        final h = AddFlowHarness();
        addTearDown(h.dispose);
        await t.runAsync(() => seedDemoLibrary(h));
        await h.pump(
          t,
          start: e.value,
          size: const Size(320, 640),
          textScale: 2,
          disableAnimations: true,
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(milliseconds: 400));
      });
    }
  });

  group('keyboard', () {
    testWidgets('Escape closes a bottom sheet', (t) async {
      final h = AddFlowHarness();
      addTearDown(h.dispose);
      await t.runAsync(() => seedDemoLibrary(h));
      await h.pump(
        t,
        start: '/book/b1',
        size: const Size(800, 1000),
        disableAnimations: true,
      );
      await t.ensureVisible(find.text('Update page'));
      await t.pumpAndSettle();
      await t.tap(find.text('Update page'));
      await t.pumpAndSettle();
      expect(find.text('Where are you now?'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.text('Where are you now?'), findsNothing);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 400));
    });
  });
}
