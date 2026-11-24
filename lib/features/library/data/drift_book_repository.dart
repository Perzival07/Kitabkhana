import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../core/text/fts_query.dart';
import '../../../core/text/isbn.dart';
import '../../../core/text/title_key.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/db_guard.dart';
import '../../../data/db/sync_sql.dart';
import '../domain/book.dart';
import '../domain/book_filter.dart';
import '../domain/book_repository.dart';
import 'book_mapper.dart';
import 'book_query.dart';

class DriftBookRepository implements BookRepository {
  DriftBookRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  Set<TableInfo<Table, Object?>> get _reads => <TableInfo<Table, Object?>>{
    _db.books,
    _db.loans,
    _db.bookTags,
    _db.readingLogs,
  };

  Book _mapRow(QueryRow row) => _db.books.map(row.data).toDomain();

  @override
  Stream<List<Book>> watchAll({
    BookFilter filter = const BookFilter(),
    BookSort sort = BookSort.recentlyAdded,
    int limit = 100,
    int offset = 0,
  }) {
    final where = bookWhere(filter);
    return _db
        .customSelect(
          'SELECT books.* FROM books WHERE ${where.sql} '
          'ORDER BY ${bookOrderBy(sort)} LIMIT ? OFFSET ?',
          variables: <Variable<Object>>[
            ...where.variables,
            Variable<int>(limit),
            Variable<int>(offset),
          ],
          readsFrom: _reads,
        )
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }

  @override
  Stream<int> watchCount({BookFilter filter = const BookFilter()}) {
    final where = bookWhere(filter);
    return _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM books WHERE ${where.sql}',
          variables: where.variables,
          readsFrom: _reads,
        )
        .watchSingle()
        .map((row) => row.read<int>('c'));
  }

  @override
  Stream<Book?> watchById(String id) {
    final query = _db.select(_db.books)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return query.watchSingleOrNull().map((row) => row?.toDomain());
  }

  @override
  Stream<List<Book>> watchSeries(String series) {
    final name = series.trim().toLowerCase();
    final query = _db.select(_db.books)
      ..where((t) => t.deletedAt.isNull() & t.series.lower().equals(name))
      ..orderBy(<OrderClauseGenerator<$BooksTable>>[
        (t) => OrderingTerm(expression: t.seriesNumber, nulls: NullsOrder.last),
        (t) => OrderingTerm(expression: t.title),
      ]);
    return query.watch().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<Result<Book?>> getById(String id) => dbGuard(() async {
    final row = await (_db.select(
      _db.books,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return row?.toDomain();
  });

  @override
  Future<Result<List<Book>>> search(String query, {int limit = 20}) =>
      dbGuard(() async {
        final fts = buildFtsQuery(query);
        if (fts == null) return <Book>[];
        final rows = await _db
            .customSelect(
              'SELECT books.* FROM books_fts '
              'JOIN books ON books.rowid = books_fts.rowid '
              'WHERE books_fts MATCH ? AND books.deleted_at IS NULL '
              'ORDER BY bm25(books_fts, 10.0, 2.0, 5.0), books.title_key '
              'LIMIT ?',
              variables: [Variable<String>(fts), Variable<int>(limit)],
              readsFrom: {_db.books},
            )
            .get();
        return rows.map(_mapRow).toList();
      });

  Future<List<Book>> _where(
    Expression<bool> Function($BooksTable t) test,
  ) async {
    final rows =
        await (_db.select(_db.books)
              ..where((t) => t.deletedAt.isNull() & test(t))
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Result<List<Book>>> findByIsbn(Isbn13 isbn) =>
      dbGuard(() => _where((t) => t.isbn13.equals(isbn.value)));

  @override
  Future<Result<List<Book>>> findByWorkKey(String workKey) =>
      dbGuard(() => _where((t) => t.olWorkKey.equals(workKey)));

  @override
  Future<Result<List<Book>>> findByTitleKey(TitleKey key) =>
      dbGuard(() => _where((t) => t.titleKey.equals(key.value)));

  @override
  Future<Result<Book>> upsert(Book book) => dbGuard(
    () => _db.transaction(() async {
      final now = _clock.now();
      final existing = await (_db.select(
        _db.books,
      )..where((t) => t.id.equals(book.id))).getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.books)
            .insert(
              bookToCompanion(book, createdAt: now, updatedAt: now, rev: 1),
            );
      } else {
        await (_db.update(_db.books)..where((t) => t.id.equals(book.id))).write(
          bookToCompanion(book, updatedAt: now, rev: existing.rev + 1),
        );
      }
      final saved = await (_db.select(
        _db.books,
      )..where((t) => t.id.equals(book.id))).getSingle();
      return saved.toDomain();
    }),
  );

  @override
  Future<Result<Book>> update(String id, Book Function(Book current) change) =>
      dbGuard(
        () => _db.transaction(() async {
          final row =
              await (_db.select(_db.books)
                    ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
                  .getSingleOrNull();
          if (row == null) {
            throw const FailureException(NotFoundFailure('book'));
          }
          final changed = change(row.toDomain());
          await (_db.update(_db.books)..where((t) => t.id.equals(id))).write(
            bookToCompanion(changed, updatedAt: _clock.now(), rev: row.rev + 1),
          );
          final saved = await (_db.select(
            _db.books,
          )..where((t) => t.id.equals(id))).getSingle();
          return saved.toDomain();
        }),
      );

  @override
  Future<Result<void>> softDelete(String id) => dbGuard(() async {
    final n = await softDeleteById(
      _db,
      table: _db.books,
      id: id,
      now: _clock.now(),
    );
    if (n == 0) throw const FailureException(NotFoundFailure('book'));
  });

  @override
  Future<Result<void>> restore(String id) => dbGuard(() async {
    final n = await restoreById(
      _db,
      table: _db.books,
      id: id,
      now: _clock.now(),
    );
    if (n == 0) throw const FailureException(NotFoundFailure('book'));
  });
}
