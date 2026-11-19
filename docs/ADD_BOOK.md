# Adding a book (P04.1)

Entry: `/library/add` offers four ways in. All of them end in the same form and the same use case.

```
Scan barcode ─┐
Type ISBN ────┼─ lookup ─ found ──────► Preview (form pre-filled, catalogue cover)
              │           └ not found / offline / error ─► Manual form (ISBN + a friendly note)
Search title ─┴─ result tapped ───────► Preview
Enter manually ───────────────────────► Manual form
```

A failed lookup never blocks: the user lands on the manual form with whatever is known.

## Screens (`lib/features/library/presentation/add/`)

| File | Route | Notes |
|---|---|---|
| `add_entry_screen.dart` | `/library/add` | four cards |
| `add_isbn_screen.dart` | `/library/add/isbn` | numeric keyboard, live validation, paste button |
| `add_search_screen.dart` | `/library/add/search` | 350 ms debounce, skeletons, stale answers ignored |
| `add_scan_screen.dart` | `/library/add/scan` | basic scan; full scanner arrives with the Scan tab (P05.2) |
| `book_form_screen.dart` | `/library/add/manual`, `/library/add/preview` | the shared form; extra = `BookFormArgs` |
| `duplicate_sheet.dart` | (bottom sheet) | "You may already have this" |

The preview and manual routes read their data from `GoRouterState.extra`; without it (for example
after a browser refresh) they fall back to an empty manual form.

## Use case (`AddBook`)

1. Title is required; pages, when given, must be above 0.
2. Duplicates are looked up by **ISBN, work key and title key** (deleted books ignored) and reported
   once each. Nothing is saved until the user chooses: *Open existing*, *Add another copy* or *Cancel*.
3. The book is saved in one transaction. Status `reading` sets `startedOn`; `finished` sets
   `finishedOn` and `currentPage = pages`.
4. The cover is attached **in the background**: a chosen photo wins over the catalogue image. The
   attach step uses `BookRepository.update`, an atomic read-modify-write, so edits made meanwhile are
   not lost. Failures are logged, never thrown.

## Known limits

- The ISBN screen uses the numeric keyboard, so an ISBN-10 ending in `X` can be pasted but not typed.
- A title-key duplicate needs the same author text style; "Hobbit" with no author does not match
  "The Hobbit by Tolkien". The fuzzy matching in the Scan tab (P05.1) covers that case.
- The location field is a simple dropdown; the searchable picker with inline creation comes in P04.3.
