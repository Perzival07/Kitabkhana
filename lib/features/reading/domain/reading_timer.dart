import '../../../core/result.dart';

/// A reading timer that is running: which book, and since when.
final class RunningTimer {
  const RunningTimer(this.bookId, this.startedAt);

  final String bookId;
  final DateTime startedAt;

  Duration elapsed(DateTime now) {
    final d = now.difference(startedAt);
    return d.isNegative ? Duration.zero : d;
  }
}

/// Shorter than this is taken as a tap by mistake and not logged.
const Duration minTimedSession = Duration(seconds: 30);

/// Whole minutes logged for [elapsed]: rounded, at least 1, at most a day.
/// Null when it is too short to count.
int? sessionMinutes(Duration elapsed) {
  if (elapsed < minTimedSession) return null;
  return (elapsed.inSeconds / 60).round().clamp(1, 1440);
}

/// Time spent reading, from the timer. Minutes for one book on one day are
/// added together into one record.
abstract interface class ReadingSessionRepository {
  Future<Result<void>> addMinutes(String bookId, DateTime day, int minutes);

  /// Minutes read on days in `[from, to]` (local dates), books not deleted.
  Stream<int> watchMinutesBetween(DateTime from, DateTime to);

  /// Minutes spent on one book, ever.
  Stream<int> watchMinutesForBook(String bookId);
}

/// Where a running timer is kept, so it survives the app being closed.
abstract interface class ReadingTimerStore {
  Future<RunningTimer?> load();
  Future<void> save(RunningTimer timer);
  Future<void> clear();
}
