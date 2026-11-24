import 'package:drift/drift.dart';

import '../../../data/db/app_database.dart';

typedef CsvRecord = Map<String, Object?>;

/// The rows behind the CSV exports, read with SQL (live rows only).
class CsvStore {
  CsvStore(this._db);

  final AppDatabase _db;

  Set<TableInfo<Table, dynamic>> get _reads => <TableInfo<Table, dynamic>>{
    _db.books,
    _db.bookTags,
    _db.tags,
    _db.loans,
    _db.locations,
  };

  /// Books by title, each with its tag names joined by `; `.
  Future<List<CsvRecord>> books() async {
    final rows = await _db
        .customSelect(
          'SELECT b.title, b.authors, b.isbn13, b.status, b.ownership, '
          'b.location_id, b.rating, b.pages, b.started_on, b.finished_on, '
          'b.series, b.series_number, '
          "(SELECT group_concat(name, '; ') FROM ("
          'SELECT t.name AS name FROM book_tags bt '
          'JOIN tags t ON t.id = bt.tag_id '
          'WHERE bt.book_id = b.id AND bt.deleted_at IS NULL '
          'AND t.deleted_at IS NULL ORDER BY lower(t.name))) AS tag_names '
          'FROM books b WHERE b.deleted_at IS NULL '
          'ORDER BY lower(b.title), b.id',
          readsFrom: _reads,
        )
        .get();
    return [for (final r in rows) r.data];
  }

  /// Every location (deleted ones too, so an old reference still has a name).
  Future<List<CsvRecord>> locations() async {
    final rows = await _db
        .customSelect(
          'SELECT id, name, parent_id FROM locations',
          readsFrom: _reads,
        )
        .get();
    return [for (final r in rows) r.data];
  }

  /// Loans, newest first, with the book's title and authors.
  Future<List<CsvRecord>> loans() async {
    final rows = await _db
        .customSelect(
          'SELECT b.title, b.authors, l.direction, l.person_name, '
          'l.person_phone, l.started_on, l.due_on, l.returned_on, l.note '
          'FROM loans l JOIN books b ON b.id = l.book_id '
          'WHERE l.deleted_at IS NULL AND b.deleted_at IS NULL '
          'ORDER BY l.started_on DESC, l.id',
          readsFrom: _reads,
        )
        .get();
    return [for (final r in rows) r.data];
  }
}
