import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

/// Floating toast helper: icon + message with an optional action.
abstract final class KToast {
  static int _showing = 0;
  static final ValueNotifier<bool> _visible = ValueNotifier<bool>(false);

  /// Whether a toast is on screen. A button that would sit under it (the
  /// library's Add button lives in a nested Scaffold the toast knows nothing
  /// about) can lift itself while this is true.
  static ValueListenable<bool> get visible => _visible;

  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = KDurations.toast,
  }) {
    showWith(
      ScaffoldMessenger.of(context),
      message,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Like [show], for callers that captured the messenger before navigating
  /// (so the toast survives the screen being replaced).
  static void showWith(
    ScaffoldMessengerState messenger,
    String message, {
    IconData icon = Icons.check_circle_rounded,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = KDurations.toast,
  }) {
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        duration: duration,
        // Snack bars with an action stay up until dismissed by default; a
        // toast should leave on its own.
        persist: false,
        content: Row(
          children: <Widget>[
            Icon(icon, size: 20),
            const SizedBox(width: KSpacing.md),
            Expanded(child: Text(message)),
          ],
        ),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
    _visible.value = ++_showing > 0;
    unawaited(controller.closed.then((_) => _visible.value = --_showing > 0));
  }
}
