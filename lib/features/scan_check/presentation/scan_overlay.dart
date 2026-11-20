import 'package:flutter/material.dart';

import '../../../app/theme/tokens.dart';

/// The scan window: a rounded cut-out in a dimmed layer, with gently pulsing
/// corner marks. Purely visual; touches pass through.
class ScanOverlay extends StatefulWidget {
  const ScanOverlay({required this.hint, super.key});

  final String hint;

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
      _pulse.value = 1;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, c) {
            final side = (c.maxWidth * 0.78).clamp(200.0, 360.0);
            final window = Size(side, side * 0.62);
            final rect = Rect.fromCenter(
              center: Offset(c.maxWidth / 2, c.maxHeight * 0.46),
              width: window.width,
              height: window.height,
            );
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CustomPaint(painter: _DimPainter(rect)),
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) => CustomPaint(
                    painter: _CornerPainter(
                      rect,
                      color.withValues(alpha: 0.55 + 0.45 * _pulse.value),
                    ),
                  ),
                ),
                Positioned(
                  left: KSpacing.screen,
                  right: KSpacing.screen,
                  top: rect.bottom + KSpacing.lg,
                  child: Text(
                    widget.hint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: color),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

const double _radius = 20;

class _DimPainter extends CustomPainter {
  _DimPainter(this.window);
  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(
        RRect.fromRectAndRadius(window, const Radius.circular(_radius)),
      )
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_DimPainter old) => old.window != window;
}

class _CornerPainter extends CustomPainter {
  _CornerPainter(this.window, this.color);
  final Rect window;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const len = 28.0;
    final r = window;
    void corner(Offset a, Offset b, Offset c) {
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(c.dx, c.dy),
        p,
      );
    }

    corner(
      r.topLeft + const Offset(0, len),
      r.topLeft,
      r.topLeft + const Offset(len, 0),
    );
    corner(
      r.topRight + const Offset(-len, 0),
      r.topRight,
      r.topRight + const Offset(0, len),
    );
    corner(
      r.bottomLeft + const Offset(0, -len),
      r.bottomLeft,
      r.bottomLeft + const Offset(len, 0),
    );
    corner(
      r.bottomRight + const Offset(-len, 0),
      r.bottomRight,
      r.bottomRight + const Offset(0, -len),
    );
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.window != window || old.color != color;
}
