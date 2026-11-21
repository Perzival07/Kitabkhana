import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/db/database_provider.dart';
import '../features/settings/data/drift_settings_repository.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/reminders/application/loan_nudge.dart';
import '../features/settings/domain/settings_repository.dart';
import '../platform/notifications/url_nudge_launcher.dart';
import 'router/routes.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    DriftSettingsRepository(ref.watch(appDatabaseProvider));

/// Settings as they change.
@Riverpod(keepAlive: true)
Stream<AppSettings> settingsStream(Ref ref) =>
    ref.watch(settingsRepositoryProvider).watch();

/// The current settings: the defaults until they have loaded.
@Riverpod(keepAlive: true)
AppSettings appSettings(Ref ref) =>
    ref.watch(settingsStreamProvider).value ?? AppSettings.defaults;

/// Opens links and mail apps. Tests swap in a fake.
@Riverpod(keepAlive: true)
NudgeLauncher externalLauncher(Ref ref) => const UrlNudgeLauncher();

/// Where the app opens: the introduction on first run (and after erasing
/// everything), the library otherwise. `bootstrap` sets it before the first
/// screen; tests leave it at the library.
@Riverpod(keepAlive: true)
class InitialRoute extends _$InitialRoute {
  @override
  String build() => Routes.library;

  void set(String route) => state = route;
}
