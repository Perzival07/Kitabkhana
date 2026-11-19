import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../l10n/app_localizations.dart';

Duration _animDuration(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : KDurations.slow;

/// A circular progress ring (e.g. yearly goal) with a centre child.
class KProgressRing extends StatelessWidget {
  const KProgressRing({
    required this.value,
    required this.semanticLabel,
    this.child,
    this.size = 120,
    this.strokeWidth = 10,
    super.key,
  });

  /// 0..1.
  final double value;

  /// Spoken summary, e.g. "18 of 24 books, 75 percent".
  final String semanticLabel;
  final Widget? child;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: v),
        duration: _animDuration(context),
        curve: KCurves.standard,
        builder: (context, animated, _) => SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: animated,
              track: cs.surfaceContainerHighest,
              color: cs.primary,
              strokeWidth: strokeWidth,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.track,
    required this.color,
    required this.strokeWidth,
  });

  final double value;
  final Color track;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(
        arcRect,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.track != track ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}

/// A rounded linear progress bar (e.g. book progress).
class KProgressBar extends StatelessWidget {
  const KProgressBar({
    required this.value,
    this.semanticLabel,
    this.height = 6,
    super.key,
  });

  /// 0..1.
  final double value;

  /// Defaults to the localised "N percent".
  final String? semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final v = value.clamp(0.0, 1.0);
    final label =
        semanticLabel ??
        AppLocalizations.of(context).percentSemantics((v * 100).round());
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: v),
        duration: _animDuration(context),
        curve: KCurves.standard,
        builder: (context, animated, _) => ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: LinearProgressIndicator(
            value: animated,
            minHeight: height,
            backgroundColor: cs.surfaceContainerHighest,
            color: cs.primary,
          ),
        ),
      ),
    );
  }
}
