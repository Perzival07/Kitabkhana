import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import '../../../core/failure.dart';
import '../domain/backup_format.dart';

/// What goes into a backup archive. Plain data, so it can cross an isolate.
final class BackupArchiveInput {
  const BackupArchiveInput({
    required this.appVersion,
    required this.schemaVersion,
    required this.deviceId,
    required this.exportedAt,
    required this.tables,
    required this.covers,
  });

  final String appVersion;
  final int schemaVersion;
  final String deviceId;
  final DateTime exportedAt;

  /// Rows per table name, as JSON-ready maps.
  final Map<String, List<Map<String, dynamic>>> tables;

  /// Cover JPEG bytes by book id.
  final Map<String, Uint8List> covers;
}

String _sha(List<int> bytes) => sha256.convert(bytes).toString();

/// Builds the `.kitab` zip. Top-level so it can run via `compute`.
Uint8List encodeBackupArchive(BackupArchiveInput input) {
  final archive = Archive();
  final files = <String, String>{};
  final counts = <String, int>{};

  void add(String path, List<int> bytes) {
    files[path] = _sha(bytes);
    archive.addFile(ArchiveFile.bytes(path, bytes));
  }

  for (final name in backupTableNames) {
    final rows = input.tables[name] ?? const <Map<String, dynamic>>[];
    counts[name] = rows.length;
    add(dataFilePath(name), utf8.encode(jsonEncode(rows)));
  }
  final ids = input.covers.keys.toList()..sort();
  for (final id in ids) {
    add(coverFilePath(id), input.covers[id]!);
  }

  final manifest = BackupManifest(
    formatVersion: backupFormatVersion,
    appVersion: input.appVersion,
    schemaVersion: input.schemaVersion,
    deviceId: input.deviceId,
    exportedAt: input.exportedAt,
    counts: counts,
    files: files,
  );
  archive.addFile(
    ArchiveFile.bytes(
      manifestPath,
      utf8.encode(
        const JsonEncoder.withIndent('  ').convert(manifest.toJson()),
      ),
    ),
  );
  return ZipEncoder().encodeBytes(archive);
}

/// A validated backup, ready to import.
final class BackupContents {
  const BackupContents({
    required this.manifest,
    required this.tables,
    required this.covers,
  });

  final BackupManifest manifest;
  final Map<String, List<Map<String, dynamic>>> tables;
  final Map<String, Uint8List> covers;
}

/// What [decodeBackupArchive] needs to know about this app.
final class BackupDecodeInput {
  const BackupDecodeInput(this.bytes, this.supportedSchemaVersion);

  final Uint8List bytes;
  final int supportedSchemaVersion;
}

/// Opens and validates a `.kitab` file. Top-level so it can run via
/// `compute`; throws a [BackupFailure] (never anything else) when the file is
/// not a usable backup.
BackupContents decodeBackupArchive(BackupDecodeInput input) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(input.bytes);
  } on Object {
    throw const BackupFailure(BackupProblem.notABackup, 'not a zip');
  }

  final entries = <String, ArchiveFile>{
    for (final f in archive.files)
      if (f.isFile) f.name: f,
  };

  final manifestFile = entries[manifestPath];
  if (manifestFile == null) {
    throw const BackupFailure(BackupProblem.notABackup, 'no manifest');
  }
  final BackupManifest manifest;
  try {
    manifest = BackupManifest.fromJson(
      jsonDecode(utf8.decode(manifestFile.content)),
    );
  } on Object {
    throw const BackupFailure(BackupProblem.notABackup, 'bad manifest');
  }

  if (manifest.formatVersion > backupFormatVersion ||
      manifest.schemaVersion > input.supportedSchemaVersion) {
    throw BackupFailure(
      BackupProblem.newerVersion,
      'format ${manifest.formatVersion}, schema ${manifest.schemaVersion}',
    );
  }
  if (manifest.formatVersion < 1) {
    throw const BackupFailure(BackupProblem.notABackup, 'format < 1');
  }

  // Every file must be listed and match, and nothing unlisted may be there.
  final unlisted = entries.keys.where(
    (n) => n != manifestPath && !manifest.files.containsKey(n),
  );
  if (unlisted.isNotEmpty) {
    throw BackupFailure(BackupProblem.damaged, 'unlisted ${unlisted.first}');
  }
  for (final e in manifest.files.entries) {
    final file = entries[e.key];
    if (file == null) {
      throw BackupFailure(BackupProblem.damaged, 'missing ${e.key}');
    }
    if (_sha(file.content) != e.value) {
      throw BackupFailure(BackupProblem.damaged, 'checksum ${e.key}');
    }
  }

  final tables = <String, List<Map<String, dynamic>>>{};
  for (final name in backupTableNames) {
    final file = entries[dataFilePath(name)];
    if (file == null) {
      throw BackupFailure(BackupProblem.damaged, 'no ${dataFilePath(name)}');
    }
    try {
      final decoded = jsonDecode(utf8.decode(file.content));
      if (decoded is! List) throw const FormatException('not a list');
      final rows = <Map<String, dynamic>>[
        for (final r in decoded)
          r is Map<String, dynamic>
              ? r
              : throw const FormatException('row is not an object'),
      ];
      if (manifest.counts[name] != rows.length) {
        throw const FormatException('count mismatch');
      }
      tables[name] = rows;
    } on Object catch (e) {
      throw BackupFailure(BackupProblem.damaged, '$name: $e');
    }
  }

  const prefix = 'covers/';
  final covers = <String, Uint8List>{
    for (final e in entries.entries)
      if (e.key.startsWith(prefix) && e.key.endsWith('.jpg'))
        e.key.substring(prefix.length, e.key.length - 4): e.value.content,
  };
  return BackupContents(manifest: manifest, tables: tables, covers: covers);
}
