import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/ui/gallery/dev_gallery_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  for (final scale in <double>[1, 2]) {
    testWidgets('gallery scrolls without overflow at 320dp, ${scale}x text', (
      t,
    ) async {
      await pumpThemed(
        t,
        const DevGalleryScreen(),
        size: const Size(320, 640),
        textScale: scale,
        scaffold: false,
      );
      for (var i = 0; i < 40; i++) {
        await t.drag(find.byType(ListView).first, const Offset(0, -400));
        await t.pump(const Duration(milliseconds: 50));
      }
      expect(t.takeException(), isNull);
    });
  }
}
