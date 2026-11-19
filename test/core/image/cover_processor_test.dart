import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:kitabkhana/core/image/cover_processor.dart';

import '../../helpers/test_images.dart';

img.Image decode(Uint8List bytes) => img.decodeImage(bytes)!;

void main() {
  group('resize', () {
    test('a large portrait photo becomes 360px wide, keeping the ratio', () {
      final input = jpegBytes(1200, 1800);
      final r = processCover(input);
      expect(r.status, CoverProcessStatus.ok);
      expect(r.width, 360);
      expect(r.height, 540);
      final out = decode(r.jpeg!);
      expect([out.width, out.height], [360, 540]);
      expect(r.jpeg!.length, lessThan(input.length));
    });

    test('small images are never enlarged', () {
      final r = processCover(jpegBytes(200, 300));
      expect([r.width, r.height], [200, 300]);
    });

    test('exactly 360 wide is left alone', () {
      final r = processCover(jpegBytes(360, 540));
      expect([r.width, r.height], [360, 540]);
    });

    test('a landscape image is limited by width', () {
      final r = processCover(jpegBytes(1200, 600));
      expect([r.width, r.height], [360, 180]);
    });

    test('maxWidth is configurable', () {
      final r = processCover(jpegBytes(1000, 1000), maxWidth: 100);
      expect([r.width, r.height], [100, 100]);
    });

    test('PNG input is converted to JPEG', () {
      final r = processCover(pngBytes(800, 1200));
      expect(r.status, CoverProcessStatus.ok);
      // JPEG magic number.
      expect(r.jpeg!.sublist(0, 3), [0xFF, 0xD8, 0xFF]);
    });

    test('lower quality gives a smaller file', () {
      final bytes = jpegBytes(800, 1200);
      final hi = processCover(bytes, quality: 95).jpeg!.length;
      final lo = processCover(bytes, quality: 30).jpeg!.length;
      expect(lo, lessThan(hi));
    });
  });

  group('placeholders', () {
    test('a 1x1 GIF is treated as no cover', () {
      expect(
        processCover(placeholderGif()).status,
        CoverProcessStatus.placeholder,
      );
    });

    test('any image smaller than 16px on both sides is a placeholder', () {
      final tiny = Uint8List.fromList(img.encodePng(makeImage(10, 12)));
      expect(processCover(tiny).status, CoverProcessStatus.placeholder);
    });

    test('a real small cover is not a placeholder', () {
      expect(processCover(jpegBytes(120, 180)).status, CoverProcessStatus.ok);
    });
  });

  group('invalid input', () {
    test('empty, garbage and truncated data', () {
      expect(processCover(Uint8List(0)).status, CoverProcessStatus.invalid);
      expect(
        processCover(
          Uint8List.fromList(List<int>.generate(500, (i) => i % 251)),
        ).status,
        CoverProcessStatus.invalid,
      );
      final truncated = jpegBytes(600, 900).sublist(0, 40);
      expect(processCover(truncated).status, CoverProcessStatus.invalid);
    });

    test('HTML error pages are not images', () {
      final html = Uint8List.fromList('<html>Not found</html>'.codeUnits);
      expect(processCover(html).status, CoverProcessStatus.invalid);
    });

    test('inputs over the size limit are rejected', () {
      final big = Uint8List(kMaxCoverInputBytes + 1);
      expect(processCover(big).status, CoverProcessStatus.invalid);
    });
  });

  group('colour and orientation', () {
    test('transparent PNGs are flattened onto white', () {
      final rgba = img.Image(width: 400, height: 600, numChannels: 4);
      img.fill(rgba, color: img.ColorRgba8(0, 0, 0, 0)); // fully transparent
      final r = processCover(Uint8List.fromList(img.encodePng(rgba)));
      final out = decode(r.jpeg!);
      final p = out.getPixel(10, 10);
      expect(p.r, greaterThan(240));
      expect(p.g, greaterThan(240));
      expect(p.b, greaterThan(240));
    });

    test('EXIF rotation is applied (phone photos come out upright)', () {
      final photo = makeImage(400, 200);
      photo.exif.imageIfd.orientation = 6; // rotate 90 degrees clockwise
      final bytes = Uint8List.fromList(img.encodeJpg(photo));
      final r = processCover(bytes);
      expect([r.width, r.height], [200, 400]);
    });
  });

  test('processCoverDefault uses the default settings', () {
    final r = processCoverDefault(jpegBytes(900, 900));
    expect(r.width, 360);
  });
}
