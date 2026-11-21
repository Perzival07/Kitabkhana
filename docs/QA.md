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
