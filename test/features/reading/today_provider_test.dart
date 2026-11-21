import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/providers.dart';
import 'package:kitabkhana/app/today_provider.dart';
import 'package:kitabkhana/core/clock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('today moves on at midnight, and disposing cancels the timer', () {
    fakeAsync((async) {
      final clock = FakeClock(DateTime(2026, 3, 1, 23, 59, 30));
      final c = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          midnightTimerProvider.overrideWithValue(true),
        ],
      );
      final seen = <DateTime>[];
      c.listen(todayProvider, (_, next) => seen.add(next));
      expect(c.read(todayProvider), DateTime(2026, 3, 1));

      // Time passes: the clock and the timer advance together.
      clock.set(DateTime(2026, 3, 2, 0, 0, 5));
      async.elapse(const Duration(seconds: 40));
      expect(c.read(todayProvider), DateTime(2026, 3, 2));
      expect(seen, [DateTime(2026, 3, 2)]);

      // Re-armed for the next midnight; nothing fires early.
      async.elapse(const Duration(hours: 12));
      expect(seen, hasLength(1));

      c.dispose();
      expect(async.pendingTimers, isEmpty);
    });
  });
}
