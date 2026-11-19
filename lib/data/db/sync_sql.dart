import 'package:drift/drift.dart';

/// Soft-deletes the row with [id] in [tableName]: sets `deleted_at`, stamps
/// `updated_at` and bumps `rev`. Returns the number of rows changed (0 if the
/// row is missing or already deleted).
Future<int> softDeleteById(
  GeneratedDatabase db, {
  required TableInfo<Table, Object?> table,
  required String id,
  required DateTime now,
}) {
  return db.customUpdate(
    'UPDATE ${table.actualTableName} '
    'SET deleted_at = ?1, updated_at = ?1, rev = rev + 1 '
    'WHERE id = ?2 AND deleted_at IS NULL',
    variables: [Variable<DateTime>(now), Variable<String>(id)],
    updates: {table},
    updateKind: UpdateKind.update,
  );
}

/// Undoes [softDeleteById]. Returns the number of rows changed.
Future<int> restoreById(
  GeneratedDatabase db, {
  required TableInfo<Table, Object?> table,
  required String id,
  required DateTime now,
}) {
  return db.customUpdate(
    'UPDATE ${table.actualTableName} '
    'SET deleted_at = NULL, updated_at = ?1, rev = rev + 1 '
    'WHERE id = ?2 AND deleted_at IS NOT NULL',
    variables: [Variable<DateTime>(now), Variable<String>(id)],
    updates: {table},
    updateKind: UpdateKind.update,
  );
}
