import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

/// An outlined card (radius 20) with an optional ink-ripple tap.
class KCard extends StatelessWidget {
  const KCard({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(KSpacing.lg),
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null && onLongPress == null
          ? body
          : Semantics(
              button: true,
              label: semanticLabel,
              child: InkWell(
                onTap: onTap,
                onLongPress: onLongPress,
                child: body,
              ),
            ),
    );
  }
}
