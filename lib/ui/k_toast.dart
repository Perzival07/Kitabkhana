import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

/// Floating toast helper: icon + message with an optional action.
abstract final class KToast {
  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
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
  }
}
