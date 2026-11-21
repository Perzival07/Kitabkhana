import 'dart:typed_data';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../data/backup_store.dart';
import 'export_backup.dart';

/// A file in the backups folder.
final class BackupEntry {
  const BackupEntry(this.name, this.modified);

  final String name;
  final DateTime modified;
}

/// Where automatic backups live on this device (`<documents>/backups`).
abstract interface class BackupFolder {
  /// False where there is no such place (the web).
  bool get supported;

  Future<List<BackupEntry>> list();

  Future<void> write(String name, Uint8List bytes);

  Future<void> delete(String name);

  /// Removes every file in the folder.
  Future<void> deleteAll();
}

/// The web: no folder, so no automatic backups.
class NoBackupFolder implements BackupFolder {
  const NoBackupFolder();

  @override
  bool get supported => false;
  @override
  Future<List<BackupEntry>> list() async => const <BackupEntry>[];
  @override
  Future<void> write(String name, Uint8List bytes) async {}
  @override
  Future<void> delete(String name) async {}
  @override
  Future<void> deleteAll() async {}
}

/// When the library was last backed up, and whether to do it automatically.
abstract interface class BackupPrefs {
  Future<DateTime?> lastBackupAt();
  Future<void> setLastBackupAt(DateTime at);
  Future<bool> autoEnabled();
  Future<void> setAutoEnabled({required bool enabled});
}

/// How long to wait between automatic backups.
const Duration autoBackupEvery = Duration(days: 7);

/// How many automatic backups to keep.
const int autoBackupKeep = 3;

const String autoBackupPrefix = 'auto-';

/// `auto-20250310-093000.kitab`: sorts by time, so the newest sorts last.
String autoBackupName(DateTime at) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '$autoBackupPrefix${at.year}${two(at.month)}${two(at.day)}'
      '-${two(at.hour)}${two(at.minute)}${two(at.second)}.kitab';
}

/// Weekly automatic backups into the app's own folder, newest
/// [autoBackupKeep] kept. They protect against a bad edit or a failed
/// import, not against losing the phone; sharing a backup does that.
class AutoBackup {
  AutoBackup({
    required this.export,
    required this.store,
    required this.folder,
    required this.prefs,
    required this.clock,
  });

  final ExportBackup export;
  final BackupStore store;
  final BackupFolder folder;
  final BackupPrefs prefs;
  final Clock clock;

  /// Backs up if automatic backups are on, this platform has a folder, the
  /// library is not empty and the last backup is [autoBackupEvery] old or
  /// missing. Returns whether a backup was made. Never throws.
  Future<bool> runIfDue() async {
    try {
      if (!folder.supported || !await prefs.autoEnabled()) return false;
      if ((await store.allBookIds()).isEmpty) return false;
      final last = await prefs.lastBackupAt();
      if (last != null && clock.now().difference(last) < autoBackupEvery) {
        return false;
      }
      return (await backUpNow()).isOk;
    } on Object {
      return false;
    }
  }

  /// Backs up now, whatever the schedule says.
  Future<Result<String>> backUpNow() async {
    if (!folder.supported) {
      return const Err(UnsupportedOnPlatformFailure('backup'));
    }
    final made = await export();
    if (made case Err<BackupFile>(:final failure)) return Err(failure);
    final file = (made as Ok<BackupFile>).value;
    try {
      final now = clock.now();
      final name = autoBackupName(now);
      await folder.write(name, file.bytes);
      await _prune();
      await prefs.setLastBackupAt(now);
      return Ok(name);
    } on Object catch (e, s) {
      return Err(StorageFailure('$e\n$s'));
    }
  }

  Future<void> _prune() async {
    final mine =
        (await folder.list())
            .where((e) => e.name.startsWith(autoBackupPrefix))
            .toList()
          ..sort((a, b) => b.name.compareTo(a.name));
    for (final old in mine.skip(autoBackupKeep)) {
      try {
        await folder.delete(old.name);
      } on Object {
        // Housekeeping only.
      }
    }
  }
}
