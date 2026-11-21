import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Shares text or an image through the system share sheet (a download on the
/// web). Behind an interface so tests do not open real sheets.
abstract interface class ShareService {
  Future<void> shareText(String text);

  Future<void> shareImage(Uint8List png, {required String name, String? text});

  /// Shares any file (a backup, an export): the share sheet on phones, a
  /// download on the web.
  Future<void> shareFile(
    Uint8List bytes, {
    required String name,
    String? mimeType,
  });

  /// Shares several files at once.
  Future<void> shareFiles(List<ShareableFile> files);
}

/// A file to hand to the share sheet.
typedef ShareableFile = ({Uint8List bytes, String name, String? mimeType});

class SharePlusShareService implements ShareService {
  const SharePlusShareService();

  @override
  Future<void> shareText(String text) =>
      SharePlus.instance.share(ShareParams(text: text));

  @override
  Future<void> shareImage(
    Uint8List png, {
    required String name,
    String? text,
  }) => SharePlus.instance.share(
    ShareParams(
      text: text,
      files: <XFile>[XFile.fromData(png, mimeType: 'image/png', name: name)],
      fileNameOverrides: <String>[name],
    ),
  );

  @override
  Future<void> shareFile(
    Uint8List bytes, {
    required String name,
    String? mimeType,
  }) => SharePlus.instance.share(
    ShareParams(
      files: <XFile>[XFile.fromData(bytes, mimeType: mimeType, name: name)],
      fileNameOverrides: <String>[name],
    ),
  );

  @override
  Future<void> shareFiles(List<ShareableFile> files) =>
      SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            for (final f in files)
              XFile.fromData(f.bytes, mimeType: f.mimeType, name: f.name),
          ],
          fileNameOverrides: <String>[for (final f in files) f.name],
        ),
      );
}
