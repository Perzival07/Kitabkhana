import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../core/uuid.dart';
import '../../../data/db/app_database.dart';
import '../domain/reading_timer.dart';

class DriftReadingSessionRepository implements ReadingSessionRepository {
  DriftReadingSessionRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  @override
  Future<Result<void>> addMinutes(
    String bookId,
    DateTime day,
    int minutes,
  ) async {
    if (minutes <= 0) return const Ok(null);
    final date = DateTime(day.year, day.month, day.day);
    try {
      await _db.transaction(() async {
        final s = _db.readingSessions;
        final existing =
            await (_db.select(s)..where(
                  (t) =>
                      t.bookId.equals(bookId) &
                      t.date.equalsValue(date) &
                      t.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        final now = _clock.now();
        if (existing == null) {
          await _db
              .into(s)
              .insert(
                ReadingSessionsCompanion.insert(
                  id: Value(uuidV7()),
                  bookId: bookId,
                  date: date,
                  minutes: minutes.clamp(1, 1440),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        } else {
          await (_db.update(s)..where((t) => t.id.equals(existing.id))).write(
            ReadingSessionsCompanion(
              minutes: Value((existing.minutes + minutes).clamp(1, 1440)),
              updatedAt: Value(now),
              rev: Value(existing.rev + 1),
            ),
          );
        }
      });
      return const Ok(null);
    } on Object catch (e, st) {
      return Err(StorageFailure(UnexpectedFailure(e, st)));
    }
  }

  Stream<int> _sum(Expression<bool> Function($ReadingSessionsTable s) where) {
    final s = _db.readingSessions;
    final total = s.minutes.sum();
    final q =
        _db.selectOnly(s).join([
            innerJoin(_db.books, _db.books.id.equalsExp(s.bookId)),
          ])
          ..addColumns(<Expression<Object>>[total])
          ..where(
            s.deletedAt.isNull() & _db.books.deletedAt.isNull() & where(s),
          );
    return q.watchSingle().map((r) => r.read(total) ?? 0);
  }

  @override
  Stream<int> watchMinutesBetween(DateTime from, DateTime to) => _sum(
    (s) =>
        s.date.isBiggerOrEqualValue(_iso(from)) &
        s.date.isSmallerOrEqualValue(_iso(to)),
  );

  @override
  Stream<int> watchMinutesForBook(String bookId) =>
      _sum((s) => s.bookId.equals(bookId));

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// The running timer in `app_meta` (device-local, never in a backup).
class DbReadingTimerStore implements ReadingTimerStore {
  DbReadingTimerStore(this._db);

  final AppDatabase _db;

  static const String bookKey = 'timer.book';
  static const String startKey = 'timer.started';

  @override
  Future<RunningTimer?> load() async {
    final rows = await (_db.select(
      _db.appMeta,
    )..where((t) => t.key.isIn(<String>[bookKey, startKey]))).get();
    final m = <String, String>{for (final r in rows) r.key: r.value};
    final book = m[bookKey];
    final ms = int.tryParse(m[startKey] ?? '');
    if (book == null || book.isEmpty || ms == null) return null;
    return RunningTimer(book, DateTime.fromMillisecondsSinceEpoch(ms));
  }

  @override
  Future<void> save(RunningTimer timer) => _db.transaction(() async {
    for (final (k, v) in <(String, String)>[
      (bookKey, timer.bookId),
      (startKey, '${timer.startedAt.millisecondsSinceEpoch}'),
    ]) {
      await _db
          .into(_db.appMeta)
          .insertOnConflictUpdate(AppMetaCompanion.insert(key: k, value: v));
    }
  });

  @override
  Future<void> clear() => (_db.delete(
    _db.appMeta,
  )..where((t) => t.key.isIn(<String>[bookKey, startKey]))).go();
}
