import 'dart:typed_data';

import '../../core/failure.dart';
import '../../core/result.dart';
import 'ocr_service.dart';

/// The web has no on-device reader; quotes are typed instead.
class WebOcrService implements OcrService {
  const WebOcrService();

  @override
  bool get isSupported => false;

  @override
  List<OcrScript> get scripts => const <OcrScript>[];

  @override
  Future<Result<List<OcrLine>>> recognise(
    Uint8List image, {
    OcrScript script = OcrScript.latin,
  }) async => const Err(UnsupportedOnPlatformFailure('ocr'));
}
