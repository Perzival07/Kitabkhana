import 'package:drift/drift.dart';

import '../../../core/result.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/converters.dart';
import '../../../data/db/db_guard.dart';
import '../../library/data/book_mapper.dart';
import '../../library/domain/book.dart';
import '../domain/stats.dart';
import '../domain/stats_repository.dart';

/// SQL aggregates over live (non-deleted) rows.
class DriftStatsRepository implements StatsRepository {
  DriftStatsRepository(this._db);

  final AppDatabase _db;

  static const _dates = DateOnlyConverter();

  Set<TableInfo<Table, dynamic>> get _reads => <TableInfo<Table, dynamic>>{
    _db.books,
    _db.loans,
    _db.readingLogs,
    _db.readThroughs,
  };

  /// `books` rows finished in the year bound to the first `?`.
  static const _finishedInYear =
      "deleted_at IS NULL AND status = 'finished' AND finished_on IS NOT NULL "
      'AND substr(finished_on, 1, 4) = ?';

  /// Every finished read as a `fin` table: each book's current read when it
  /// is finished, plus its earlier reads (re-reads count every time). The
  /// book's columns, with `finished_on` taken from the read.
  static const _finBody =
      'SELECT * FROM books '
      "WHERE deleted_at IS NULL AND status = 'finished' "
      'AND finished_on IS NOT NULL '
      'UNION ALL '
      'SELECT b.id, b.created_at, b.updated_at, b.deleted_at, b.rev, '
      'b.isbn13, b.ol_work_key, b.title, b.subtitle, b.authors, b.title_key, '
      'b.cover_url, b.cover_local_path, b.pages, b.genre, b.language, '
      'b.ownership, b.status, b.current_page, b.rating, b.location_id, '
      'b.owner_name, b.notes, b.started_on, r.finished_on, b.series, '
      'b.series_number '
      'FROM read_throughs r JOIN books b ON b.id = r.book_id '
      'WHERE r.deleted_at IS NULL AND b.deleted_at IS NULL '
      'AND r.finished_on IS NOT NULL';

  static const _fin = 'WITH fin AS ($_finBody) ';

  static const _finYear = 'substr(finished_on, 1, 4) = ?';

  Selectable<QueryRow> _q(String sql, [List<Variable<Object>> v = const []]) =>
      _db.customSelect(sql, variables: v, readsFrom: _reads);

  @override
  Stream<int> watchFinishedCount(int year) => _q(
    '${_fin}SELECT COUNT(*) AS c FROM fin WHERE $_finYear',
    [Variable<String>(_year(year))],
  ).watchSingle().map((r) => r.read<int>('c'));

  @override
  Stream<List<int>> watchFinishedPerMonth(int year) =>
      _q(
        '${_fin}SELECT CAST(substr(finished_on, 6, 2) AS INTEGER) AS m, '
        'COUNT(*) AS c FROM fin WHERE $_finYear GROUP BY m',
        [Variable<String>(_year(year))],
      ).watch().map((rows) {
        final out = List<int>.filled(12, 0);
        for (final r in rows) {
          final m = r.read<int>('m');
          if (m >= 1 && m <= 12) out[m - 1] = r.read<int>('c');
        }
        return out;
      });

  @override
  Future<Result<List<Book>>> finishedInMonth(int year, int month) =>
      dbGuard(() async {
        final mm = month.toString().padLeft(2, '0');
        final rows = await _q(
          '${_fin}SELECT * FROM fin WHERE $_finYear '
          'AND substr(finished_on, 6, 2) = ? '
          'ORDER BY finished_on DESC, title',
          [Variable<String>(_year(year)), Variable<String>(mm)],
        ).get();
        return rows.map((r) => _db.books.map(r.data).toDomain()).toList();
      });

