import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'matrix.dart';

/// Every main screen at every device size, light and dark, plus 200% text at
/// 360x800: nothing may overflow or throw. (Pictures of the same matrix are
/// in `golden_matrix_test.dart`.)
void main() {
  for (final screen in matrixScreens) {
    for (final (sizeName, size) in matrixSizes) {
      for (final dark in <bool>[false, true]) {
        testWidgets(
          '${screen.name} at $sizeName (${dark ? 'dark' : 'light'})',
          (t) async {
            final h = await openMatrixScreen(t, screen, size: size, dark: dark);
            expect(t.takeException(), isNull);
            await closeMatrixScreen(t, h);
          },
        );
      }
    }
    for (final dark in <bool>[false, true]) {
      testWidgets(
        '${screen.name} at 360x800 with 200% text (${dark ? 'dark' : 'light'})',
        (t) async {
          final h = await openMatrixScreen(
            t,
            screen,
            size: const Size(360, 800),
            dark: dark,
            textScale: 2,
          );
          expect(t.takeException(), isNull);
          await closeMatrixScreen(t, h);
        },
      );
    }
  }
}
