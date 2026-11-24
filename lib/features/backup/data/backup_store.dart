import 'package:drift/drift.dart';

import '../../../core/uuid.dart';
import '../../../data/db/app_database.dart';
import '../domain/backup_format.dart';

typedef Row = Map<String, dynamic>;

/// One table, seen as JSON rows. Wraps the typed Drift table so the backup
/// code can treat every table the same way.
class _Table<T extends Table, D extends Insertable<D>> {
  _Table(this.db, this.name, this.table, this.fromJson, this.toJson);

  final AppDatabase db;
  final String name;
  final TableInfo<T, D> table;
  final D Function(Row json) fromJson;
  final Row Function(D row) toJson;

  Future<List<Row>> dump() async {
    final rows = (await db.select(table).get()).map(toJson).toList()
      ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
    return rows;
  }

  Future<void> deleteAll() => db.delete(table).go();

  Future<void> insert(Row json) => db.into(table).insert(fromJson(json));

  Future<void> update(Row json) => db.update(table).replace(fromJson(json));

  Future<Row?> find(String id) async {
    final r = await db
        .customSelect(
          'SELECT * FROM ${table.actualTableName} WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(id)],
          readsFrom: <TableInfo<Table, dynamic>>{table},
        )
        .getSingleOrNull();
    return r == null ? null : toJson(await table.map(r.data));
  }

  Future<List<Row>> where(String sql, List<Variable<Object>> vars) async {
    final rs = await db
        .customSelect(
          'SELECT * FROM ${table.actualTableName} WHERE $sql',
          variables: vars,
          readsFrom: <TableInfo<Table, dynamic>>{table},
        )
        .get();
    return [for (final r in rs) toJson(await table.map(r.data))];
  }
}

bool _live(Row r) => r['deletedAt'] == null;
int _updated(Row r) => r['updatedAt'] as int;
int _rev(Row r) => r['rev'] as int;
String _lower(Object? s) => (s as String).toLowerCase();

/// Reads every row for a backup and writes them back for an import. All
/// writes happen inside one transaction, so any error leaves the library
/// exactly as it was.
class BackupStore {
  BackupStore(this._db) {
    _locations = _Table(
      _db,
      'locations',
      _db.locations,
      LocationRow.fromJson,
      (r) => r.toJson(),
    );
    _tags = _Table(_db, 'tags', _db.tags, TagRow.fromJson, (r) => r.toJson());
    _goals = _Table(
      _db,
      'goals',
      _db.goals,
      GoalRow.fromJson,
      (r) => r.toJson(),
    );
    _books = _Table(
      _db,
      'books',
      _db.books,
      BookRow.fromJson,
      (r) => r.toJson(),
    );
    _loans = _Table(
      _db,
      'loans',
      _db.loans,
      LoanRow.fromJson,
      (r) => r.toJson(),
    );
    _logs = _Table(
      _db,
      'reading_logs',
      _db.readingLogs,
      ReadingLogRow.fromJson,
      (r) => r.toJson(),
    );
    _sessions = _Table(
      _db,
      'reading_sessions',
      _db.readingSessions,
      ReadingSessionRow.fromJson,
      (r) => r.toJson(),
    );
    _reads = _Table(
      _db,
      'read_throughs',
      _db.readThroughs,
      ReadThroughRow.fromJson,
      (r) => r.toJson(),
    );
    _quotes = _Table(
      _db,
      'quotes',
      _db.quotes,
      QuoteRow.fromJson,
      (r) => r.toJson(),
    );
    _bookTags = _Table(
      _db,
      'book_tags',
      _db.bookTags,
      BookTagRow.fromJson,
      (r) => r.toJson(),
    );
  }

  final AppDatabase _db;

  late final _Table<$LocationsTable, LocationRow> _locations;
  late final _Table<$TagsTable, TagRow> _tags;
  late final _Table<$GoalsTable, GoalRow> _goals;
  late final _Table<$BooksTable, BookRow> _books;
  late final _Table<$LoansTable, LoanRow> _loans;
  late final _Table<$ReadingLogsTable, ReadingLogRow> _logs;
  late final _Table<$ReadingSessionsTable, ReadingSessionRow> _sessions;
  late final _Table<$ReadThroughsTable, ReadThroughRow> _reads;
  late final _Table<$QuotesTable, QuoteRow> _quotes;
  late final _Table<$BookTagsTable, BookTagRow> _bookTags;

  /// Parents before children, matching [backupTableNames].
  late final List<(String, _Table<dynamic, dynamic>)> _ordered =
      <(String, _Table<dynamic, dynamic>)>[
        ('locations', _locations),
        ('tags', _tags),
        ('goals', _goals),
        ('books', _books),
        ('loans', _loans),
        ('reading_logs', _logs),
        ('reading_sessions', _sessions),
        ('read_throughs', _reads),
        ('quotes', _quotes),
        ('book_tags', _bookTags),
      ];

