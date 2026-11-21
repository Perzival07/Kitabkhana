import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Shares text or an image through the system share sheet (a download on the
/// web). Behind an interface so tests do not open real sheets.
abstract interface class ShareService {
  Future<void> shareText(String text);

  Future<void> shareImage(Uint8List png, {required String name, String? text});
}

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
}
