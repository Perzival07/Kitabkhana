/// Build flavor of the app.
enum Flavor { dev, prod }

/// Immutable per-flavor configuration passed to [bootstrap].
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.enableVerboseLogs,
  });

  const AppConfig.dev()
    : flavor = Flavor.dev,
      appName = 'Kitabkhana Dev',
      enableVerboseLogs = true;

  const AppConfig.prod()
    : flavor = Flavor.prod,
      appName = 'Kitabkhana',
      enableVerboseLogs = false;

  final Flavor flavor;
  final String appName;
  final bool enableVerboseLogs;

  bool get isDev => flavor == Flavor.dev;
}