  static const String _deviceKey = 'device_id';

  /// This device's random id, created on first use.
  Future<String> deviceId() async {
    final row = await (_db.select(
      _db.appMeta,
    )..where((t) => t.key.equals(_deviceKey))).getSingleOrNull();
    if (row != null && row.value.isNotEmpty) return row.value;
    final id = uuidV7();
    await _db
        .into(_db.appMeta)
        .insertOnConflictUpdate(
          AppMetaCompanion.insert(key: _deviceKey, value: id),
        );
    return id;
  }

  int get schemaVersion => _db.schemaVersion;

  /// Every row of every backed-up table, soft-deleted ones included.
  Future<Map<String, List<Row>>> readAll() async => <String, List<Row>>{
    for (final (name, t) in _ordered) name: await t.dump(),
  };

  /// Cover references of the books, by book id (null when none).
  Future<Map<String, String>> coverReferences() async {
    final rows = await _db.select(_db.books).get();
    return <String, String>{
      for (final b in rows)
        if (b.coverLocalPath != null && b.coverLocalPath!.isNotEmpty)
          b.id: b.coverLocalPath!,
    };
  }

  /// Ids of every book currently stored (deleted ones too).
  Future<List<String>> allBookIds() async =>
      (await _db.select(_db.books).get()).map((b) => b.id).toList();

  /// Points a book at a freshly stored cover (or none), without touching its
  /// sync columns: restoring a file is not an edit.
  Future<void> setCoverReference(String bookId, String? reference) =>
      (_db.update(_db.books)..where((t) => t.id.equals(bookId))).write(
        BooksCompanion(coverLocalPath: Value(reference)),
      );

  /// The current cover reference of one book.
  Future<String?> coverReferenceOf(String bookId) async => (await (_db.select(
    _db.books,
  )..where((t) => t.id.equals(bookId))).getSingleOrNull())?.coverLocalPath;

  // ---------------------------------------------------------------- replace

  /// Wipes the library and inserts [tables]. Foreign keys are checked at
  /// commit, so the order of rows cannot matter.
  Future<ImportSummary> replaceAll(Map<String, List<Row>> tables) =>
      _db.transaction(() async {
        await _db.customStatement('PRAGMA defer_foreign_keys = ON');
        for (final (_, t) in _ordered.reversed) {
          await t.deleteAll();
        }
        for (final (name, t) in _ordered) {
          for (final row in tables[name] ?? const <Row>[]) {
            await t.insert(row);
          }
        }
        return _summary(<String, int>{
          for (final name in backupTableNames)
            name: (tables[name] ?? const <Row>[]).where(_live).length,
        });
      });

  // ------------------------------------------------------------------ merge

