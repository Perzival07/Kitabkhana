// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backupStore)
final backupStoreProvider = BackupStoreProvider._();

final class BackupStoreProvider
    extends $FunctionalProvider<BackupStore, BackupStore, BackupStore>
    with $Provider<BackupStore> {
  BackupStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupStoreHash();

  @$internal
  @override
  $ProviderElement<BackupStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupStore create(Ref ref) {
    return backupStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupStore>(value),
    );
  }
}

String _$backupStoreHash() => r'717aade2cb7114c9b4816fae5d7a0cafbcc92ef9';

/// Zipping runs off the UI thread.

@ProviderFor(exportBackup)
final exportBackupProvider = ExportBackupProvider._();

/// Zipping runs off the UI thread.

final class ExportBackupProvider
    extends $FunctionalProvider<ExportBackup, ExportBackup, ExportBackup>
    with $Provider<ExportBackup> {
  /// Zipping runs off the UI thread.
  ExportBackupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportBackupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportBackupHash();

  @$internal
  @override
  $ProviderElement<ExportBackup> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExportBackup create(Ref ref) {
    return exportBackup(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportBackup value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportBackup>(value),
    );
  }
}

String _$exportBackupHash() => r'f954f1cc1be65058d5dc5cbf4d5d47d7c9281476';

/// A copy of the library taken before every import (phones only).

@ProviderFor(safetyBackup)
final safetyBackupProvider = SafetyBackupProvider._();

/// A copy of the library taken before every import (phones only).

final class SafetyBackupProvider
    extends $FunctionalProvider<SafetyBackup, SafetyBackup, SafetyBackup>
    with $Provider<SafetyBackup> {
  /// A copy of the library taken before every import (phones only).
  SafetyBackupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safetyBackupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safetyBackupHash();

  @$internal
  @override
  $ProviderElement<SafetyBackup> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SafetyBackup create(Ref ref) {
    return safetyBackup(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyBackup value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyBackup>(value),
    );
  }
}

String _$safetyBackupHash() => r'974ab41c3e15d39a90ae437512ce319a6a8c7f30';

@ProviderFor(importBackup)
final importBackupProvider = ImportBackupProvider._();

final class ImportBackupProvider
    extends $FunctionalProvider<ImportBackup, ImportBackup, ImportBackup>
    with $Provider<ImportBackup> {
  ImportBackupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importBackupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importBackupHash();

  @$internal
  @override
  $ProviderElement<ImportBackup> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImportBackup create(Ref ref) {
    return importBackup(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportBackup value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportBackup>(value),
    );
  }
}

String _$importBackupHash() => r'ee45a45fad6bbc889e401e190ca3031dd31c027a';

@ProviderFor(backupFilePicker)
final backupFilePickerProvider = BackupFilePickerProvider._();

final class BackupFilePickerProvider
    extends
        $FunctionalProvider<
          BackupFilePicker,
          BackupFilePicker,
          BackupFilePicker
        >
    with $Provider<BackupFilePicker> {
  BackupFilePickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupFilePickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupFilePickerHash();

  @$internal
  @override
  $ProviderElement<BackupFilePicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupFilePicker create(Ref ref) {
    return backupFilePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupFilePicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupFilePicker>(value),
    );
  }
}

String _$backupFilePickerHash() => r'b45a50638d4f466efff270d50c34abbb39f5f7f7';
