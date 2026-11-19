import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'k_tokens.dart';
import 'tokens.dart';
import 'type_scale.dart';

/// Builds the "Ink & Paper" themes.
abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: KColors.paperBackground,
    surface: KColors.paperSurface,
    surfaceVariant: KColors.paperSurfaceVariant,
    text: KColors.paperText,
    muted: KColors.paperMuted,
    outline: KColors.paperOutline,
    primary: KColors.paperPrimary,
    primaryStrong: KColors.paperPrimaryStrong,
    onPrimary: KColors.paperOnPrimary,
    secondary: KColors.paperSecondary,
    onSecondary: KColors.paperSurface,
    error: KColors.paperError,
    tokens: KTokens.light,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: KColors.lampBackground,
    surface: KColors.lampSurface,
    surfaceVariant: KColors.lampSurfaceVariant,
    text: KColors.lampText,
    muted: KColors.lampMuted,
    outline: KColors.lampOutline,
    primary: KColors.lampPrimary,
    primaryStrong: KColors.lampPrimaryStrong,
    onPrimary: KColors.lampOnPrimary,
    secondary: KColors.lampSecondary,
    onSecondary: KColors.lampBackground,
    error: KColors.lampError,
    tokens: KTokens.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color text,
    required Color muted,
    required Color outline,
    required Color primary,
    required Color primaryStrong,
    required Color onPrimary,
    required Color secondary,
    required Color onSecondary,
    required Color error,
    required KTokens tokens,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: error,
      onError: brightness == Brightness.light
          ? KColors.paperSurface
          : KColors.lampBackground,
      surface: background,
      onSurface: text,
      surfaceContainerLowest: surface,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceVariant,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: muted,
      outline: muted,
      outlineVariant: outline,
      primaryContainer: surfaceVariant,
      onPrimaryContainer: primaryStrong,
      secondaryContainer: surfaceVariant,
      onSecondaryContainer: secondary,
      shadow: const Color(0xFF000000),
      surfaceTint: const Color(0x00000000),
    );

    final textTheme = buildTextTheme(text, muted);
    const buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(KRadii.button)),
    );
    const buttonSize = Size(48, 48);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(KRadii.input),
      borderSide: BorderSide(color: outline),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: KFonts.sans,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[tokens],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KRadii.card),
          side: BorderSide(color: outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          side: BorderSide(color: muted.withValues(alpha: 0.5)),
          foregroundColor: text,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: buttonSize,
          foregroundColor: text,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KSpacing.lg,
          vertical: KSpacing.md,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: muted),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: error)),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: error, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: surfaceVariant,
        side: BorderSide(color: outline),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KRadii.chip),
        ),
        showCheckmark: false,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: outline,
        modalBackgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(KRadii.sheet),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: surfaceVariant,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KRadii.chip),
        ),
        labelTextStyle: WidgetStatePropertyAll<TextStyle?>(
          textTheme.labelSmall?.copyWith(color: text),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? primary : muted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: surfaceVariant,
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: primary),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: muted),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: text,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: background),
        actionTextColor: brightness == Brightness.light
            ? KColors.lampPrimary
            : KColors.paperPrimaryStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KRadii.button),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KRadii.card),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall,
        minVerticalPadding: KSpacing.sm,
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceVariant,
        circularTrackColor: surfaceVariant,
        linearMinHeight: 6,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? onPrimary : muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : surfaceVariant,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary
              : muted.withValues(alpha: 0.6),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: surfaceVariant,
        thumbColor: primary,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: muted,
        indicatorColor: primary,
        dividerColor: outline,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelMedium,
      ),
    );
  }
}
