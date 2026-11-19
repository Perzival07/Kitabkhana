import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/logger.dart';

void main() {
  DateTime fixed() => DateTime.utc(2025, 1, 2, 3, 4, 5);

  test('writes formatted lines to the console sink and buffer', () {
    final out = <String>[];
    final log =
        AppLogger(minLevel: LogLevel.debug, console: out.add, now: fixed)
          ..debug('d')
          ..info('i')
          ..warn('w')
          ..error('e');
    expect(out, hasLength(4));
    expect(out[0], '2025-01-02T03:04:05.000Z D d');
    expect(out[1], '2025-01-02T03:04:05.000Z I i');
    expect(out[2], endsWith('W w'));
    expect(out[3], endsWith('E e'));
    expect(log.lines, out);
  });

  test('respects the minimum level', () {
    final log = AppLogger(now: fixed)
      ..debug('hidden')
      ..info('shown');
    expect(log.lines, hasLength(1));
    expect(log.lines.single, endsWith('I shown'));
  });

  test('keeps only the last 1000 lines (oldest dropped first)', () {
    final log = AppLogger(now: fixed);
    for (var i = 0; i < 1500; i++) {
      log.info('line $i');
    }
    expect(log.lines, hasLength(1000));
    expect(log.lines.first, endsWith('line 500'));
    expect(log.lines.last, endsWith('line 1499'));
  });

  test('buffer cannot be mutated from outside', () {
    final log = AppLogger(now: fixed)..info('x');
    expect(() => log.lines.add('y'), throwsUnsupportedError);
  });

  group('redaction at info and above', () {
    test('masks phone numbers', () {
      final log = AppLogger(now: fixed)
        ..info('lent to +91 98765 43210 today')
        ..warn('call 9876543210')
        ..error('tel 098-765-4321');
      for (final l in log.lines) {
        expect(l, contains('<number>'));
        expect(l, isNot(matches(RegExp(r'\d{7}'))));
      }
    });

    test('masks e-mail addresses', () {
      final log = AppLogger(now: fixed)..info('mail a.b+c@example.co.in now');
      expect(log.lines.single, contains('<email>'));
      expect(log.lines.single, isNot(contains('example')));
    });

    test('keeps short numbers and dates intact', () {
      final log = AppLogger(now: fixed)..info('loaded 12 books in 340 ms');
      expect(log.lines.single, endsWith('loaded 12 books in 340 ms'));
    });

    test('does not redact debug lines', () {
      final log = AppLogger(minLevel: LogLevel.debug, now: fixed)
        ..debug('isbn 9780143127550');
      expect(log.lines.single, contains('9780143127550'));
    });

    test('errors log only the exception type, not its text', () {
      final log = AppLogger(now: fixed)
        ..error('save failed', error: StateError('Priya Sharma 9876543210'));
      expect(log.lines.single, contains('[StateError]'));
      expect(log.lines.single, isNot(contains('Priya')));
    });
  });

  test('static redact is usable directly', () {
    expect(AppLogger.redact('x 1234567 y'), 'x <number> y');
  });
}
