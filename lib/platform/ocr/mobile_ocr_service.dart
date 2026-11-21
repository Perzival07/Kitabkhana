import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/failure.dart';
import '../../core/result.dart';
import 'ocr_service.dart';

/// Reads text with Google ML Kit, fully on the device.
///
/// ML Kit reads from a file, so the photo is written to a temporary file for
/// the duration of the call and always deleted afterwards.
class MobileOcrService implements OcrService {
  MobileOcrService({
    Future<Directory> Function()? tempDir,
    TextRecognizer Function(OcrScript script)? recogniser,
  }) : _tempDir = tempDir ?? getTemporaryDirectory,
       _recogniser = recogniser ?? _defaultRecogniser;

  final Future<Directory> Function() _tempDir;
  final TextRecognizer Function(OcrScript script) _recogniser;

  static TextRecognizer _defaultRecogniser(OcrScript script) =>
      switch (script) {
        OcrScript.latin => TextRecognizer(script: TextRecognitionScript.latin),
      };

  @override
  bool get isSupported => true;

  @override
  Future<Result<List<OcrLine>>> recognise(
    Uint8List image, {
    OcrScript script = OcrScript.latin,
  }) async {
    File? file;
    TextRecognizer? recogniser;
    try {
      final dir = await _tempDir();
      file = File(
        '${dir.path}/ocr_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(image, flush: true);
      recogniser = _recogniser(script);
      final text = await recogniser.processImage(
        InputImage.fromFilePath(file.path),
      );
      return Ok(<OcrLine>[
        for (final block in text.blocks)
          for (final line in block.lines)
            if (line.text.trim().isNotEmpty) OcrLine(line.text),
      ]);
    } on Object catch (e, s) {
      return Err(UnexpectedFailure(e, s));
    } finally {
      await recogniser?.close();
      try {
        if (file != null && file.existsSync()) await file.delete();
      } on Object {
        // Best effort: it is a temp file.
      }
    }
  }
}
