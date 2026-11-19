/// The only source of "now" and "today" in the app. Never call
/// `DateTime.now()` elsewhere, so time-dependent logic is testable.
abstract interface class Clock {
  /// The current local date and time.
  DateTime now();

  /// Local midnight of the current day.
  DateTime today() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  DateTime today() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }
}

/// A controllable clock for tests.
class FakeClock implements Clock {
  FakeClock([DateTime? start]) : _now = start ?? DateTime(2025, 1, 1, 12);

  DateTime _now;

  @override
  DateTime now() => _now;

  @override
  DateTime today() => DateTime(_now.year, _now.month, _now.day);

  void set(DateTime value) => _now = value;

  void advance(Duration by) => _now = _now.add(by);
}