  /// Folds [tables] into the library: the newer `updatedAt` wins per id, and
  /// rows that would break a uniqueness rule under a different id are folded
  /// into the one already here (see `docs/BACKUP_FORMAT.md`).
  Future<ImportSummary> mergeAll(Map<String, List<Row>> tables) =>
      _db.transaction(() async {
        await _db.customStatement('PRAGMA defer_foreign_keys = ON');
        final counts = <String, int>{for (final n in backupTableNames) n: 0};
        // Backup id -> local id, for rows folded into an existing one.
        final remap = <String, String>{};
        String? mapped(Object? id) =>
            id == null ? null : remap[id] ?? id as String;

        Future<void> apply<T extends Table, D extends Insertable<D>>(
          _Table<T, D> t,
          Row row,
          String name,
        ) async {
          final local = await t.find(row['id'] as String);
          if (local == null) {
            await t.insert(row);
          } else if (_backupWins(row, local)) {
            await t.update(row);
          } else {
            return;
          }
          if (_live(row)) counts[name] = counts[name]! + 1;
        }

        // Locations: parents first, so a child's folded parent is known.
        for (final row in _parentsFirst(tables['locations'] ?? const <Row>[])) {
          row['parentId'] = mapped(row['parentId']);
          if (_live(row)) {
            final same = (await _locations.where(
              'deleted_at IS NULL AND lower(name) = ? AND '
              "coalesce(parent_id, '') = ? AND id != ?",
              <Variable<Object>>[
                Variable<String>(_lower(row['name'])),
                Variable<String>((row['parentId'] as String?) ?? ''),
                Variable<String>(row['id'] as String),
              ],
            ));
            if (same.isNotEmpty) {
              remap[row['id'] as String] = same.first['id'] as String;
              continue;
            }
          }
          await apply(_locations, row, 'locations');
        }

        for (final row in tables['tags'] ?? const <Row>[]) {
          if (_live(row)) {
            final same = await _tags.where(
              'deleted_at IS NULL AND lower(name) = ? AND id != ?',
              <Variable<Object>>[
                Variable<String>(_lower(row['name'])),
                Variable<String>(row['id'] as String),
              ],
            );
            if (same.isNotEmpty) {
              remap[row['id'] as String] = same.first['id'] as String;
              continue;
            }
          }
          await apply(_tags, row, 'tags');
        }

        for (final row in tables['goals'] ?? const <Row>[]) {
          if (_live(row)) {
            final same = await _goals.where(
              'deleted_at IS NULL AND year = ? AND id != ?',
              <Variable<Object>>[
                Variable<int>(row['year'] as int),
                Variable<String>(row['id'] as String),
              ],
            );
            if (same.isNotEmpty) {
              final local = same.first;
              remap[row['id'] as String] = local['id'] as String;
              // One goal per year: the newer target wins.
              if (_updated(row) > _updated(local)) {
                await _goals.update(<String, dynamic>{
                  ...local,
                  'targetBooks': row['targetBooks'],
                  'updatedAt': row['updatedAt'],
                  'rev': _rev(local) + 1,
                });
              }
              continue;
            }
          }
          await apply(_goals, row, 'goals');
        }

        for (final row in tables['books'] ?? const <Row>[]) {
          row['locationId'] = mapped(row['locationId']);
          await apply(_books, row, 'books');
        }

        for (final row in tables['loans'] ?? const <Row>[]) {
          row['previousLocationId'] = mapped(row['previousLocationId']);
          if (_live(row) && row['returnedOn'] == null) {
            final clash = await _loans.where(
              'deleted_at IS NULL AND returned_on IS NULL AND book_id = ? '
              'AND id != ?',
              <Variable<Object>>[
                Variable<String>(row['bookId'] as String),
                Variable<String>(row['id'] as String),
              ],
            );
            if (clash.isNotEmpty) continue; // the local loan stays
          }
          await apply(_loans, row, 'loans');
        }

        for (final row in tables['reading_logs'] ?? const <Row>[]) {
          await apply(_logs, row, 'reading_logs');
        }
        for (final row in tables['reading_sessions'] ?? const <Row>[]) {
          await apply(_sessions, row, 'reading_sessions');
        }
        for (final row in tables['read_throughs'] ?? const <Row>[]) {
          await apply(_reads, row, 'read_throughs');
        }
        for (final row in tables['quotes'] ?? const <Row>[]) {
          await apply(_quotes, row, 'quotes');
        }

        for (final row in tables['book_tags'] ?? const <Row>[]) {
          row['tagId'] = mapped(row['tagId']);
          if (_live(row)) {
            final clash = await _bookTags.where(
              'deleted_at IS NULL AND book_id = ? AND tag_id = ? AND id != ?',
              <Variable<Object>>[
                Variable<String>(row['bookId'] as String),
                Variable<String>(row['tagId'] as String),
                Variable<String>(row['id'] as String),
              ],
            );
            if (clash.isNotEmpty) continue;
          }
          await apply(_bookTags, row, 'book_tags');
        }
        return _summary(counts);
      });

  ImportSummary _summary(Map<String, int> counts) => ImportSummary(
    books: counts['books'] ?? 0,
    loans: counts['loans'] ?? 0,
    quotes: counts['quotes'] ?? 0,
    readingLogs: counts['reading_logs'] ?? 0,
  );

  /// Newer `updatedAt` wins; a higher `rev` breaks a tie; on a full tie the
  /// local row stays.
  bool _backupWins(Row backup, Row local) {
    final a = _updated(backup);
    final b = _updated(local);
    if (a != b) return a > b;
    return _rev(backup) > _rev(local);
  }

  /// Locations ordered so each parent comes before its children. A parent
  /// that is not in the backup counts as already there.
  List<Row> _parentsFirst(List<Row> rows) {
    final ids = <String>{for (final r in rows) r['id'] as String};
    final done = <String>{};
    final out = <Row>[];
    var pending = List<Row>.of(rows);
    while (pending.isNotEmpty) {
      final next = <Row>[];
      for (final r in pending) {
        final parent = r['parentId'] as String?;
        if (parent == null || !ids.contains(parent) || done.contains(parent)) {
          out.add(r);
          done.add(r['id'] as String);
        } else {
          next.add(r);
        }
      }
      if (next.length == pending.length) {
        // A cycle: take them as they are rather than loop forever.
        out.addAll(next);
        break;
      }
      pending = next;
    }
    return out;
  }
}
