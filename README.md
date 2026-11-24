# Kitabkhana

![CI](https://github.com/Perzival07/Kitabkhana/actions/workflows/ci.yml/badge.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Platforms](https://img.shields.io/badge/platforms-Android%20·%20iOS%20·%20Web%20(PWA)-B4532A)
![Privacy](https://img.shields.io/badge/accounts-none-1F5C5B)
![Licence](https://img.shields.io/badge/licence-all%20rights%20reserved-6B6259)

**A private, offline-first home library and reading tracker for Android, iOS and the web.**

*Kitabkhana* (کتاب‌خانہ / किताबख़ाना) means "house of books". The app answers three
questions, with no internet and no account:

1. **Do I own this book?** Scan a barcode in a shop and get an answer at once.
2. **Where is it?** Every book has a place: a shelf, a desk, a box under the bed.
3. **Who has it?** Lend and borrow with due dates, reminders and a friendly nudge.

It also tracks reading (pages, streaks, pace, a yearly goal and charts) and keeps the
lines you love (snap a page, tap the lines, keep the text).

<p align="center">
  <img src="docs/screenshots/library-grid.png" width="200" alt="Library">
  <img src="docs/screenshots/scan-verdict.png" width="200" alt="Scan verdict: you own this">
  <img src="docs/screenshots/reading.png" width="200" alt="Reading">
  <img src="docs/screenshots/dark-stats.png" width="200" alt="Stats in dark mode">
</p>

## Download

**Android:** [⬇️ Download the latest APK](https://github.com/Perzival07/Kitabkhana/releases/latest/download/kitabkhana.apk)
· [all releases](https://github.com/Perzival07/Kitabkhana/releases)

1. Open the link on your phone and download `kitabkhana.apk`.
2. Tap it, and allow your browser to "install unknown apps" when Android asks.
3. **To update**, download the newer APK and install it over the old one. Your library stays.

Every release is signed with the same key, so updates always install over the previous
version.

**iPhone and iPad:** [⬇️ Download the latest IPA](https://github.com/Perzival07/Kitabkhana/releases/latest/download/kitabkhana.ipa)

iOS only runs apps signed by an Apple ID, and this IPA is unsigned, so you sign it
yourself while installing. You need a computer and a free Apple ID:

1. Install [AltStore](https://altstore.io) or [Sideloadly](https://sideloadly.io) on your
   Mac or PC and follow its setup.
2. Connect your iPhone, open `kitabkhana.ipa` with it and sign in with your Apple ID.
3. On the iPhone, open *Settings → General → VPN & Device Management* and trust your
   Apple ID.
4. **To update**, install the newer IPA the same way. Your library stays.

With a free Apple ID the signature lasts **7 days**. AltStore renews it in the background
when your phone and computer are on the same Wi-Fi. A paid Apple Developer account makes it
last a year, and also allows [TestFlight](https://developer.apple.com/testflight/), which
installs and updates with no computer. The release workflow already supports TestFlight
once its secrets are added (see [docs/RELEASING.md](docs/RELEASING.md)).

---

## Contents

- [Highlights](#highlights)
- [Screens](#screens)
  - [First run](#first-run)
  - [Library](#library)
  - [Adding a book](#adding-a-book)
  - [Book detail](#book-detail)
  - [Scan: "Don't buy it twice"](#scan-dont-buy-it-twice)
  - [Reading](#reading)
  - [Stats and goal](#stats-and-goal)
  - [Loans](#loans)
  - [Quotes](#quotes)
  - [Locations and tags](#locations-and-tags)
  - [More, Settings and About](#more-settings-and-about)
  - [Dark theme](#dark-theme)
  - [Tablets and the web](#tablets-and-the-web)
- [Feature reference](#feature-reference)
- [Privacy](#privacy)
- [Accessibility](#accessibility)
- [Platform support](#platform-support)
- [Getting started (development)](#getting-started-development)
- [Project structure](#project-structure)
- [Architecture](#architecture)
- [Data model](#data-model)
- [Book lookups (Open Library)](#book-lookups-open-library-then-google-books)
- [Backup format](#backup-format)
- [Design system](#design-system)
- [Testing and quality](#testing-and-quality)
- [Performance](#performance)
- [CI and releasing](#ci-and-releasing)
- [Localisation](#localisation)
- [Known limits](#known-limits)
- [Documentation index](#documentation-index)
- [Licence](#licence)

---

## Highlights

| | |
| --- | --- |
| **Add books five ways** | Barcode scan, **scan a whole shelf in one go**, typed ISBN (10 or 13), title search in the catalogue, or by hand. Duplicates are caught before saving. |
| **Don't buy it twice** | Scan in a shop: *You own this* (and where it is), *Other edition*, *On your wishlist*, *Lent to Priya*, *Borrowed*, *Did you mean…?* (fuzzy title match), or *Not in your library* with a one-tap "Add to wishlist". Works offline for everything you own. |
| **Places** | Nested locations ("Bedroom › Shelf 2") with icons, drag to reorder, delete with reassign. |
| **Lending and borrowing** | Who has it, since when, due when. Local reminders on the due date and 3 days later, WhatsApp / SMS nudges, and a returned book goes back to its own shelf by itself. |
| **Reading tracker** | Current page, percent read, a predicted finish date at your pace, a daily streak, a 7-day pages chart, a yearly goal, and stats by month, week, genre and author. |
| **Snap a quote** | Photograph a page, crop, tap the lines you want. Text is read on the device (ML Kit), tidied up (hyphens re-joined, spacing fixed) and saved with its page number. The photo is never kept. Share quotes as image cards. |
| **Your data, your device** | No account, no backend, no analytics, no ads. `.kitab` backups (replace or merge), weekly automatic backups, CSV export, and "Erase everything". |
| **Every screen** | Phones, tablets (navigation rail and two-pane), the web as an offline PWA, light and dark themes, 200% text, screen readers, keyboards and reduced motion. |

---

## Screens

All screenshots below come from the app itself, rendered by
[`test/tool/generate_readme_screenshots_test.dart`](test/tool/generate_readme_screenshots_test.dart)
with the built-in demo library of public-domain classics (`StoreDemoSeeder`). The camera
picture on the scan screens is a stand-in, because a test cannot open a camera.
[Regenerate them](#regenerating-the-screenshots) whenever the UI changes.

### First run

A five-step introduction: what the app is for, the scan check, the privacy promise, a
choice of starter places, and a final "You are all set" with *Add your first book*,
*Restore from backup* or *Explore the app*. *Skip* is always available.

| Know what you own | Never buy it twice | Your books stay with you | Where do your books live? |
| :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/onboarding-1.png" width="200"> | <img src="docs/screenshots/onboarding-2.png" width="200"> | <img src="docs/screenshots/onboarding-3.png" width="200"> | <img src="docs/screenshots/onboarding-places.png" width="200"> |

### Library

The home tab. A count line ("13 books · 2 lent out"), debounced full-text search with
highlighted matches, filter chips (All, Reading, Want to read, Finished, Wishlist, Lent,
Borrowed, by place, by tag), five sort orders, and grid or list views. Long-press a book for
quick actions with undo. Covers come from Open Library or your own photo. Books without a
cover get a generated, typeset cover in a colour picked from the title.

| Grid | List | Search | Sort | Backup reminder |
| :---: | :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/library-grid.png" width="170"> | <img src="docs/screenshots/library-list.png" width="170"> | <img src="docs/screenshots/library-search.png" width="170"> | <img src="docs/screenshots/library-sort.png" width="170"> | <img src="docs/screenshots/library-backup-reminder.png" width="170"> |

Sort orders: **Recently added, Title, Author, Recently read, Rating.** Grid density
(*Comfortable* / *Compact*) and the default view are set in Settings.

### Adding a book

`/library/add` offers four ways in. They all end in the same form and the same `AddBook`
use case. A failed lookup never blocks you: you land on the manual form with whatever is
known.

```
Scan barcode ─┐
Type ISBN ────┼─ lookup ─ found ──────► Preview (form pre-filled, catalogue cover)
              │           └ not found / offline / error ─► Manual form (ISBN + a note)
Search title ─┴─ result tapped ───────► Preview
Enter manually ───────────────────────► Manual form
```

| Add a book | Scan barcode | Scan a shelf | Type ISBN | Search by title | Enter manually |
| :---: | :---: | :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/add-entry.png" width="140"> | <img src="docs/screenshots/add-scan.png" width="140"> | <img src="docs/screenshots/add-batch.png" width="140"> | <img src="docs/screenshots/add-isbn.png" width="140"> | <img src="docs/screenshots/add-search.png" width="140"> | <img src="docs/screenshots/add-manual.png" width="140"> |

- **Scan a shelf** (`/library/add/batch`): the camera stays open while you scan book after
  book. Each barcode is looked up and listed (repeat scans and non-book barcodes are
  ignored); books already in your library are listed but unticked. Choose a place for all
  of them, then *Add N books*.
- **Type ISBN**: numeric keyboard, live ISBN-10/13 validation (checksums), paste button.
- **Search by title**: 350 ms debounce, loading skeletons, stale answers ignored.
- **Form**: cover (take or choose a photo), title, subtitle, authors, pages, ISBN, series
  and number, genre,
  language, ownership (*Owned / Wishlist / Borrowed*), status, location and tags.
- **Duplicates**: before saving, the library is checked by ISBN, Open Library work key and a
  normalised title key. You choose *Open existing*, *Add another copy* or *Cancel*.
- **Covers** download in the background. A photo you took beats the catalogue picture.
  Covers are resized to 360 px wide JPEGs (about 30 KB each).

### Book detail

A blurred-cover header, a reading status with dates, progress with a finish estimate, the
book's place or its loan, quick actions (**Lend, Move, Edit, Share**), notes, quotes, tags,
a 1–5 star rating and details. Delete has undo. Finishing a book plays a small celebration
(skipped with reduced motion).

| Reading | Further down | Finished, rated | Lent out | Wishlist |
| :---: | :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/book-detail.png" width="170"> | <img src="docs/screenshots/book-detail-more.png" width="170"> | <img src="docs/screenshots/book-detail-finished.png" width="170"> | <img src="docs/screenshots/book-detail-lent.png" width="170"> | <img src="docs/screenshots/book-detail-wishlist.png" width="170"> |

| In a series | Lend sheet | Edit book | Snap a quote |
| :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/book-detail-series.png" width="200"> | <img src="docs/screenshots/lend-sheet.png" width="200"> | <img src="docs/screenshots/book-edit.png" width="200"> | <img src="docs/screenshots/quote-capture.png" width="200"> |

- **Series**: a book in a series shows "Book 4 of Discworld", the series books you have
  (tap to open) and what is missing ("Missing: 2, 3"). Series come from Open Library
  when it knows them, from Goodreads/StoryGraph titles like "Mort (Discworld, #4)", or
  typed on the form.
- **Re-reads**: a finished book offers *Read again*. The finished read is kept under
  *Earlier reads* ("May 1, 2024 – May 20, 2024") and a new read starts today; the page
  says "Read 3 times". Stats count every finished read in its own year.
- **Status**: Want to read, Reading, Finished or Dropped. *Reading* stamps the start
  date. *Finished* stamps the finish date and sets the page to the last page.
- **Update page**: a sheet with the page number, +/- steppers and "Add N pages" shortcuts.
  Each update writes a reading log for the day, which drives streaks, pace and charts.
- **Lend sheet**: Lend or Borrow toggle, the person (typed, picked from earlier loans, or
  **chosen from your contacts** with the phone's own picker, which needs no contacts
  permission),
  phone (optional, normalised with your default country code), start date, due date
  (*No due date, 1 week, 2 weeks, 1 month* or *Pick a date*) and a note.

### Scan: "Don't buy it twice"

The Scan tab is built for standing in a bookshop. The scanner waits until it has seen the
same code twice, then answers from your library in milliseconds, with no network for books
you have.

| Scanner | Verdict |
| :---: | :---: |
| <img src="docs/screenshots/scan.png" width="220"> | <img src="docs/screenshots/scan-verdict.png" width="220"> |

The possible verdicts (`OwnershipResult`):

| Verdict | Meaning |
| --- | --- |
| **You own this** | This exact edition is on a shelf. Shows where, e.g. "On Study desk". |
| **Other edition** | You own the same work (matched by Open Library work key) in another edition. |
| **On your wishlist** | Not owned yet, but you wanted it. |
| **Lent to {name}** | You own it, but someone has it right now. |
| **Borrowed** | It is someone else's copy, borrowed in. |
| **Did you mean…?** | No exact match, but up to three books score ≥ 0.8 trigram similarity on title. |
| **Not in your library** | With the catalogue details when online, so "Add to wishlist" is one tap. |

No barcode? Search by title or type the ISBN right under the scanner.

### Reading

A greeting, your **current streak**, a carousel of books you are reading (page, percent ring,
"Finish by …" at your recent pace, *Update page*), **today's pages** with a 7-day bar chart,
the **quote of the week**, an overdue-loans banner and "Up next" from your want-to-read shelf.

| Reading tab | Dark theme |
| :---: | :---: |
| <img src="docs/screenshots/reading.png" width="220"> | <img src="docs/screenshots/dark-reading.png" width="220"> |

- **Streak**: consecutive reading days ending today, or yesterday while today is still to
  come. Days are counted on local calendar dates, so time zones and DST cannot break them.
- **Reading timer**: the timer button on each card times a session. It keeps running if
  you close the app; stopping logs the minutes (half a minute or more) and asks for the
  page you reached. Today's card shows "35 min with the timer", and Stats shows the year's
  time reading.
- **Pace**: pages read over the last 14 days, never longer than the time since you started
  the book. It needs at least 2 reading days before it predicts anything.
- **Quote of the week**: changes every Monday, picked from favourites first and topped up
  from other quotes.
- **Daily reading reminder** (optional, in Settings): a gentle nudge at the time you pick,
  skipped once you have read that day.

### Stats and goal

"Your reading year": a goal ring with ahead/behind/on-pace wording, books finished per
month (tap a bar to see that month's books), pages per week (last 12 weeks), top genres,
top authors and library facts. A year switcher covers every year with finished books.

| Stats | Further down | Goal sheet | Year in review |
| :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/stats.png" width="200"> | <img src="docs/screenshots/stats-more.png" width="200"> | <img src="docs/screenshots/goal-sheet.png" width="200"> | <img src="docs/screenshots/year-review.png" width="200"> |

**Year in review**: the share button next to the year draws a story-sized card (1080 ×
1920): books finished, pages read, longest streak, goal, books per month, favourite genre,
most-read author and longest book, ready for WhatsApp or Instagram.

Past years read "N books short" or "Goal reached". Future years read "A fresh year ahead".
Goals go from 1 to 999 books.

### Loans

Four tabs with counts: **Lent out, Borrowed, Overdue, History**. Due dates are coloured *and*
worded ("Due in 2 days", "4 days overdue"). Swipe to return (with undo), extend, or remind
by WhatsApp or SMS.

| Lent out | Borrowed | Overdue | History |
| :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/loans-lent.png" width="200"> | <img src="docs/screenshots/loans-borrowed.png" width="200"> | <img src="docs/screenshots/loans-overdue.png" width="200"> | <img src="docs/screenshots/loans-history.png" width="200"> |

- **One active loan per book**, enforced by a partial unique index in the database.
- **Returning** a lent book puts it back on the shelf it came from (`previousLocationId`).
- **Reminders**: local notifications at 10:00 (changeable) on the due date and once more 3
  days later. They are rebuilt from the loans at every start, and the nearest 64 are kept,
  which is the iOS limit. They are inexact on purpose
  ([ADR 0004](docs/adr/0004-inexact-reminders.md)), so no exact-alarm permission is needed.
  The web cannot schedule notifications, so it shows an "N books are overdue" banner instead.
- **Nudges** open `wa.me/<number>` or an `sms:` link with a polite pre-filled message.

### Quotes

Every quote you have saved, searchable, with a *Favourites* filter and a filter by book.
Each quote can be edited, favourited, deleted, or shared as text or as an image card in
Fraunces italic on "paper".

| Quotes |
| :---: |
| <img src="docs/screenshots/quotes.png" width="220"> |

**Snap-a-Quote flow** (mobile): take or choose a photo → crop (rotate in quarter turns,
drag the corners) → the text is read on the device → tap the lines you want → edit → save
with the page number. Text clean-up joins words broken across lines ("exam-" / "ple"),
keeps real hyphens ("Anglo-" / "Saxon"), fixes spacing before punctuation and rebuilds
paragraphs. On the web you type the quote instead.

### Locations and tags

| Locations | Add location | Tags |
| :---: | :---: | :---: |
| <img src="docs/screenshots/locations.png" width="200"> | <img src="docs/screenshots/location-editor.png" width="200"> | <img src="docs/screenshots/tags.png" width="200"> |

- **Locations**: a name, an icon (*Shelf, Box, Room, Bag, Office, Other*) and an optional
  parent, so places can nest ("Bedroom › Shelf 2"). Drag to reorder. Deleting a place asks
  where its books should go. A searchable picker with inline "create" is used everywhere a
  place is chosen. First-run suggestions: Living room shelf, Bedroom shelf, Storage box.
- **Tags**: free-form labels with book counts. Rename or delete them here, and add them on
  a book's page. Filter the library by tag.

### More, Settings and About

| More | Settings | Settings (cont.) | About |
| :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/more.png" width="200"> | <img src="docs/screenshots/settings.png" width="200"> | <img src="docs/screenshots/settings-more.png" width="200"> | <img src="docs/screenshots/about.png" width="200"> |

**Settings, in full:**

When something has gone wrong, the next launch offers to email a report (see
[Privacy](#privacy)):

<img src="docs/screenshots/crash-prompt.png" width="220">

| Section | Settings |
| --- | --- |
| Appearance | Theme (*System / Light / Dark*), default library view (*Grid / List*), grid density (*Comfortable / Compact*) |
| Reading | Yearly goal, daily reading reminder (on/off and time) |
| Lending | Default loan length, default country code (for phone numbers and WhatsApp), loan reminder time |
| Your data | Back up now, automatic weekly backup (keeps the last 3), **save a copy to…** (the system Save dialog: Google Drive, iCloud Drive, Downloads, a USB stick), share a backup, restore from backup (*Replace* or *Merge*), **import from Goodreads or StoryGraph**, export as spreadsheet (CSV), erase all data (type a word to confirm) |
| Privacy | A plain-language summary, and *Offer to send problem reports* (on by default; a report only ever leaves when you press Send in your own mail app) |
| Help | Export diagnostics (versions and recent app messages, with none of your library), *Report a problem* (emails the developer with the diagnostics attached), send feedback, About |

### Dark theme

"Lamplight": a warm dark theme, not just inverted colours. Every pairing meets WCAG AA.

| Library | Book detail | Stats | Reading |
| :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/dark-library.png" width="200"> | <img src="docs/screenshots/dark-book-detail.png" width="200"> | <img src="docs/screenshots/dark-stats.png" width="200"> | <img src="docs/screenshots/dark-reading.png" width="200"> |

### Home-screen widget (Android)

Long-press the home screen → *Widgets* → *Kitabkhana*. The widget shows the book you are
reading (title, author, page and a progress bar) and your loans ("1 book overdue",
"2 books lent out"); tapping it opens the app. The app pushes new text whenever the page
or a loan changes, so it never polls and needs no extra permission. An iPhone widget needs
a WidgetKit extension and an App Group set up in Xcode with a paid Apple Developer
account, so it is not included yet.

### Tablets and the web

Under 600 dp wide you get a bottom navigation bar. From 600 to 1000 dp you get a navigation
rail. Above 1000 dp you get the rail plus a **two-pane library**: the list on the left and
the selected book on the right. Short windows, such as a phone on its side, keep the bottom
bar.

**Library, two-pane with a book open**

<img src="docs/screenshots/wide-library-selected.png" width="820">

| Library, nothing selected | Book detail (wide, short window) | Stats |
| :---: | :---: | :---: |
| <img src="docs/screenshots/wide-library.png" width="270"> | <img src="docs/screenshots/wide-book-detail.png" width="270"> | <img src="docs/screenshots/wide-stats.png" width="270"> |

---

## Feature reference

<details>
<summary><b>Everything the app does, by area</b> (click to expand)</summary>

**Library**
- Grid and list views, comfortable or compact grid.
- Full-text search (SQLite FTS5) over title, subtitle and authors, diacritic-insensitive,
  with prefix matching and highlighted results, debounced at 250 ms.
- Filters: status, wishlist, lent, borrowed, location, tag. Five sort orders. Paged loading
  (a 5,000-book library builds only a screenful of tiles).
- Long-press quick actions with undo. Soft delete with undo everywhere.
- Overdue banner (web).

**Books**
- Fields: title, subtitle, authors, ISBN-13 (ISBN-10 accepted and converted), Open Library
  work key, pages, genre, language, ownership (*owned, wishlist, borrowed*), status
  (*want, reading, finished, dropped*), current page, rating (1–5), location, owner name
  (for borrowed books), notes, start and finish dates, tags, cover.
- Share a book as text.
- Generated covers for books without one, with the title shrinking (down to 62%) so the
  longest word always fits on a line.

**Scanning**
- `mobile_scanner` on Android and iOS. On the web it uses the browser's `BarcodeDetector`
  (Chrome, Edge, Safari).
- A code must be read twice before it is trusted.
- Ownership check: exact ISBN → same work (other edition) → title key → trigram fuzzy
  match (≥ 0.8) → catalogue lookup.

**Lending**
- Lend out or borrow in, with person, phone, start, due date and note.
- Past-people suggestions, phone normalisation with a default country code.
- Extend, return (back to the previous shelf), history.
- Due-date chips: due today, due in N days, N days overdue.
- Local notifications (Android and iOS), WhatsApp and SMS nudges.

**Reading**
- Page updates create one reading log per book per day (from page, to page, pages read).
- Current and longest streak, 14-day pace with a predicted finish date, today's pages,
  a 7-day chart.
- Yearly goal with ahead/behind/on-pace wording.
- Stats: books per month, pages per week (12 weeks), top genres, top authors, library facts.
- Optional daily reading reminder.
- Year in review: a shareable 9:16 card of the year's reading.

**Quotes**
- On-device OCR (Google ML Kit) with a built-in cropper that runs off the UI thread. On
  Android it also reads **Hindi, Marathi and other Devanagari** pages: the capture screen asks
  "The page is in…" and guesses from the book's language or title.
- Line picking, text clean-up, page number, favourites, search, filter by book.
- Share as text or as a PNG card.
- Quote of the week on the Reading tab.

**Your data**
- `.kitab` backup: a zip of JSON plus covers, with SHA-256 checksums
  ([format](#backup-format)).
- Restore by **Replace** or **Merge** (newer `updatedAt` wins, tombstones respected). A
  safety backup is made first, and the import runs in one transaction.
- Automatic weekly backup to the app's own storage, keeping the last 3 (mobile).
- **Save a copy to…** any place the phone's Save dialog offers (Google Drive, iCloud
  Drive, Downloads, a USB stick). When no copy has left the phone for 30 days (and the
  library has at least 5 books), the Library shows a reminder with *Save a copy* and
  *Later* (quiet for 14 days).
- **Import from Goodreads or StoryGraph**: pick the CSV from either app's "Export
  library". It shows how many books are new, asks whether want-to-read books are on your
  wishlist or your shelves, and adds title, authors, ISBN, pages, status, rating, finish
  date, shelves/tags (as tags) and private notes. Books already in the library (same ISBN,
  or same title and author) are skipped. Covers are shown from Open Library by ISBN.
- CSV export: `books.csv` (title, authors, ISBN-13, status, ownership, location, rating,
  pages, started, finished, tags, series, series number) and `loans.csv` (title, authors, direction, person,
  phone, started, due, returned, note).
- Erase everything: every table, cover files, the backups folder and pending notifications.

</details>

---

## Privacy

> No accounts. No backend. No analytics. No ads. Your library lives on your device.

| Promise | How it is kept |
| --- | --- |
| The library is only stored on the device | SQLite (Drift) in the app's own storage. No sync code exists. |
| Only an ISBN or title is ever sent anywhere | The only requests go to Open Library (`openlibrary.org`, `covers.openlibrary.org`), and to Google Books only when Open Library has no answer. A test checks every `https://` host in `lib/` against the web CSP. |
| No tracking | No analytics, ads or crash SDKs in `pubspec.yaml`. A test forbids the advertising ID, tracking and SKAdNetwork keys ([ADR 0005](docs/adr/0005-no-analytics.md)). |
| Problem reports are your choice | After an error, the app keeps a report on the device and asks next time whether to email it to the developer. Your mail app opens with the error, recent app messages and (optionally) a screenshot, and nothing is sent unless you press Send. |
| Logs never hold library contents | A test checks that every log call at *info* and above uses constant text. The logger also masks phone-like digits and e-mail addresses. |
| Quote photos are thrown away | The photo goes to a temp file for ML Kit and is deleted in a `finally`. Only the text is kept. |
| No silent cloud copy | Android: `allowBackup="false"` and data-extraction rules that exclude every domain. iOS: the app's folders are marked *excluded from backup*, so iCloud and computer backups skip them. |
| HTTPS only | No cleartext on Android, no ATS exception on iOS, `upgrade-insecure-requests` on the web. |
| Minimal permissions | Android: `INTERNET`, `CAMERA`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, with **no** exact-alarm permission. iOS: camera and photo library only. |
| No third-party CDN on the web | Built with `--no-web-resources-cdn`, and the CSP locks scripts to `'self'`. |

The full maintainer view is in [docs/PRIVACY.md](docs/PRIVACY.md). The public policy is in
[docs/privacy/privacy-policy.md](docs/privacy/privacy-policy.md).

---

## Accessibility

- **Screen readers**: book tiles read as one sentence ("Middlemarch, by George Eliot,
  Reading, Lent out, at Living room shelf"). Progress rings speak their value. Charts have
  text summaries. Decorative art is hidden. Section titles are headings.
- **Not colour alone**: statuses have icons and words. Due dates are worded.
- **Touch targets** of at least 48 × 48 dp, checked against Android and iOS guidelines.
- **Contrast**: WCAG AA in both themes, checked pair by pair in `contrast_test.dart`.
- **Large text**: every main screen is tested at 320 dp wide with 200% text and no overflow.
- **Keyboard**: everything is reachable by Tab, with a visible 3 dp focus ring. Escape
  closes sheets and dialogs.
- **Reduced motion**: every animation goes through `MotionPrefs` and stops when the system
  asks it to.

Details and the TalkBack/VoiceOver walkthrough: [docs/A11Y.md](docs/A11Y.md).

---

## Platform support

| | Android | iOS | Web (PWA) |
| --- | :---: | :---: | :---: |
| Minimum | Flutter's default `minSdk` (compileSdk 37) | iOS 15.0 | Browsers with WasmGC run the faster wasm build (Chrome 119+, Firefox 120+, Safari 18.2+); older ones fall back to JS |
| Database | SQLite (FFI, WAL) | SQLite (FFI, WAL) | `sqlite3.wasm` in a worker (OPFS, then IndexedDB) |
| Barcode scan | ✅ | ✅ | ✅ where `BarcodeDetector` exists (not Firefox; the CSP blocks the CDN fallback on purpose) |
| Quote OCR | ✅ ML Kit, Latin + Devanagari | ✅ ML Kit, Latin | ✍️ type it instead |
| Reminders | ✅ local notifications | ✅ local notifications | Overdue banner |
| Auto-backup | ✅ | ✅ | ❌ (no folder; use *Back up now*) |
| Home-screen widget | ✅ | ❌ (needs a WidgetKit extension) | ❌ |
| Covers stored in | `<documents>/covers/` | `<documents>/covers/` | `cover_blobs` table |
| Works offline | ✅ | ✅ | ✅ (installable PWA) |

---

## Getting started (development)

### Requirements

- Flutter (stable) with Dart SDK `^3.13.7`
- Xcode for iOS (iOS 15+ target; every plugin is a Swift package, so there is no Podfile)
- Android SDK for Android
- Chrome for the web

### Run

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift, Riverpod codegen

flutter run --flavor dev -t lib/main_dev.dart   # Android / iOS
flutter run -d chrome -t lib/main_dev.dart      # Web
```

### Flavors

| Flavor | App name | Android id | Entry point | Extras |
| --- | --- | --- | --- | --- |
| `dev` | Kitabkhana Dev | `com.kitabkhana.kitabkhana.dev` | `lib/main_dev.dart` | `/dev/gallery` (every UI component, with dark-mode and text-scale toggles), `/dev/lookup` (Open Library debugger), demo-data seeders in More |
| `prod` | Kitabkhana | `com.kitabkhana.kitabkhana` | `lib/main_prod.dart` | — |

Both install side by side.

### Build-time settings (`--dart-define`)

| Key | Used for | When empty |
| --- | --- | --- |
| `CONTACT_EMAIL` | Contact in the Open Library `User-Agent` (mobile only) | Omitted, so no personal address is compiled in |
| `FEEDBACK_EMAIL` | *Send feedback* recipient | Mail app opens with no recipient |
| `PRIVACY_URL` | Privacy policy link in Settings | Link hidden |
| `GOOGLE_BOOKS_KEY` | Google Books API key for the fallback lookup (CI reads the `GOOGLE_BOOKS_KEY` repository secret) | Google Books is still tried, but the shared keyless quota is usually used up, so the fallback rarely answers. **Set the key.** |

### Demo data (dev flavor)

More → **Load store demo data (dev)** loads 13 public-domain classics with places, loans
(one due soon, one overdue), a reading streak, quotes, tags and a goal. This is the data in
every screenshot here. More → **Seed 5,000 books (dev)** loads a large library for
performance checks. The Library app bar's flask button adds 300 demo books.

### Useful commands

```sh
flutter test --exclude-tags golden          # what CI runs
flutter test test/matrix --update-goldens   # regenerate golden images (macOS)
flutter test test/perf                      # 5,000-book timings (PERF lines)
flutter test integration_test               # whole-app journeys
dart format lib test integration_test test_driver
flutter analyze --fatal-infos --fatal-warnings
```

### Regenerating the screenshots

```sh
GENERATE_ASSETS=1 flutter test test/tool/generate_readme_screenshots_test.dart  # README (docs/screenshots/)
GENERATE_ASSETS=1 flutter test test/tool/generate_store_screenshots_test.dart   # store listings (docs/store/screenshots/)
```

Both are skipped in normal test runs, so tests never rewrite the repository.

---

## Project structure

```
lib/
  main_dev.dart, main_prod.dart   entry points per flavor
  app/        bootstrap, router (go_router), adaptive shell, theme, Riverpod providers
  core/       Result/Failure, Clock, UUIDv7, logger, rate limiter, debouncer,
              text utils (ISBN, FTS queries, title keys, trigram similarity, phone, quote clean-up),
              image processing (covers, page images)
  data/       db/ (Drift tables, migrations, connection), open_library/ (client, mapper), cache
  platform/   one folder per device capability, each an interface + mobile + web version:
              backup, camera_permission, cover_store, notifications, ocr, photo_picker,
              scanner, share
  features/   backup · book · lending · library · locations · more · onboarding · quotes ·
              reading · reminders · scan_check · settings · stats · tags
              each split into domain/ application/ data/ presentation/
  ui/         design-system widgets (K-prefixed: KButton, KCard, KBookCover, KChip, KToast, …)
  l10n/       ARB files and generated localisations
test/         unit, widget, golden, a11y, perf, security, matrix and tool tests
integration_test/  whole-app journeys over fake platform services
docs/         architecture, design, database, privacy, QA, release guides, ADRs, store listing
tool/         changelog script, privacy page builder, release smoke test, device probe
drift_schemas/  schema snapshots for migration tests
web/          PWA manifest, icons, CSP headers, redirects, sqlite3.wasm, drift worker
```

About 40,000 lines of hand-written Dart in `lib/`, plus 115 test files.

---

## Architecture

```
presentation  →  application (use cases)  →  domain  ←  data
      widgets,          all writes,           pure Dart:      Drift DAOs,
      Riverpod          one transaction       entities,       Open Library,
      providers         per multi-row write   repo interfaces mappers
                                   ↓
                         platform services (interface + mobile + web)
```

- **Dependencies point downward only.** `domain` is pure Dart with no Flutter imports.
  The UI never touches Drift or HTTP.
- **Errors** are sealed `Failure` classes inside a `Result<T>`. No raw exception reaches the UI.
- **Time** comes from an injected `Clock`, never `DateTime.now()`, so streaks, due dates and
  goals are fully testable.
- **State**: Riverpod 3 with code generation ([ADR 0002](docs/adr/0002-riverpod-3.md)).
  Database providers have automatic retry turned off.
- **Navigation**: go_router with a `StatefulShellRoute` for the five tabs (Library, Scan,
  Reading, Stats, More) and full-screen routes for book, edit, quote capture, loans, quotes,
  locations, tags, settings, about and onboarding. Deep links such as `/book/<id>` work on
  the web after a refresh.
- **Concurrent writes**: `BookRepository.update(id, fn)` reads and writes in one transaction,
  so background work (cover downloads) never overwrites the user's edits.
- **Every string** goes through l10n. Every colour, size and duration comes from theme tokens.

### Routes

| Path | Screen |
| --- | --- |
| `/library` | Library (tab) |
| `/library/add` · `/scan` · `/batch` · `/isbn` · `/search` · `/manual` · `/preview` | Add flow |
| `/scan` | Scan check (tab) |
| `/reading` | Reading (tab) |
| `/stats` | Stats (tab) |
| `/more` | More (tab) |
| `/book/:id` · `/book/:id/edit` · `/book/:id/quote` | Book detail, edit, Snap-a-Quote |
| `/loans` · `/quotes` · `/locations` · `/tags` · `/settings` · `/about` · `/onboarding` | Secondary screens |
| `/dev/gallery` · `/dev/lookup` | Dev flavor only |

More: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## Data model

Drift (SQLite), schema **v3**. Every synced table carries a UUIDv7 text `id`
([ADR 0001](docs/adr/0001-uuid-v7-ids.md)), `createdAt`, `updatedAt`, `deletedAt` (soft
delete) and `rev`. These columns exist so backup merges are safe. There is no sync.

| Table | Holds |
| --- | --- |
| `books` | Title, subtitle, authors, series and number, ISBN-13, work key, title key, cover (URL and local ref), pages, genre, language, ownership, status, current page, rating, location, owner name, notes, start/finish dates |
| `locations` | Name, parent (nesting), sort order, icon |
| `loans` | Book, direction (lent/borrowed), person, phone, started, due, returned, previous location, note. One active loan per book (partial unique index). |
| `reading_logs` | Book, date, pages read, from page, to page |
| `reading_sessions` | Book, date, minutes read (from the timer) |
| `read_throughs` | Earlier reads of a book being read again: started, finished |
| `quotes` | Book, body, page, favourite |
| `goals` | Year, target books |
| `tags`, `book_tags` | Tags and the book ↔ tag links |
| `books_fts` | FTS5 index over title, subtitle and authors (`unicode61 remove_diacritics 2`), only for non-deleted books ([ADR 0003](docs/adr/0003-drift-fts5.md)) |
| `cover_blobs` | Web-only cover JPEGs (added in v2) |
| `lookup_cache` | Open Library answers: successes for 30 days, not-found for 7 |
| `app_meta` | Settings and device id (key/value) |

Foreign keys are on, and native builds use WAL. Migrations are tested against the
snapshots in `drift_schemas/`. More: [docs/DATABASE.md](docs/DATABASE.md).

---

## Book lookups (Open Library, then Google Books)

The app's **only** network traffic. Only an ISBN or a title/author query is ever sent.
Open Library is always asked first.

- **ISBN**: `/isbn/{isbn13}.json` → `/works/{key}.json` (only if the edition has no
  authors) → `/authors/{key}.json` (up to 3, fetched in parallel). The work key is what lets
  the scan check recognise *another edition* of a book you own.
- **Title search**: `/search.json` with a short `fields` list.
- **Resilience**: a token bucket (1 request/s, burst 3), timeouts, 2 retries with backoff
  and jitter for timeouts and 5xx only, `Retry-After` honoured on 429, and a circuit
  breaker after repeated failures. A slow network is not treated as offline.
- **Google Books fallback**: when Open Library has no record (or is unreachable), the
  same ISBN or title is asked of Google Books, which knows many more Indian titles.
  Google is never asked when Open Library answers.
- **Cache first**: successes are kept 30 days and not-found answers 7 days. When offline,
  an expired success is still served, so a book you looked up once keeps working.
  Network failures are never cached.

More: [docs/OPEN_LIBRARY.md](docs/OPEN_LIBRARY.md).

---

## Backup format

A `.kitab` file is a plain **zip** you can open with any zip tool:

```
manifest.json            formatVersion, appVersion, schemaVersion, deviceId, exportedAt,
                         counts, and a SHA-256 for every other file
data/books.json          one JSON array per table, soft-deleted rows included (tombstones)
data/locations.json
data/loans.json
data/reading_logs.json
data/quotes.json
data/goals.json
data/tags.json
data/book_tags.json
covers/<bookId>.jpg      processed covers
```

The import refuses non-backups ("This isn't a Kitabkhana backup"), newer formats ("Update
the app first") and damaged files (any checksum mismatch or extra file). It always makes a
**safety backup** first and imports in **one transaction**. **Merge** keeps the row with the
newer `updatedAt` (`rev` breaks ties), so a deletion on one device is not undone by an
older copy. Settings, the lookup cache and web cover blobs are device-local and not backed
up. More: [docs/BACKUP_FORMAT.md](docs/BACKUP_FORMAT.md).

---

## Design system

**"Ink & Paper"**: calm, warm, bookish. Covers are the hero.

| Token | Light "Paper" | Dark "Lamplight" |
| --- | --- | --- |
| background | `#FBF7F0` | `#15120F` |
| surface | `#FFFFFF` | `#1E1A16` |
| text | `#1F1B16` | `#F2EBE1` |
| primary (terracotta) | `#B4532A` | `#E08A5B` |
| secondary (teal) | `#1F5C5B` | `#7FB8B5` |

- **Type**: Fraunces (display, headlines, book titles) and Inter (UI), both bundled. Scale
  34 / 26 / 20 / 16 / 14 / 12.
- **Shape**: 4-pt spacing grid, 20 dp screen padding. Radii: cards 20, sheets 28, buttons
  14, chips 12, covers 6. Soft warm shadows.
- **Motion**: 200–300 ms, `easeOutCubic`, 30 ms list stagger, hero covers. All of it is
  turned off by reduced motion.
- **Breakpoints**: compact < 600 dp (bottom bar), medium 600–1000 dp (rail), expanded
  > 1000 dp (rail + two-pane).
- **Components**: `lib/ui/` (`KButton`, `KCard`, `KChip`, `KBookCover`, `KGeneratedCover`,
  `KBottomSheet`, `KToast`, `KEmptyState`, `KSkeleton`, `KProgress`, …), all shown in
  `/dev/gallery`.

More: [docs/DESIGN.md](docs/DESIGN.md).

---

## Testing and quality

| Suite | What it covers |
| --- | --- |
| Unit and widget tests | Domain rules (ISBN, streaks, pace, due dates, similarity, quote clean-up), repositories, use cases and screens |
| **Layout matrix** (`test/matrix/`) | Every main screen × 9 sizes (320×568 to 1440×900) × light/dark, plus 200% text: nothing may overflow (260 tests) |
| **Goldens** | 91 pixel images with the real fonts, tagged `golden`, generated on macOS |
| **Insets** | Notches and gesture bars in portrait and landscape |
| **Accessibility** | Tap-target, label and contrast guidelines on every screen and key sheet, light and dark |
| **Security** | CSP vs. hosts used in code, no tracking keys in platform config, log privacy |
| **Performance** | Query budgets on a 5,000-book library |
| **Journeys** (`integration_test/`) | Six whole-app flows: first run, scan, lend and return, streaks over days, quotes, backup and restore |

Tests use an in-memory database, a fake clock and fakes for every platform service (camera,
OCR, notifications, Open Library, sharing, files). Details: [docs/QA.md](docs/QA.md).

---

## Performance

Measured on a 5,000-book library with 300 loans, 20,000 reading logs and 500 quotes
(development machine, medians of 9 runs):

| What | Budget | Measured |
| --- | --- | --- |
| Full-text search (English, Hindi, Bengali, prefix, author) | 50 ms | 0.8–2.1 ms |
| Ownership check, unknown ISBN | 500 ms | 2.1 ms |
| Ownership check, typo'd title (fuzzy) | 500 ms | 19.6 ms |
| Library first page, any sort | 100 ms | ~1 ms |
| Reading tab queries | 100 ms | 13 ms |
| All statistics queries together | 200 ms | 1.1 ms |

Covers are decoded at display size, never at full size. Icon fonts are tree-shaken. More:
[docs/PERFORMANCE.md](docs/PERFORMANCE.md).

---

## CI and releasing

**CI** (`.github/workflows/ci.yml`, on pushes to `main` and on pull requests):
code generation → format check → `flutter analyze --fatal-infos --fatal-warnings` → tests
with coverage (goldens excluded on Linux) → web build (wasm, no CDN) → Android debug APK →
iOS release build (no codesign) → journeys on an Android emulator → a prod release APK
(R8) smoke test with size and permission checks, uploaded as an artifact for sideloading.

**Release** (`.github/workflows/release.yml`, on a `v*` tag): CI, then in parallel a signed
AAB to the Play **internal** track, an IPA to **TestFlight**, and the web app to
**Cloudflare Pages**, then a GitHub Release with a changelog built from conventional
commits (`tool/changelog.sh`).

Guides: [Releasing](docs/RELEASING.md) · [Android](docs/ANDROID_RELEASE.md) ·
[iOS](docs/IOS_RELEASE.md) · [iOS flavors](docs/IOS_FLAVORS.md) · [Web](docs/WEB_RELEASE.md) ·
[Store listing](docs/store/README.md).

---

## Localisation

The app is fully translated into **English**, **Hindi (हिन्दी)** and **Bengali (বাংলা)**,
about 700 messages each, in `lib/l10n/app_*.arb`. It follows the phone's language.
`test/l10n/arb_parity_test.dart` fails if a translation is missing, or if it drops or adds
a placeholder or a plural case. `test/l10n/translated_screens_test.dart` opens every main
screen in each language on a 360 dp phone and fails on any overflow. Search and title
matching handle Devanagari and Bengali text (Unicode normalisation, FTS5 with diacritic
folding).

To add a language, copy `app_en.arb` to `app_<code>.arb`, translate the values (keep
`{placeholders}` and plural cases), and add the code to the two l10n tests.

## Known limits

- **Hindi OCR is Android-only.** The ML Kit plugin's iOS Swift package carries only the Latin
  model, so iPhones read Latin text.
- **Web**: no barcode scanning in Firefox, no OCR, no notifications, no automatic backup.
- **Automatic backups** stay in the app's own storage, because apps cannot keep writing to
  a folder outside it. The Library reminds you monthly to *Save a copy* elsewhere.
- **Release pipeline**: the Play, App Store and Cloudflare jobs have not run end to end yet.
- **ISBN screen**: an ISBN-10 ending in `X` can be pasted but not typed (numeric keyboard).

---

## Documentation index

| Doc | About |
| --- | --- |
| [ARCHITECTURE](docs/ARCHITECTURE.md) | Layers, rules, data design |
| [DATABASE](docs/DATABASE.md) | Schema, search, soft delete, web setup, migrations |
| [DESIGN](docs/DESIGN.md) | "Ink & Paper" design system |
| [ADD_BOOK](docs/ADD_BOOK.md) | The add-a-book flow |
| [COVERS](docs/COVERS.md) | Cover processing and storage |
| [OPEN_LIBRARY](docs/OPEN_LIBRARY.md) | Lookups, resilience, caching |
| [BACKUP_FORMAT](docs/BACKUP_FORMAT.md) | The `.kitab` file |
| [PRIVACY](docs/PRIVACY.md) | Every privacy promise and what enforces it |
| [A11Y](docs/A11Y.md) | Accessibility and the screen-reader walkthrough |
| [PERFORMANCE](docs/PERFORMANCE.md) | Budgets and measurements |
| [QA](docs/QA.md) | Test matrix, journeys, manual checks |
| [LICENSES](docs/LICENSES.md) | Third-party licences |
| [RELEASING](docs/RELEASING.md) and platform guides | Shipping to Play, App Store and the web |
| [ADRs](docs/adr/) | UUIDv7 ids · Riverpod 3 · Drift + FTS5 · Inexact reminders · No analytics |
| [BUILD_LOG](BUILD_LOG.md) · [CHANGELOG](CHANGELOG.md) | How it was built, what changed |

---

## Licence

Copyright © 2026 Perzival07. **All rights reserved.**

The code is shared for viewing only: you may not copy, modify, publish or use it, in
whole or in part, without written permission. To ask, [open an issue](https://github.com/Perzival07/Kitabkhana/issues).
Downloading and installing the released app for your own use is fine. See [LICENSE](LICENSE).
