import 'dart:io';
import 'dart:typed_data';

import '../../features/backup/application/auto_backup.dart';

/// The backups folder on disk: `<documents>/backups`.
class DirectoryBackupFolder implements BackupFolder {
  DirectoryBackupFolder(this._documentsDir);

  final Future<Directory> Function() _documentsDir;

  Future<Directory> _dir({bool create = false}) async {
    final d = Directory('${(await _documentsDir()).path}/backups');
    if (create) await d.create(recursive: true);
    return d;
  }

  @override
  bool get supported => true;

  @override
  Future<List<BackupEntry>> list() async {
    final d = await _dir();
    if (!d.existsSync()) return const <BackupEntry>[];
    return [
      for (final f in d.listSync().whereType<File>())
        BackupEntry(f.uri.pathSegments.last, f.lastModifiedSync()),
    ];
  }

  @override
  Future<void> write(String name, Uint8List bytes) async {
    final d = await _dir(create: true);
    await File('${d.path}/$name').writeAsBytes(bytes, flush: true);
  }

  @override
  Future<void> delete(String name) async {
    final f = File('${(await _dir()).path}/$name');
    if (f.existsSync()) await f.delete();
  }

  @override
  Future<void> deleteAll() async {
    final d = await _dir();
    if (d.existsSync()) await d.delete(recursive: true);
  }
}
