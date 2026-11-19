import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme/tokens.dart';

enum KButtonVariant { primary, secondary, tonal, text }

/// A themed button with a loading state and optional leading icon.
class KButton extends StatelessWidget {
  const KButton({
    required this.label,
    required this.onPressed,
    this.variant = KButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final KButtonVariant variant;
  final IconData? icon;
  final bool loading;

  /// Stretch to the full available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    void handle() {
      if (variant == KButtonVariant.primary) {
        HapticFeedback.lightImpact();
      }
      onPressed?.call();
    }

    final child = _content(context);
    final VoidCallback? cb = enabled ? handle : null;
    final button = switch (variant) {
      KButtonVariant.primary => FilledButton(onPressed: cb, child: child),
      KButtonVariant.secondary => OutlinedButton(onPressed: cb, child: child),
      KButtonVariant.tonal => FilledButton.tonal(onPressed: cb, child: child),
      KButtonVariant.text => TextButton(onPressed: cb, child: child),
    };
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _content(BuildContext context) {
    final color = IconTheme.of(context).color;
    final leading = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        : (icon != null ? Icon(icon, size: 20) : null);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (leading != null) ...<Widget>[
          leading,
          const SizedBox(width: KSpacing.sm),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
  }
}

/// An icon button with a guaranteed 48dp target and a required tooltip.
class KIconButton extends StatelessWidget {
  const KIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final button = filled
        ? IconButton.filledTonal(
            icon: Icon(icon),
            tooltip: tooltip,
            onPressed: onPressed,
          )
        : IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onPressed);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: button,
    );
  }
}
