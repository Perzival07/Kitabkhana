import 'dart:typed_data';

import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/platform/ocr/ocr_service.dart';

/// An [OcrService] that returns canned lines and remembers what it was given.
class FakeOcrService implements OcrService {
  FakeOcrService({this.supported = true, this.lines = const <String>[]});

  final bool supported;
  List<String> lines;
  bool fail = false;
  final List<Uint8List> seen = <Uint8List>[];

  @override
  bool get isSupported => supported;

  @override
  Future<Result<List<OcrLine>>> recognise(
    Uint8List image, {
    OcrScript script = OcrScript.latin,
  }) async {
    seen.add(image);
    if (fail) return const Err(UnexpectedFailure('boom'));
    return Ok(<OcrLine>[for (final l in lines) OcrLine(l)]);
  }
}
