import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// A test image with a visible gradient so JPEG output is non-trivial.
img.Image makeImage(int w, int h, {int channels = 3}) {
  final image = img.Image(width: w, height: h, numChannels: channels);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      image.setPixelRgb(x, y, (x * 255) ~/ w, (y * 255) ~/ h, 128);
    }
  }
  return image;
}

Uint8List jpegBytes(int w, int h, {int quality = 95}) =>
    Uint8List.fromList(img.encodeJpg(makeImage(w, h), quality: quality));

Uint8List pngBytes(int w, int h) =>
    Uint8List.fromList(img.encodePng(makeImage(w, h)));

/// A real 1x1 GIF, like the placeholder Open Library serves for no cover.
Uint8List placeholderGif() =>
    Uint8List.fromList(img.encodeGif(img.Image(width: 1, height: 1)));
