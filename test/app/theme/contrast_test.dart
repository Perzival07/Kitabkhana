import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/app_theme.dart';
import 'package:kitabkhana/app/theme/contrast.dart';
import 'package:kitabkhana/app/theme/k_tokens.dart';

void main() {
  group('contrast helper', () {
    test('black on white is 21:1', () {
      expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
    });
    test('identical colours are 1:1', () {
      expect(contrastRatio(Colors.red, Colors.red), closeTo(1, 0.0001));
    });
    test('is symmetric', () {
      expect(
        contrastRatio(Colors.black, Colors.white),
        contrastRatio(Colors.white, Colors.black),
      );
    });
  });

  for (final entry in <String, ThemeData>{
    'light': AppTheme.light,
    'dark': AppTheme.dark,
  }.entries) {
    group('${entry.key} theme meets WCAG AA', () {
      final theme = entry.value;
      final cs = theme.colorScheme;
      final tokens = theme.extension<KTokens>()!;
      final surfaces = <String, Color>{
        'background': cs.surface,
        'card surface': cs.surfaceContainerLowest,
        'surface variant': cs.surfaceContainerHighest,
      };

      void expectRatio(String label, Color fg, Color bg, double min) {
        test('$label >= $min:1', () {
          expect(contrastRatio(fg, bg), greaterThanOrEqualTo(min));
        });
      }

      surfaces.forEach((name, bg) {
        expectRatio('text on $name', cs.onSurface, bg, 4.5);
        expectRatio('muted text on $name', tokens.mutedText, bg, 4.5);
        if (name == 'surface variant') {
          expectRatio(
            'primary-strong on $name',
            cs.onPrimaryContainer,
            bg,
            4.5,
          );
        } else {
          expectRatio('primary on $name', cs.primary, bg, 4.5);
        }
        expectRatio('secondary on $name', cs.secondary, bg, 4.5);
        expectRatio('success on $name', tokens.success, bg, 3);
        expectRatio('warning on $name', tokens.warning, bg, 3);
        expectRatio('error on $name', cs.error, bg, 3);
      });
      expectRatio('on-primary on primary', cs.onPrimary, cs.primary, 4.5);
      expectRatio(
        'on-secondary on secondary',
        cs.onSecondary,
        cs.secondary,
        4.5,
      );
      expectRatio('on-error on error', cs.onError, cs.error, 4.5);
      expectRatio(
        'snackbar text',
        theme.snackBarTheme.contentTextStyle!.color!,
        theme.snackBarTheme.backgroundColor!,
        4.5,
      );
      expectRatio(
        'snackbar action',
        theme.snackBarTheme.actionTextColor!,
        theme.snackBarTheme.backgroundColor!,
        4.5,
      );
      expectRatio('outline (UI) on background', cs.outline, cs.surface, 3);
    });
  }
}
