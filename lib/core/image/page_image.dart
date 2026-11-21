import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// A crop rectangle as fractions of the (already rotated) image, each 0..1.
final class CropRect {
  const CropRect(this.left, this.top, this.right, this.bottom);

  static const full = CropRect(0, 0, 1, 1);

  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  bool operator ==(Object other) =>
      other is CropRect &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);
}

/// Arguments for [rotateAndCrop], bundled so it can run in an isolate.
final class PageEdit {
  const PageEdit(this.bytes, this.quarterTurns, this.crop);

  final Uint8List bytes;

  /// Clockwise quarter turns, any integer.
  final int quarterTurns;
  final CropRect crop;
}

/// Longest side of an edited photo. Text stays readable well below the
/// camera's native size, and OCR is faster.
const int pageMaxSide = 2000;

/// Applies the photo's EXIF orientation, then rotates clockwise by
/// `quarterTurns` quarter turns, crops to `crop` and returns JPEG bytes.
///
/// Top-level and free of Flutter types so it can run via `compute`.
/// Throws a [FormatException] when [PageEdit.bytes] is not a readable image.
Uint8List rotateAndCrop(PageEdit edit) {
  final decoded = img.decodeImage(edit.bytes);
  if (decoded == null) throw const FormatException('Not an image');
  var image = img.bakeOrientation(decoded);

  final turns = ((edit.quarterTurns % 4) + 4) % 4;
  if (turns != 0) image = img.copyRotate(image, angle: turns * 90);

  final c = edit.crop;
  final x = (c.left * image.width).round().clamp(0, image.width - 1);
  final y = (c.top * image.height).round().clamp(0, image.height - 1);
  final w = ((c.right - c.left) * image.width).round().clamp(
    1,
    image.width - x,
  );
  final h = ((c.bottom - c.top) * image.height).round().clamp(
    1,
    image.height - y,
  );
  if (x != 0 || y != 0 || w != image.width || h != image.height) {
    image = img.copyCrop(image, x: x, y: y, width: w, height: h);
  }

  final longest = image.width > image.height ? image.width : image.height;
  if (longest > pageMaxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: pageMaxSide)
        : img.copyResize(image, height: pageMaxSide);
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}
