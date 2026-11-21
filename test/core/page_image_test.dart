import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:kitabkhana/core/image/page_image.dart';

import '../helpers/test_images.dart';

img.Image decode(List<int> bytes) =>
    img.decodeJpg(bytes is Uint8List ? bytes : Uint8List.fromList(bytes))!;

void main() {
  final src = jpegBytes(200, 100);

  test('no change keeps the size', () {
    final out = decode(rotateAndCrop(PageEdit(src, 0, CropRect.full)));
    expect((out.width, out.height), (200, 100));
  });

  test('quarter turns swap the sides; four is a full turn; negative works', () {
    for (final (turns, w, h) in <(int, int, int)>[
      (1, 100, 200),
      (2, 200, 100),
      (3, 100, 200),
      (4, 200, 100),
      (-1, 100, 200),
    ]) {
      final out = decode(rotateAndCrop(PageEdit(src, turns, CropRect.full)));
      expect((out.width, out.height), (w, h), reason: 'turns $turns');
    }
  });

  test('crops to the fractions of the rotated image', () {
    final out = decode(
      rotateAndCrop(PageEdit(src, 0, const CropRect(0.25, 0.5, 0.75, 1))),
    );
    expect((out.width, out.height), (100, 50));
    // Rotated first, so the same fractions apply to 100x200.
    final r = decode(
      rotateAndCrop(PageEdit(src, 1, const CropRect(0, 0, 1, 0.5))),
    );
    expect((r.width, r.height), (100, 100));
  });

  test('degenerate or out-of-range crops still give a valid image', () {
    final out = decode(
      rotateAndCrop(PageEdit(src, 0, const CropRect(0.99, 0.99, 1.4, 1.4))),
    );
    expect(out.width, greaterThanOrEqualTo(1));
    expect(out.height, greaterThanOrEqualTo(1));
  });

  test('big photos are scaled down to the limit', () {
    final out = decode(
      rotateAndCrop(PageEdit(jpegBytes(3000, 1500), 0, CropRect.full)),
    );
    expect(out.width, pageMaxSide);
    expect(out.height, 1000);
  });

  test('something that is not an image is a FormatException', () {
    expect(
      () => rotateAndCrop(
        PageEdit(Uint8List.fromList(<int>[1, 2, 3]), 0, CropRect.full),
      ),
      throwsFormatException,
    );
  });
}
