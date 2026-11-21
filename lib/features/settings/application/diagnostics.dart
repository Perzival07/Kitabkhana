/// The text of a diagnostics export: versions and recent app messages only.
/// Never any library contents (titles, names, phone numbers, quotes). The log
/// lines come from `AppLogger`, which masks phone-number-like digits and
/// e-mail addresses.
String buildDiagnostics({
  required String appName,
  required String appVersion,
  required int schemaVersion,
  required String platform,
  required String locale,
  required DateTime generatedAt,
  required List<String> logLines,
}) {
  final b = StringBuffer()
    ..writeln('$appName diagnostics')
    ..writeln('Generated: ${generatedAt.toUtc().toIso8601String()}')
    ..writeln('App version: $appVersion')
    ..writeln('Database schema: $schemaVersion')
    ..writeln('Platform: $platform')
    ..writeln('Language: $locale')
    ..writeln()
    ..writeln('No library contents are included in this file.')
    ..writeln()
    ..writeln('Recent messages (${logLines.length}):');
  for (final line in logLines) {
    b.writeln(line);
  }
  return b.toString();
}

/// "today", "yesterday" or "N days ago" for [last] as seen on [today], by
/// calendar day; null when there has been no backup.
({int days})? daysSince(DateTime? last, DateTime today) {
  if (last == null) return null;
  final a = DateTime.utc(last.year, last.month, last.day);
  final b = DateTime.utc(today.year, today.month, today.day);
  final d = b.difference(a).inDays;
  return (days: d < 0 ? 0 : d);
}
