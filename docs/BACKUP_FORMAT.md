# Kitabkhana backup format (`.kitab`)

A `.kitab` file is a plain **zip archive**. You can open it with any zip tool.
Everything in it is UTF-8 JSON except the cover images.

```
manifest.json
data/books.json
data/locations.json
data/loans.json
data/reading_logs.json
data/reading_sessions.json   (schema 3 and later)
data/read_throughs.json      (schema 3 and later)
data/quotes.json
data/goals.json
data/tags.json
data/book_tags.json
covers/<bookId>.jpg        (one per book that has a cover)
```

## manifest.json

```json
{
  "formatVersion": 1,
  "appVersion": "1.0.0",
  "schemaVersion": 3,
  "deviceId": "0192f0c4-…",
  "exportedAt": "2025-03-10T09:30:00.000Z",
  "counts": { "books": 312, "loans": 14, "quotes": 58, "...": 0 },
  "files": {
    "data/books.json": "<sha256 hex>",
    "covers/<bookId>.jpg": "<sha256 hex>"
  }
}
```

| Field | Meaning |
| --- | --- |
| `formatVersion` | Version of *this file layout*. Starts at 1. A reader refuses files with a higher number ("Update the app first"). Bump it only for changes older readers cannot cope with. |
| `appVersion` | App version that wrote the file. Informational. |
| `schemaVersion` | Database schema version of the data. A reader refuses a higher one than its own. |
| `deviceId` | Random id of the device that exported (kept in `app_meta` as `device_id`). Informational; useful when merging. |
| `exportedAt` | UTC time of export, ISO 8601. |
| `counts` | Rows per table in `data/`, **including** soft-deleted rows. |
| `files` | SHA-256 (lower-case hex) of every other file in the archive. Every listed file must be present and match, and no file may be missing from the list. |

## data/*.json

Each file is a JSON array with one object per row, using the column names of
the Dart data classes (camelCase). Rules:

* **Every row is included, soft-deleted ones too** (`deletedAt` not null).
  They are tombstones: they stop an older copy of the same row from coming
  back to life when merging.
* Timestamps (`createdAt`, `updatedAt`, `deletedAt`) are integer **milliseconds
  since the Unix epoch**. Calendar dates (`startedOn`, `finishedOn`, `dueOn`,
  `returnedOn`, `date`) are `YYYY-MM-DD` strings (local dates, no time zone).
* Ids are UUIDv7 strings.
* Device-local tables are **not** backed up: Open Library lookup cache,
  `app_meta` (settings), and web cover blobs.

Tables added in a later schema (`backupTablesAddedIn` in
`lib/features/backup/domain/backup_format.dart`) may be missing from a backup
made before that schema; they import as empty. A backup that claims the newer
schema but lacks them is damaged.

## covers/

The processed JPEG (max 360 px wide) for each book, named by book id. On
import a cover is stored again through the normal cover store and the book's
cover reference is updated, so the same file works across Android, iOS and
the web.

## Importing

1. Open the zip. If it is not a zip, or `manifest.json` is missing or invalid:
   *"This isn't a Kitabkhana backup."*
2. `formatVersion` or `schemaVersion` higher than the app knows:
   *"This backup was made by a newer version. Update the app first."*
3. Check every listed file exists and matches its SHA-256 (and that no extra
   files hide in the archive): otherwise *"This backup looks damaged."*
4. Parse every `data/*.json`. Any invalid row: *"This backup looks damaged."*
5. Make a **safety backup** of the current library (mobile: app documents
   `backups/`), then import in **one transaction**. Any error rolls
   everything back.
6. **Replace**: delete every row, insert the backup's rows (foreign keys are
   checked at commit, so parents and children can arrive in any order).
7. **Merge**: for rows with the same id, the one with the **newer `updatedAt`**
   wins (higher `rev` breaks a tie, and on a full tie the local row stays);
   a winner that is a tombstone deletes. Rows only in the backup are added.
   Rows that would break a uniqueness rule with a *different* id are folded
   into the existing row instead: same tag name, same location name under the
   same parent, same goal year (the newer target wins), a second active loan
   for one book (the local loan stays), a repeated tag on a book. References
   to a folded row are redirected to the one that was kept.
8. Copy covers, then re-run loan-reminder reconciliation.

Covers are copied after the database commit. If a cover fails to copy the
rest of the import stands, and the summary says how many covers were skipped.
