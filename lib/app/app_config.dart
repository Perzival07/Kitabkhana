/// Build flavor of the app.
enum Flavor { dev, prod }

/// The app version; kept equal to `pubspec.yaml` (a test enforces it).
const String kAppVersion = '1.1.0';

/// Contact address sent in the Open Library User-Agent, as Open Library asks
/// API clients to do. Supply with `--dart-define=CONTACT_EMAIL=you@example.com`;
/// empty by default so no personal address is ever baked in.
const String kContactEmail = String.fromEnvironment('CONTACT_EMAIL');

/// Where feedback and problem reports go: the developer's support address.
/// Only ever used to fill in the "To" line of a draft in the reader's own mail
/// app. Override with `--dart-define=FEEDBACK_EMAIL=...`.
const String kFeedbackEmail = String.fromEnvironment(
  'FEEDBACK_EMAIL',
  defaultValue: 'daskoustav04@gmail.com',
);

/// Google Books API key, used only when Open Library has no answer. Supply
/// with `--dart-define=GOOGLE_BOOKS_KEY=...` (CI reads it from a repository
/// secret). Empty still tries Google, but its shared keyless quota is usually
/// used up, so the fallback then rarely answers.
const String kGoogleBooksKey = String.fromEnvironment('GOOGLE_BOOKS_KEY');

/// SHA-1 of the release signing certificate, sent with Google Books requests
/// on Android so a key restricted to this app is accepted. Public information.
const String kReleaseCertSha1 = '9B79747109110E63F1855CB701F6CE6DA42EAB2F';

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
