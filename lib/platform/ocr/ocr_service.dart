import 'dart:typed_data';

import '../../core/result.dart';

/// One line of text found in a photo, top to bottom.
final class OcrLine {
  const OcrLine(this.text);

  final String text;

  @override
  bool operator ==(Object other) => other is OcrLine && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'OcrLine($text)';
}

/// The scripts text can be read in. Devanagari (Hindi, Marathi, Nepali,
/// Sanskrit) also reads Latin letters mixed in.
enum OcrScript { latin, devanagari }

/// Reads text from a photo of a page, on the device.
abstract interface class OcrService {
  /// False where there is no on-device reader (the web); callers then go
  /// straight to typing.
  bool get isSupported;

  /// The scripts this device can read, Latin first. Empty when unsupported.
  List<OcrScript> get scripts;

  /// The lines of text in [image] (any common image format), in reading
  /// order. An image with no text gives an empty list, not an error.
  /// Anything written to disk along the way is deleted before returning.
  Future<Result<List<OcrLine>>> recognise(
    Uint8List image, {
    OcrScript script = OcrScript.latin,
  });
}
