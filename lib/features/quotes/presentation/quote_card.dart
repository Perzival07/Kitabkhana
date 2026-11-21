import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../app/theme/tokens.dart';

/// What a shared quote card shows.
final class QuoteCardData {
  const QuoteCardData({required this.body, required this.attribution});

  final String body;

  /// For example `Middlemarch, p. 42`; shown after a dash.
  final String attribution;
}

/// The logical size of the card; exported at a multiple of it.
const Size quoteCardSize = Size(360, 450);

/// Draws a 4:5 quote card: paper with a faint grain, a large opening mark,
/// the quote in Fraunces italic (sized to fit), the source in Inter and a
/// small Kitabkhana wordmark. Always the light "paper" look so a shared
/// image reads the same wherever it lands.
class QuoteCardPainter extends CustomPainter {
  const QuoteCardPainter(this.data);

  final QuoteCardData data;

  static const double _margin = 36;
  static const double _maxFont = 30;
  static const double _minFont = 13;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = KColors.paperBackground,
    );
    _grain(canvas, size);

    // A thin inset frame.
    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(14, 14, w - 28, h - 28),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = KColors.paperOutline,
    );

    // Opening mark.
    final mark = TextPainter(
      text: const TextSpan(
        text: '“',
        style: TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 96,
          height: 1,
          fontWeight: FontWeight.w700,
          color: KColors.paperPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    mark.paint(canvas, const Offset(_margin - 4, 34));

    // Attribution and wordmark sit at the bottom; the quote fills between.
    final source = TextPainter(
      text: TextSpan(
        text: '— ${data.attribution}',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.3,
          color: KColors.paperText,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: w - 2 * _margin);
    final wordmark = TextPainter(
      text: const TextSpan(
        text: 'Kitabkhana',
        style: TextStyle(
          fontFamily: 'Fraunces',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: KColors.paperMuted,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final wordmarkY = h - 34 - wordmark.height;
    final sourceY = wordmarkY - 18 - source.height;
    const top = 34 + 62.0;
    final avail = Rect.fromLTRB(_margin, top, w - _margin, sourceY - 16);

    final body = _fit(data.body, avail.width, avail.height);
    body.paint(canvas, Offset(avail.left, avail.top));
    source.paint(canvas, Offset(_margin, sourceY));
    wordmark.paint(canvas, Offset(_margin, wordmarkY));
  }

  /// The largest italic size that fits; ellipsised at the smallest size.
  TextPainter _fit(String text, double width, double height) {
    TextPainter at(double size, {int? maxLines}) => TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Fraunces',
          fontStyle: FontStyle.italic,
          fontSize: size,
          height: 1.32,
          color: KColors.paperText,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '…',
    )..layout(maxWidth: width);

    for (var size = _maxFont; size >= _minFont; size -= 1) {
      final p = at(size);
      if (p.height <= height) return p;
    }
    const lineHeight = _minFont * 1.32;
    return at(_minFont, maxLines: math.max(1, (height / lineHeight).floor()));
  }

  /// Faint, repeatable speckle so the paper is not flat. Seeded, so the same
  /// card always renders the same.
  void _grain(Canvas canvas, Size size) {
    final rng = math.Random(7);
    final paint = Paint();
    final count = (size.width * size.height / 14).round();
    for (var i = 0; i < count; i++) {
      final dark = rng.nextBool();
      paint.color = (dark ? KColors.shade : KColors.highlight).withValues(
        alpha: dark ? 0.035 : 0.5,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          rng.nextDouble() * size.width,
          rng.nextDouble() * size.height,
          1,
          1,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(QuoteCardPainter old) =>
      old.data.body != data.body || old.data.attribution != data.attribution;
}

/// The card as an on-screen 4:5 widget.
class QuoteCardPreview extends StatelessWidget {
  const QuoteCardPreview({required this.data, super.key});

  final QuoteCardData data;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: quoteCardSize.width / quoteCardSize.height,
    child: LayoutBuilder(
      builder: (context, c) => FittedBox(
        child: SizedBox.fromSize(
          size: quoteCardSize,
          child: CustomPaint(painter: QuoteCardPainter(data)),
        ),
      ),
    ),
  );
}

/// Renders the card to PNG bytes (1080 x 1350 at the default ratio).
Future<Uint8List> renderQuoteCardPng(
  QuoteCardData data, {
  double pixelRatio = 3,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  QuoteCardPainter(data).paint(canvas, quoteCardSize);
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (quoteCardSize.width * pixelRatio).round(),
    (quoteCardSize.height * pixelRatio).round(),
  );
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  } finally {
    image.dispose();
    picture.dispose();
  }
}
