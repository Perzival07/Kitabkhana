import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/logger.dart';
import 'app_config.dart';
import 'error_fallback.dart';

/// Routes framework and async errors to [logger] and swaps the red error
/// screen for a friendly fallback outside the dev flavor.
void installGlobalErrorHandlers(AppConfig config, AppLogger logger) {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    logger.error(
      'FlutterError: ${details.exceptionAsString().split('\n').first}',
      error: details.exception,
      stack: details.stack,
    );
    if (config.isDev) previous?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Uncaught error', error: error, stack: stack);
    return true;
  };

  if (!config.isDev) {
    ErrorWidget.builder = buildErrorFallback;
  }
}
