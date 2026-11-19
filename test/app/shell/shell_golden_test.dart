@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';

import '../../helpers/pump_router_app.dart';

void main() {
  const sizes = <String, Size>{
    'phone_360x800': Size(360, 800),
    'tablet_800x1280': Size(800, 1280),
    'desktop_1280x800': Size(1280, 800),
  };
  for (final dark in <bool>[false, true]) {
    for (final e in sizes.entries) {
      final mode = dark ? 'dark' : 'light';
      testWidgets('shell ${e.key} ($mode)', (t) async {
        final c = await pumpRouterApp(t, size: e.value);
        if (dark) {
          c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
          await t.pumpAndSettle();
        }
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/shell_${e.key}_$mode.png'),
        );
      });
    }
  }
}
