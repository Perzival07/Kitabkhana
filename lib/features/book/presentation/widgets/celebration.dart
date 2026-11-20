import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A short, subtle burst of confetti-like dots. Plays once each time [play]
/// changes to a new value; draws nothing when the user prefers reduced motion.
class CelebrationBurst extends StatefulWidget {
  const CelebrationBurst({required this.play, super.key});

  /// Bump this number to play the burst.
  final int play;

  @override
  State<CelebrationBurst> createState() => _CelebrationBurstState();
}

class _CelebrationBurstState extends State<CelebrationBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didUpdateWidget(CelebrationBurst old) {
    super.didUpdateWidget(old);
    if (widget.play != old.play && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = <Color>[
      cs.primary,
      cs.secondary,
      cs.tertiary,
      cs.primaryContainer,
    ];
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (_controller.isDismissed) return const SizedBox.shrink();
            return CustomPaint(
              size: Size.infinite,
              painter: _BurstPainter(_controller.value, colors),
            );
          },
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t, this.colors);

  final double t;
  final List<Color> colors;

  static const int _count = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.3);
    final ease = Curves.easeOutCubic.transform(t);
    for (var i = 0; i < _count; i++) {
      final angle = (i / _count) * math.pi * 2 + (i.isEven ? 0.2 : -0.2);
      final reach = (80 + (i % 5) * 28) * ease;
      final drop = 40 * t * t;
      final p =
          origin +
          Offset(math.cos(angle) * reach, math.sin(angle) * reach + drop);
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 1 - t);
      canvas.drawCircle(p, 3 + (i % 3).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
