import 'dart:async';

import 'package:flutter/services.dart';

/// The app's haptic vocabulary, in one place.
///
/// * [light]: a primary action was taken.
/// * [success]: something good and certain happened (a scan match, a book
///   finished). Flutter has no separate "success notification" feedback, so
///   this is a firmer tap.
/// * [selection]: a small choice was made.
abstract final class Haptics {
  static void light() => unawaited(HapticFeedback.lightImpact());

  static void success() => unawaited(HapticFeedback.mediumImpact());

  static void selection() => unawaited(HapticFeedback.selectionClick());
}
