# QA: devices, sizes and what is checked

## The automated matrix

Everything below runs with `flutter test` (the goldens carry the `golden` tag).
Code is in `test/matrix/`.

### Screens

Library (grid and list), Add book (entry and manual form), Book detail
(reading, and finished + lent), Scan result (the "Lent to Priya" verdict
sheet), Loans, Reading, Stats, Quotes, Settings, Onboarding. Demo data comes
from `test/helpers/seed_library.dart`.

### Sizes (logical pixels)

| Size | What it stands for |
| --- | --- |
| 320x568 | smallest phone |
| 360x800 | common Android |
| 412x915 | large Android |
| 430x932 | large iPhone |
| 844x390 | a phone on its side |
| 600x960 | small tablet, foldable inner screen |
| 800x1280 | tablet, portrait |
| 1280x800 | tablet, landscape |
| 1440x900 | web desktop |

### Checks

* **`layout_matrix_test.dart`**: every screen x every size x light/dark, plus
  200% text at 360x800 in both themes (260 tests). Nothing may overflow or
  throw.
* **`golden_matrix_test.dart`**: pictures (91) at 320x568, 360x800, 600x960 and
  1280x800 in light; 360x800 and 1280x800 in dark; 360x800 at 200% text. All
  eight sizes in both themes would be over 200 files, so the pictures cover the
  ends and the middle; the layout test above covers the rest. Fonts are the
  bundled Fraunces and Inter, so the images are stable. Update them with
  `flutter test test/matrix --update-goldens`.
* **`insets_test.dart`**: a notch (portrait) and a notch on both sides plus
  gesture bar (landscape): nothing may overflow, and no fixed text may start
  under the status bar or beside a notch (a row that scrolls sideways may pass
  under it while it moves).
* **`test/a11y/accessibility_test.dart`**: tap-target, label and contrast
  guidelines on every main screen (see `docs/A11Y.md`).

### What the matrix found and fixed

* The navigation rail overflowed on windows shorter than 500dp (a phone on its
  side): short windows now use the bottom bar.
* Reduce-motion plus a tablet width threw a layout error (a zero-length
  `AnimatedSize` on the library's Add button).
* Generated covers broke long words in the middle ("Middlema / rch"): the title
  now shrinks (down to 62%) so the longest word fits on a line.
* Book detail's header took most of a landscape screen: the cover now sits
  beside the titles on wide, short windows.
* The generated cover used as the detail page's blurred backdrop overflowed in a
  very wide, short area.
* Library, Reading and others ran under a landscape notch: the shell now keeps
  the left and right system insets.
* Loading skeletons on Reading and Stats overflowed short screens.
* Loans tabs now scroll at large text instead of squeezing.

## End-to-end journeys

Six whole-app journeys (`integration_test/flows.dart`), each driven through the
real screens over an in-memory database and fake platform services (camera,
text reading, notifications, Open Library, sharing, file picking, the app's
backup folder):

1. First run: introduction, starter places, then three books added by ISBN,
   by title search and by hand with no ISBN, each put on a shelf; the library
   shows them with their places.
2. Scan a barcode of a book you own ("You own this", "On Hall"); find a book
   without a barcode by typing its title.
3. Lend a book (it shows "Lent to Priya"), scan it ("Lent to Priya"), return
   it (it goes back to its shelf).
4. Update the page on three successive days (each a fresh launch with the
   clock moved on): the streak reaches 3; finish the book; Stats counts it.
5. Photograph a page (fake text reading), pick lines, save: the quote is in
   Quotes and on the book.
6. Share a backup, erase everything (back to the introduction), restore:
   books, places, quotes and goal come back identical.

They run three ways from the same code:

* `flutter test test/e2e`: in the ordinary runner (and so in CI's `verify`).
* `flutter test integration_test --flavor dev -d <device>`: on a device or
  emulator (CI job `e2e-android`).
* `flutter drive --driver=test_driver/integration_test.dart
  --target=integration_test/app_test.dart -d web-server --browser-name=chrome`:
  in a browser (CI job `e2e-web`).

The two CI device jobs run on pushes to `main` and on manual runs, not on every
pull request. I could not run them here (no emulator or Chrome driver), so
their first run may need small adjustments; the journeys themselves pass in
the ordinary runner.

What writing them found: the confirmation toast covered the library's Add
button (the toast and the button belong to different Scaffolds); the button
now steps out of the way while a toast is showing.

## Max content widths on big screens

Forms and reading content are capped so they do not stretch across a tablet or
a desktop browser: onboarding 520, About 560, Settings 640, Book detail content
640, and Reading, Stats, Quotes, Tags and the other tab content 720
(`kMaxContentWidth`). The library uses a two-pane layout above 1000dp.

## Not covered by tests: do these by hand

Run on real devices or emulators, in light and dark, at text scale 1.0, 1.3
and 2.0, with reduce motion on once:

* Phones: small Android (320-360dp, older Android), standard Android
  (393-412dp, gesture navigation), a large phone (430dp+), an iPhone with a
  notch or Dynamic Island, an iPhone SE-size screen.
* Larger: a foldable (inner and outer display, fold and unfold live; check
  nothing sits on the hinge), an Android tablet or iPad in both orientations,
  Android split-screen and multi-window.
* Web: Chrome, Safari and Firefox on desktop; Chrome on Android; Safari on
  iPhone; the installed PWA.
* Also: airplane mode, camera permission denied, notifications denied, Hindi
  as the language (once translations exist).

The foldable hinge is handled by `DisplayFeatureSubScreen` in the shell, but
only a real fold or the emulator's can confirm it.
