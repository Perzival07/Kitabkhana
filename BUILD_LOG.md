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
- [x] P09.3

## Phase 10 — Polish & QA
- [x] P10.1
- [x] P10.2
- [x] P10.3
- [x] P10.4
- [x] P10.5
- [x] P10.6
- [x] P10.7

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
- (P09.3) More is now grouped: Your library (Loans with "N out", Quotes, Locations, Tags, each with a live count) and App (Settings, About). The backup, restore, CSV and erase actions moved from More into Settings > Your data. New screens: `/settings`, `/tags` (counts, rename, delete, tap to filter the library) and `/about` (version, licences, privacy-policy link only when `--dart-define=PRIVACY_URL=…` is given, "Made with care" sign-off).
- (P09.3) Settings are typed (`AppSettings`, `SettingsRepository`) and stored as text in `app_meta`; earlier keys (`library.view`, `phone.default_cc`, `backup.auto`) are unchanged. Theme now persists (it was memory-only). Unreadable stored values fall back to defaults. Sections: Appearance (theme, default view, grid density = one more column), Reading (yearly goal via the goal sheet, optional daily reading reminder + time), Lending (default loan length, 0 = no due date, which the Lend sheet now starts from; default country code; loan reminder time), Your data, Privacy, Help, About.
- (P09.3) Loan reminders now fire at the chosen time (default 10:00) and are rebuilt when it changes. The daily reading reminder schedules the next 14 days at the chosen time (ids from 1,500,000,000; loan reminder ids were narrowed to 29 bits so they stay below it), rebuilt at start-up, when settings change and after you log reading (today's nudge is dropped once you've read). Notification permission is asked for when you switch it on.
- (P09.3) Crash reports: a switch that is off by default and is only stored; no reporting provider is connected, so nothing is sent either way, and the screen says so. Diagnostics export = versions + the in-memory log lines (already masked for phone numbers and e-mail), never library contents. "Send feedback" opens a mail draft; the recipient comes from `--dart-define=FEEDBACK_EMAIL=…` and is empty by default.
- (P09.3) Removed my duplicate `app_version.dart`; backups use `kAppVersion` from `app_config.dart` (already tied to pubspec by an existing test).
- (P09.3) Not verified on a device: the time pickers and the daily reading reminder firing, the mail app opening, and the share sheets. Settings are English only so far.
- (P10.1) First-run onboarding at `/onboarding`: three intro pages ("Know what you own", "Never buy it twice", "Your books stay with you"), a step to pick starter places (Living room shelf, Bedroom shelf, Storage box; all ticked, untick or skip), then "Add your first book" / "Restore from backup" / "Explore the app". Skip is on every page but the last; page dots with a spoken "Step N of 5"; illustrations are painted in the theme colour (a new `privateShelf` illustration was added); subtle parallax and fade while swiping, switched off (and page changes made instant) under reduce-motion; content is centred and capped at 520dp, scrolls in landscape, and was checked at 320dp with 200% text.
- (P10.1) Shown once: `bootstrap` reads `onboarding.done` and opens on the introduction when it is not set. Skip, Add first book, Explore and a successful restore all set it; cancelling or failing a restore does not. Erase all data wipes it, so the introduction returns. Tests open the library by default.
- (P10.1) Fix found along the way: windows shorter than 500dp (a phone on its side) now use the bottom bar instead of the navigation rail, which overflowed by 52dp at 800x360.
- (P10.2) One place for motion (`lib/ui/motion.dart`): `MotionPrefs` (from `MediaQuery.disableAnimations`, so it follows the system reduce-motion setting) turns every duration to zero and curves to linear; `context.motion` is how widgets ask. It is a context extension rather than a Riverpod provider because the setting lives in `MediaQuery`.
- (P10.2) Added: a staggered fade/slide-in (`KEnter`) for library grid and list items, first load only (the first 14 items, once per app run; filtering, sorting and scrolling never replay it); a "pop" (`KPop`) on the scan verdict badge, replayed when "Did you mean…?" resolves to another verdict; a 97% press scale on primary buttons; a spring-like rise for bottom sheets (plain dismissal, none under reduce-motion); status chips on Book Detail with an outlined/filled icon that swaps with a quick fade (so the state no longer rests on colour alone). Already present from earlier phases: Hero covers, animated progress bars and rings, the finish-a-book particle burst (draws nothing under reduce-motion).
- (P10.2) Haptics are now one vocabulary (`Haptics.light` for primary actions, `.success` for a scan match / adding by scan / finishing a book, `.selection`). Flutter has no separate "success notification" haptic, so success is a firmer tap.
- (P10.2) NOT done: profiling on a low-end Android in profile mode (no device here), so there are no frame-time numbers and I cannot claim every animation holds 60fps. To measure: `flutter run --profile` on the device, open DevTools > Performance, and record the library first-load cascade, a sheet opening, a scan verdict and a book finishing; look for UI or raster frames over 16ms. If the cascade janks on weak hardware, lower the 14-item cap in `library_screen.dart`.
- (P10.3) New `test/a11y/accessibility_test.dart` runs Flutter's four accessibility guidelines (Android and iOS tap targets, labelled tap targets, text contrast) on 15 screens plus the library as a list, the Update-page and Lend sheets, in light and dark; checks 200% text at 320dp on every screen; and checks Escape closes a bottom sheet. The contrast test now covers every text/icon pairing the theme draws (container colours, navigation bar and rail, hints, focus ring), and checks the keyboard-focus ring.
- (P10.3) Fixes it found: library tiles (grid and list) had no spoken label, so a screen reader read nothing useful; each tile is now one labelled button ("Title, by Authors, Status, Lent out, at Place") with tap and long-press actions. The library status dot is now an icon in a coloured disc (it was colour only). The Stats goal ring speaks its percent too ("5 of 12 books, 42 percent"). The Loans tabs scroll at big text or under 360dp instead of overflowing. Buttons now show a 3dp focus ring for keyboard users.
- (P10.3) Walkthrough scripts for TalkBack and VoiceOver (add, scan, lend, return) and the full list of what is built in are in `docs/A11Y.md`.
- (P10.3) NOT done: the actual TalkBack and VoiceOver walkthrough, focus rings and Escape in real browsers, and iOS "Larger Accessibility Sizes" on small phones; all need a device or browser session.
- (P10.4) A device matrix in `test/matrix/` (documented in `docs/QA.md`): every main screen at 9 sizes (320x568 to 1440x900, including a phone on its side) in light and dark, plus 200% text, checked for overflow (260 tests); 91 golden images at the key sizes; and a notch/gesture-bar insets test. It found and fixed: the navigation rail overflowing on short windows (now the bottom bar under 500dp tall), a layout error under reduce-motion on tablet widths (zero-length `AnimatedSize`), generated covers breaking words mid-word, the detail header eating a landscape screen, the blurred backdrop overflowing, content under a landscape notch, loading skeletons overflowing, and the Loans tabs.
- (P10.4) Goldens are only kept for 7 of the 18 size/theme combinations per screen (5.6 MB); the rest are overflow-checked only. Real devices, foldables (hinge), split-screen and browsers are still to do by hand (list in `docs/QA.md`).
- (P10.5) Added a dev-only bulk seeder (5,000 books incl. Hindi and Bengali titles, 300 loans, 20,000 reading logs, 500 quotes; More > "Seed 5,000 books (dev)") and benchmarks in `test/perf/` (tag `perf`). On the dev machine every query is far inside its budget (search 1-2 ms vs 50; ownership check 2-20 ms vs 500; statistics 0.1-0.2 ms vs 200), the key lookups use their indexes, and the library builds only a screenful of tiles at 5,000 books and pages in more on scroll. So no indexes or query changes were needed. Full table in `docs/PERFORMANCE.md`.
- (P10.5) Removed unused packages `uuid` and `path` and the unused Fraunces 500 font. Covers were already decoded at thumbnail size.
- (P10.5) NOT done (needs a low-end Android in profile mode, none here): cold-start time, real frame times while scrolling 5,000 books, and `flutter build apk --analyze-size` (no Android SDK). `docs/PERFORMANCE.md` says exactly how to measure each; use `--split-per-abi` for APKs. These numbers are a best case: a phone is several times slower than this machine.
- (P10.6) Six whole-app journeys in `integration_test/flows.dart` (first run + three books three ways; scan owned + title search; lend, scan lent, return; three days of reading, streak, finish, stats; quote capture; backup, erase, restore), one list used by two runners: `test/e2e/` (ordinary `flutter test`, all six pass) and `integration_test/app_test.dart` (device or browser). Fake camera, text reading, notifications, Open Library, sharing, file picking and backup folder. CI gets `e2e-android` (emulator) and `e2e-web` (Chrome via `flutter drive`) jobs on pushes to main and manual runs; `docs/QA.md` has the commands.
- (P10.6) Bug found by the journeys and fixed: the "Added to <place>" toast sat on top of the library's Add button, so a tap meant for the button hit the toast's "View" action. The button now lifts while any toast is showing (`KToast.visible`), with a regression test.
- (P10.6) NOT verified: the two CI device jobs and `integration_test/app_test.dart` on a real emulator or browser (none here, so the YAML and the web driver setup are untested); and the journeys use fake services, so camera, ML Kit and the share sheet are not exercised end to end.
- (P10.6) Noted, not fixed: the Reading tab computes "today" once when it builds, so an app left open across midnight shows yesterday's bar as today until it is rebuilt (the journeys relaunch the app on each day).
- (P10.7) Android: `INTERNET` was missing from the main manifest (debug builds add it, a release build would have been offline for good), so it is declared. Cloud backup and device-to-device copy are off (`allowBackup=false`, `fullBackupContent=false`, data-extraction rules excluding every domain), cleartext HTTP is off (`usesCleartextTraffic=false` + a network security config), the permission list is exactly INTERNET, CAMERA, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED (plus VIBRATE from the notifications plugin), and there is no SCHEDULE_EXACT_ALARM. iOS: camera and photo strings rewritten to say what they are for and that nothing is uploaded; no ATS exceptions. Web: a Content Security Policy in `index.html` (scripts from this origin plus `wasm-unsafe-eval` only, connections to Open Library only, HTTP upgraded), `web/_headers` for what a meta tag cannot set (HSTS, frame-ancestors, nosniff, permissions), proper name/colours in the manifest; CI builds web with `--no-web-resources-cdn` so CanvasKit is not fetched from gstatic.com. All of this is guarded by `test/security/`.
- (P10.7) Logs: a test now checks every log call at info and above uses constant text or an exception's type. It caught a real leak: the global error handler logged the first line of exception messages (which can quote on-screen content); it now logs only the type. The `$e` interpolations in warnings were reduced to `runtimeType` too.
- (P10.7) Dependencies: all licences are permissive (`docs/LICENSES.md`); every direct dependency is current except `cupertino_icons` (major bump, font only); a few transitive packages updated; `sqlite3` is deliberately held back because `web/sqlite3.wasm` must match it. Docs: `docs/PRIVACY.md` (each promise and what enforces it), the public policy in `docs/privacy/privacy-policy.md`, and `docs/privacy/index.html` (self-contained page built by `dart run tool/build_privacy_page.dart`; a test fails if it is stale or if its claims drift from the code).
- (P10.7) NOT done / known gaps: the merged Android manifest and a signed iOS build were not inspected (no Android SDK or Xcode); the iOS database is included in the user's own iCloud/device backup (excluding it needs native code: `isExcludedFromBackup`); crash reporting is a switch with nothing behind it; the privacy page needs hosting and its URL passed as `--dart-define=PRIVACY_URL=…`.

## Phase 10 audit (PA)
- Done and tested here: onboarding, motion, accessibility, device matrix, performance benchmarks, six end-to-end journeys, security and privacy hardening.
- Needs a device, browser or other tool I did not have (each listed in its own entry above and in `docs/QA.md`, `docs/A11Y.md`, `docs/PERFORMANCE.md`, `docs/PRIVACY.md`): TalkBack/VoiceOver walkthrough, profile-mode frame times and cold start, release APK size and merged manifest, foldable hinge, the emulator and Chrome CI jobs, real-browser CSP behaviour.
- Open small issues: the Reading tab's notion of "today" is fixed when it builds (an app left open past midnight shows yesterday until rebuilt); the iOS backup exclusion above.
