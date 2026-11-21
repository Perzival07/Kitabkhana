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
- [x] P04.3
- [x] P04.4

## Phase 05 — Scan & match
- [x] P05.1
- [x] P05.2

## Phase 06 — Lending
- [x] P06.1
- [x] P06.2
- [x] P06.3

## Phase 07 — Reading & stats
- [x] P07.1
- [x] P07.2
- [x] P07.3

## Phase 08 — Quotes
- [x] P08.1
- [x] P08.2

## Phase 09 — Data & settings
- [x] P09.1
- [x] P09.2
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
- (P04.1) Location is chosen with the P04.3 picker (searchable, recent first, create inline).
- (P04.1) Widget tests must scroll lazily-built form rows into view and avoid `pumpAndSettle` while a loading spinner is shown (see test/features/add/add_flow_test.dart helpers).
- (P04.2) Tapping a book opens the `/book/:id` stub route at every width; the two-pane detail pane stays a placeholder until P04.4.
- (P04.2) The long-press menu has Change status, Move and Delete (with undo). "Lend" is left out until lending is built (Phase 06), rather than shipping a dead action.
- (P04.2) Search highlights word prefixes case-insensitively but not across accents (the search index folds accents; the highlight does not).
- (P04.2) Not yet checked on a device: 300-book scroll smoothness (use the dev-only flask button in the Library app bar to seed demo data) and the filter chip row with a screen reader.
- (P04.2) Library view (grid/list) is stored in `app_meta` under `library.view`, local to the device.
- (P04.2) Test tip: routed tests get an in-memory database by default (`pumpRouterApp`); golden tests must close the harness in `addTearDown`, not in the test body, or live Library streams stall `db.close()`.
- (P04.3) Locations are one level deep in the UI (a location with children cannot become a child). Recent locations (`location.recent`) and the first-run starter flag (`location.starter_done`) live in `app_meta`, local to the device.
- (P04.3) The first-run starter suggestion (Living room shelf, Bedroom shelf, Storage box) appears on the empty Locations screen; Onboarding (a later phase) may surface it earlier.
- (P04.3) More tab now has one entry (Manage locations); loans, quotes and settings entries arrive with their phases. The picker is used in Add Book and the Library long-press Move; Book Detail (P04.4) will reuse it.
- (P04.3) Not yet checked on a device: drag-to-reorder feel and screen-reader labels on the drag handle.
- (P04.4) Not built yet, by design: "Lend" action and the loan "Remind" button (Phase 06; Return works), the Quotes section (P08), and the pace prediction on the progress card (P07).
- (P04.4) When a book's page count is unknown, "Update page" takes a plain page number (no percentage input), because progress needs the total.
- (P04.4) Two-pane: the shell's detail pane (>1000dp, Library tab) now shows the selected book, held in `selectedBookIdProvider`; narrower widths push `/book/:id`.
- (P04.4) The Edit screen is the manual form in edit mode (`BookFormArgs.edit`); changing status there follows the same date rules as the detail page.
- (P04.4) Not yet checked on a device: Hero animation smoothness (grid to detail and back), the celebration burst with reduce-motion on, and the blurred header on low-end phones.
- (PA Phase 04) Fixed: content screens (Detail, Edit, Locations) load with skeletons, not spinners; Locations is capped at the 720dp content width on wide screens.
- (PA Phase 04, P3) The Detail header uses fixed white text over the darkened cover (intentional for contrast on any cover) rather than theme tokens; the status chips wrap onto two lines at 360dp; the Add Book camera screen still shows a spinner while busy (not content).
- (PA Phase 04, P3) Not verified here (no device): 200% text, landscape and foldable layouts on the new Locations and Detail screens beyond the 320dp overflow test and 360dp goldens.
- (P05.1) Matching: an ISBN is checked exactly, then by catalogue work key (cache first, network at most 1.5 s), then by title key, then by trigram similarity of at least 0.8 (shortlisted from full-text search). Transposed-letter typos can score under 0.8 and fall through to "not in library".
- (P05.2) Not built: the "Remind" button on the Lent-out card (arrives with Phase 06 reminders).
- (P05.2) The "Search by title" field checks after 3 typed letters or on submit. Camera runs only while the Scan tab is showing and the app is in front.
- (P05.2) iOS: `permission_handler` needs the camera macro enabled in `ios/Podfile` (`PERMISSION_CAMERA=1`) and `NSCameraUsageDescription` (already present). Not verifiable here (no Xcode).
- (P05.2) Not verified on a device: the 10-owned/5-unowned shop test with and without network, low-light torch, deny-permission flow, Chrome on Android over HTTPS.
- (Android) The local Android build needs the Android 37 SDK platform (the project targets it); the emulator setup was abandoned at your request, so no Android build has been run.
- (PA Phase 05, P3) The verdict sheet resizes without animation (an animated resize crashed when the sheet closed mid-animation). The scan overlay's pulse stops under reduce-motion. Title search can open the verdict sheet while typing once 3 letters are in; it never opens a second sheet over the first.
- (PA Phase 05, P3) 200% text, landscape and foldable layouts of the Scan tab are not verified (no device); the 360dp goldens (light and dark) are checked.
- (P06.1) Lend, borrow and return are atomic: the loan and the book change in one transaction (`LoanRepository.startLoan` / `finishLoan`). Lending clears the book's location and remembers it; returning restores it, or asks for a new one when the old place was deleted.
- (P06.1) Phone: typed manually with a default country code (+91, stored in `app_meta` as `phone.default_cc`; no settings screen for it yet). "Pick from contacts" is not offered, because it needs the contacts permission.
- (P06.1) Reminders: the `ReminderService` interface is wired into every use case but is a no-op until P06.2. A reminder failure never fails a loan.
- (P06.1) Not yet checked on a device: the Lend sheet with the keyboard open on small phones and at 200% text.
- (P06.2) Reminders are inexact local notifications at 10:00 local on the due date, plus one follow-up 3 days later, rebuilt from the loans on every app start (`LoanReminderService.reconcile`, nearest 64 kept for iOS). The web schedules nothing and shows an "N books are overdue" banner in the Library instead.
- (P06.2) Notification text follows the device language but only English strings exist so far. Tapping a notification opens that book.
- (P06.2) Android build changes made without being able to build: boot/package-replaced receivers, POST_NOTIFICATIONS and RECEIVE_BOOT_COMPLETED permissions, core library desugaring, and package queries for WhatsApp/SMS.
- (P06.2) Not verified on a device: the +2 minute test reminder (More tab, dev flavour only), reboot survival, WhatsApp opening pre-filled, "WhatsApp not installed" fallback to SMS then the share sheet.
- (P06.2) iOS: notification permission is requested only after the explanation sheet; no Xcode here to confirm.
- (P06.3) Swipe right to return: a lent book whose old spot still exists is returned after the toast's undo window (the loan is committed when the toast closes, so Undo is a true undo). Borrowed books, and lent books whose old spot was deleted, ask their question first instead, so they cannot be undone by swiping. Swipe left on a lent loan sends a WhatsApp reminder.
- (P06.3) The "card on the Reading/home screen" that links to Loans arrives with the Reading tab (P07.2); until then Loans is reached from More and from the web overdue banner.
- (PA Phase 06, fixed) Toasts with an action (Undo, View) never closed on their own in current Flutter; `KToast` now sets `persist: false`. This affected every earlier undo toast.
- (PA Phase 06, P3) On a 360x780 phone the Detail page's Lend/Move/Edit/Share row sits below the first screen because of the large header; consider a shorter header or a sticky action bar.
- (PA Phase 06, P3) The Loans tabs (4) are tight at 320dp and 200% text; not verified on a device. Reminder wording is English only.
- (P07.1) `UpdateProgress` keeps one log per book per day (`fromPage` = where the day began, `toPage` = now). Going back shrinks or removes today's log; earlier days are never touched. A page past the last is rejected; the last page offers "Mark as finished" in a toast. Updating from Want/Dropped starts the book.
- (P07.1) Pages-unknown books take a plain page number (a percent can't become pages without a total), so no percent input; no pace shown for them.
- (P07.1) Pace = pages in the last min(14, days since start) days / that many days; needs 2+ reading days. Shows "About N days left" up to 14 days, else "Finish by Sat, 23 Nov". Streak counts local calendar days, alive if today or yesterday has a log.
- (P07.2) The Reading tab: greeting by local time (morning before 12:00, afternoon before 17:00), streak badge (hidden at 0), a "Currently reading" carousel with progress ring, page count, pace line and an Update page button, a Today card (pages today + 7-day bars), an Overdue loans card linking to Loans (so Loans is now reachable from here too), and "Up next" (3 want-to-read books). The Update page sheet now has +10 / +25 chips; Detail and the Reading tab share `updateBookPage`.
- (P07.2) With large text (>=140%) or a single book, reading cards stack vertically instead of swiping sideways. Minutes read are not shown (not tracked).
- (P07.2) Not built: "Quote of the week" (hidden until quotes exist, P08). Nothing reading and nothing wanted shows an Add a book empty state; nothing reading but books wanted shows "Pick your next read" with those covers.
- (P07.2) From the Reading card, "Mark as finished" only sets the status (no confetti; that stays on the Detail page).
- (P07.3) Stats tab: goal ring with ahead/behind/on-pace wording (whole books against an even pace through the year; past years show "N books short", future years "A fresh year ahead"), set/edit/remove goal sheet, books finished per month (tap a bar for that month's books), pages per week (last 12 weeks), top genres and authors, library facts, and a year selector over years that have finished books (plus this year).
- (P07.3) All aggregates are SQL (`DriftStatsRepository`). A book counts toward a year by its `finishedOn`. Authors are split on commas in SQL, so "A, B" counts for both; genres are matched case-insensitively as whole strings. Average rating covers every rated book in the library, not just the year.
- (P07.3) Pages per week uses 7-day windows ending today (current year) or on 31 Dec (past years), not calendar weeks. Library facts are library-wide except "Longest read", which is for the chosen year.
- (P07.3) Not verified on a device: touch feel of tapping the month bars (tested only through the repository and layout, not a real tap), and 200% text beyond the 320dp overflow test.
- (P08.1) Capture flow at `/book/:id/quote` (opened from a new Quotes section on Book Detail): photo (camera or gallery) → crop/rotate → on-device text reading → tap lines (marker highlight) → edit text + page (prefilled with the current page) → save. "Type it instead" skips the photo; where reading is unsupported (web) it opens on the text field.
- (P08.1) Text cleanup (`cleanQuoteText`): rejoins words hyphenated across lines when the next line continues in lower case (a hyphen before a capital or digit is kept), joins lines into paragraphs (blank line = new paragraph), collapses spaces, and turns quotes into typographic ones.
- (P08.1) Privacy: only text is saved. The photo is held in memory, handed to ML Kit through a temp file that is deleted straight after reading, and dropped from the screen once the text is read.
- (P08.1) The cropper is built in: rotate in quarter turns, drag corners or the box; edits run off the UI thread (`compute`). Latin script only; `OcrScript` is the place to add Devanagari later (needs the extra Android dependency and its own recogniser).
- (P08.1) The Quotes screen is still a stub, so quote capture is only reachable from Book Detail until P08.2.
- (P08.1) iOS setup I could not do without Xcode: add `-ObjC` and `-all_load` to Other Linker Flags and add `LatinOCRResources.bundle` to Copy Bundle Resources (see the plugin README), or text reading will fail on iOS.
- (P08.1) Not verified on a device (no emulator/Xcode here): reading a real page in normal and dim light, camera/gallery pickers, and cropper drag feel.
- (P08.2) `/quotes` (also in More): search over text, book title and author; Favourites filter; filter by book; cards with a big opening mark, Fraunces italic body and "— Title, p. 42"; favourite heart; menu with Edit, Share as image, Share as text, Delete (with Undo). A "Snap a quote" button asks which book, then opens the capture flow.
- (P08.2) Quote of the week (Reading tab, hidden until a quote exists): deterministic per week (Monday to Sunday, counted from a fixed epoch Monday, not ISO week numbers, so year ends have no quirks). Favourites are preferred: with 3+ favourites only they rotate; with fewer, they lead and other quotes top the pool up. The pool is stepped through in a stable shuffled order, one per week, so nothing repeats until all have had a turn. Adding or deleting a quote reshuffles which quote is next.
- (P08.2) Share as image: a 1080x1350 (4:5) PNG drawn directly with a painter (paper tone, faint seeded grain, big mark, Fraunces italic sized to fit, source in Inter, Kitabkhana wordmark); always the light "paper" look. Via share_plus (a download on web).
- (P08.2) Not verified on a device: the system share sheet and the web download; the grain's look on a real screen.
- (P09.1) `.kitab` backups are a zip of `manifest.json`, one JSON file per table (every row, tombstones included) and `covers/<bookId>.jpg`; every file has a SHA-256 in the manifest. Format documented in `docs/BACKUP_FORMAT.md`. Entry points for now: More > Back up library / Restore from backup (P09.3 moves them into Settings).
- (P09.1) Export warns that the file holds borrower names and phone numbers, then builds the zip off the UI thread and shares it (a download on the web). Import checks the whole file first (zip, manifest, newer format or schema, checksums, unlisted or missing files, row counts) and changes nothing if anything is wrong; friendly messages for "not a backup", "damaged" and "made by a newer version, update the app first".
- (P09.1) Import always takes a safety copy of the current library first (phones: `<documents>/backups/before-restore-*.kitab`, newest 3 kept) and stops if that fails. The database work is one transaction with foreign keys checked at commit, so any error rolls everything back. On the web there is nowhere to keep a safety copy, so the single transaction is the only protection there.
- (P09.1) Replace wipes and inserts. Merge: newer `updatedAt` wins per id (higher `rev` breaks a tie, a full tie keeps the local row), so a newer tombstone deletes and an older live row never revives one. Rows that would break a uniqueness rule under another id are folded into the existing one (same tag name, same location name under the same parent, same goal year with the newer target kept, a second active loan for a book is skipped, a repeated tag on a book), with references redirected.
- (P09.1) Covers are copied after the database commit; a book whose cover file isn't in the archive loses its stale reference, and failed copies are counted in the summary rather than undoing the import. Loan reminders are reconciled afterwards.
- (P09.1) Not verified on a device: the system file picker (it is not filtered by extension, since phone pickers don't know `.kitab`), the share sheet / web download, and timing on a large library (zipping runs in an isolate, database reads and writes on the main isolate).
- (P09.2) CSV export (More > Export as spreadsheet): `books.csv` (title, authors, isbn13, status, ownership, location as "Room / Shelf", rating, pages, startedOn, finishedOn, tags joined by "; ") and `loans.csv` (title, authors, direction, person, phone, startedOn, dueOn, returnedOn, note); UTF-8 with a byte-order mark, CRLF line ends, quoting only where needed, so Hindi/Bengali open correctly in Excel. Deleted books and their loans are left out. Text that starts like a formula (`=`, `+`, `@`, a leading tab/return, or `-` before a non-digit) gets a leading apostrophe so spreadsheets don't run it. Headers are always English.
- (P09.2) Automatic backups (phones only): on app start, if automatic backups are on (default), the library isn't empty and the last backup is 7+ days old or missing, a `.kitab` is written to `<documents>/backups/auto-YYYYMMDD-HHMMSS.kitab` and only the newest 3 `auto-` files are kept (safety copies from restores and other files are never pruned). "Last backup" is stored in `app_meta` (`backup.last_at`) and is also updated when you share a backup by hand. There is no Settings screen yet, so the toggle and the "Last backup: 4 days ago / Back up now" row arrive with P09.3 (the service and preferences are ready: `AutoBackup`, `BackupPrefs`).
- (P09.2) Erase all data (More, in red): a confirmation, then a second dialog that needs the word DELETE typed exactly (capitals). It clears every table (settings included), cover images, every file in the backups folder and all pending notifications, resets cached settings, and goes to `/onboarding`, which is still a placeholder screen until its phase.
- (P09.2) Not verified on a device: that the automatic backup runs at launch on a real phone, the CSV files in real Excel/Numbers, and that deleting the backups folder works on iOS and Android file systems. The web has no folder, so there are no automatic backups there.
