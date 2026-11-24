import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// `android`, `iOS`, `web`, … for reports.
String currentPlatformName() => kIsWeb ? 'web' : defaultTargetPlatform.name;

/// The operating system's own version text; "unknown" where there is none.
String currentOsVersion() {
  if (kIsWeb) return 'browser';
  try {
    return Platform.operatingSystemVersion;
  } on Object {
    return 'unknown';
  }
}
