import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/app_config.dart';
import 'package:kitabkhana/app/app_root.dart';
import 'package:kitabkhana/app/theme/app_theme.dart';
import 'package:kitabkhana/app/theme/k_tokens.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/app/theme/tokens.dart';

void main() {
  test('serif for display/headline/titleLarge, sans for body', () {
    final t = AppTheme.light.textTheme;
    expect(t.displayLarge?.fontFamily, 'Fraunces');
    expect(t.headlineMedium?.fontFamily, 'Fraunces');
    expect(t.titleLarge?.fontFamily, 'Fraunces');
    expect(t.bodyLarge?.fontFamily, 'Inter');
    expect(t.labelLarge?.fontFamily, 'Inter');
    expect(t.bodyLarge?.fontSize, 16);
    expect(t.displayLarge?.fontSize, 34);
  });

  test('palette maps to the spec', () {
    expect(AppTheme.light.scaffoldBackgroundColor, KColors.paperBackground);
    expect(AppTheme.light.colorScheme.primary, KColors.paperPrimary);
    expect(AppTheme.dark.scaffoldBackgroundColor, KColors.lampBackground);
    expect(AppTheme.dark.colorScheme.primary, KColors.lampPrimary);
  });

  test('KTokens lerp interpolates colours', () {
    final mid = KTokens.light.lerp(KTokens.dark, 0.5);
    expect(mid.success, isNot(KTokens.light.success));
    expect(KTokens.light.lerp(KTokens.dark, 0).success, KTokens.light.success);
    expect(KTokens.light.lerp(KTokens.dark, 1).success, KTokens.dark.success);
  });

  testWidgets('theme mode provider switches the live theme', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AppRoot(config: AppConfig.dev()),
      ),
    );
    final bg = find.byType(Scaffold);
    expect(Theme.of(tester.element(bg)).brightness, Brightness.light);
    container.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(bg)).brightness, Brightness.dark);
  });
}
