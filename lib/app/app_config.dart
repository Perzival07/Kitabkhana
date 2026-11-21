/// Build flavor of the app.
enum Flavor { dev, prod }

/// The app version; kept equal to `pubspec.yaml` (a test enforces it).
const String kAppVersion = '1.0.0';

/// Contact address sent in the Open Library User-Agent, as Open Library asks
/// API clients to do. Supply with `--dart-define=CONTACT_EMAIL=you@example.com`;
/// empty by default so no personal address is ever baked in.
const String kContactEmail = String.fromEnvironment('CONTACT_EMAIL');

/// Where "Send feedback" mails go. Supply with
/// `--dart-define=FEEDBACK_EMAIL=...`; when empty the mail app opens with no
/// recipient filled in.
const String kFeedbackEmail = String.fromEnvironment('FEEDBACK_EMAIL');

/// Link to the privacy policy. Supply with `--dart-define=PRIVACY_URL=...`;
/// the About screen shows the link only when it is set.
const String kPrivacyPolicyUrl = String.fromEnvironment('PRIVACY_URL');

/// Immutable per-flavor configuration passed to [bootstrap].
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.enableVerboseLogs,
    this.contactEmail = kContactEmail,
    this.version = kAppVersion,
  });

  const AppConfig.dev()
    : flavor = Flavor.dev,
      appName = 'Kitabkhana Dev',
      enableVerboseLogs = true,
      contactEmail = kContactEmail,
      version = kAppVersion;

  const AppConfig.prod()
    : flavor = Flavor.prod,
      appName = 'Kitabkhana',
      enableVerboseLogs = false,
      contactEmail = kContactEmail,
      version = kAppVersion;

  final Flavor flavor;
  final String appName;
  final bool enableVerboseLogs;
  final String contactEmail;
  final String version;

  /// `Kitabkhana/<version> (<contact>)`, or without the contact when unset.
  String get userAgent => contactEmail.isEmpty
      ? 'Kitabkhana/$version'
      : 'Kitabkhana/$version ($contactEmail)';

  bool get isDev => flavor == Flavor.dev;
}
