import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/db/database_provider.dart';
import '../features/settings/data/drift_settings_repository.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/reminders/application/loan_nudge.dart';
import '../features/settings/domain/settings_repository.dart';
import '../platform/notifications/url_nudge_launcher.dart';

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
