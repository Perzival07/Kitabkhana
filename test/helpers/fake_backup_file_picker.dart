import 'dart:typed_data';

import 'package:kitabkhana/platform/backup/backup_file_picker.dart';

/// Returns a canned file, or null for "cancelled".
class FakeBackupFilePicker implements BackupFilePicker {
  Uint8List? next;
  int asked = 0;

  @override
  Future<Uint8List?> pick() async {
    asked++;
    return next;
  }

  /// What was saved, and whether the next save "succeeds".
  final List<({Uint8List bytes, String name})> saved =
      <({Uint8List bytes, String name})>[];
  bool saveOk = true;

  @override
  Future<bool> save(Uint8List bytes, {required String name}) async {
    if (!saveOk) return false;
    saved.add((bytes: bytes, name: name));
    return true;
  }
}
