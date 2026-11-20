import 'reading_log.dart';

/// How long a book will take to finish at the reader's recent pace.
final class PaceEstimate {
  const PaceEstimate({
    required this.pagesPerDay,
    required this.daysLeft,
    required this.finishBy,
  });

  final double pagesPerDay;

  /// Whole days from today, at least 1.
  final int daysLeft;
  final DateTime finishBy;

  @override
  bool operator ==(Object other) =>
      other is PaceEstimate &&
      other.pagesPerDay == pagesPerDay &&
      other.daysLeft == daysLeft &&
      other.finishBy == finishBy;

  @override
  int get hashCode => Object.hash(pagesPerDay, daysLeft, finishBy);

  @override
  String toString() => 'PaceEstimate($pagesPerDay/day, $daysLeft days)';
}

/// The longest look-back, in days, for the average.
const int paceWindowDays = 14;

/// Fewest distinct reading days before a prediction is trusted.
const int paceMinReadingDays = 2;

int _dayNumber(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

/// Predicts the finish for a book with [remainingPages] left.
///
/// The average is pages read in the window divided by the window's length in
/// days, where the window is the last [paceWindowDays] days but never longer
/// than the days since the book was started (so a book begun 5 days ago is
/// averaged over 5 days, not 14). [startedOn] falls back to the first log.
///
/// Null when there is not enough to go on: nothing left to read, fewer than
/// [paceMinReadingDays] reading days, or no pages read in the window.
PaceEstimate? predictPace({
  required int remainingPages,
  required Iterable<ReadingLog> logs,
  required DateTime today,
  DateTime? startedOn,
}) {
  if (remainingPages <= 0) return null;
  final t = _dayNumber(today);
  final live = <ReadingLog>[
    for (final l in logs)
      if (l.deletedAt == null && _dayNumber(l.date) <= t) l,
  ];
  if (live.isEmpty) return null;

  var start = startedOn == null ? null : _dayNumber(startedOn);
  final first = live
      .map((l) => _dayNumber(l.date))
      .reduce((a, b) => a < b ? a : b);
  if (start == null || first < start) start = first;

  final sinceStart = t - start + 1;
  final window = sinceStart < paceWindowDays ? sinceStart : paceWindowDays;
  if (window < 1) return null;
  final windowStart = t - window + 1;

  var pages = 0;
  final readingDays = <int>{};
  for (final l in live) {
    final d = _dayNumber(l.date);
    if (d >= windowStart) {
      pages += l.pagesRead;
      readingDays.add(d);
    }
  }
  if (pages <= 0 || readingDays.length < paceMinReadingDays) return null;

  final perDay = pages / window;
  final daysLeft = (remainingPages / perDay).ceil().clamp(1, 100000);
  return PaceEstimate(
    pagesPerDay: perDay,
    daysLeft: daysLeft,
    finishBy: DateTime(today.year, today.month, today.day + daysLeft),
  );
}
