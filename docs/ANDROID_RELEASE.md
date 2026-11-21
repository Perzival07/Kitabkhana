# Android release

Everything here was written without an Android SDK, so the Gradle changes, the
R8 rules and the bundle build have **not been run**. Do the first release
build on a machine with the SDK and follow "First build" below.

## 1. Upload keystore (once)

The upload key signs the bundle you send to Google; with Play App Signing on
(the default) Google holds the real app signing key. Create it outside the repo:

```
keytool -genkey -v -keystore ~/kitabkhana-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep `kitabkhana-upload.jks` and its passwords in a password manager and in an
offline backup. If the upload key is lost, Play can reset it (support request),
but only because App Signing is on, so do not opt out.

Then create `android/key.properties` (gitignored, never commit it):

```
storeFile=/Users/you/kitabkhana-upload.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

`storeFile` is resolved from the `android/` folder; an absolute path is safest.
To check the key: `keytool -list -v -keystore ~/kitabkhana-upload.jks`.

`android/app/build.gradle.kts` signs release builds with it. Without the file,
release builds use the debug key (fine for `flutter run --release`), and
`bundleProdRelease` stops with an explanation instead of producing an
unuploadable bundle.

## 2. Shrinking

`release` has R8 code shrinking and obfuscation and resource shrinking on, with
rules in `android/app/proguard-rules.pro`:

- ML Kit's optional Chinese, Japanese, Korean and Devanagari recognizer classes
  are referenced but deliberately not bundled, so R8 is told not to fail on them
  (`-dontwarn`). Only the Latin recognizer is used.
- ML Kit and Play services components are kept (they are found by name).
- Source file and line numbers are kept so crash traces can be de-obfuscated.

Upload `build/app/outputs/mapping/prodRelease/mapping.txt` with each release
(the release workflow does), or Play Console crashes will be unreadable.

## 3. Versioning

`pubspec.yaml` has `version: 1.0.0+1`: `1.0.0` is `versionName`, `+1` is
`versionCode`. Play needs `versionCode` to rise on every upload. Bump the build
number for every upload, even a rejected one. (`flutter build ... --build-number
N` overrides it, which the release workflow uses.)

## 4. First build

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

Output: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`.

Then test the **release** build, not the debug one, because R8 is where plugin
problems appear: build an APK from the same config and install it on a
low-end and a recent phone:

```
flutter build apk --release --flavor prod -t lib/main_prod.dart
flutter install --release --flavor prod
```

Run the manual regression (docs/QA.md) with attention to the things R8 can
break: **scan a barcode, read a quote from a photo (ML Kit), backup and restore,
a reminder notification, share a quote card, open the database after a restart.**
If something works in debug and crashes in release, read `adb logcat` for
`ClassNotFoundException` or `NoSuchMethodError` and add a `-keep` rule.

Also check the size: `flutter build appbundle --analyze-size` (compare with
docs/PERFORMANCE.md), and the merged manifest
(`build/app/intermediates/merged_manifests/prodRelease/`) for any permission you
did not expect. INTERNET should be the only network permission.

## 5. Play Console checklist

**Create the app**: name Kitabkhana, default language English, App, Free.

**Store listing**: text from `docs/store/`, icon `assets/brand/icon_rounded_512.png`
(512x512), screenshots from `docs/store/screenshots/phone-play/` (and `tablet/`).
A 1024x500 feature graphic is required: see `docs/store/README.md`.

**App content**:
- *Privacy policy*: the URL where `docs/privacy/index.html` is hosted (it must
  be public, not a PDF, and match the app). Hosting is not set up yet.
- *Data safety*: "Does your app collect or share any of the required user data
  types?" **No.** Nothing leaves the device except the ISBN or title typed or
  scanned, sent to Open Library to look up a book; that is not collected by
  you, is not linked to the user, and Open Library is not a service you share
  data with in Google's sense, but if the form asks about it, answer for "app
  activity / search history" transient, not stored, not shared. Re-read
  Google's wording when filling it in, and keep it consistent with the policy.
  The camera is used on-device only (scanning and text reading) and nothing is
  uploaded.
- *App access*: all features available without login.
- *Ads*: none. *Content rating*: complete the IARC questionnaire (utility/
  reference, no user-generated content shared, no violence); expect "Everyone".
- *Target audience*: 18 and over is simplest. Choosing under 13 pulls in the
  Families policy and more review. *News app*: no. *Government app*: no.
  *Financial features*: none. *Health*: none.

**Release**: App Signing: let Google manage it, then upload the `.aab`.

## 6. Tester requirement for new personal accounts

For a **personal** developer account created after 13 November 2023, you can't
publish to production straight away: you must run a **closed test** with at
least **12 testers opted in continuously for 14 days**, then apply for
production access ([Google's help page](https://support.google.com/googleplay/android-developer/answer/14151465)).
The number was 20 earlier; it is 12 now. Organization accounts are not
subject to this. Rules like this change: re-read the page before planning.

Plan: create a closed testing track, add testers by email or Google Group, send
them the opt-in link on day 1, ask them to keep it installed, and fix any
feedback during the 14 days. Open testing does not count towards it.

Practical order: upload to **internal testing** first (up to 100 testers, no
review, available in minutes) to check install and signing, then the closed
track, then production with a staged rollout (docs/RELEASING.md).
