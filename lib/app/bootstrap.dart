import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logger.dart';
import 'app_config.dart';
import 'app_config_provider.dart';
import 'app_root.dart';
import 'error_handling.dart';
import 'providers.dart';
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
  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        appLoggerProvider.overrideWithValue(logger),
      ],
      child: const AppRoot(),
    ),
  );
}
