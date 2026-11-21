@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'matrix.dart';

/// Pictures of every main screen at the sizes that matter most. The full
/// size list is checked for overflow in `layout_matrix_test.dart`; keeping
/// images for all 8 sizes x 2 themes x 13 screens would be over 200 files, so
/// the pictures cover: the smallest phone, the common phone, a small tablet,
/// a landscape tablet, dark at the two ends, and 200% text.
void main() {
  const light = <String, Size>{
    '320x568': Size(320, 568),
    '360x800': Size(360, 800),
    '600x960': Size(600, 960),
    '1280x800': Size(1280, 800),
  };
  const dark = <String, Size>{
    '360x800': Size(360, 800),
    '1280x800': Size(1280, 800),
  };

  for (final screen in matrixScreens) {
    Future<void> shoot(
      WidgetTester t, {
      required Size size,
      required bool isDark,
      required double scale,
      required String file,
    }) async {
      final h = await openMatrixScreen(
        t,
        screen,
        size: size,
        dark: isDark,
        textScale: scale,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$file.png'),
      );
      await closeMatrixScreen(t, h);
    }

    for (final e in light.entries) {
      testWidgets('${screen.name} ${e.key} light', (t) async {
        await shoot(
          t,
          size: e.value,
          isDark: false,
          scale: 1,
          file: '${screen.name}_${e.key}_light',
        );
      });
    }
    for (final e in dark.entries) {
      testWidgets('${screen.name} ${e.key} dark', (t) async {
        await shoot(
          t,
          size: e.value,
          isDark: true,
          scale: 1,
          file: '${screen.name}_${e.key}_dark',
        );
      });
    }
    testWidgets('${screen.name} 360x800 200% text', (t) async {
      await shoot(
        t,
        size: const Size(360, 800),
        isDark: false,
        scale: 2,
        file: '${screen.name}_360x800_text2_light',
      );
    });
  }
}
