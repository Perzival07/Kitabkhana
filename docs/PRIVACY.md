# Privacy: what the app does and how it is enforced

The public, plain-language policy is `docs/privacy/privacy-policy.md` (built to
`docs/privacy/index.html`). This page is for the people who maintain the app:
every promise in the policy, and what keeps it true.

## The promises, and what backs each one

| Promise | Where it is enforced |
| --- | --- |
| The library is only stored on the device | Drift/SQLite in the app's own storage; no sync code exists. The `sync` columns (`rev`, `updatedAt`, `deletedAt`) only serve backup merges. |
| Only ISBN or title text is sent to Open Library (and Google Books as a fallback) | `lib/data/open_library/` and `lib/data/google_books/` build the only requests; `test/data/` checks the URLs. The User-Agent is `Kitabkhana/<version>` and carries no contact address unless `--dart-define=CONTACT_EMAIL` is given. |
| Those are the only hosts the app contacts | `test/security/web_csp_test.dart` finds every `https://` host in `lib/` and checks the web policy allows exactly Open Library, Google Books and their cover hosts. |
| No analytics, ads or tracking | None in `pubspec.yaml` (see `docs/LICENSES.md`); `test/security/platform_config_test.dart` forbids the advertising ID, tracking and SKAdNetwork keys. |
| Problem reports leave only by the reader's hand | `CrashRecorder` keeps the first error of a run on the device (`FileCrashStore`); `CrashReportPrompt` asks next launch; `ProblemReporter` opens the reader's own mail app (`flutter_email_sender`), falling back to a `mailto:` link or the share sheet. The app has no way to send mail itself. Tested in `test/features/crash`. |
| Logs never hold library contents | `test/security/log_privacy_test.dart` checks every log call at info and above uses constant text (or an exception's type); `AppLogger` also masks phone-like digits and e-mail addresses. |
| The diagnostics export has no library contents | `buildDiagnostics` takes versions and log lines only; `test/features/settings` proves a book's title never appears in it. |
| No cloud backup of the library | `android:allowBackup="false"`, `android:fullBackupContent="false"` and data-extraction rules excluding every domain (cloud and device transfer); tested in `platform_config_test.dart`. iOS: the database is in the app's documents folder, which iCloud backs up with the device (see "Known gaps"). |
| HTTPS only | Android `usesCleartextTraffic="false"` and a network security config; iOS has no ATS exception; the web policy has `upgrade-insecure-requests` and no `http:` source. |
| Only the permissions the features need | Android: `INTERNET`, `CAMERA`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, nothing else of ours; **no** `SCHEDULE_EXACT_ALARM` (reminders are inexact on purpose). iOS: camera and photo picker strings only. |
| The camera photo of a quote is discarded | `MobileOcrService` writes it to a temp file for ML Kit and deletes it in a `finally`; the capture screen drops the bytes once text is read; only text is saved. |
| Erase really erases | `EraseAllData` clears every table, cover files, the backups folder and pending notifications; tested. |

## Network requests, in full

| To | Why | Contains |
| --- | --- | --- |
| `openlibrary.org` | book details by ISBN, search by title | the ISBN or title text |
| `covers.openlibrary.org` (redirects to `*.archive.org`) | cover pictures | an ISBN or cover id in the URL |
| `www.googleapis.com` | book details, **only** when Open Library has no answer (`FallbackBookInfoSource`) | the ISBN or title text, the app's API key (`GOOGLE_BOOKS_KEY`), the package or bundle id |
| `books.google.com`, `books.googleusercontent.com` | cover pictures for books found on Google Books | the volume id in the URL |

Nothing else. The web build must be made with `--no-web-resources-cdn`, or the
CanvasKit engine would be fetched from `gstatic.com` (a third party the policy
says is not used); the CI web build does this.

## Platform hardening

**Android** (`android/app/src/main/AndroidManifest.xml`, `res/xml/`):
backup off, cleartext off, a minimal permission list, one exported activity.
`INTERNET` is declared in the main manifest because debug and profile builds add
it by themselves and a release build does not. After building a release APK or
bundle, check the **merged** manifest (plugins add entries):

```
flutter build apk --release --flavor prod -t lib/main_prod.dart
$ANDROID_HOME/build-tools/<ver>/aapt2 dump permissions build/app/outputs/flutter-apk/app-prod-release.apk
```

Expect `INTERNET`, `CAMERA`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`
and `VIBRATE` (added by the notifications plugin for reminder vibration). Anything
else is a plugin change to investigate; remove it with `tools:node="remove"`.

**iOS** (`ios/Runner/Info.plist`): only `NSCameraUsageDescription` and
`NSPhotoLibraryUsageDescription`, each saying what it is for and that nothing is
uploaded. No App Transport Security exceptions, so HTTPS only by default. The
notification permission has no plist string (the system asks at runtime, after
the app has explained why).

**Web** (`web/index.html`, `web/_headers`): a Content Security Policy that allows
scripts from this origin and `wasm-unsafe-eval` only (no `unsafe-eval`, no inline
scripts), connections to Open Library only, `upgrade-insecure-requests`,
`referrer: no-referrer`. Styles allow `unsafe-inline` because Flutter writes
inline styles. `web/_headers` adds what a `<meta>` tag cannot (HSTS,
`frame-ancestors 'none'`, `nosniff`, a permissions policy that allows the camera
only to this origin); copy it into your host's configuration if it does not read
that file.

## Dependencies

All direct dependencies are permissive (MIT, BSD, Apache-2.0); see
`docs/LICENSES.md`. `flutter pub outdated` was run: every direct dependency is
current except `cupertino_icons` (a font-only package, major bump available).
A few transitive packages were updated; `sqlite3` is deliberately held back,
because the web build ships `web/sqlite3.wasm` and `drift_worker.js`, which must
match the `sqlite3` package version. When upgrading it, replace both files with
the matching release.

## Known gaps

* **iOS backup.** The database lives in the app's documents folder, which iOS
  includes in iCloud and device backups. The policy's "never sent to our
  servers" is true (we have none), but Apple's backup would copy the library to
  the user's own iCloud. To exclude it, set `isExcludedFromBackup` on the
  database file from native code; not done yet (no Xcode here).
* The Android merged manifest and the signed iOS build were not inspected here
  (no Android SDK or Xcode); the commands above do it.
