import 'dart:io' show Directory;

import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/db/database_provider.dart';
import '../features/backup/application/backup_codec.dart';
import '../features/backup/application/export_backup.dart';
import '../features/backup/application/import_backup.dart';
import '../features/backup/data/backup_store.dart';
import '../platform/backup/backup_file_picker.dart';
import '../platform/backup/file_safety_backup.dart';
import 'app_version.dart';
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
  appVersion: appVersion,
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
