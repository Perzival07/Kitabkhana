# Build log

Tick a task only when it is green (see Definition of Green).

## Phase 00 — Foundation
- [x] P00.1
- [x] P00.2

## Phase 01 — Design system & shell
- [x] P01.1
- [x] P01.2
- [x] P01.3

## Phase 02 — Core & data
- [x] P02.1
- [x] P02.2
- [x] P02.3
- [x] P02.4

## Phase 03 — Book data
- [x] P03.1
- [x] P03.2

## Phase 04 — Library
- [x] P04.1
- [x] P04.2
- [ ] P04.3
- [ ] P04.4

## Phase 05 — Scan & match
- [ ] P05.1
- [ ] P05.2

## Phase 06 — Lending
- [ ] P06.1
- [ ] P06.2
- [ ] P06.3

## Phase 07 — Reading & stats
- [ ] P07.1
- [ ] P07.2
- [ ] P07.3

## Phase 08 — Quotes
- [ ] P08.1
- [ ] P08.2

## Phase 09 — Data & settings
- [ ] P09.1
- [ ] P09.2
- [ ] P09.3

## Phase 10 — Polish & QA
- [ ] P10.1
- [ ] P10.2
- [ ] P10.3
- [ ] P10.4
- [ ] P10.5
- [ ] P10.6
- [ ] P10.7

## Phase 11 — Release
- [ ] P11.1
- [ ] P11.2
- [ ] P11.3
- [ ] P11.4
- [ ] P11.5

## Known issues

- Android SDK and Xcode are not installed on the dev machine yet: Android/iOS builds are unverified; only web is built locally.
- iOS dev/prod flavors need one-time Xcode setup (see docs/IOS_FLAVORS.md).
- Foldable hinge handling uses `DisplayFeatureSubScreen` and is untested on real hardware or emulator.
- Two-pane (list + detail) applies to the Library tab only; other tabs are centred at max 720dp. The detail pane is a placeholder until P04.4.
- hi/bn ARB files are empty scaffolds (fall back to English); parity test is warning-only.
- Goldens are generated on macOS and excluded from CI (`--exclude-tags golden`).
- Gallery (dev-only) strings are not localised by design.
- `custom_lint` is not used: riverpod_lint 3 runs as an analyzer plugin.
- (P02 audit, P3) `watchOverdue` fixes "today" when subscribed; it does not roll over at midnight until resubscribed.
- (P02 audit, P3) `QuoteRepository.watchAll` and `LoanRepository.watchActive/History` are unpaged; add paging if lists get large (P10.5 will measure).
- (P02 audit, P3) No index on `books.created_at` (default sort); measure with 5,000 books in P10.5.
- (P02 audit, P3) `mapDbError` falls back to matching SQLite message text for constraint errors (Drift exposes no typed exception); business rules use explicit pre-checks instead.
- (P02 audit, P3) The plan's P02.3 was built after P02.4 because `Isbn13` and `TitleKey` are needed by the domain.
- Repositories double as DAOs (queries live in `Drift*Repository`), rather than separate `DatabaseAccessor` classes.
- (P03 audit, P3) On web `compute` runs on the main thread, so processing a very large photo can briefly block the UI.
- (P03 audit, P3) Hard-deleting a book on mobile does not yet delete its cover file (there is no purge flow until "Erase all data", P09.2); `CoverStore.delete` exists and web cascades in the database.
- (P03 audit, P3) Cover downloads are not rate limited (covers.openlibrary.org by id is not limited); add a limiter if bulk import is ever added.
- Schema is now v2 (cover_blobs); migration tested incl. on a real persisted browser DB.
- (P04.1) Scanning is a basic `mobile_scanner` view, untested on a device (no camera here); Android CAMERA and iOS usage strings were added but not built. The full scanner service arrives in P05.2.
- (P04.1) Location is a plain dropdown until the picker in P04.3.
- (P04.1) Widget tests must scroll lazily-built form rows into view and avoid `pumpAndSettle` while a loading spinner is shown (see test/features/add/add_flow_test.dart helpers).
- (P04.2) Tapping a book opens the `/book/:id` stub route at every width; the two-pane detail pane stays a placeholder until P04.4.
- (P04.2) The long-press menu has Change status, Move and Delete (with undo). "Lend" is left out until lending is built (Phase 06), rather than shipping a dead action.
- (P04.2) Search highlights word prefixes case-insensitively but not across accents (the search index folds accents; the highlight does not).
- (P04.2) Not yet checked on a device: 300-book scroll smoothness (use the dev-only flask button in the Library app bar to seed demo data) and the filter chip row with a screen reader.
- (P04.2) Library view (grid/list) is stored in `app_meta` under `library.view`, local to the device.
- (P04.2) Test tip: routed tests get an in-memory database by default (`pumpRouterApp`); golden tests must close the harness in `addTearDown`, not in the test body, or live Library streams stall `db.close()`.
