import 'package:flutter/foundation.dart';

import '../../../core/logger.dart';
import '../../../platform/crash/crash_store.dart';
import '../domain/crash_report.dart';

/// Keeps the first problem of each run on the device, with the recent log
/// and (when it can be taken) a screenshot, so the reader can choose to send
/// it next time the app opens. Never throws and never sends anything.
class CrashRecorder {
  CrashRecorder({
    required this.store,
    required this.logger,
    required this.appVersion,
    required this.platform,
    required this.osVersion,
    this.screenshot,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final CrashStore store;
  final AppLogger logger;
  final String appVersion;
  final String platform;
  final String osVersion;

  /// Takes a picture of the screen; null when it cannot.
  final Future<Uint8List?> Function()? screenshot;
  final DateTime Function() _now;

  bool _recorded = false;

  /// Whether a problem has been kept in this run.
  bool get recorded => _recorded;

  /// Errors from images that failed to load (a cover that could not be
  /// downloaded) are expected, and are not problems worth a report.
  static bool isReportable(FlutterErrorDetails details) =>
      !details.silent && details.library != 'image resource service';

  Future<void> record(
    Object error,
    StackTrace? stack, {
    required String kind,
  }) async {
    // The first problem is usually the cause; later ones tend to follow it.
    if (_recorded) return;
    _recorded = true;
    try {
      final lines = logger.lines;
      final report = CrashReport(
        at: _now().toUtc(),
        kind: kind,
        errorType: error.runtimeType.toString(),
        message: clip(error.toString(), kMaxCrashMessage),
        stack: clip(stack?.toString() ?? '', kMaxCrashStack),
        logLines: lines.length > kCrashLogLines
            ? lines.sublist(lines.length - kCrashLogLines)
            : lines,
        appVersion: appVersion,
        platform: platform,
        osVersion: osVersion,
      );
      // Save first, so a failing screenshot cannot lose the report.
      await store.save(report);
      final shot = await _shot();
      if (shot != null) await store.save(report, screenshot: shot);
      logger.info('Problem report kept on the device');
    } on Object catch (e) {
      logger.warn('Keeping a problem report failed: ${e.runtimeType}');
    }
  }

  Future<Uint8List?> _shot() async {
    final take = screenshot;
    if (take == null) return null;
    try {
      return await take();
    } on Object {
      return null;
    }
  }
}
