import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Outcome of [processCover].
enum CoverProcessStatus {
  /// A usable cover was produced.
  ok,

  /// The image is a catalogue placeholder (Open Library sends a 1x1 GIF when
  /// it has no cover), so there is no cover.
  placeholder,

  /// The bytes are not a decodable image.
  invalid,
}

class CoverProcessResult {
  const CoverProcessResult(
    this.status, {
    this.jpeg,
    this.width = 0,
    this.height = 0,
  });

  final CoverProcessStatus status;

  /// The processed JPEG when [status] is [CoverProcessStatus.ok].
  final Uint8List? jpeg;
  final int width;
  final int height;
}

/// Longest allowed input, to protect memory (decoding multiplies size).
const int kMaxCoverInputBytes = 25 * 1024 * 1024;

/// Anything smaller than this on both sides cannot be a real cover.
const int kMinCoverSide = 16;

/// Decodes [bytes], applies EXIF rotation, resizes to at most [maxWidth]
/// pixels wide (never enlarging), flattens transparency onto white and
/// encodes JPEG at [quality]. Pure Dart; call it off the UI thread.
CoverProcessResult processCover(
  Uint8List bytes, {
  int maxWidth = 360,
  int quality = 85,
}) {
  if (bytes.isEmpty || bytes.length > kMaxCoverInputBytes) {
    return const CoverProcessResult(CoverProcessStatus.invalid);
  }
  final decoded = _decode(bytes);
  if (decoded == null) {
    return const CoverProcessResult(CoverProcessStatus.invalid);
  }
  if (decoded.width < kMinCoverSide && decoded.height < kMinCoverSide) {
    return const CoverProcessResult(CoverProcessStatus.placeholder);
  }

  var image = img.bakeOrientation(decoded);
  if (image.hasAlpha) {
    final flat = img.Image(width: image.width, height: image.height);
    img.fill(flat, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(flat, image);
    image = flat;
  }
  if (image.width > maxWidth) {
    image = img.copyResize(
      image,
      width: maxWidth,
      interpolation: img.Interpolation.average,
    );
  }
  final jpeg = Uint8List.fromList(img.encodeJpg(image, quality: quality));
  return CoverProcessResult(
    CoverProcessStatus.ok,
    jpeg: jpeg,
    width: image.width,
    height: image.height,
  );
}

img.Image? _decode(Uint8List bytes) {
  try {
    return img.decodeImage(bytes);
  } on Object {
    // The decoder throws on truncated or corrupt data.
    return null;
  }
}

/// [processCover] with default settings, shaped for `compute`.
CoverProcessResult processCoverDefault(Uint8List bytes) => processCover(bytes);
