import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/ui/brand/book_mark_painter.dart';

/// Protects the app icon design: a change to the painter shows up here.
void main() {
  testWidgets('app icon layers', (t) async {
    t.view
      ..physicalSize = const Size(720, 260)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    Widget cell(BookMarkPainter p, Color bg) => Container(
      width: 200,
      height: 200,
      color: bg,
      child: CustomPaint(painter: p),
    );
    await t.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: const ValueKey('icons'),
          child: Container(
            color: const Color(0xFFEEEEEE),
            padding: const EdgeInsets.all(20),
            child: Row(
              spacing: 20,
              children: <Widget>[
                cell(
                  const BookMarkPainter(rounded: true),
                  const Color(0x00000000),
                ),
                cell(
                  const BookMarkPainter(layer: BrandLayer.monochrome),
                  const Color(0xFF3C3C46),
                ),
                cell(
                  const BookMarkPainter(layer: BrandLayer.glyph),
                  const Color(0xFFB4532A),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byKey(const ValueKey('icons')),
      matchesGoldenFile('goldens/brand_mark.png'),
    );
  }, tags: 'golden');
}
