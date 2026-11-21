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
}
