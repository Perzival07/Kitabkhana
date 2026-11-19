import 'package:flutter/material.dart';

import 'tokens.dart';

/// Extra design tokens that [ColorScheme] has no slot for.
@immutable
class KTokens extends ThemeExtension<KTokens> {
  const KTokens({
    required this.success,
    required this.warning,
    required this.mutedText,
    required this.coverPalette,
    required this.shadows,
  });

  static const KTokens light = KTokens(
    success: KColors.paperSuccess,
    warning: KColors.paperWarning,
    mutedText: KColors.paperMuted,
    coverPalette: KColors.coverPalette,
    shadows: KShadows.light,
  );

  static const KTokens dark = KTokens(
    success: KColors.lampSuccess,
    warning: KColors.lampWarning,
    mutedText: KColors.lampMuted,
    coverPalette: KColors.coverPalette,
    shadows: KShadows.dark,
  );

  final Color success;
  final Color warning;
  final Color mutedText;
  final List<Color> coverPalette;
  final List<BoxShadow> shadows;

  @override
  KTokens copyWith({
    Color? success,
    Color? warning,
    Color? mutedText,
    List<Color>? coverPalette,
    List<BoxShadow>? shadows,
  }) {
    return KTokens(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      mutedText: mutedText ?? this.mutedText,
      coverPalette: coverPalette ?? this.coverPalette,
      shadows: shadows ?? this.shadows,
    );
  }

  @override
  KTokens lerp(ThemeExtension<KTokens>? other, double t) {
    if (other is! KTokens) return this;
    return KTokens(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      mutedText: Color.lerp(mutedText, other.mutedText, t) ?? mutedText,
      coverPalette: t < 0.5 ? coverPalette : other.coverPalette,
      shadows: BoxShadow.lerpList(shadows, other.shadows, t) ?? shadows,
    );
  }
}

extension KTokensX on BuildContext {
  /// The extra design tokens for the current theme.
  KTokens get kTokens => Theme.of(this).extension<KTokens>() ?? KTokens.light;
}
