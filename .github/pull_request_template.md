## What and why

<!-- Short summary. Link the BUILD_LOG.md task ID (e.g. P04.2). -->

## Definition of Green

- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `dart format --set-exit-if-changed lib test integration_test`
- [ ] `flutter analyze` reports 0 issues
- [ ] `flutter test` passes (goldens included)
- [ ] Android debug build (dev flavor) builds and runs
- [ ] Web build builds and runs in Chrome
- [ ] iOS build builds and runs (if on a Mac)
- [ ] Manual checks for this step pass on the device matrix
- [ ] Light and dark mode correct
- [ ] No overflow at 200% text scale; 320dp width OK; landscape OK
- [ ] No new hard-coded strings, colors or sizes
- [ ] `BUILD_LOG.md` updated
