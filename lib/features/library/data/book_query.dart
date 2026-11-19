import 'package:drift/drift.dart';

import '../../../core/text/fts_query.dart';
import '../domain/book_filter.dart';

/// A parameterised SQL fragment.
class SqlFragment {
  const SqlFragment(this.sql, this.variables);

  final String sql;
  final List<Variable<Object>> variables;
}

const String _activeLoan =
    'l.book_id = books.id AND l.returned_on IS NULL AND l.deleted_at IS NULL';

/// The WHERE clause (without the keyword) for [filter]. Always excludes
/// soft-deleted books.
SqlFragment bookWhere(BookFilter filter) {
  final clauses = <String>['books.deleted_at IS NULL'];
  final vars = <Variable<Object>>[];

  final status = filter.status;
  if (status != null) {
    clauses.add('books.status = ?');
    vars.add(Variable<String>(status.name));
  }
  final ownership = filter.ownership;
  if (ownership != null) {
    clauses.add('books.ownership = ?');
    vars.add(Variable<String>(ownership.name));
  }
  if (filter.lentOut) {
    clauses.add(
      "EXISTS (SELECT 1 FROM loans l WHERE $_activeLoan AND l.direction = 'lent')",
    );
  }
  if (filter.borrowed) {
    clauses.add(
      "(books.ownership = 'borrowed' OR EXISTS "
      "(SELECT 1 FROM loans l WHERE $_activeLoan AND l.direction = 'borrowed'))",
    );
  }
  final locationId = filter.locationId;
  if (locationId != null) {
    clauses.add('books.location_id = ?');
    vars.add(Variable<String>(locationId));
  }
  final tagId = filter.tagId;
  if (tagId != null) {
    clauses.add(
      'EXISTS (SELECT 1 FROM book_tags bt WHERE bt.book_id = books.id '
      'AND bt.tag_id = ? AND bt.deleted_at IS NULL)',
    );
    vars.add(Variable<String>(tagId));
  }
  final fts = buildFtsQuery(filter.query);
  if (fts != null) {
    clauses.add(
      'books.rowid IN (SELECT rowid FROM books_fts WHERE books_fts MATCH ?)',
    );
    vars.add(Variable<String>(fts));
  }
  return SqlFragment(clauses.join(' AND '), vars);
}

/// The ORDER BY expression list for [sort].
String bookOrderBy(BookSort sort) {
  switch (sort) {
    case BookSort.recentlyAdded:
      return 'books.created_at DESC, books.id DESC';
    case BookSort.title:
      return 'books.title_key ASC, books.id ASC';
    case BookSort.author:
      // Sort by first-author surname, which title_key stores after the '|'.
      // Books without an author sort last.
      return "(instr(books.title_key, '|') = 0) ASC, "
          "substr(books.title_key, instr(books.title_key, '|') + 1) ASC, "
          'books.title_key ASC, books.id ASC';
    case BookSort.recentlyRead:
      return "COALESCE((SELECT MAX(r.date) FROM reading_logs r "
          "WHERE r.book_id = books.id AND r.deleted_at IS NULL), '') DESC, "
          'books.created_at DESC, books.id DESC';
    case BookSort.rating:
      return 'COALESCE(books.rating, 0) DESC, books.title_key ASC, books.id ASC';
  }
}
