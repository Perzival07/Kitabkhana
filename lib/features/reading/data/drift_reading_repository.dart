import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/converters.dart';
import '../../../data/db/db_guard.dart';
import '../../../data/db/sync_sql.dart';
import '../domain/reading_log.dart';
import '../domain/reading_repository.dart';

ReadingLog _toDomain(ReadingLogRow r) => ReadingLog(
  id: r.id,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  rev: r.rev,
  bookId: r.bookId,
  date: r.date,
  pagesRead: r.pagesRead,
  fromPage: r.fromPage,
  toPage: r.toPage,
);

ReadingLogsCompanion _toCompanion(
  ReadingLog l, {
  required DateTime updatedAt,
  required int rev,
  DateTime? createdAt,
}) => ReadingLogsCompanion(
  id: Value(l.id),
  createdAt: createdAt == null ? const Value.absent() : Value(createdAt),
  updatedAt: Value(updatedAt),
  deletedAt: Value(l.deletedAt),
  rev: Value(rev),
  bookId: Value(l.bookId),
  date: Value(l.date),
  pagesRead: Value(l.pagesRead),
  fromPage: Value(l.fromPage),
  toPage: Value(l.toPage),
);

class DriftReadingRepository implements ReadingRepository {
  DriftReadingRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  static const _dates = DateOnlyConverter();

  JoinedSelectStatement<HasResultSet, dynamic> _joined(
    Expression<bool> Function($ReadingLogsTable l) where,
  ) {
    final l = _db.readingLogs;
    return _db.select(l).join([
      innerJoin(_db.books, _db.books.id.equalsExp(l.bookId)),
    ])..where(l.deletedAt.isNull() & _db.books.deletedAt.isNull() & where(l));
  }

  List<ReadingLog> _rows(List<TypedResult> rows) =>
      rows.map((r) => _toDomain(r.readTable(_db.readingLogs))).toList();

  @override
  Stream<List<ReadingLog>> watchForBook(String bookId) {
    final q = _joined((l) => l.bookId.equals(bookId))
      ..orderBy([
        OrderingTerm.desc(_db.readingLogs.date),
        OrderingTerm.desc(_db.readingLogs.createdAt),
      ]);
    return q.watch().map(_rows);
  }

  @override
  Stream<List<ReadingLog>> watchBetween(DateTime from, DateTime to) {
    final a = _dates.toSql(from);
    final b = _dates.toSql(to);
    final q =
        _joined(
          (l) =>
              l.date.isBiggerOrEqualValue(a) & l.date.isSmallerOrEqualValue(b),
        )..orderBy([
          OrderingTerm.asc(_db.readingLogs.date),
          OrderingTerm.asc(_db.readingLogs.createdAt),
        ]);
    return q.watch().map(_rows);
  }

  @override
  Future<Result<ReadingLog?>> findForDay(String bookId, DateTime date) =>
      dbGuard(() async {
        final row =
            await (_db.select(_db.readingLogs)
                  ..where(
                    (t) =>
                        t.deletedAt.isNull() &
                        t.bookId.equals(bookId) &
                        t.date.equals(_dates.toSql(date)),
                  )
                  ..limit(1))
                .getSingleOrNull();
        return row == null ? null : _toDomain(row);
      });

  @override
  Future<Result<ReadingLog>> upsert(ReadingLog log) => dbGuard(
    () => _db.transaction(() async {
      final now = _clock.now();
      final existing = await (_db.select(
        _db.readingLogs,
      )..where((t) => t.id.equals(log.id))).getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.readingLogs)
            .insert(_toCompanion(log, createdAt: now, updatedAt: now, rev: 1));
      } else {
        await (_db.update(_db.readingLogs)..where((t) => t.id.equals(log.id)))
            .write(_toCompanion(log, updatedAt: now, rev: existing.rev + 1));
      }
      final saved = await (_db.select(
        _db.readingLogs,
      )..where((t) => t.id.equals(log.id))).getSingle();
      return _toDomain(saved);
    }),
  );

  @override
  Future<Result<void>> softDelete(String id) => dbGuard(() async {
    final n = await softDeleteById(
      _db,
      table: _db.readingLogs,
      id: id,
      now: _clock.now(),
    );
    if (n == 0) {
      throw const FailureException(NotFoundFailure('readingLog'));
    }
  });
}