  @override
  Stream<List<WeekPages>> watchPagesPerWeek(DateTime end, {int weeks = 12}) {
    final day = _dates.toSql(end);
    return _q(
      'SELECT CAST((julianday(?) - julianday(l.date)) / 7 AS INTEGER) AS w, '
      'SUM(l.pages_read) AS p '
      'FROM reading_logs l JOIN books b ON b.id = l.book_id '
      'WHERE l.deleted_at IS NULL AND b.deleted_at IS NULL '
      "AND l.date <= ? AND l.date > date(?, '-${weeks * 7} days') "
      'GROUP BY w',
      [Variable<String>(day), Variable<String>(day), Variable<String>(day)],
    ).watch().map((rows) {
      final byWeek = <int, int>{
        for (final r in rows) r.read<int>('w'): r.read<int>('p'),
      };
      return <WeekPages>[
        for (var w = weeks - 1; w >= 0; w--)
          WeekPages(
            DateTime(end.year, end.month, end.day - 6 - 7 * w),
            byWeek[w] ?? 0,
          ),
      ];
    });
  }

  @override
  Stream<List<LabelCount>> watchTopGenres(int year, {int limit = 5}) => _q(
    '${_fin}SELECT trim(genre) AS label, COUNT(*) AS c FROM fin '
    "WHERE $_finYear AND trim(genre) <> '' "
    'GROUP BY lower(trim(genre)) ORDER BY c DESC, label LIMIT ?',
    [Variable<String>(_year(year)), Variable<int>(limit)],
  ).watch().map(_labels);

  @override
  Stream<List<LabelCount>> watchTopAuthors(int year, {int limit = 5}) => _q(
    'WITH RECURSIVE fin AS ($_finBody), '
    'split(author, rest) AS ('
    "SELECT '', trim(authors) || ',' FROM fin WHERE $_finYear "
    'UNION ALL '
    "SELECT trim(substr(rest, 1, instr(rest, ',') - 1)), "
    "substr(rest, instr(rest, ',') + 1) FROM split WHERE rest <> ''"
    ') SELECT author AS label, COUNT(*) AS c FROM split '
    "WHERE author <> '' GROUP BY lower(author) "
    'ORDER BY c DESC, label LIMIT ?',
    [Variable<String>(_year(year)), Variable<int>(limit)],
  ).watch().map(_labels);

  List<LabelCount> _labels(List<QueryRow> rows) => [
    for (final r in rows) LabelCount(r.read<String>('label'), r.read<int>('c')),
  ];

  @override
  Stream<LibraryFacts> watchFacts(int year) =>
      _q(
        'SELECT '
        '(SELECT COUNT(*) FROM books WHERE deleted_at IS NULL) AS total, '
        "(SELECT COUNT(*) FROM books WHERE deleted_at IS NULL AND ownership = 'owned') AS owned, "
        "(SELECT COUNT(*) FROM books WHERE deleted_at IS NULL AND ownership = 'wishlist') AS wish, "
        '(SELECT COUNT(*) FROM loans l JOIN books b ON b.id = l.book_id '
        "WHERE l.deleted_at IS NULL AND b.deleted_at IS NULL AND l.direction = 'lent' "
        'AND l.returned_on IS NULL) AS lent, '
        '(SELECT AVG(rating) FROM books WHERE deleted_at IS NULL AND rating IS NOT NULL) AS avg_rating, '
        '(SELECT title FROM books WHERE $_finishedInYear AND pages IS NOT NULL '
        'ORDER BY pages DESC, title LIMIT 1) AS long_title, '
        '(SELECT MAX(pages) FROM books WHERE $_finishedInYear) AS long_pages',
        [Variable<String>(_year(year)), Variable<String>(_year(year))],
      ).watchSingle().map((r) {
        final title = r.readNullable<String>('long_title');
        final pages = r.readNullable<int>('long_pages');
        return LibraryFacts(
          totalBooks: r.read<int>('total'),
          owned: r.read<int>('owned'),
          wishlist: r.read<int>('wish'),
          lentOut: r.read<int>('lent'),
          averageRating: r.readNullable<double>('avg_rating'),
          longest: title == null || pages == null
              ? null
              : LongestBook(title, pages),
        );
      });

  @override
  Stream<List<int>> watchFinishedYears() => _q(
    '${_fin}SELECT DISTINCT CAST(substr(finished_on, 1, 4) AS INTEGER) AS y '
    'FROM fin ORDER BY y DESC',
  ).watch().map((rows) => [for (final r in rows) r.read<int>('y')]);

  static String _year(int y) => y.toString().padLeft(4, '0');
}
