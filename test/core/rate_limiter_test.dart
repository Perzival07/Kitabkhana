import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/clock.dart';
import 'package:kitabkhana/core/rate_limiter.dart';

void main() {
  late FakeClock clock;
  late List<Duration> waits;

  RateLimiter make({double rate = 1, int burst = 3}) => RateLimiter(
    rate: rate,
    burst: burst,
    clock: clock,
    delay: (d) async {
      waits.add(d);
      clock.advance(d);
    },
  );

  setUp(() {
    clock = FakeClock(DateTime(2025));
    waits = <Duration>[];
  });

  test('allows a burst immediately', () async {
    final l = make();
    for (var i = 0; i < 3; i++) {
      await l.acquire();
    }
    expect(waits, isEmpty);
  });

  test('then paces at the configured rate', () async {
    final l = make();
    for (var i = 0; i < 6; i++) {
      await l.acquire();
    }
    expect(waits, hasLength(3));
    for (final w in waits) {
      expect(w, const Duration(seconds: 1));
    }
  });

  test('a faster rate waits proportionally less', () async {
    final l = make(rate: 4, burst: 1);
    await l.acquire();
    await l.acquire();
    expect(waits.single, const Duration(milliseconds: 250));
  });

  test('refills over time but never beyond the burst', () async {
    final l = make();
    for (var i = 0; i < 3; i++) {
      await l.acquire();
    }
    clock.advance(const Duration(minutes: 10));
    for (var i = 0; i < 3; i++) {
      await l.acquire();
    }
    expect(waits, isEmpty);
    await l.acquire(); // 4th needs a wait: capped at burst
    expect(waits, hasLength(1));
  });

  test('partial refill shortens the wait', () async {
    final l = make(burst: 1);
    await l.acquire();
    clock.advance(const Duration(milliseconds: 400));
    await l.acquire();
    expect(waits.single, const Duration(milliseconds: 600));
  });

  test('concurrent callers are served in order', () async {
    final l = make(burst: 1);
    final order = <int>[];
    final futures = <Future<void>>[
      for (var i = 0; i < 4; i++) l.acquire().then((_) => order.add(i)),
    ];
    await Future.wait(futures);
    expect(order, <int>[0, 1, 2, 3]);
    expect(waits, hasLength(3));
  });

  test('rejects invalid configuration', () {
    expect(
      () => RateLimiter(rate: 0, burst: 1),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => RateLimiter(rate: 1, burst: 0),
      throwsA(isA<AssertionError>()),
    );
  });
}
