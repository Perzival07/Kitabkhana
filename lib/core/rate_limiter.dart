import 'dart:async';

import 'clock.dart';

/// An async token bucket: up to [burst] immediate calls, then [rate] per
/// second. Callers `await acquire()` before the rate-limited work. Waiters are
/// served in order.
class RateLimiter {
  RateLimiter({
    required this.rate,
    required this.burst,
    Clock? clock,
    Future<void> Function(Duration)? delay,
  }) : assert(rate > 0, 'rate must be positive'),
       assert(burst >= 1, 'burst must be at least 1'),
       _clock = clock ?? const SystemClock(),
       _delay = delay ?? Future<void>.delayed {
    _tokens = burst.toDouble();
    _last = _clock.now();
  }

  /// Tokens added per second.
  final double rate;

  /// Maximum stored tokens.
  final int burst;

  final Clock _clock;
  final Future<void> Function(Duration) _delay;
  late double _tokens;
  late DateTime _last;
  Future<void> _tail = Future<void>.value();

  void _refill() {
    final now = _clock.now();
    final elapsed = now.difference(_last).inMicroseconds / 1e6;
    if (elapsed > 0) {
      _tokens = (_tokens + elapsed * rate).clamp(0, burst.toDouble());
    }
    _last = now;
  }

  Future<void> _take() async {
    while (true) {
      _refill();
      if (_tokens >= 1) {
        _tokens -= 1;
        return;
      }
      final wait = Duration(
        microseconds: (((1 - _tokens) / rate) * 1e6).ceil(),
      );
      await _delay(wait);
    }
  }

  /// Completes when a token is available.
  Future<void> acquire() {
    final next = _tail.then((_) => _take());
    _tail = next;
    return next;
  }
}
