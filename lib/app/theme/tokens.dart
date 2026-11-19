import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Colour palettes for "Paper" (light) and "Lamplight" (dark).
abstract final class KColors {
  // Paper (light)
  static const Color paperBackground = Color(0xFFFBF7F0);
  static const Color paperSurface = Color(0xFFFFFFFF);
  static const Color paperSurfaceVariant = Color(0xFFF3EDE3);
  static const Color paperText = Color(0xFF1F1B16);
  static const Color paperMuted = Color(0xFF6B6259);
  static const Color paperOutline = Color(0xFFE5DDD0);
  static const Color paperPrimary = Color(0xFFB4532A);

  /// Deeper terracotta for primary-coloured text on tinted surfaces (AA).
  static const Color paperPrimaryStrong = Color(0xFFA64A24);
  static const Color paperOnPrimary = Color(0xFFFFFFFF);
  static const Color paperSecondary = Color(0xFF1F5C5B);
  static const Color paperSuccess = Color(0xFF3E7A4F);
  static const Color paperWarning = Color(0xFFB7791F);
  static const Color paperError = Color(0xFFB3261E);

  // Lamplight (dark)
  static const Color lampBackground = Color(0xFF15120F);
  static const Color lampSurface = Color(0xFF1E1A16);
  static const Color lampSurfaceVariant = Color(0xFF2A241E);
  static const Color lampText = Color(0xFFF2EBE1);
  static const Color lampMuted = Color(0xFFB3A89A);
  static const Color lampOutline = Color(0xFF3A322A);
  static const Color lampPrimary = Color(0xFFE08A5B);
  static const Color lampPrimaryStrong = Color(0xFFE08A5B);
  static const Color lampOnPrimary = Color(0xFF2A1308);
  static const Color lampSecondary = Color(0xFF7FB8B5);
  static const Color lampSuccess = Color(0xFF7DBF8E);
  static const Color lampWarning = Color(0xFFE0B05A);
  static const Color lampError = Color(0xFFF2B8B5);

  /// Ivory ink used on generated covers and avatars (sits on dark palette tones).
  static const Color coverInk = Color(0xFFF7F1E6);

  /// Highlight/shade used for cover gradients and the spine highlight.
  static const Color highlight = Color(0xFFFFFFFF);
  static const Color shade = Color(0xFF000000);

  /// Muted tones for generated covers; legible with light text in both themes.
  static const List<Color> coverPalette = <Color>[
    Color(0xFF7A3E2E),
    Color(0xFF2F5D5B),
    Color(0xFF5B4A7A),
    Color(0xFF4F6B3C),
    Color(0xFF8A5A1F),
    Color(0xFF3B5A7A),
    Color(0xFF7A3B55),
    Color(0xFF5A5247),
    Color(0xFF2E4A3F),
    Color(0xFF6B4226),
  ];
}

/// 4-pt spacing scale.
abstract final class KSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double huge = 48;

  /// Horizontal padding for every screen.
  static const double screen = 20;
}

abstract final class KRadii {
  static const double card = 20;
  static const double sheet = 28;
  static const double chip = 12;
  static const double button = 14;
  static const double cover = 6;
  static const double input = 14;
}

abstract final class KDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration stagger = Duration(milliseconds: 30);
  static const Duration shimmer = Duration(milliseconds: 1400);
  static const Duration search = Duration(milliseconds: 250);
  static const Duration toast = Duration(seconds: 4);
}

abstract final class KCurves {
  static const Curve standard = Curves.easeOutCubic;
}

abstract final class KBreakpoints {
  static const double compact = 600;
  static const double expanded = 1000;
}

/// Soft, warm shadows. Black at 6–10% with 16–24 blur.
abstract final class KShadows {
  static const List<BoxShadow> light = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 6)),
  ];
  static const List<BoxShadow> dark = <BoxShadow>[
    BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}
