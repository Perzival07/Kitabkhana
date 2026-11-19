# Cover storage

`CoverStore` (`lib/platform/cover_store/`) keeps one processed cover per book.

## Processing (`processCover`, pure Dart, run via `compute`)

Decode, apply EXIF rotation, flatten transparency onto white, resize to at most **360px wide**
(never enlarged), encode JPEG quality **85**. Open Library's 1x1 placeholder GIF (and anything under
16px on both sides) means "no cover"; undecodable data is invalid; inputs over 25 MB are rejected.

## Where covers live

| Platform | Storage | Reference stored in `Book.coverLocalPath` |
|---|---|---|
| Android / iOS | `<documents>/covers/<bookId>.jpg` (written via temp file + rename) | `covers/<bookId>.jpg?v=<millis>` |
| Web | `cover_blobs` table (IndexedDB through Drift) | `cover:<bookId>?v=<millis>` |

Web uses the database rather than relying on the browser HTTP cache because only the database is
guaranteed to survive offline, to persist with the rest of the data, and to be readable by backup.

References are relative (iOS can move the app container) and carry a version, so replacing a
cover produces a new reference. Images are served as `MemoryImage` (about 30 KB each) because
Flutter caches `FileImage` by path and would keep showing a replaced picture.

## Behaviour

- `saveFromUrl`: `Ok(ref)`, or `Ok(null)` when there is no real cover (404, placeholder,
  unreadable image) so the caller keeps the generated cover; network problems are failures.
- `saveFromBytes`: for camera/gallery photos; unusable images are a `ValidationFailure`.
- Book ids must match `[A-Za-z0-9_-]{1,64}` (they become file names), and references are validated
  on read, so no path traversal is possible.
- `KBookCover` shows: stored image, then network image, then the generated cover.
  `BookCoverView` resolves the reference for a `Book`.
