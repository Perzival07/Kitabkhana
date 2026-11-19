import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/db_guard.dart';
import '../../../data/db/sync_sql.dart';
import '../domain/quote.dart';
import '../domain/quote_repository.dart';

Quote _toDomain(QuoteRow r) => Quote(
  id: r.id,
  createdAt: r.createdAt,
  updatedAt: r.updatedAt,
  deletedAt: r.deletedAt,
  rev: r.rev,
  bookId: r.bookId,
  body: r.body,
  page: r.page,
  isFavourite: r.isFavourite,
);

QuotesCompanion _toCompanion(
  Quote q, {
  required DateTime updatedAt,
  required int rev,
  DateTime? createdAt,
}) => QuotesCompanion(
  id: Value(q.id),
  createdAt: createdAt == null ? const Value.absent() : Value(createdAt),
  updatedAt: Value(updatedAt),
  deletedAt: Value(q.deletedAt),
  rev: Value(rev),
  bookId: Value(q.bookId),
  body: Value(q.body),
  page: Value(q.page),
  isFavourite: Value(q.isFavourite),
);

class DriftQuoteRepository implements QuoteRepository {
  DriftQuoteRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  @override
  Stream<List<Quote>> watchAll({String? bookId, bool favouritesOnly = false}) {
    final q = _db.quotes;
    final query =
        _db.select(q).join([
            innerJoin(_db.books, _db.books.id.equalsExp(q.bookId)),
          ])
          ..where(
            q.deletedAt.isNull() &
                _db.books.deletedAt.isNull() &
                (bookId == null
                    ? const Constant(true)
                    : q.bookId.equals(bookId)) &
                (favouritesOnly
                    ? q.isFavourite.equals(true)
                    : const Constant(true)),
          )
          ..orderBy([OrderingTerm.desc(q.createdAt), OrderingTerm.desc(q.id)]);
    return query.watch().map(
      (rows) => rows.map((r) => _toDomain(r.readTable(q))).toList(),
    );
  }

  @override
  Future<Result<Quote?>> getById(String id) => dbGuard(() async {
    final row = await (_db.liveQuotes()..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  });

  @override
  Future<Result<Quote>> upsert(Quote quote) => dbGuard(
    () => _db.transaction(() async {
      final now = _clock.now();
      final existing = await (_db.select(
        _db.quotes,
      )..where((t) => t.id.equals(quote.id))).getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.quotes)
            .insert(
              _toCompanion(quote, createdAt: now, updatedAt: now, rev: 1),
            );
      } else {
        await (_db.update(_db.quotes)..where((t) => t.id.equals(quote.id)))
            .write(_toCompanion(quote, updatedAt: now, rev: existing.rev + 1));
      }
      final saved = await (_db.select(
        _db.quotes,
      )..where((t) => t.id.equals(quote.id))).getSingle();
      return _toDomain(saved);
    }),
  );

  @override
  Future<Result<void>> softDelete(String id) => dbGuard(() async {
    final n = await softDeleteById(
      _db,
      table: _db.quotes,
      id: id,
      now: _clock.now(),
    );
    if (n == 0) throw const FailureException(NotFoundFailure('quote'));
  });

  @override
  Future<Result<void>> restore(String id) => dbGuard(() async {
    final n = await restoreById(
      _db,
      table: _db.quotes,
      id: id,
      now: _clock.now(),
    );
    if (n == 0) throw const FailureException(NotFoundFailure('quote'));
  });
}
