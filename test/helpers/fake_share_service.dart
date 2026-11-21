import 'dart:typed_data';

import 'package:kitabkhana/platform/share/share_service.dart';

/// Records what would have been shared.
class FakeShareService implements ShareService {
  final List<String> texts = <String>[];
  final List<({Uint8List png, String name})> images =
      <({Uint8List png, String name})>[];

  @override
  Future<void> shareText(String text) async => texts.add(text);

  @override
  Future<void> shareImage(
    Uint8List png, {
    required String name,
    String? text,
  }) async => images.add((png: png, name: name));

  final List<({Uint8List bytes, String name})> files =
      <({Uint8List bytes, String name})>[];

  @override
  Future<void> shareFile(
    Uint8List bytes, {
    required String name,
    String? mimeType,
  }) async => files.add((bytes: bytes, name: name));

  final List<List<ShareableFile>> batches = <List<ShareableFile>>[];

  @override
  Future<void> shareFiles(List<ShareableFile> files) async =>
      batches.add(files);
}
