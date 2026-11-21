import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/tokens.dart';
import 'package:kitabkhana/ui/brand/book_mark_painter.dart';

/// Writes the app icon, splash and web icon PNGs from `BookMarkPainter`.
///
///   GENERATE_ASSETS=1 flutter test test/tool/generate_brand_assets_test.dart
///
/// then `dart run flutter_launcher_icons` and
/// `dart run flutter_native_splash:create` to put them in the platform
/// projects. Skipped in ordinary runs so tests never rewrite the repository.
void main() {
  final generate = Platform.environment['GENERATE_ASSETS'] == '1';

  Future<Uint8List> render(
    BookMarkPainter painter,
    int px, {
    Color? underlay,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    if (underlay != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, px.toDouble(), px.toDouble()),
        Paint()..color = underlay,
      );
    }
    painter.paint(canvas, Size.square(px.toDouble()));
    final image = await recorder.endRecording().toImage(px, px);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  Future<void> write(String path, Uint8List bytes) async {
    final f = File(path);
    f.parent.createSync(recursive: true);
    await f.writeAsBytes(bytes);
  }

  testWidgets('writes the brand PNGs', (t) async {
    await t.runAsync(() async {
      const full = BookMarkPainter();
      const rounded = BookMarkPainter(rounded: true);
      // iOS 1024 icon: opaque, full bleed (the system rounds it).
      await write('assets/brand/icon_1024.png', await render(full, 1024));
      // Store listing and web: rounded tile.
      await write(
        'assets/brand/icon_rounded_512.png',
        await render(rounded, 512),
      );
      // Android adaptive foreground. flutter_launcher_icons insets it by 16%,
      // which is what keeps it inside the 66% safe zone.
      await write(
        'assets/brand/icon_foreground.png',
        await render(const BookMarkPainter(layer: BrandLayer.glyph), 1024),
      );
      // Android themed icon.
      await write(
        'assets/brand/icon_monochrome.png',
        await render(const BookMarkPainter(layer: BrandLayer.monochrome), 1024),
      );
      // Web maskable icons: full bleed with the mark in the safe zone.
      await write(
        'assets/brand/icon_maskable.png',
        await render(const BookMarkPainter(glyphScale: 0.8), 1024),
      );
      // Splash: the book alone, terracotta pages... on ivory the glyph is
      // ivory-on-nothing, so draw it as the tile colour instead.
      await write(
        'assets/brand/splash_light.png',
        await render(
          const BookMarkPainter(
            layer: BrandLayer.glyph,
            page: KColors.paperPrimary,
            tile: KColors.paperBackground,
            tileDeep: KColors.paperPrimaryStrong,
          ),
          512,
        ),
      );
      // Android 12 splash: a 960px canvas whose centre circle (640px) is
      // what shows, so the book is drawn small inside it.
      for (final (name, page, bg) in <(String, Color, Color)>[
        ('splash12_light', KColors.paperPrimary, KColors.paperBackground),
        ('splash12_dark', KColors.lampPrimary, KColors.lampBackground),
      ]) {
        await write(
          'assets/brand/$name.png',
          await render(
            BookMarkPainter(
              layer: BrandLayer.glyph,
              glyphScale: 0.62,
              page: page,
              tile: bg,
              tileDeep: page,
            ),
            960,
          ),
        );
      }
      // Web: the icons the manifest and the page use.
      for (final px in <int>[192, 512]) {
        await write('web/icons/Icon-$px.png', await render(rounded, px));
        await write(
          'web/icons/Icon-maskable-$px.png',
          await render(const BookMarkPainter(glyphScale: 0.8), px),
        );
      }
      await write('web/favicon.png', await render(rounded, 64));
      await write(
        'assets/brand/splash_dark.png',
        await render(
          const BookMarkPainter(
            layer: BrandLayer.glyph,
            page: KColors.lampPrimary,
            tile: KColors.lampBackground,
            tileDeep: KColors.lampPrimaryStrong,
          ),
          512,
        ),
      );
    });
  }, skip: !generate); // Set GENERATE_ASSETS=1 to write the assets.
}
