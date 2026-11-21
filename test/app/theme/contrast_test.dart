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

      // Every other pairing the app draws text or icons in.
      surfaces.forEach((name, bg) {
        expectRatio(
          'on-surface-variant text on $name',
          cs.onSurfaceVariant,
          bg,
          4.5,
        );
        expectRatio('hint text on $name', tokens.mutedText, bg, 4.5);
        expectRatio('tertiary on $name', cs.tertiary, bg, 3);
      });
      expectRatio(
        'on-primary-container on primary-container',
        cs.onPrimaryContainer,
        cs.primaryContainer,
        4.5,
      );
      expectRatio(
        'on-secondary-container on secondary-container',
        cs.onSecondaryContainer,
        cs.secondaryContainer,
        4.5,
      );
      expectRatio(
        'on-error-container on error-container',
        cs.onErrorContainer,
        cs.errorContainer,
        4.5,
      );
      expectRatio('on-tertiary on tertiary', cs.onTertiary, cs.tertiary, 4.5);
      expectRatio(
        'on-surface on the navigation indicator',
        cs.onSurface,
        theme.navigationBarTheme.indicatorColor!,
        4.5,
      );
      expectRatio(
        'selected tab icon on the navigation bar',
        theme.navigationBarTheme.iconTheme!.resolve(<WidgetState>{
          WidgetState.selected,
        })!.color!,
        theme.navigationBarTheme.backgroundColor!,
        3,
      );
      expectRatio(
        'unselected tab icon on the navigation bar',
        theme.navigationBarTheme.iconTheme!.resolve(<WidgetState>{})!.color!,
        theme.navigationBarTheme.backgroundColor!,
        3,
      );
      expectRatio(
        'tab label on the navigation bar',
        theme.navigationBarTheme.labelTextStyle!
            .resolve(<WidgetState>{})!
            .color!,
        theme.navigationBarTheme.backgroundColor!,
        4.5,
      );
      expectRatio(
        'selected rail label on the surface',
        theme.navigationRailTheme.selectedLabelTextStyle!.color!,
        theme.navigationRailTheme.backgroundColor!,
        4.5,
      );
      expectRatio(
        'unselected rail label on the surface',
        theme.navigationRailTheme.unselectedLabelTextStyle!.color!,
        theme.navigationRailTheme.backgroundColor!,
        4.5,
      );
      expectRatio(
        'selected rail icon on the indicator',
        theme.navigationRailTheme.selectedIconTheme!.color!,
        theme.navigationRailTheme.indicatorColor!,
        3,
      );
      expectRatio(
        'focus ring colour on the background',
        cs.primary,
        cs.surface,
        3,
      );
    });
  }

  for (final entry in <String, ThemeData>{
    'light': AppTheme.light,
    'dark': AppTheme.dark,
  }.entries) {
    group('${entry.key} keyboard focus', () {
      final theme = entry.value;
      final focused = <WidgetState>{WidgetState.focused};

      test('buttons grow a 3dp ring that contrasts with the page', () {
        for (final style in <ButtonStyle?>[
          theme.filledButtonTheme.style,
          theme.outlinedButtonTheme.style,
          theme.textButtonTheme.style,
          theme.iconButtonTheme.style,
        ]) {
          final ring = style!.side!.resolve(focused)!;
          expect(ring.width, 3);
          expect(
            contrastRatio(ring.color, theme.colorScheme.surface),
            greaterThanOrEqualTo(3),
          );
        }
      });

      test('there is no ring until focused, and outlined keeps its border', () {
        expect(theme.filledButtonTheme.style!.side!.resolve({}), isNull);
        expect(theme.outlinedButtonTheme.style!.side!.resolve({}), isNotNull);
      });
    });
  }
}
