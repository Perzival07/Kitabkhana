/// Reading streaks over local calendar days.
final class Streak {
  const Streak({required this.current, required this.longest});

  static const none = Streak(current: 0, longest: 0);

  /// Consecutive reading days ending today, or yesterday while today is
  /// still to come. Zero once a whole day has been missed.
  final int current;

  /// The longest run of consecutive reading days ever.
  final int longest;

  @override
  bool operator ==(Object other) =>
      other is Streak && other.current == current && other.longest == longest;

  @override
  int get hashCode => Object.hash(current, longest);

  @override
  String toString() => 'Streak($current, longest $longest)';
}

/// A calendar day as a day count, immune to time zones and DST: the date
/// parts are read as-is (they are already local) and counted in UTC.
int _dayNumber(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

/// The streaks for [days] (any times of day, duplicates fine) as seen on
/// [today]. Days after [today] are ignored.
Streak computeStreak(Iterable<DateTime> days, DateTime today) {
  final t = _dayNumber(today);
  final set = <int>{
    for (final d in days)
      if (_dayNumber(d) <= t) _dayNumber(d),
  };
  if (set.isEmpty) return Streak.none;

  final sorted = set.toList()..sort();
  var longest = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    run = sorted[i] == sorted[i - 1] + 1 ? run + 1 : 1;
    if (run > longest) longest = run;
  }

  var cursor = set.contains(t) ? t : (set.contains(t - 1) ? t - 1 : null);
  var current = 0;
  while (cursor != null && set.contains(cursor)) {
    current++;
    cursor--;
  }
  return Streak(current: current, longest: longest);
}
