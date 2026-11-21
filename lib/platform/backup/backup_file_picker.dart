import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Lets the reader choose a `.kitab` file. Returns its bytes, or null when
/// they cancel. (The file is not filtered by extension: Android and iOS
/// pickers do not know custom extensions; the importer checks the content.)
abstract interface class BackupFilePicker {
  Future<Uint8List?> pick();
}

class SystemBackupFilePicker implements BackupFilePicker {
  const SystemBackupFilePicker();

  @override
  Future<Uint8List?> pick() async {
    final file = await FilePicker.pickFile();
    if (file == null) return null;
    return file.readAsBytes();
  }
}
