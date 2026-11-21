import '../../../data/db/app_database.dart';
import '../application/auto_backup.dart';

/// Backup settings kept in the device-local `app_meta` table (never part of a
/// backup itself).
class DbBackupPrefs implements BackupPrefs {
  DbBackupPrefs(this._db);

  final AppDatabase _db;

  static const String lastKey = 'backup.last_at';
  static const String autoKey = 'backup.auto';

  Future<String?> _get(String key) async => (await (_db.select(
    _db.appMeta,
  )..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _set(String key, String value) => _db
      .into(_db.appMeta)
      .insertOnConflictUpdate(AppMetaCompanion.insert(key: key, value: value));

  @override
  Future<DateTime?> lastBackupAt() async {
    final v = int.tryParse(await _get(lastKey) ?? '');
    return v == null ? null : DateTime.fromMillisecondsSinceEpoch(v);
  }

  @override
  Future<void> setLastBackupAt(DateTime at) =>
      _set(lastKey, '${at.millisecondsSinceEpoch}');

  @override
  Future<bool> autoEnabled() async => (await _get(autoKey)) != 'off';

  @override
  Future<void> setAutoEnabled({required bool enabled}) =>
      _set(autoKey, enabled ? 'on' : 'off');
}
