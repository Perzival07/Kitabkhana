import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/clock.dart';

void main() {
  test('FakeClock returns, sets and advances time', () {
    final c = FakeClock(DateTime(2025, 3, 10, 23, 59));
    expect(c.now(), DateTime(2025, 3, 10, 23, 59));
    expect(c.today(), DateTime(2025, 3, 10));
    c.advance(const Duration(minutes: 2));
    expect(c.now(), DateTime(2025, 3, 11, 0, 1));
    expect(c.today(), DateTime(2025, 3, 11));
    c.set(DateTime(2030));
    expect(c.today(), DateTime(2030));
  });

  test('today() is local midnight at the day boundary', () {
    final c = FakeClock(DateTime(2025, 12, 31, 23, 59, 59));
    expect(c.today(), DateTime(2025, 12, 31));
    c.advance(const Duration(seconds: 1));
    expect(c.today(), DateTime(2026));
  });

  test('SystemClock is close to the wall clock', () {
    const c = SystemClock();
    final diff = c.now().difference(DateTime.now()).abs();
    expect(diff, lessThan(const Duration(seconds: 1)));
    final t = c.today();
    expect([t.hour, t.minute, t.second], [0, 0, 0]);
  });
}
