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
- [ ] P02.3
- [ ] P02.4

## Phase 03 — Book data
- [ ] P03.1
- [ ] P03.2

## Phase 04 — Library
- [ ] P04.1
- [ ] P04.2
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
