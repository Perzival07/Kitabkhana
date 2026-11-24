import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../app/theme/tokens.dart';

/// The words on a "Year in review" card, already in the reader's language.
final class YearReviewCardData {
  const YearReviewCardData({
    required this.title,
    required this.bigNumber,
    required this.bigLabel,
    required this.figures,
    required this.monthInitials,
    required this.perMonth,
    required this.lines,
    required this.footer,
  });

  /// "My 2026 in books".
  final String title;
  final String bigNumber;

  /// "books finished".
  final String bigLabel;

  /// Up to three (value, label) pairs: pages, longest streak, goal.
  final List<(String, String)> figures;

  /// Twelve one-letter month labels.
  final List<String> monthInitials;
  final List<int> perMonth;

  /// Up to three (label, value) lines: top genre, author, longest book.
  final List<(String, String)> lines;

  /// "Made with Kitabkhana".
  final String footer;
}

/// The logical size of the card (9:16, story-shaped); exported at 3x.
const Size yearReviewCardSize = Size(360, 640);

/// Paper, a big terracotta number, a row of figures, a month chart and a few
/// highlights. Always the light "paper" look, like the quote card.
class YearReviewCardPainter extends CustomPainter {
  const YearReviewCardPainter(this.data);

  final YearReviewCardData data;

  static const double _m = 32;

  TextPainter _text(
    String text, {
    required double size,
    String family = 'Inter',
    FontWeight weight = FontWeight.w400,
    Color color = KColors.paperText,
    double? maxWidth,
    int maxLines = 1,
    TextAlign align = TextAlign.left,
    double height = 1.2,
    double spacing = 0,
  }) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: spacing,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: align,
    maxLines: maxLines,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth ?? double.infinity);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final inner = w - 2 * _m;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = KColors.paperBackground,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(14, 14, w - 28, h - 28),
        const Radius.circular(16),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = KColors.paperOutline,
    );

    var y = 44.0;
    final mark = _text(
      'KITABKHANA',
      size: 11,
      weight: FontWeight.w600,
      color: KColors.paperPrimary,
      spacing: 2.4,
    );
    mark.paint(canvas, Offset(_m, y));
    y += mark.height + 10;

    final title = _text(
      data.title,
      size: 28,
      family: 'Fraunces',
      weight: FontWeight.w600,
      maxWidth: inner,
      maxLines: 2,
    );
    title.paint(canvas, Offset(_m, y));
    y += title.height + 22;

    // The big number.
    final big = _text(
      data.bigNumber,
      size: 96,
      family: 'Fraunces',
      weight: FontWeight.w700,
      color: KColors.paperPrimary,
      height: 1,
    );
    big.paint(canvas, Offset(_m - 4, y));
    y += big.height + 4;
    final bigLabel = _text(
      data.bigLabel,
      size: 18,
      weight: FontWeight.w500,
      maxWidth: inner,
    );
    bigLabel.paint(canvas, Offset(_m, y));
    y += bigLabel.height + 20;

    // Figures in a row.
    if (data.figures.isNotEmpty) {
      final n = data.figures.length;
      final cell = inner / n;
      var tallest = 0.0;
      for (final (i, (value, label)) in data.figures.indexed) {
        final x = _m + i * cell;
        final v = _text(
          value,
          size: 22,
          family: 'Fraunces',
          weight: FontWeight.w600,
          maxWidth: cell - 8,
        );
        final l = _text(
          label,
          size: 11,
          color: KColors.paperMuted,
          maxWidth: cell - 8,
          maxLines: 2,
        );
        v.paint(canvas, Offset(x, y));
        l.paint(canvas, Offset(x, y + v.height + 2));
        tallest = math.max(tallest, v.height + 2 + l.height);
      }
      y += tallest + 20;
    }

    // Books per month.
    const chartH = 64.0;
    final top = data.perMonth.fold<int>(0, math.max);
    final slot = inner / 12;
    final barW = slot * 0.56;
    for (var i = 0; i < 12; i++) {
      final v = i < data.perMonth.length ? data.perMonth[i] : 0;
      final x = _m + i * slot + (slot - barW) / 2;
      final track = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barW, chartH),
        const Radius.circular(4),
      );
      canvas.drawRRect(track, Paint()..color = KColors.paperSurfaceVariant);
      if (v > 0 && top > 0) {
        final bh = math.max(6.0, chartH * v / top);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y + chartH - bh, barW, bh),
            const Radius.circular(4),
          ),
          Paint()..color = KColors.paperPrimary,
        );
      }
      final m = _text(
        i < data.monthInitials.length ? data.monthInitials[i] : '',
        size: 10,
        color: KColors.paperMuted,
        maxWidth: slot,
        align: TextAlign.center,
      );
      m.paint(
        canvas,
        Offset(_m + i * slot + (slot - m.width) / 2, y + chartH + 6),
      );
    }
    y += chartH + 26;

    // Highlights.
    for (final (label, value) in data.lines) {
      final l = _text(
        label,
        size: 11,
        color: KColors.paperMuted,
        maxWidth: inner,
      );
      final v = _text(
        value,
        size: 16,
        family: 'Fraunces',
        weight: FontWeight.w600,
        maxWidth: inner,
      );
      if (y + l.height + v.height > h - 62) break;
      l.paint(canvas, Offset(_m, y));
      v.paint(canvas, Offset(_m, y + l.height + 1));
      y += l.height + v.height + 10;
    }

    final footer = _text(
      data.footer,
      size: 12,
      family: 'Fraunces',
      weight: FontWeight.w600,
      color: KColors.paperMuted,
      maxWidth: inner,
    );
    footer.paint(canvas, Offset(_m, h - 40 - footer.height));
  }

  @override
  bool shouldRepaint(YearReviewCardPainter old) => old.data != data;
}

/// The card as a widget (for the preview).
class YearReviewCard extends StatelessWidget {
  const YearReviewCard({super.key, required this.data});

  final YearReviewCardData data;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: yearReviewCardSize.aspectRatio,
    child: FittedBox(
      child: SizedBox.fromSize(
        size: yearReviewCardSize,
        child: CustomPaint(painter: YearReviewCardPainter(data)),
      ),
    ),
  );
}

/// Renders the card to PNG bytes (1080 x 1920 at the default ratio).
Future<Uint8List> renderYearReviewPng(
  YearReviewCardData data, {
  double pixelRatio = 3,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  YearReviewCardPainter(data).paint(canvas, yearReviewCardSize);
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (yearReviewCardSize.width * pixelRatio).round(),
    (yearReviewCardSize.height * pixelRatio).round(),
  );
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  } finally {
    image.dispose();
    picture.dispose();
  }
}
