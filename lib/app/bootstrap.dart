import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logger.dart';
import '../data/db/database_provider.dart';
import 'app_config.dart';
import 'app_config_provider.dart';
import 'app_root.dart';
import 'backup_providers.dart';
import 'error_handling.dart';
import 'providers.dart';
import 'reminder_providers.dart';
import 'router/routes.dart';
import 'settings_providers.dart';
import 'theme/font_licenses.dart';
import 'theme/system_ui.dart';

/// Shared entry point used by every flavor's `main_*.dart`.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = AppLogger(
    minLevel: config.enableVerboseLogs ? LogLevel.debug : LogLevel.info,
    console: config.enableVerboseLogs ? debugPrint : null,
  );
  installGlobalErrorHandlers(config, logger);
  enableEdgeToEdge();
  registerFontLicenses();
  logger.info('${config.appName} starting');

  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(config),
      appLoggerProvider.overrideWithValue(logger),
    ],
  );

  // Open the database up front so migrations run before the first screen.
  try {
    await container.read(appDatabaseProvider).customSelect('SELECT 1').get();
  } on Object catch (error, stack) {
    logger.error('database failed to open', error: error, stack: stack);
  }

  // First run (or after erasing everything): open on the introduction.
  try {
    final done = await container
        .read(settingsRepositoryProvider)
        .onboardingDone();
    if (!done) {
      container.read(initialRouteProvider.notifier).set(Routes.onboarding);
    }
  } on Object catch (error) {
    logger.warn('Reading onboarding flag failed: ${error.runtimeType}');
  }

  // Rebuild pending reminders from the loans (after a reboot, an update or
  // edits made elsewhere). Never blocks or breaks start-up.
  try {
    unawaited(
      container
          .read(loanReminderServiceProvider)
          .reconcile()
          .catchError(
            (Object e) =>
                logger.warn('Reminder reconcile failed: ${e.runtimeType}'),
          ),
    );
  } on Object catch (e) {
    logger.warn('Reminder reconcile failed: ${e.runtimeType}');
  }

  unawaited(container.read(readingReminderServiceProvider).reconcile());

  // Weekly automatic backup (phones only; does nothing on the web, when it is
  // switched off, or when the last one is recent). Never blocks start-up.
  unawaited(container.read(autoBackupProvider).runIfDue());

  runApp(
    UncontrolledProviderScope(container: container, child: const AppRoot()),
  );
}
