import 'dart:collection';

import 'package:logging/logging.dart';

enum LogLevel { debug, info, warn, error }

/// A leveled logger that writes to an optional console sink and keeps the
/// last [capacity] lines in memory for the diagnostics export.
///
/// Privacy: never pass book titles, names or phone numbers at [info] or above.
/// As a safety net, messages at info+ have phone-number-like digit runs and
/// e-mail addresses masked.
class AppLogger {
  AppLogger({
    this.minLevel = LogLevel.info,
    this.capacity = 1000,
    this.console,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       _logger = Logger.detached('kitabkhana') {
    _logger.level = Level.ALL;
    _logger.onRecord.listen(_onRecord);
  }

  final LogLevel minLevel;
  final int capacity;

  /// Receives every formatted line, e.g. `debugPrint` in dev.
  final void Function(String line)? console;
  final DateTime Function() _now;
  final Logger _logger;
  final Queue<String> _buffer = Queue<String>();

  /// The buffered lines, oldest first.
  List<String> get lines => List<String>.unmodifiable(_buffer);

  void debug(String message) => _log(LogLevel.debug, message);
  void info(String message) => _log(LogLevel.info, message);
  void warn(String message) => _log(LogLevel.warn, message);

  void error(String message, {Object? error, StackTrace? stack}) =>
      _log(LogLevel.error, message, error: error, stack: stack);

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stack,
  }) {
    if (level.index < minLevel.index) return;
    _logger.log(
      switch (level) {
        LogLevel.debug => Level.FINE,
        LogLevel.info => Level.INFO,
        LogLevel.warn => Level.WARNING,
        LogLevel.error => Level.SEVERE,
      },
      message,
      error,
      stack,
    );
  }

  void _onRecord(LogRecord r) {
    final isDebug = r.level < Level.INFO;
    final text = isDebug ? r.message : redact(r.message);
    final label = switch (r.level) {
      Level.SEVERE => 'E',
      Level.WARNING => 'W',
      Level.INFO => 'I',
      _ => 'D',
    };
    final err = r.error == null
        ? ''
        // Only the error's type at info+; its text may carry personal data.
        : ' [${r.error.runtimeType}]';
    final line = '${_now().toIso8601String()} $label $text$err';
    _buffer.addLast(line);
    while (_buffer.length > capacity) {
      _buffer.removeFirst();
    }
    console?.call(line);
  }

  static final RegExp _digitsRun = RegExp(r'\+?\d[\d\s\-().]{5,}\d');
  static final RegExp _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');

  /// Masks phone-like numbers and e-mail addresses.
  static String redact(String input) =>
      input.replaceAll(_email, '<email>').replaceAllMapped(_digitsRun, (m) {
        final digits = m.group(0)!.replaceAll(RegExp(r'\D'), '');
        return digits.length >= 7 ? '<number>' : m.group(0)!;
      });
}
