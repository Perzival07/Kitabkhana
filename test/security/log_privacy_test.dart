import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Logs at info level and above end up in the diagnostics export the reader may
/// share, so they must never carry what is in the library (titles, authors,
/// names, phone numbers, notes, quotes). The logger masks phone-like digits
/// and e-mail addresses as a safety net, but the real rule is to not pass any
/// of it in: log constant text, and at most the *type* of an exception.
void main() {
  /// Interpolations that are safe in a log line.
  bool safe(String expr) =>
      expr.endsWith('.runtimeType') ||
      expr == 'config.appName' ||
      expr == 'details.versionNow' ||
      expr == "details.wasCreated ? ' (created)' : ''";

  final calls = RegExp(
    r'\b(?:logger\??|appLoggerProvider\))\.(?:info|warn|error)\(',
  );

  test('no log call above debug level interpolates anything personal', () {
    var checked = 0;
    final problems = <String>[];
    for (final f
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'),
            )) {
      if (f.path.endsWith('lib/core/logger.dart')) continue;
      final text = f.readAsStringSync();
      for (final m in calls.allMatches(text)) {
        // The call's arguments, up to its closing ");" on the statement.
        final end = text.indexOf(');', m.end);
        final args = text.substring(m.end, end);
        checked++;
        for (final interp in RegExp(
          r'\$\{([^}]*)\}|\$([A-Za-z_][A-Za-z0-9_.]*)',
        ).allMatches(args)) {
          final expr = (interp.group(1) ?? interp.group(2))!.trim();
          if (!safe(expr)) {
            problems.add('${f.path}: log call interpolates "$expr"');
          }
        }
        // Passing a value as `error:` is fine: the logger prints only its type.
      }
    }
    expect(checked, greaterThan(10), reason: 'the search found the calls');
    expect(problems, isEmpty);
  });

  test('the logger prints only the type of an attached error', () {
    final src = File('lib/core/logger.dart').readAsStringSync();
    expect(src, contains('r.error.runtimeType'));
  });
}
