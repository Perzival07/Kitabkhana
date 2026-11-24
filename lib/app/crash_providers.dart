import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/crash/application/problem_reporter.dart';
import '../platform/crash/crash_store.dart';
import '../platform/crash/device_info.dart';
import '../platform/crash/report_mailer.dart';
import 'app_config.dart';
import 'app_config_provider.dart';
import 'quote_providers.dart';
import 'settings_providers.dart';

part 'crash_providers.g.dart';

/// Where a problem report waits for the reader. `bootstrap` overrides it with
/// the store the error handlers write to.
@Riverpod(keepAlive: true)
CrashStore crashStore(Ref ref) => kIsWeb
    ? MemoryCrashStore()
    : FileCrashStore(getApplicationSupportDirectory);

@Riverpod(keepAlive: true)
ReportMailer reportMailer(Ref ref) => const PlatformReportMailer();

@Riverpod(keepAlive: true)
ProblemReporter problemReporter(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return ProblemReporter(
    mailer: ref.watch(reportMailerProvider),
    launcher: ref.watch(externalLauncherProvider),
    share: ref.watch(shareServiceProvider),
    to: kFeedbackEmail,
    appName: config.appName,
    appVersion: config.version,
    platform: currentPlatformName(),
    osVersion: currentOsVersion(),
  );
}
