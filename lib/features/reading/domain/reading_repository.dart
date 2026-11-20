import '../../../core/result.dart';
import 'reading_log.dart';

abstract interface class ReadingRepository {
  /// Live logs for one book, newest day first.
  Stream<List<ReadingLog>> watchForBook(String bookId);

  /// Live logs for days in `[from, to]` (inclusive, dates at local midnight),
  /// oldest first. Logs of deleted books are excluded.
  Stream<List<ReadingLog>> watchBetween(DateTime from, DateTime to);

  /// Live distinct days with any reading, oldest first (for streaks).
  /// Logs of deleted books are excluded.
  Stream<List<DateTime>> watchReadingDays();

  /// The log for [bookId] on [date], if any.
  Future<Result<ReadingLog?>> findForDay(String bookId, DateTime date);

  /// Inserts or updates; stamps `updatedAt`, bumps `rev`.
  Future<Result<ReadingLog>> upsert(ReadingLog log);

  Future<Result<void>> softDelete(String id);
}
