# Database

Drift (SQLite). Native: SQLite via FFI in WAL mode. Web: `sqlite3.wasm` plus `drift_worker.js`.

## Schema (v3)

Synced tables carry `SyncColumns`: `id` (UUIDv7 text), `createdAt`, `updatedAt`, `deletedAt`
(soft delete), `rev`. Repositories set timestamps from the app `Clock` and bump `rev` on each write.

`Books`, `Locations`, `Loans`, `ReadingLogs`, `Quotes`, `Goals`, `Tags`, `BookTags`.

Three tables are device-local and deliberately have **no** `SyncColumns`: `LookupCache` (Open Library
cache, keyed by `key`), `AppMeta` (settings key/value) and `CoverBlobs` (v2: processed cover JPEGs for
web, one row per book, cascade-deleted with the book). They are not merged between devices.

Timestamps are stored as ISO-8601 text. Calendar dates (`startedOn`, `finishedOn`, loan dates,
reading-log `date`) are `yyyy-MM-dd` text via `DateOnlyConverter`, so they never shift with time zones.

Constraints live in table-level `customConstraints` (pages > 0, current page >= 0, rating 1..5,
enum values, `pagesRead > 0`, `targetBooks > 0`). Indexes, partial unique indexes and FTS are in
`lib/data/db/search.drift`:

- one active loan per book: unique on `loans(book_id)` where not returned and not deleted
- one goal per year, one tag name (any case), one location name per parent (any case), one tag per
  book, each among non-deleted rows

`PRAGMA foreign_keys = ON` runs on every open. Deleting a location sets `books.location_id`,
`loans.previous_location_id` and child `parent_id` to NULL.

## Search

`books_fts` is an FTS5 external-content table over `title`, `subtitle`, `authors`
(`unicode61 remove_diacritics 2`). Triggers index **only non-deleted** books, so soft delete
removes a book from search and restoring adds it back. Query with prefix tokens, e.g. `harr*`.

FTS5 is compiled into the shipped `sqlite3.wasm` and verified end to end in Chrome, so no `LIKE`
fallback on `titleKey` is needed.

## Soft delete

Use `db.liveBooks()` (and `liveLocations`, `liveLoans`, ...) rather than `select(table)`: they
exclude rows with `deletedAt` set.

## Web setup

1. `web/sqlite3.wasm` from the `sqlite3-<version>` release of `simolus3/sqlite3.dart` matching the
   resolved `sqlite3` version (3.5.2).
2. `web/drift_worker.js` from the `drift-<version>` release of `simolus3/drift` (2.35.4).
3. `openAppConnection()` points `DriftWebOptions` at both files.

Without COOP/COEP headers Drift uses shared IndexedDB storage (works everywhere). OPFS storage
needs cross-origin isolation headers; revisit in P11.4. Re-download both files when upgrading
`drift` or `sqlite3`.

## Migrations

`schemaVersion` is a literal in `AppDatabase` (`drift_dev` reads it statically). To change the schema:

1. Edit the tables, bump `schemaVersion`.
2. `dart run build_runner build`
3. `dart run drift_dev make-migrations` (writes `drift_schemas/default/drift_schema_vN.json`,
   updates `lib/data/db/app_database.steps.dart` and generated test helpers).
4. Fill in the new `fromXToY` step in `migrationSteps()` (called by `stepByStep()`).
5. Add a migration test using `SchemaVerifier` (see `test/drift/default/migration_test.dart`).

## Version history

- **v1**: initial schema.
- **v3**: `books.series` and `books.series_number`; `reading_sessions` (minutes read per book
  per day, from the reading timer); `read_throughs` (earlier reads of a book being read
  again). Migrated in `from2To3` with `addColumn`/`createTable`, covered by
  `test/drift/default/migration_test.dart` (v1 and v2 both reach v3; data survives).
- **v2**: `cover_blobs` table (web cover storage). Migrated with `m.createTable` in `from1To2`,
  covered by `test/drift/default/migration_test.dart` (data survives, new table works, cascade
  works) and verified on a real persisted browser database.
