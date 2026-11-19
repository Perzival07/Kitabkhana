import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../core/uuid.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/db_guard.dart';
import '../../../data/db/sync_sql.dart';
import '../domain/goal.dart';
import '../domain/goal_repository.dart';

Goal _toDomain(GoalRow r) => Goal(
  id: r.id,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  rev: r.rev,
  year: r.year,
  targetBooks: r.targetBooks,
);

class DriftGoalRepository implements GoalRepository {
  DriftGoalRepository(this._db, this._clock, {String Function()? newId})
    : _newId = newId ?? uuidV7;

  final AppDatabase _db;
  final Clock _clock;
  final String Function() _newId;

  SimpleSelectStatement<$GoalsTable, GoalRow> _forYear(int year) =>
      _db.liveGoals()..where((t) => t.year.equals(year));

  @override
  Stream<Goal?> watchForYear(int year) =>
      _forYear(year)
          .watchSingleOrNull()
          .map((r) => r == null ? null : _toDomain(r));

  @override
  Future<Result<Goal?>> getForYear(int year) => dbGuard(() async {
    final row = await _forYear(year).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  });

  @override
  Future<Result<Goal>> setTarget(int year, int targetBooks) => dbGuard(
    () => _db.transaction(() async {
      if (targetBooks <= 0) {
        throw const FailureException(
          ValidationFailure(
            field: 'targetBooks',
            messageKey: 'failureValidation',
          ),
        );
      }
      final now = _clock.now();
      final existing = await _forYear(year).getSingleOrNull();
      final String id;
      if (existing == null) {
        id = _newId();
        await _db
            .into(_db.goals)
            .insert(
              GoalsCompanion.insert(
                id: Value(id),
                year: year,
                targetBooks: targetBooks,
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        id = existing.id;
        await (_db.update(_db.goals)..where((t) => t.id.equals(id))).write(
          GoalsCompanion(
            targetBooks: Value(targetBooks),
            updatedAt: Value(now),
            rev: Value(existing.rev + 1),
          ),
        );
      }
      final saved = await (_db.select(
        _db.goals,
      )..where((t) => t.id.equals(id))).getSingle();
      return _toDomain(saved);
    }),
  );

  @override
  Future<Result<void>> clear(int year) => dbGuard(() async {
    final row = await _forYear(year).getSingleOrNull();
    if (row == null) throw const FailureException(NotFoundFailure('goal'));
    await softDeleteById(_db, table: _db.goals, id: row.id, now: _clock.now());
  });
}
