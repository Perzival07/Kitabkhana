import 'dart:typed_data';

import 'package:kitabkhana/features/backup/application/auto_backup.dart';

/// An in-memory backups folder.
class FakeBackupFolder implements BackupFolder {
  FakeBackupFolder({this.supported = true});

  @override
  final bool supported;
  final Map<String, Uint8List> files = <String, Uint8List>{};
  bool failWrites = false;

  @override
  Future<List<BackupEntry>> list() async => [
    for (final n in files.keys) BackupEntry(n, DateTime(2025)),
  ];

  @override
  Future<void> write(String name, Uint8List bytes) async {
    if (failWrites) throw StateError('disk full');
    files[name] = bytes;
  }

  @override
  Future<void> delete(String name) async => files.remove(name);

  @override
  Future<void> deleteAll() async => files.clear();
}
