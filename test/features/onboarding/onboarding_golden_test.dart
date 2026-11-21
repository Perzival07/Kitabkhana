@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/router/routes.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';

import '../../helpers/add_flow_harness.dart';

void main() {
  for (final dark in <bool>[false, true]) {
    final mode = dark ? 'dark' : 'light';
    for (final (name, taps) in <(String, int)>[
      ('welcome', 0),
      ('private', 2),
      ('places', 3),
      ('ready', 4),
    ]) {
      testWidgets('onboarding $name ($mode)', (t) async {
        final h = AddFlowHarness();
        addTearDown(h.dispose);
        final c = await h.pump(
          t,
          start: Routes.onboarding,
          size: const Size(360, 780),
          disableAnimations: true,
        );
        if (dark) {
          c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
          await t.pumpAndSettle();
        }
        for (var i = 0; i < taps; i++) {
          if (find.text('Next').evaluate().isNotEmpty) {
            await t.tap(find.text('Next'));
          } else {
            await t.tap(find.text('Not now'));
          }
          await t.pumpAndSettle();
        }
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/onboarding_${name}_$mode.png'),
        );
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(milliseconds: 400));
      });
    }
  }
}
