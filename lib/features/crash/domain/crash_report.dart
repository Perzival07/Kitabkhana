/// What went wrong, kept on the device until the reader chooses to email it to
/// the developer (or dismisses it). Nothing here is ever sent on its own.
final class CrashReport {
  const CrashReport({
    required this.at,
    required this.kind,
    required this.errorType,
    required this.message,
    required this.stack,
    required this.logLines,
    required this.appVersion,
    required this.platform,
    required this.osVersion,
    this.hasScreenshot = false,
  });

  factory CrashReport.fromJson(Map<String, Object?> json) => CrashReport(
    at:
        DateTime.tryParse(json['at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    kind: json['kind'] as String? ?? 'error',
    errorType: json['errorType'] as String? ?? 'Object',
    message: json['message'] as String? ?? '',
    stack: json['stack'] as String? ?? '',
    logLines: switch (json['logLines']) {
      final List<Object?> lines => lines.whereType<String>().toList(),
      _ => const <String>[],
    },
    appVersion: json['appVersion'] as String? ?? '',
    platform: json['platform'] as String? ?? '',
    osVersion: json['osVersion'] as String? ?? '',
    hasScreenshot: json['hasScreenshot'] == true,
  );

  /// When it happened (UTC).
  final DateTime at;

  /// `flutter` (a framework error) or `uncaught` (an async error).
  final String kind;
  final String errorType;
  final String message;
  final String stack;

  /// The app's recent log lines (already masked by `AppLogger`).
  final List<String> logLines;
  final String appVersion;
  final String platform;
  final String osVersion;
  final bool hasScreenshot;

  CrashReport withScreenshot({required bool value}) => CrashReport(
    at: at,
    kind: kind,
    errorType: errorType,
    message: message,
    stack: stack,
    logLines: logLines,
    appVersion: appVersion,
    platform: platform,
    osVersion: osVersion,
    hasScreenshot: value,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'at': at.toUtc().toIso8601String(),
    'kind': kind,
    'errorType': errorType,
    'message': message,
    'stack': stack,
    'logLines': logLines,
    'appVersion': appVersion,
    'platform': platform,
    'osVersion': osVersion,
    'hasScreenshot': hasScreenshot,
  };
}

/// Longest error message kept, so a huge one cannot bloat the report.
const int kMaxCrashMessage = 4000;

/// Longest stack trace kept.
const int kMaxCrashStack = 12000;

/// Log lines kept with a report (the newest ones).
const int kCrashLogLines = 200;

String clip(String text, int max) =>
    text.length <= max ? text : '${text.substring(0, max)}… (cut)';

/// The full text of a report, attached to the email as a file.
String crashReportText(CrashReport r) {
  final b = StringBuffer()
    ..writeln('Kitabkhana problem report')
    ..writeln('When: ${r.at.toUtc().toIso8601String()}')
    ..writeln('App version: ${r.appVersion}')
    ..writeln('Platform: ${r.platform}')
    ..writeln('OS: ${r.osVersion}')
    ..writeln('Kind: ${r.kind}')
    ..writeln()
    ..writeln('Error: ${r.errorType}')
    ..writeln(r.message)
    ..writeln()
    ..writeln('Stack trace:')
    ..writeln(r.stack.isEmpty ? '(none)' : r.stack)
    ..writeln()
    ..writeln('Recent app messages (${r.logLines.length}):');
  for (final line in r.logLines) {
    b.writeln(line);
  }
  return b.toString();
}

/// Subject and body of a problem-report email. [report] is null for a report
/// the reader starts by hand from Settings.
({String subject, String body}) problemEmailText({
  required CrashReport? report,
  required String appName,
  required String appVersion,
  required String platform,
  required String osVersion,
}) {
  final subject = report == null
      ? '$appName problem report ($appVersion)'
      : '$appName crash report ($appVersion): ${report.errorType}';
  final b = StringBuffer()
    ..writeln('What were you doing when it happened? (optional)')
    ..writeln()
    ..writeln()
    ..writeln('---')
    ..writeln('App: $appName $appVersion')
    ..writeln('Platform: $platform')
    ..writeln('OS: $osVersion');
  if (report != null) {
    b
      ..writeln('When: ${report.at.toUtc().toIso8601String()}')
      ..writeln('Error: ${report.errorType}')
      ..writeln(clip(report.message.split('\n').first, 300));
  }
  b.writeln('Details are in the attached file.');
  return (subject: subject, body: b.toString());
}
