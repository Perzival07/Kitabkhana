import 'dart:io';

import '../../core/failure.dart';
import '../../core/result.dart';
import '../../features/backup/application/export_backup.dart';
import '../../features/backup/application/import_backup.dart';

/// Keeps a copy of the library in `<documents>/backups/` before an import
/// changes it, and only the newest [keep] such copies.
class FileSafetyBackup implements SafetyBackup {
  FileSafetyBackup({
    required this.export,
    required this.documentsDir,
    this.keep = 3,
  });

  final ExportBackup export;
  final int keep;
  final Future<Directory> Function() documentsDir;

  static const String prefix = 'before-restore-';

  @override
  Future<Result<void>> create() async {
    final made = await export();
    if (made case Err<BackupFile>(:final failure)) return Err(failure);
    final file = (made as Ok<BackupFile>).value;
    try {
      final dir = Directory('${(await documentsDir()).path}/backups');
      await dir.create(recursive: true);
      await File('${dir.path}/$prefix${file.name}')
          .writeAsBytes(file.bytes, flush: true);
      final mine =
          dir
              .listSync()
              .whereType<File>()
              .where((f) => f.uri.pathSegments.last.startsWith(prefix))
              .toList()
            ..sort(
              (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
            );
      for (final old in mine.skip(keep)) {
        try {
          old.deleteSync();
        } on Object {
          // Housekeeping only.
        }
      }
      return const Ok<void>(null);
    } on Object catch (e, s) {
      return Err(UnexpectedFailure(e, s));
    }
  }
}
