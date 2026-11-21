# iOS release

Written without a Mac toolchain (the machine used had no full Xcode run, no
CocoaPods, no fastlane), so **nothing here has been built or uploaded**. Expect
to fix small things on the first run, and treat this file as the plan.

## 1. One-time setup

1. Join the Apple Developer Program and note the **Team ID**.
2. Do the flavor setup in `docs/IOS_FLAVORS.md` (schemes `dev` and `prod`,
   configurations `Debug-prod`, `Release-prod` and so on). The `Podfile` already
   lists those configuration names; `fastlane` and the build command below need
   the `prod` scheme to exist.
3. Bundle IDs: `com.kitabkhana.kitabkhana` (prod) and `.dev` (dev). Register the
   prod ID in the developer portal, or let Xcode do it. Capabilities: none are
   required. **Notifications** need no entitlement for local notifications; the
   app asks permission at runtime. Do not add Push Notifications, iCloud, or
   Background Modes: the app uses none, and each adds review questions.
4. Signing: in Xcode, target Runner > Signing & Capabilities > tick
   "Automatically manage signing" for each configuration and choose your team.
5. Create the App Store Connect app record (name, bundle ID, SKU, primary
   language).
6. `ios/Runner/Info.plist` already sets `ITSAppUsesNonExemptEncryption` to
   `false` (the app only uses the system's HTTPS), so TestFlight won't ask the
   export-compliance question on every upload.

## 2. Deployment target and ML Kit

- Deployment target is **iOS 15.0**: the plugins' ML Kit packages (text
  recognition and barcode scanning) require 15.0, and `mobile_scanner` 12.0.
  Don't lower it.
- `ios/Podfile` pins `platform :ios, '15.0'`, forces pods up to 15.0 and
  declares the flavor configurations. These plugins also ship Swift Package
  Manager manifests, so Flutter may use SwiftPM instead of CocoaPods for them;
  both paths are set up.
- Simulator on Apple Silicon: if a pod complains about `arm64` for the
  simulator, add `config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] =
  'i386'` (or, for old ML Kit builds, `arm64`, and run under Rosetta) in the
  Podfile's `post_install`. Not needed so far; unverified.

## 3. Build

```
flutter build ipa --release --flavor prod -t lib/main_prod.dart
```

The archive is in `build/ios/archive/` and the `.ipa` in `build/ios/ipa/`.
Validate it before uploading with Xcode's Organizer (Validate App) or
`xcrun altool --validate-app`.

## 4. TestFlight with fastlane

```
cd ios
bundle install
export ASC_KEY_ID=... ASC_ISSUER_ID=... ASC_KEY_CONTENT=$(base64 < AuthKey_XXXX.p8) APPLE_TEAM_ID=...
bundle exec fastlane beta
```

`ios/fastlane/Fastfile` builds the `prod` scheme and uploads with the App Store
Connect API key; no Apple ID password. CI does the same from secrets (see
`docs/RELEASING.md`).

## 5. App Store Connect checklist

- **App Privacy ("nutrition label")**: **Data Not Collected.** No data is
  collected by you or any third party; the only network request is the ISBN or
  title lookup to Open Library, which carries no identifier and is not stored by
  you. Camera: used on device only. Keep this in step with the privacy policy.
- **Privacy manifest**: `ios/Runner/PrivacyInfo.xcprivacy` is in the Runner
  target (tracking false, no tracking domains, no collected data, no
  required-reason APIs of its own). I registered it in `project.pbxproj` by hand
  (the file parses, but it has not been opened in Xcode): confirm it shows
  under Runner and in Build Phases > Copy Bundle Resources. Plugins ship their
  own manifests; run Xcode's "Generate Privacy Report" on the archive to see the
  combined list and fix any gap Apple's upload check emails about.
- **Privacy policy URL**: required. Use the hosted `docs/privacy/index.html`.
- **Screenshots**: `docs/store/screenshots/phone-ios/` (6.7" 1290x2796) and
  `tablet/` (iPad 12.9" 2048x2732). Both are needed because the app runs on iPad.
- **Text**: description, subtitle (30), keywords (100), what's new, from
  `docs/store/`. Support URL: required (a page or the repo's issues page).
- **Age rating**: complete the questionnaire; expect 4+.
- **Review notes** (paste this):

  > Kitabkhana is a private, offline-first home library tracker. There is no
  > account or login, so no demo credentials are needed: every feature is
  > available on first launch. The camera is used only on the device, to scan
  > book barcodes and to read text from a photographed page for saving quotes;
  > nothing is uploaded. The only network use is looking up a book's details
  > (ISBN or title) from the public Open Library service. Notifications are
  > local reminders for lent books and reading goals, and are optional. To try
  > the app without books, open More > Settings, or add a book by typing a
  > title. If you have no physical book to scan, use "Add by title" instead.

- **Export compliance**: already answered by the plist key above.
- Submit for review; choose manual release the first time so you can control
  the date.
