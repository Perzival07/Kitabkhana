import 'package:flutter/material.dart';

/// The line illustrations available to [KEmptyState].
enum KIllustration {
  emptyShelf,
  openBook,
  scannerFrame,
  quoteMarks,

  /// A phone holding a book, with a lock: your books stay on your device.
  privateShelf,
}

/// Draws a [KIllustration] with simple strokes on a 160x160 canvas.
class KIllustrationPainter extends CustomPainter {
  const KIllustrationPainter({required this.kind, required this.color});

  final KIllustration kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 160, size.height / 160);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (kind) {
      case KIllustration.emptyShelf:
        _shelf(canvas, stroke);
      case KIllustration.openBook:
        _book(canvas, stroke);
      case KIllustration.scannerFrame:
        _scanner(canvas, stroke);
      case KIllustration.quoteMarks:
        _quotes(canvas, stroke);
      case KIllustration.privateShelf:
        _private(canvas, stroke);
    }
    canvas.restore();
  }

  void _shelf(Canvas c, Paint p) {
    c.drawLine(const Offset(14, 128), const Offset(146, 128), p);
    c.drawLine(const Offset(22, 128), const Offset(22, 140), p);
    c.drawLine(const Offset(138, 128), const Offset(138, 140), p);
    // Books standing.
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(34, 62, 16, 66),
        const Radius.circular(3),
      ),
      p,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(54, 48, 20, 80),
        const Radius.circular(3),
      ),
      p,
    );
    c.drawLine(const Offset(54, 64), const Offset(74, 64), p);
    c.drawLine(const Offset(54, 112), const Offset(74, 112), p);
    // Leaning book.
    c.save();
    c.translate(112, 128);
    c.rotate(0.28);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -72, 18, 72),
        const Radius.circular(3),
      ),
      p,
    );
    c.restore();
    // A little sparkle for "room to grow".
    c.drawLine(const Offset(120, 28), const Offset(120, 44), p);
    c.drawLine(const Offset(112, 36), const Offset(128, 36), p);
  }

  void _book(Canvas c, Paint p) {
    final left = Path()
      ..moveTo(80, 52)
      ..cubicTo(64, 40, 40, 40, 22, 48)
      ..lineTo(22, 120)
      ..cubicTo(40, 112, 64, 112, 80, 124)
      ..close();
    final right = Path()
      ..moveTo(80, 52)
      ..cubicTo(96, 40, 120, 40, 138, 48)
      ..lineTo(138, 120)
      ..cubicTo(120, 112, 96, 112, 80, 124)
      ..close();
    c.drawPath(left, p);
    c.drawPath(right, p);
    for (final y in <double>[64, 78, 92]) {
      c.drawLine(Offset(34, y - 4), Offset(66, y), p);
      c.drawLine(Offset(94, y), Offset(126, y - 4), p);
    }
  }

  void _scanner(Canvas c, Paint p) {
    const a = 28.0;
    const b = 132.0;
    const l = 22.0;
    for (final corner in <(double, double, double, double)>[
      (a, a, 1, 1),
      (b, a, -1, 1),
      (a, b, 1, -1),
      (b, b, -1, -1),
    ]) {
      final (x, y, dx, dy) = corner;
      c.drawPath(
        Path()
          ..moveTo(x, y + dy * l)
          ..lineTo(x, y)
          ..lineTo(x + dx * l, y),
        p,
      );
    }
    // Barcode bars.
    var x = 50.0;
    for (final w in <double>[2, 5, 2, 3, 6, 2, 4, 2, 5]) {
      c.drawLine(Offset(x, 56), Offset(x, 104), p..strokeWidth = w * 0.6 + 1.5);
      x += w + 5;
    }
    p.strokeWidth = 2.5;
    c.drawLine(const Offset(36, 80), const Offset(124, 80), p);
  }

  void _quotes(Canvas c, Paint p) {
    final fill = Paint()
      ..color = p.color
      ..style = PaintingStyle.fill;
    void mark(double x) {
      c.drawCircle(Offset(x + 16, 70), 15, fill);
      c.drawPath(
        Path()
          ..moveTo(x + 30, 70)
          ..cubicTo(x + 30, 94, x + 20, 108, x + 2, 116),
        p..strokeWidth = 6,
      );
    }

    mark(22);
    mark(88);
    p.strokeWidth = 2.5;
    c.drawLine(const Offset(40, 134), const Offset(120, 134), p);
  }

  void _private(Canvas c, Paint p) {
    // The phone.
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(44, 14, 72, 132),
        const Radius.circular(14),
      ),
      p,
    );
    c.drawLine(const Offset(70, 24), const Offset(90, 24), p);
    // An open book on its screen.
    final book = Path()
      ..moveTo(80, 74)
      ..cubicTo(72, 66, 60, 64, 54, 66)
      ..lineTo(54, 100)
      ..cubicTo(60, 98, 72, 100, 80, 108)
      ..cubicTo(88, 100, 100, 98, 106, 100)
      ..lineTo(106, 66)
      ..cubicTo(100, 64, 88, 66, 80, 74)
      ..close();
    c
      ..drawPath(book, p)
      ..drawLine(const Offset(80, 74), const Offset(80, 108), p);
    // A little padlock hanging off the phone's corner.
    final fill = Paint()
      ..color = p.color
      ..style = PaintingStyle.fill;
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(104, 112, 32, 26),
        const Radius.circular(5),
      ),
      fill,
    );
    c.drawArc(const Rect.fromLTWH(110, 96, 20, 24), 3.14159, 3.14159, false, p);
    c.drawCircle(
      const Offset(120, 124),
      3,
      Paint()..color = const Color(0xFFFFFFFF),
    );
  }

  @override
  bool shouldRepaint(KIllustrationPainter old) =>
      old.kind != kind || old.color != color;
}
