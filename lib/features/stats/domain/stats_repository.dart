import '../../../core/result.dart';
import '../../library/domain/book.dart';
import 'stats.dart';

/// Reading aggregates, computed by the database. A book counts toward a year
/// by the year of its `finishedOn`.
abstract interface class StatsRepository {
  /// Books finished in [year].
  Stream<int> watchFinishedCount(int year);

  /// Books finished in each month of [year]; 12 entries, January first.
  Stream<List<int>> watchFinishedPerMonth(int year);

  /// Books finished in [month] (1-12) of [year], by finish date.
  Future<Result<List<Book>>> finishedInMonth(int year, int month);

  /// Pages read in each of the [weeks] 7-day windows ending on [end],
  /// oldest first (so the last entry ends on [end]).
  Stream<List<WeekPages>> watchPagesPerWeek(DateTime end, {int weeks = 12});

  /// Most common genres among books finished in [year].
  Stream<List<LabelCount>> watchTopGenres(int year, {int limit = 5});

  /// Most read authors among books finished in [year].
  Stream<List<LabelCount>> watchTopAuthors(int year, {int limit = 5});

  /// Library totals and the longest book finished in [year].
  Stream<LibraryFacts> watchFacts(int year);

  /// Years that have finished books, newest first.
  Stream<List<int>> watchFinishedYears();
}
