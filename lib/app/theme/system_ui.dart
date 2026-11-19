import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Edge-to-edge with transparent system bars whose icons follow the theme.
void enableEdgeToEdge() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

/// System bar style matching [brightness] (icons are dark on light themes).
SystemUiOverlayStyle systemOverlayFor(Brightness brightness) {
  final iconBrightness = brightness == Brightness.light
      ? Brightness.dark
      : Brightness.light;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    statusBarIconBrightness: iconBrightness,
    statusBarBrightness: brightness,
    systemNavigationBarIconBrightness: iconBrightness,
  );
}
