import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/db_guard.dart';
import '../../../data/db/sync_sql.dart';
import '../domain/location.dart';
import '../domain/location_repository.dart';

Location _toDomain(LocationRow r) => Location(
  id: r.id,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  rev: r.rev,
  name: r.name,
  parentId: r.parentId,
  sortOrder: r.sortOrder,
  icon: r.icon,
);

LocationsCompanion _toCompanion(
  Location l, {
  required DateTime updatedAt,
  required int rev,
  DateTime? createdAt,
}) => LocationsCompanion(
  id: Value(l.id),
  createdAt: createdAt == null ? const Value.absent() : Value(createdAt),
  updatedAt: Value(updatedAt),
  deletedAt: Value(l.deletedAt),
  rev: Value(rev),
  name: Value(l.name),
  parentId: Value(l.parentId),
  sortOrder: Value(l.sortOrder),
  icon: Value(l.icon),
);

class DriftLocationRepository implements LocationRepository {
  DriftLocationRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  @override
  Stream<List<Location>> watchAll() {
    final q = _db.liveLocations()
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.name),
        (t) => OrderingTerm.asc(t.id),
      ]);
    return q.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<Result<Location?>> getById(String id) => dbGuard(() async {
    final row = await (_db.liveLocations()..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  });

  @override
  Future<Result<Location>> upsert(Location location) => dbGuard(
    () => _db.transaction(() async {
      final name = location.name.trim();
      if (name.isEmpty) {
        throw const FailureException(
          ValidationFailure(field: 'name', messageKey: 'failureValidation'),
        );
      }
      final siblings =
          await (_db.liveLocations()..where(
                (t) =>
                    t.id.equals(location.id).not() &
                    (location.parentId == null
                        ? t.parentId.isNull()
                        : t.parentId.equals(location.parentId!)),
              ))
              .get();
      final wanted = name.toLowerCase();
      if (siblings.any((s) => s.name.trim().toLowerCase() == wanted)) {
        throw const FailureException(ConflictFailure());
      }

      final now = _clock.now();
      final clean = location.copyWith(name: name);
      final existing = await (_db.select(
        _db.locations,
      )..where((t) => t.id.equals(location.id))).getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.locations)
            .insert(
              _toCompanion(clean, createdAt: now, updatedAt: now, rev: 1),
            );
      } else {
        await (_db.update(_db.locations)
              ..where((t) => t.id.equals(location.id)))
            .write(_toCompanion(clean, updatedAt: now, rev: existing.rev + 1));
      }
      final saved = await (_db.select(
        _db.locations,
      )..where((t) => t.id.equals(location.id))).getSingle();
      return _toDomain(saved);
    }),
  );

  @override
  Future<Result<void>> reorder(List<String> orderedIds) => dbGuard(
    () => _db.transaction(() async {
      final now = _clock.now();
      for (var i = 0; i < orderedIds.length; i++) {
        await _db.customUpdate(
          'UPDATE locations SET sort_order = ?1, updated_at = ?2, '
          'rev = rev + 1 WHERE id = ?3',
          variables: [
            Variable<int>(i),
            Variable<DateTime>(now),
            Variable<String>(orderedIds[i]),
          ],
          updates: {_db.locations},
          updateKind: UpdateKind.update,
        );
      }
    }),
  );

  @override
  Future<Result<void>> softDelete(String id, {String? moveBooksTo}) => dbGuard(
    () => _db.transaction(() async {
      if (moveBooksTo == id) {
        throw const FailureException(
          ValidationFailure(
            field: 'moveBooksTo',
            messageKey: 'failureValidation',
          ),
        );
      }
      if (moveBooksTo != null) {
        final target =
            await (_db.liveLocations()..where((t) => t.id.equals(moveBooksTo)))
                .getSingleOrNull();
        if (target == null) {
          throw const FailureException(NotFoundFailure('location'));
        }
      }
      final now = _clock.now();
      // Books (including soft-deleted ones) never point at a deleted place.
      await _db.customUpdate(
        'UPDATE books SET location_id = ?1, updated_at = ?2, '
        'rev = rev + 1 WHERE location_id = ?3',
        variables: [
          Variable<String>(moveBooksTo),
          Variable<DateTime>(now),
          Variable<String>(id),
        ],
        updates: {_db.books},
        updateKind: UpdateKind.update,
      );
      await _db.customUpdate(
        'UPDATE locations SET parent_id = NULL, updated_at = ?1, '
        'rev = rev + 1 WHERE parent_id = ?2',
        variables: [Variable<DateTime>(now), Variable<String>(id)],
        updates: {_db.locations},
        updateKind: UpdateKind.update,
      );
      final n = await softDeleteById(
        _db,
        table: _db.locations,
        id: id,
        now: now,
      );
      if (n == 0) throw const FailureException(NotFoundFailure('location'));
    }),
  );

  @override
  Stream<Map<String, int>> watchBookCounts() {
    return _db
        .customSelect(
          'SELECT location_id AS id, COUNT(*) AS c FROM books '
          'WHERE deleted_at IS NULL AND location_id IS NOT NULL '
          'GROUP BY location_id',
          readsFrom: {_db.books},
        )
        .watch()
        .map(
          (rows) => <String, int>{
            for (final r in rows) r.read<String>('id'): r.read<int>('c'),
          },
        );
  }
}
