import 'dart:typed_data';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../platform/cover_store/cover_store.dart';
import '../data/backup_store.dart';
import 'backup_codec.dart';

/// A finished backup: the bytes and a good file name.
final class BackupFile {
  const BackupFile(this.bytes, this.name);

  final Uint8List bytes;
  final String name;
}

/// `kitabkhana-2025-03-10.kitab`
String backupFileName(DateTime day) {
  String two(int n) => n.toString().padLeft(2, '0');
  return 'kitabkhana-${day.year}-${two(day.month)}-${two(day.day)}.kitab';
}

/// Builds a `.kitab` backup of the whole library: every row (soft-deleted
/// ones too) and the cover images. The slow zip step runs through [encode],
/// which the app points at a background isolate.
class ExportBackup {
  ExportBackup({
    required this.store,
    required this.covers,
    required this.clock,
    required this.appVersion,
    this.encode = _encodeHere,
  });

  final BackupStore store;
  final CoverStore covers;
  final Clock clock;
  final String appVersion;
  final Future<Uint8List> Function(BackupArchiveInput input) encode;

  static Future<Uint8List> _encodeHere(BackupArchiveInput i) async =>
      encodeBackupArchive(i);

  Future<Result<BackupFile>> call() async {
    try {
      final now = clock.now();
      final tables = await store.readAll();
      final refs = await store.coverReferences();
      final images = <String, Uint8List>{};
      for (final e in refs.entries) {
        final bytes = await covers.readBytes(e.value);
        if (bytes != null) images[e.key] = bytes;
      }
      final bytes = await encode(
        BackupArchiveInput(
          appVersion: appVersion,
          schemaVersion: store.schemaVersion,
          deviceId: await store.deviceId(),
          exportedAt: now.toUtc(),
          tables: tables,
          covers: images,
        ),
      );
      return Ok(BackupFile(bytes, backupFileName(now)));
    } on Object catch (e, s) {
      return Err(UnexpectedFailure(e, s));
    }
  }
}
