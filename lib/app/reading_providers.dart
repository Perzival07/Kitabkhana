import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/library/domain/book.dart';
import '../features/library/domain/book_enums.dart';
import '../features/library/domain/book_filter.dart';
import '../features/reading/application/update_progress.dart';
import '../features/reading/domain/pace.dart';
import '../data/db/database_provider.dart';
import '../features/reading/data/drift_reading_sessions.dart';
import '../features/reading/domain/reading_log.dart';
import '../features/reading/domain/reading_timer.dart';
import '../features/reading/domain/streak.dart';
import 'providers.dart';
import 'repositories.dart';
import 'today_provider.dart';

part 'reading_providers.g.dart';

@Riverpod(keepAlive: true)
UpdateProgress updateProgress(Ref ref) => UpdateProgress(
  books: ref.watch(bookRepositoryProvider),
  readings: ref.watch(readingRepositoryProvider),
  clock: ref.watch(clockProvider),
);

/// The reader's current and longest streak, across all books.
@riverpod
Stream<Streak> readingStreak(Ref ref) {
  final today = ref.watch(todayProvider);
  return ref
      .watch(readingRepositoryProvider)
      .watchReadingDays()
      .map((days) => computeStreak(days, today));
}

/// Live logs of one book, newest day first.
@riverpod
Stream<List<ReadingLog>> bookReadingLogs(Ref ref, String bookId) =>
    ref.watch(readingRepositoryProvider).watchForBook(bookId);

/// The predicted finish for a book with [remainingPages] left; null when
/// there is not enough reading to go on.
@riverpod
PaceEstimate? bookPace(
  Ref ref,
  String bookId, {
  required int remainingPages,
  DateTime? startedOn,
}) {
  final logs = ref.watch(bookReadingLogsProvider(bookId)).value;
  if (logs == null) return null;
  return predictPace(
    remainingPages: remainingPages,
    logs: logs,
    today: ref.watch(todayProvider),
    startedOn: startedOn,
  );
}

/// Books being read now, most recently read first.
@riverpod
Stream<List<Book>> currentlyReading(Ref ref) => ref
    .watch(bookRepositoryProvider)
    .watchAll(
      filter: const BookFilter(status: ReadStatus.reading),
      sort: BookSort.recentlyRead,
      limit: 20,
    );

/// A few books from the want-to-read shelf, newest first.
@riverpod
Stream<List<Book>> upNextBooks(Ref ref) => ref
    .watch(bookRepositoryProvider)
    .watchAll(filter: const BookFilter(status: ReadStatus.want), limit: 3);

/// Pages read on each of the last 7 days, oldest first (today is last).
@riverpod
Stream<List<int>> pagesLast7Days(Ref ref) {
  final today = ref.watch(todayProvider);
  final from = DateTime(today.year, today.month, today.day - 6);
  return ref.watch(readingRepositoryProvider).watchBetween(from, today).map((
    logs,
  ) {
    final totals = List<int>.filled(7, 0);
    for (final l in logs) {
      final i = DateTime.utc(
        l.date.year,
        l.date.month,
        l.date.day,
      ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
      if (i >= 0 && i < 7) totals[i] += l.pagesRead;
    }
    return totals;
  });
}

@Riverpod(keepAlive: true)
ReadingSessionRepository readingSessionRepository(Ref ref) =>
    DriftReadingSessionRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    );

@Riverpod(keepAlive: true)
ReadingTimerStore readingTimerStore(Ref ref) =>
    DbReadingTimerStore(ref.watch(appDatabaseProvider));

/// The reading timer: at most one runs, for one book. Kept in the database,
/// so closing the app does not lose it.
@Riverpod(keepAlive: true)
class ReadingTimer extends _$ReadingTimer {
  @override
  Future<RunningTimer?> build() => ref.watch(readingTimerStoreProvider).load();

  /// Starts timing [bookId]; a timer running for another book is stopped and
  /// logged first.
  Future<void> start(String bookId) async {
    final running = await future;
    if (running != null && running.bookId != bookId) await stop();
    if (running?.bookId == bookId) return;
    final t = RunningTimer(bookId, ref.read(clockProvider).now());
    await ref.read(readingTimerStoreProvider).save(t);
    state = AsyncData<RunningTimer?>(t);
  }

  /// Stops the timer and logs the time on today's date. Returns the minutes
  /// logged, or null when nothing ran or it was too short to count.
  Future<int?> stop() async {
    final running = await future;
    if (running == null) return null;
    await ref.read(readingTimerStoreProvider).clear();
    state = const AsyncData<RunningTimer?>(null);
    final clock = ref.read(clockProvider);
    final minutes = sessionMinutes(running.elapsed(clock.now()));
    if (minutes == null) return null;
    await ref
        .read(readingSessionRepositoryProvider)
        .addMinutes(running.bookId, clock.today(), minutes);
    return minutes;
  }

  /// Stops without logging anything.
  Future<void> discard() async {
    await ref.read(readingTimerStoreProvider).clear();
    state = const AsyncData<RunningTimer?>(null);
  }
}

/// Minutes read today (from the timer).
@riverpod
Stream<int> minutesToday(Ref ref) {
  final today = ref.watch(todayProvider);
  return ref
      .watch(readingSessionRepositoryProvider)
      .watchMinutesBetween(today, today);
}

/// Minutes read in [year] (from the timer).
@riverpod
Stream<int> minutesInYear(Ref ref, int year) => ref
    .watch(readingSessionRepositoryProvider)
    .watchMinutesBetween(DateTime(year), DateTime(year, 12, 31));
