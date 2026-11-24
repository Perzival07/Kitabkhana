import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/logger.dart';
import '../features/crash/application/crash_recorder.dart';
import 'app_config.dart';
import 'error_fallback.dart';

/// Routes framework and async errors to [logger] (and, when given, keeps a
/// problem report with [recorder]) and swaps the red error screen for a
/// friendly fallback outside the dev flavor.
void installGlobalErrorHandlers(
  AppConfig config,
  AppLogger logger, {
  CrashRecorder? recorder,
}) {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    // Constant text only: the exception's message can quote what was on the
    // screen. The logger records the exception's type from `error:`.
    logger.error(
      'FlutterError',
      error: details.exception,
      stack: details.stack,
    );
    if (recorder != null && CrashRecorder.isReportable(details)) {
      recorder.record(details.exception, details.stack, kind: 'flutter');
    }
    if (config.isDev) previous?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Uncaught error', error: error, stack: stack);
    recorder?.record(error, stack, kind: 'uncaught');
    return true;
  };

  if (!config.isDev) {
    ErrorWidget.builder = buildErrorFallback;
  }
}
