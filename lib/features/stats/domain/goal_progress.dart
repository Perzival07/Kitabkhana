/// How a year's reading goal is going.
enum GoalStatus { reached, ahead, onPace, behind, missed, upcoming }

final class GoalProgress {
  const GoalProgress({
    required this.finished,
    required this.target,
    required this.status,
    required this.books,
  });

  final int finished;
  final int target;
  final GoalStatus status;

  /// How many books ahead, behind or short (0 for other statuses).
  final int books;

  /// Ring fill, 0..1.
  double get fraction => target <= 0 ? 0 : (finished / target).clamp(0.0, 1.0);
}

int _dayOfYear(DateTime d) =>
    DateTime.utc(
      d.year,
      d.month,
      d.day,
    ).difference(DateTime.utc(d.year, 1, 1)).inDays +
    1;

/// The goal of [target] books for [year], judged on [today].
///
/// In the current year the reader is "ahead" or "behind" by whole books
/// against an even pace through the year; within a book of it they are "on
/// pace". Past years are reached or missed (by how many); future years are
/// just upcoming.
GoalProgress goalProgress({
  required int year,
  required int target,
  required int finished,
  required DateTime today,
}) {
  GoalProgress r(GoalStatus s, [int books = 0]) =>
      GoalProgress(finished: finished, target: target, status: s, books: books);

  if (finished >= target) return r(GoalStatus.reached);
  if (year < today.year) return r(GoalStatus.missed, target - finished);
  if (year > today.year) return r(GoalStatus.upcoming);

  final daysInYear = _dayOfYear(DateTime(year, 12, 31));
  final expected = target * _dayOfYear(today) / daysInYear;
  final diff = finished - expected;
  if (diff >= 1) return r(GoalStatus.ahead, diff.floor());
  if (diff <= -1) return r(GoalStatus.behind, (-diff).ceil());
  return r(GoalStatus.onPace);
}
