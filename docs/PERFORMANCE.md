# Performance

## What was measured, and where

`test/perf/` fills an in-memory database with **5,000 books** (English, Hindi
and Bengali titles, ~80% with an ISBN, 25 places, 15 tags and ~6,000 tag
links), **300 loans**, **20,000 reading logs** and **500 quotes**
(`PerfSeeder`, deterministic) and times the queries the screens run. Seeding
takes about 2.4 s. Run it with:

```
flutter test test/perf            # numbers appear on the `PERF` lines
flutter test -x perf              # leave it out
```

The numbers below are medians of 9 runs on the development machine (an Apple
silicon laptop). **A low-end phone is several times slower**, so treat each
figure as the best case and compare it to the budget with that in mind; the
test asserts the budgets themselves, unscaled.

| What | Budget | Measured (dev machine) |
| --- | --- | --- |
| Full-text search (English, Hindi, Bengali, prefix, author) | 50 ms | 0.8-2.1 ms |
| CheckOwnership: unknown ISBN | 500 ms | 2.1 ms |
| CheckOwnership: typo'd title (fuzzy) | 500 ms | 19.6 ms |
| Library first page, any sort (60 books) | 100 ms | 1.0-1.1 ms |
| Library first page, filtered by status, place and tag | 100 ms | 0.2 ms |
| Library counts and lent-out set | 100 ms | 2.2 ms |
| Reading tab queries (books, week, streak) | 100 ms | 13.0 ms |
| Quotes + tags + loans lists | 100 ms | 21.4 ms |
| Each statistics query | 200 ms | 0.1-0.2 ms |
| All seven statistics queries at once | 200 ms | 1.1 ms |
| Library screen: type "River" to results on screen (widget test) | n/a | ~220 ms, of which 250 ms is the search debounce |

Also asserted: the ISBN, title-key, loan and reading-log lookups use their
indexes (`EXPLAIN QUERY PLAN`), and a library of 5,000 builds only a screenful
of tiles (under 40) and pages in more as you scroll
(`test/perf/library_scale_test.dart`).

### Findings

No query was near its budget, so no indexes or query changes were needed. The
slowest are the Reading tab's streak query (it reads every distinct reading
day) and the quotes/tags/loans lists, both still far inside 100 ms here. If a
real device shows them slow, the streak could be cached per day.

Memory: covers are decoded at thumbnail size (`ResizeImage` in `KBookCover`,
width = display width x pixel ratio), never at full size.

## Not measured here (needs a device)

These need a physical low-end Android in **profile mode**
(`flutter run --profile`), and I had no device while building:

* **Cold start under 2 s.** Open DevTools > Performance and record from
  launch, or use `flutter run --profile --trace-startup` and read
  `build/start_up_info.json` (`timeToFirstFrameMicros`).
* **Library scroll without jank.** In dev, More > "Seed 5,000 books (dev)",
  then record DevTools > Performance while flinging the library in grid and
  list; look for UI or raster frames over 16 ms. The first-load cascade is
  limited to the first 14 tiles so it cannot dominate.
* **Other animations** (sheets, scan verdict, finishing a book): see P10.2.
* **App size.** `flutter build apk --analyze-size --split-per-abi` needs the
  Android SDK (not installed here). The web build is 45 MB (36 MB of it the
  CanvasKit runtime Flutter ships; `main.dart.js` is 5.2 MB).

## Size housekeeping done

* Removed the unused `uuid` and `path` packages and the unused Fraunces 500
  font file (the app uses Fraunces 400, 400 italic, 600 and 700, and Inter 400,
  500, 600, 700).
* Tree-shaken icon fonts are already on (Material icons 1.6 MB to 18 KB).
* Build release APKs per ABI so each phone downloads only its own code:
  `flutter build apk --release --split-per-abi` (an App Bundle does this
  automatically).
