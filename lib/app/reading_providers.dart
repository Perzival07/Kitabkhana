import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/reading/application/update_progress.dart';
import '../features/reading/domain/pace.dart';
import '../features/reading/domain/reading_log.dart';
import '../features/reading/domain/streak.dart';
import 'providers.dart';
import 'repositories.dart';

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
  final clock = ref.watch(clockProvider);
  return ref
      .watch(readingRepositoryProvider)
      .watchReadingDays()
      .map((days) => computeStreak(days, clock.today()));
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
    today: ref.watch(clockProvider).today(),
    startedOn: startedOn,
  );
}
