import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/library/application/store_demo_seeder.dart';

import '../helpers/add_flow_harness.dart';
import '../helpers/pump_router_app.dart';

/// Every main screen in Hindi and Bengali on a small phone: no overflow, no
/// error, and the translated text actually shows.
void main() {
  const screens = <String>[
    '/library',
    '/library/add',
    '/library/add/manual',
    '/scan',
    '/reading',
    '/stats',
    '/more',
    '/loans',
    '/quotes',
    '/locations',
    '/tags',
    '/settings',
    '/about',
    '/onboarding',
    '/book/${StoreDemoSeeder.middlemarchId}',
  ];

  for (final (locale, libraryWord) in <(String, String)>[
    ('en', 'library'),
    ('hi', 'लाइब्रेरी'),
    ('bn', 'লাইব্রেরি'),
  ]) {
    testWidgets('$locale: every main screen lays out', (t) async {
      t.platformDispatcher.localesTestValue = <Locale>[Locale(locale)];
      addTearDown(t.platformDispatcher.clearLocalesTestValue);
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
      final c = await pumpRouterApp(
        t,
        size: const Size(360, 800),
        overrides: h.overrides,
        disableAnimations: true,
      );
      final problems = <String>[];
      for (final path in screens) {
        // Collect layout errors with where they happened, for a useful
        // failure; the test's own handler is back before any expect.
        final errors = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (d) {
          final where = d
              .toString()
              .split('\n')
              .where((l) => l.contains('file:///') && l.contains('/lib/'))
              .take(1)
              .join();
          errors.add('${d.exceptionAsString().split('\n').first} $where');
        };
        try {
          routerOf(c).go(path);
          for (var i = 0; i < 3; i++) {
            await t.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 30)),
            );
            await t.pumpAndSettle();
          }
        } finally {
          FlutterError.onError = previous;
        }
        problems.addAll(errors.map((e) => '$path: $e'));
      }
      expect(problems, isEmpty, reason: locale);
      routerOf(c).go('/library');
      await t.pumpAndSettle();
      expect(find.textContaining(libraryWord), findsWidgets);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 400));
    });
  }
}
