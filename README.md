# Kitabkhana

![CI](https://github.com/Perzival07/Kitabkhana/actions/workflows/ci.yml/badge.svg)

A private, offline-first home library and reading tracker for Android, iOS and Web (PWA).

It answers three questions, with no internet needed:

1. **Do I own this book?**
2. **Where is it?**
3. **Who has it?**

## Features

- Add books by barcode scan, typed ISBN, title search or manually
- Locations, and a "Don't Buy It Twice" scan check that works even for books without barcodes
- Lending and borrowing with reminders and WhatsApp/SMS nudges
- Reading tracker: progress, streaks, pace, yearly goal, stats
- Snap-a-Quote: on-device OCR on mobile, typed on web
- Backup/restore (`.kitab` zip, replace or merge) and CSV export

## Privacy

No accounts, no backend, no analytics. Data stays on your device. The only network
calls are ISBN/title lookups to [Open Library](https://openlibrary.org).

## Getting started

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --flavor dev -t lib/main_dev.dart   # Android / iOS
flutter run -d chrome -t lib/main_dev.dart      # Web
```

Flavors: `dev` ("Kitabkhana Dev", id suffix `.dev`) and `prod`. Both install side by side.

## Docs

- [Architecture](docs/ARCHITECTURE.md) · [Design system](docs/DESIGN.md) · [ADRs](docs/adr/)
- [Build log](BUILD_LOG.md) · [Changelog](CHANGELOG.md)
