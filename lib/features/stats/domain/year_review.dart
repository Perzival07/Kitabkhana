import '../../reading/domain/reading_log.dart';
import '../../reading/domain/streak.dart';
import 'goal.dart';
import 'stats.dart';

/// A reader's year in books, for the shareable "Year in review" card.
final class YearReview {
  const YearReview({
    required this.year,
    required this.booksFinished,
    required this.pagesRead,
    required this.perMonth,
    required this.longestStreak,
    this.goalTarget,
    this.topGenre,
    this.topAuthor,
    this.longest,
  });

  final int year;
  final int booksFinished;

  /// Pages logged on days in the year.
  final int pagesRead;

  /// Books finished in each month, January first (12 entries).
  final List<int> perMonth;

  /// The longest run of consecutive reading days inside the year.
  final int longestStreak;
  final int? goalTarget;
  final String? topGenre;
  final String? topAuthor;
  final LongestBook? longest;

  /// Nothing worth a card yet.
  bool get isEmpty => booksFinished == 0 && pagesRead == 0;
}

/// Gathers a [YearReview] from what the Stats and Reading screens already
/// know. [readingDays] may span every year; only [year]'s days count, and
/// the streak is measured up to [today] (or the year's last day).
YearReview buildYearReview({
  required int year,
  required int booksFinished,
  required List<int> perMonth,
  required List<ReadingLog> logs,
  required Iterable<DateTime> readingDays,
  required DateTime today,
  Goal? goal,
  List<LabelCount> genres = const <LabelCount>[],
  List<LabelCount> authors = const <LabelCount>[],
  LongestBook? longest,
}) {
  final inYear = readingDays.where((d) => d.year == year);
  final end = today.year == year ? today : DateTime(year, 12, 31);
  return YearReview(
    year: year,
    booksFinished: booksFinished,
    pagesRead: logs
        .where((l) => l.date.year == year)
        .fold<int>(0, (sum, l) => sum + l.pagesRead),
    perMonth: List<int>.generate(
      12,
      (i) => i < perMonth.length ? perMonth[i] : 0,
    ),
    longestStreak: computeStreak(inYear, end).longest,
    goalTarget: goal?.targetBooks,
    topGenre: genres.where((g) => g.label.trim().isNotEmpty).firstOrNull?.label,
    topAuthor: authors
        .where((a) => a.label.trim().isNotEmpty)
        .firstOrNull
        ?.label,
    longest: longest,
  );
}
