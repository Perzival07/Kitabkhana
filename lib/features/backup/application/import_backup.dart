import 'dart:typed_data';

import '../../../core/failure.dart';
import '../../../core/logger.dart';
import '../../../core/result.dart';
import '../../../platform/cover_store/cover_store.dart';
import '../data/backup_store.dart';
import '../domain/backup_format.dart';
import 'backup_codec.dart';

/// Takes a backup of the current library before an import changes it.
abstract interface class SafetyBackup {
  /// Ok when a safety copy exists (or none is possible on this platform).
  Future<Result<void>> create();
}

/// For platforms with nowhere to keep a copy (the web): the import's single
/// transaction is the protection there.
class NoSafetyBackup implements SafetyBackup {
  const NoSafetyBackup();

  @override
  Future<Result<void>> create() async => const Ok<void>(null);
}

/// Opens, checks and imports a `.kitab` backup.
///
/// Nothing is written until the whole file has been validated. The current
/// library is backed up first (and the import stops if that fails), then the
/// database changes happen in one transaction: any error undoes all of it.
class ImportBackup {
  ImportBackup({
    required this.store,
    required this.covers,
    required this.safety,
    this.decode = _decodeHere,
    this.afterImport,
    this.logger,
  });

  final BackupStore store;
  final CoverStore covers;
  final SafetyBackup safety;
  final Future<BackupContents> Function(BackupDecodeInput input) decode;

  /// Runs after a successful import (the app re-schedules loan reminders).
  final Future<void> Function()? afterImport;
  final AppLogger? logger;

  static Future<BackupContents> _decodeHere(BackupDecodeInput i) async =>
      decodeBackupArchive(i);

  /// Validates [bytes] without touching the library.
  Future<Result<BackupContents>> open(Uint8List bytes) async {
    try {
      return Ok(await decode(BackupDecodeInput(bytes, store.schemaVersion)));
    } on BackupFailure catch (f) {
      return Err(f);
    } on Object catch (e) {
      return Err(BackupFailure(BackupProblem.damaged, e.toString()));
    }
  }

  Future<Result<ImportSummary>> call(
    BackupContents contents,
    ImportMode mode,
  ) async {
    final safe = await safety.create();
    if (safe case Err<void>(:final failure)) return Err(failure);

    final before = mode == ImportMode.replace
        ? await store.allBookIds()
        : const <String>[];

    final ImportSummary summary;
    try {
      summary = mode == ImportMode.replace
          ? await store.replaceAll(contents.tables)
          : await store.mergeAll(contents.tables);
    } on Object catch (e) {
      // The transaction has been rolled back: nothing changed.
      return Err(BackupFailure(BackupProblem.damaged, e.toString()));
    }

    var skipped = 0;
    try {
      final kept = <String>{
        for (final b in contents.tables['books'] ?? const []) b['id'] as String,
      };
      for (final id in before) {
        if (!kept.contains(id)) await covers.delete(id);
      }
      skipped = await _restoreCovers(contents);
    } on Object catch (e) {
      logger?.warn('Restoring covers failed: $e');
    }

    try {
      await afterImport?.call();
    } on Object catch (e) {
      logger?.warn('After-import step failed: $e');
    }

    return Ok(
      ImportSummary(
        books: summary.books,
        loans: summary.loans,
        quotes: summary.quotes,
        readingLogs: summary.readingLogs,
        coversSkipped: skipped,
      ),
    );
  }

  /// Stores the archive's covers and points the books at them. A book whose
  /// cover file is not in the archive loses its (now meaningless) reference.
  /// Only books the backup actually won are touched, so a newer local cover
  /// survives a merge. Returns how many covers could not be copied.
  Future<int> _restoreCovers(BackupContents contents) async {
    var skipped = 0;
    for (final row in contents.tables['books'] ?? const []) {
      final id = row['id'] as String;
      final backupRef = row['coverLocalPath'] as String?;
      if (backupRef == null || backupRef.isEmpty) continue;
      if (await store.coverReferenceOf(id) != backupRef) continue;
      final bytes = contents.covers[id];
      if (bytes == null) {
        await store.setCoverReference(id, null);
        continue;
      }
      final saved = await covers.saveFromBytes(id, bytes);
      switch (saved) {
        case Ok<String>(:final value):
          await store.setCoverReference(id, value);
        case Err<String>():
          skipped++;
          await store.setCoverReference(id, null);
      }
    }
    return skipped;
  }
}
