import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/features/backup/application/backup_codec.dart';
import 'package:kitabkhana/features/backup/domain/backup_format.dart';

/// A backup as an app on schema [schema] wrote it: without the tables that
/// came later.
Uint8List olderBackup(int schema) {
  final full = encodeBackupArchive(
    BackupArchiveInput(
      appVersion: '1.0.0',
      schemaVersion: 3,
      deviceId: 'dev',
      exportedAt: DateTime.utc(2025, 3, 10),
      tables: const <String, List<Map<String, dynamic>>>{},
      covers: const <String, Uint8List>{},
    ),
  );
  final zip = ZipDecoder().decodeBytes(full);
  final dropped = <String>{
    for (final e in backupTablesAddedIn.entries)
      if (e.value > schema) dataFilePath(e.key),
  };
  final out = Archive();
  for (final f in zip.files) {
    if (dropped.contains(f.name)) continue;
    if (f.name == manifestPath) {
      final m = jsonDecode(utf8.decode(f.content)) as Map<String, dynamic>;
      m['schemaVersion'] = schema;
      (m['files'] as Map<String, dynamic>).removeWhere(
        (k, _) => dropped.contains(k),
      );
      out.addFile(ArchiveFile.bytes(manifestPath, utf8.encode(jsonEncode(m))));
    } else {
      out.addFile(ArchiveFile.bytes(f.name, f.content));
    }
  }
  return ZipEncoder().encodeBytes(out);
}

void main() {
  test('a backup from before reading sessions and re-reads still opens', () {
    final c = decodeBackupArchive(BackupDecodeInput(olderBackup(2), 3));
    expect(c.tables['reading_sessions'], isEmpty);
    expect(c.tables['read_throughs'], isEmpty);
    expect(c.manifest.schemaVersion, 2);
  });

  test('a current backup missing them is damaged', () {
    final bytes = olderBackup(2);
    // Same files, but claiming the current schema.
    final zip = ZipDecoder().decodeBytes(bytes);
    final out = Archive();
    for (final f in zip.files) {
      if (f.name == manifestPath) {
        final m = jsonDecode(utf8.decode(f.content)) as Map<String, dynamic>;
        m['schemaVersion'] = 3;
        out.addFile(
          ArchiveFile.bytes(manifestPath, utf8.encode(jsonEncode(m))),
        );
      } else {
        out.addFile(ArchiveFile.bytes(f.name, f.content));
      }
    }
    expect(
      () => decodeBackupArchive(
        BackupDecodeInput(ZipEncoder().encodeBytes(out), 3),
      ),
      throwsA(
        isA<BackupFailure>().having(
          (f) => f.problem,
          'problem',
          BackupProblem.damaged,
        ),
      ),
    );
  });
}
