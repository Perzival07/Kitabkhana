import 'package:drift/drift.dart';

import '../../core/logger.dart';
import '../../core/uuid.dart';
import '../../features/lending/domain/loan_direction.dart';
import '../../features/library/domain/book_enums.dart';
import 'converters.dart';
import 'schema_versions.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[
    Books,
    Locations,
    Loans,
    ReadingLogs,
    Quotes,
    Goals,
    Tags,
    BookTags,
    LookupCache,
    AppMeta,
    CoverBlobs,
  ],
  include: <String>{'search.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e, {this.logger, this.runIntegrityCheck = false});

  final AppLogger? logger;

  /// Run `PRAGMA integrity_check` on open (dev only).
  final bool runIntegrityCheck;

  /// Bump when tables change and add a migration step in `onUpgrade`.
  /// Must stay a literal: `drift_dev make-migrations` reads it statically.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      // v2: cover images for platforms without a file system (web).
      from1To2: (m, schema) async {
        await m.createTable(schema.coverBlobs);
      },
    ),
    beforeOpen: (details) async {
      // Must run outside a transaction, on every open.
      await customStatement('PRAGMA foreign_keys = ON');
      if (runIntegrityCheck) {
        final rows = await customSelect('PRAGMA integrity_check').get();
        final result = rows.first.data.values.first;
        if (result != 'ok') {
          logger?.error('db integrity check failed');
        }
      }
      logger?.info(
        'db opened, schema v${details.versionNow}'
        '${details.wasCreated ? ' (created)' : ''}',
      );
    },
  );

  // Default queries: soft-deleted rows are excluded. Use these instead of
  // `select(table)` so deleted rows never leak into the UI.

  SimpleSelectStatement<$BooksTable, BookRow> liveBooks() =>
      select(books)..where((t) => t.deletedAt.isNull());

  SimpleSelectStatement<$LocationsTable, LocationRow> liveLocations() =>
      select(locations)..where((t) => t.deletedAt.isNull());

  SimpleSelectStatement<$LoansTable, LoanRow> liveLoans() =>
      select(loans)..where((t) => t.deletedAt.isNull());

  SimpleSelectStatement<$ReadingLogsTable, ReadingLogRow> liveReadingLogs() =>
      select(readingLogs)..where((t) => t.deletedAt.isNull());

  SimpleSelectStatement<$QuotesTable, QuoteRow> liveQuotes() =>
      select(quotes)..where((t) => t.deletedAt.isNull());

  SimpleSelectStatement<$GoalsTable, GoalRow> liveGoals() =>
      select(goals)..where((t) => t.deletedAt.isNull());

  SimpleSelectStatement<$TagsTable, TagRow> liveTags() =>
      select(tags)..where((t) => t.deletedAt.isNull());
}
