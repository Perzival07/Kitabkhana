# iOS dev/prod flavors (one-time Xcode setup)

Needs full Xcode and CocoaPods. In `ios/Runner.xcworkspace`:

1. Project > Runner > Info > Configurations: duplicate Debug, Release, Profile as
   `Debug-dev`, `Release-dev`, `Profile-dev` and `Debug-prod`, `Release-prod`, `Profile-prod`
   (Flutter requires the flavor name as a suffix after a hyphen).
2. Target Runner > Build Settings: set `PRODUCT_BUNDLE_IDENTIFIER` to
   `com.kitabkhana.kitabkhana.dev` for `*-dev` and `com.kitabkhana.kitabkhana` for `*-prod`.
   Add a user-defined setting `APP_DISPLAY_NAME` = `Kitabkhana Dev` / `Kitabkhana`, and set
   `CFBundleDisplayName` in Info.plist to `$(APP_DISPLAY_NAME)`.
3. Product > Scheme > Manage Schemes: duplicate `Runner` to `dev` and `prod`; for each, set the
   Run/Profile/Archive build configurations to the matching `-dev` / `-prod` ones.
4. Run `cd ios && pod install`, then `flutter run --flavor dev -t lib/main_dev.dart`.
