# Architecture

## Layers (per feature)

`presentation -> application (use cases) -> domain -> data`, with platform services underneath.
Dependencies only point downward.

- **domain**: pure Dart (no Flutter imports); immutable entities, value objects, repository interfaces.
- **application**: use cases. All writes go through them, multi-row writes in one transaction.
- **data**: Drift DAOs, Open Library client, mappers.
- **presentation**: widgets and Riverpod providers. Never touches Drift or HTTP directly.

## Rules

- Errors: sealed `Failure` classes and `Result<T>`; no raw exceptions reach the UI.
- Every platform capability is an interface with mobile and web implementations, injected via
  Riverpod: `ScannerService`, `OcrService`, `ReminderService`, `FileStore`, `ShareService`,
  `PermissionService`.
- Time comes from `Clock`, never `DateTime.now()`.
- Database providers have automatic retry disabled.
- All user-facing strings go through l10n; all colours, sizes and durations come from theme tokens.

## Data design

- All tables: UUIDv7 text `id`, `createdAt`, `updatedAt`, `deletedAt` (soft delete), `rev`.
- Drift (SQLite; WASM on web), FTS5 for search, foreign keys on, WAL on native.
- Only one active loan per book (partial unique index).

## Layout

```
lib/app/        router, shell, theme, l10n
lib/core/       result, failure, logger, uuid, clock, rate_limiter
lib/platform/   <service>/ (interface + mobile + web)
lib/data/       db/, open_library/, cache/
lib/features/<feature>/{domain,application,data,presentation}/
lib/ui/         design system components (K-prefixed widgets)
```

## Concurrent writes

`BookRepository.upsert` writes the whole record, so a stale copy overwrites newer changes. Use
`update(id, (book) => ...)` for edits to an existing book: it reads and writes inside one
transaction, so changes made by background work (cover downloads, reminders) and by the user are
never lost. Reserve `upsert` for creating a record or saving a complete form.
