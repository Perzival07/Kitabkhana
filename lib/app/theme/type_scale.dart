import 'package:flutter/material.dart';

abstract final class KFonts {
  static const String serif = 'Fraunces';
  static const String sans = 'Inter';
}

/// Builds the text theme from the type scale:
/// display 34/40, headline 26/32, title 20/26, body 16/24, label 14/20, caption 12/16.
TextTheme buildTextTheme(Color text, Color muted) {
  TextStyle serif(double size, double line, FontWeight w) => TextStyle(
    fontFamily: KFonts.serif,
    fontSize: size,
    height: line / size,
    fontWeight: w,
    color: text,
  );
  TextStyle sans(double size, double line, FontWeight w, [Color? c]) =>
      TextStyle(
        fontFamily: KFonts.sans,
        fontSize: size,
        height: line / size,
        fontWeight: w,
        color: c ?? text,
      );

  return TextTheme(
    displayLarge: serif(34, 40, FontWeight.w600),
    displayMedium: serif(34, 40, FontWeight.w600),
    displaySmall: serif(34, 40, FontWeight.w600),
    headlineLarge: serif(26, 32, FontWeight.w600),
    headlineMedium: serif(26, 32, FontWeight.w600),
    headlineSmall: serif(26, 32, FontWeight.w600),
    titleLarge: serif(20, 26, FontWeight.w600),
    titleMedium: sans(16, 24, FontWeight.w600),
    titleSmall: sans(14, 20, FontWeight.w600),
    bodyLarge: sans(16, 24, FontWeight.w400),
    bodyMedium: sans(16, 24, FontWeight.w400),
    bodySmall: sans(12, 16, FontWeight.w400, muted),
    labelLarge: sans(14, 20, FontWeight.w600),
    labelMedium: sans(14, 20, FontWeight.w500),
    labelSmall: sans(12, 16, FontWeight.w500, muted),
  );
}
