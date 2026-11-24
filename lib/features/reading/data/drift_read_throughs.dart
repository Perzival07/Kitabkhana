import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/result.dart';
import '../../../core/uuid.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/db_guard.dart';
import '../domain/read_through.dart';

class DriftReadThroughRepository implements ReadThroughRepository {
  DriftReadThroughRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  @override
  Stream<List<ReadThrough>> watchForBook(String bookId) {
    final r = _db.readThroughs;
    return (_db.liveReadThroughs()
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy(<OrderClauseGenerator<$ReadThroughsTable>>[
            (t) => OrderingTerm.desc(r.finishedOn),
            (t) => OrderingTerm.desc(r.startedOn),
          ]))
        .watch()
        .map(
          (rows) => <ReadThrough>[
            for (final x in rows)
              ReadThrough(
                id: x.id,
                bookId: x.bookId,
                startedOn: x.startedOn,
                finishedOn: x.finishedOn,
              ),
          ],
        );
  }

  @override
  Future<Result<void>> add(
    String bookId, {
    DateTime? startedOn,
    DateTime? finishedOn,
  }) => dbGuard(() async {
    final now = _clock.now();
    await _db
        .into(_db.readThroughs)
        .insert(
          ReadThroughsCompanion.insert(
            id: Value(uuidV7()),
            bookId: bookId,
            startedOn: Value(startedOn),
            finishedOn: Value(finishedOn),
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  @override
  Future<Result<void>> softDelete(String id) => dbGuard(() async {
    final now = _clock.now();
    await (_db.update(_db.readThroughs)..where((t) => t.id.equals(id))).write(
      ReadThroughsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  });
}
