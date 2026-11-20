import 'package:flutter/material.dart';

import '../app/theme/k_tokens.dart';
import '../app/theme/tokens.dart';
import 'k_button.dart';
import 'k_illustrations.dart';

/// Warm empty/err state: line illustration, title, body and one action.
class KEmptyState extends StatelessWidget {
  const KEmptyState({
    required this.illustration,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.illustrationSize = 160,
    super.key,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction go together',
       );

  final KIllustration illustration;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// An optional quieter second action under the main one.
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final double illustrationSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.kTokens.mutedText.withValues(alpha: 0.75);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(KSpacing.screen),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.hasBoundedHeight
                  ? (constraints.maxHeight - KSpacing.screen * 2).clamp(
                      0,
                      double.infinity,
                    )
                  : 0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ExcludeSemantics(
                      child: CustomPaint(
                        size: Size.square(illustrationSize),
                        painter: KIllustrationPainter(
                          kind: illustration,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: KSpacing.xl),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                    if (body != null) ...<Widget>[
                      const SizedBox(height: KSpacing.sm),
                      Text(
                        body!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (actionLabel != null) ...<Widget>[
                      const SizedBox(height: KSpacing.xl),
                      KButton(label: actionLabel!, onPressed: onAction),
                    ],
                    if (secondaryLabel != null) ...<Widget>[
                      const SizedBox(height: KSpacing.sm),
                      KButton(
                        label: secondaryLabel!,
                        onPressed: onSecondary,
                        variant: KButtonVariant.text,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
