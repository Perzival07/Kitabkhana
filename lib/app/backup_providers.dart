import 'dart:io' show Directory;

import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/db/database_provider.dart';
import '../features/backup/application/auto_backup.dart';
import '../features/backup/application/backup_codec.dart';
import '../features/backup/application/csv_export.dart';
import '../features/backup/application/erase_all_data.dart';
import '../features/backup/application/export_backup.dart';
import '../features/backup/application/import_backup.dart';
import '../features/backup/data/backup_prefs_store.dart';
import '../features/backup/data/backup_store.dart';
import '../features/backup/data/csv_store.dart';
import '../platform/backup/backup_file_picker.dart';
import '../platform/backup/directory_backup_folder.dart';
import '../platform/backup/file_safety_backup.dart';
import 'app_config.dart' show kAppVersion;
import 'cover_providers.dart';
import 'providers.dart';
import 'reminder_providers.dart';

part 'backup_providers.g.dart';

@Riverpod(keepAlive: true)
BackupStore backupStore(Ref ref) => BackupStore(ref.watch(appDatabaseProvider));

/// Zipping runs off the UI thread.
@Riverpod(keepAlive: true)
ExportBackup exportBackup(Ref ref) => ExportBackup(
  store: ref.watch(backupStoreProvider),
  covers: ref.watch(coverStoreProvider),
  clock: ref.watch(clockProvider),
  appVersion: kAppVersion,
  encode: (input) => compute(encodeBackupArchive, input),
);

/// A copy of the library taken before every import (phones only).
@Riverpod(keepAlive: true)
SafetyBackup safetyBackup(Ref ref) => kIsWeb
    ? const NoSafetyBackup()
    : FileSafetyBackup(
        export: ref.watch(exportBackupProvider),
        documentsDir: () async =>
            Directory((await getApplicationDocumentsDirectory()).path),
      );

@Riverpod(keepAlive: true)
ImportBackup importBackup(Ref ref) => ImportBackup(
  store: ref.watch(backupStoreProvider),
  covers: ref.watch(coverStoreProvider),
  safety: ref.watch(safetyBackupProvider),
  decode: (input) => compute(decodeBackupArchive, input),
  afterImport: () => ref.read(loanReminderServiceProvider).reconcile(),
  logger: ref.watch(appLoggerProvider),
);

@Riverpod(keepAlive: true)
BackupFilePicker backupFilePicker(Ref ref) => const SystemBackupFilePicker();

@Riverpod(keepAlive: true)
ExportCsv exportCsv(Ref ref) =>
    ExportCsv(CsvStore(ref.watch(appDatabaseProvider)));

/// `<documents>/backups` on phones; nothing on the web.
@Riverpod(keepAlive: true)
BackupFolder backupFolder(Ref ref) => kIsWeb
    ? const NoBackupFolder()
    : DirectoryBackupFolder(getApplicationDocumentsDirectory);

@Riverpod(keepAlive: true)
BackupPrefs backupPrefs(Ref ref) =>
    DbBackupPrefs(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
AutoBackup autoBackup(Ref ref) => AutoBackup(
  export: ref.watch(exportBackupProvider),
  store: ref.watch(backupStoreProvider),
  folder: ref.watch(backupFolderProvider),
  prefs: ref.watch(backupPrefsProvider),
  clock: ref.watch(clockProvider),
);

/// Whether to remind the reader to keep a copy off this phone. Re-read after
/// a copy is saved or the reminder is put off.
@riverpod
Future<bool> offDeviceReminder(Ref ref) async {
  final prefs = ref.watch(backupPrefsProvider);
  return offDeviceCopyDue(
    bookCount: (await ref.watch(backupStoreProvider).allBookIds()).length,
    lastOffDevice: await prefs.lastOffDeviceAt(),
    snoozedUntil: await prefs.offDeviceSnoozedUntil(),
    now: ref.watch(clockProvider).now(),
  );
}

@Riverpod(keepAlive: true)
EraseAllData eraseAllData(Ref ref) => EraseAllData(
  db: ref.watch(appDatabaseProvider),
  store: ref.watch(backupStoreProvider),
  covers: ref.watch(coverStoreProvider),
  folder: ref.watch(backupFolderProvider),
  notifications: ref.watch(notificationSchedulerProvider),
);
