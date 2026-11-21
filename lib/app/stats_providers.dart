import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/library/domain/book.dart';
import '../features/stats/domain/goal.dart';
import '../features/stats/domain/stats.dart';
import 'repositories.dart';
import 'today_provider.dart';

part 'stats_providers.g.dart';

/// The year the Stats tab is showing. Starts as the current year.
@riverpod
class StatsYear extends _$StatsYear {
  @override
  int build() => ref.watch(todayProvider).year;

  void set(int year) => state = year;
}

/// Years the selector offers: every year with finished books or a goal,
/// plus the current one, newest first.
@riverpod
Stream<List<int>> statsYears(Ref ref) {
  final current = ref.watch(todayProvider).year;
  return ref.watch(statsRepositoryProvider).watchFinishedYears().map((ys) {
    final all = <int>{...ys, current}.toList()..sort((a, b) => b.compareTo(a));
    return all;
  });
}

@riverpod
Stream<Goal?> yearGoal(Ref ref, int year) =>
    ref.watch(goalRepositoryProvider).watchForYear(year);

@riverpod
Stream<int> yearFinishedCount(Ref ref, int year) =>
    ref.watch(statsRepositoryProvider).watchFinishedCount(year);

@riverpod
Stream<List<int>> yearFinishedPerMonth(Ref ref, int year) =>
    ref.watch(statsRepositoryProvider).watchFinishedPerMonth(year);

/// The last 12 weeks of pages: ending today for the current year, else on
/// the year's last day.
@riverpod
Stream<List<WeekPages>> yearPagesPerWeek(Ref ref, int year) {
  final today = ref.watch(todayProvider);
  final end = year == today.year ? today : DateTime(year, 12, 31);
  return ref.watch(statsRepositoryProvider).watchPagesPerWeek(end);
}

@riverpod
Stream<List<LabelCount>> yearTopGenres(Ref ref, int year) =>
    ref.watch(statsRepositoryProvider).watchTopGenres(year);

@riverpod
Stream<List<LabelCount>> yearTopAuthors(Ref ref, int year) =>
    ref.watch(statsRepositoryProvider).watchTopAuthors(year);

@riverpod
Stream<LibraryFacts> yearFacts(Ref ref, int year) =>
    ref.watch(statsRepositoryProvider).watchFacts(year);

/// Books finished in one month, for the bar-tap list.
@riverpod
Future<List<Book>> booksFinishedInMonth(Ref ref, int year, int month) async {
  final r = await ref
      .watch(statsRepositoryProvider)
      .finishedInMonth(year, month);
  return r.getOrNull() ?? const <Book>[];
}
