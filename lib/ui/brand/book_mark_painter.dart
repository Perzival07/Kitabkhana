import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../app/theme/tokens.dart';

/// Where the mark is drawn: the whole icon, or only the glyph.
enum BrandLayer {
  /// Terracotta tile with the ivory book on it (iOS, web, store listings).
  full,

  /// Just the ivory book on a transparent ground (Android adaptive icon
  /// foreground, the splash screen).
  glyph,

  /// The book as one solid shape with the spine and bookmark cut out, for
  /// Android's themed (monochrome) icon, which tints it itself.
  monochrome,
}

/// The Kitabkhana mark: an open book with a bookmark, drawn with paths so it
/// stays sharp at any size (down to a 48px launcher icon) and is editable here
/// rather than in a binary file. `test/tool/generate_brand_assets_test.dart`
/// writes the PNGs the stores and platforms need from this painter.
class BookMarkPainter extends CustomPainter {
  const BookMarkPainter({
    this.layer = BrandLayer.full,
    this.glyphScale = 1,
    this.page = KColors.coverInk,
    this.tile = KColors.paperPrimary,
    this.tileDeep = KColors.paperPrimaryStrong,
    this.rounded = false,
  });

  final BrandLayer layer;

  /// 1 fills the usual book area; the adaptive icon uses ~0.74 so the book
  /// stays inside the 66% safe zone that launchers may crop to.
  final double glyphScale;

  /// The ivory of the pages.
  final Color page;

  /// The terracotta tile and its darker edge.
  final Color tile;
  final Color tileDeep;

  /// Round the tile's corners (web favicon, previews). Off for platform icons,
  /// which are masked by the system.
  final bool rounded;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.save();
    canvas.scale(s);

    if (layer == BrandLayer.full) {
      const rect = Rect.fromLTWH(0, 0, 1, 1);
      final paint = Paint()
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(1, 1), <Color>[
          tile,
          tileDeep,
        ]);
      if (rounded) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(0.22)),
          paint,
        );
      } else {
        canvas.drawRect(rect, paint);
      }
    }

    // Everything below is in a 1x1 box centred on (0.5, 0.5).
    canvas
      ..translate(0.5, 0.5)
      ..scale(glyphScale)
      ..translate(-0.5, -0.5);

    final left = Path()
      ..moveTo(0.5, 0.345)
      ..cubicTo(0.43, 0.285, 0.32, 0.275, 0.205, 0.315)
      ..lineTo(0.205, 0.705)
      ..cubicTo(0.32, 0.665, 0.43, 0.675, 0.5, 0.735)
      ..close();
    final right = Path()
      ..moveTo(0.5, 0.345)
      ..cubicTo(0.57, 0.285, 0.68, 0.275, 0.795, 0.315)
      ..lineTo(0.795, 0.705)
      ..cubicTo(0.68, 0.665, 0.57, 0.675, 0.5, 0.735)
      ..close();

    final mono = layer == BrandLayer.monochrome;
    final ink = mono ? const Color(0xFFFFFFFF) : page;

    if (!mono) {
      // A soft shadow under the book lifts it off the tile.
      canvas.drawPath(
        Path.combine(
          PathOperation.union,
          left,
          right,
        ).shift(const Offset(0, 0.018)),
        Paint()
          ..color = const Color(0x33000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.012),
      );
    }

    final fill = Paint()..color = ink;
    if (!mono) {
      canvas
        ..drawPath(left, fill)
        ..drawPath(right, fill);
    }

    // The spine: a thin line between the pages, cut out of the shape.
    final cut = Paint()
      ..color = mono ? const Color(0x00000000) : tile
      ..strokeWidth = 0.014
      ..strokeCap = StrokeCap.butt
      ..blendMode = mono ? BlendMode.clear : BlendMode.srcOver;
    // The bookmark: a ribbon with a notched end hanging from the right page.
    final ribbon = Path()
      ..moveTo(0.605, 0.312)
      ..lineTo(0.675, 0.318)
      ..lineTo(0.675, 0.545)
      ..lineTo(0.64, 0.51)
      ..lineTo(0.605, 0.545)
      ..close();

    if (mono) {
      canvas.saveLayer(const Rect.fromLTWH(0, 0, 1, 1), Paint());
      canvas
        ..drawPath(left, fill)
        ..drawPath(right, fill)
        ..drawLine(const Offset(0.5, 0.34), const Offset(0.5, 0.74), cut)
        ..drawPath(ribbon, Paint()..blendMode = BlendMode.clear);
      canvas.restore();
    } else {
      canvas
        ..drawLine(const Offset(0.5, 0.34), const Offset(0.5, 0.74), cut)
        ..drawPath(ribbon, Paint()..color = tileDeep);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(BookMarkPainter old) =>
      old.layer != layer ||
      old.glyphScale != glyphScale ||
      old.page != page ||
      old.tile != tile ||
      old.tileDeep != tileDeep ||
      old.rounded != rounded;
}
