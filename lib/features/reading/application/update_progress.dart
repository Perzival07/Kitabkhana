import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../core/uuid.dart';
import '../../book/application/book_progress.dart';
import '../../library/domain/book.dart';
import '../../library/domain/book_enums.dart';
import '../../library/domain/book_repository.dart';
import '../domain/reading_log.dart';
import '../domain/reading_repository.dart';

/// What changed when the reader moved to a new page.
final class ProgressUpdate {
  const ProgressUpdate({
    required this.book,
    required this.log,
    required this.reachedEnd,
  });

  final Book book;

  /// Today's log for the book after the update; null when there is none
  /// (nothing read today, or the day's reading was undone).
  final ReadingLog? log;

  /// The last page was reached and the book is not yet marked finished, so
  /// the UI can offer "Mark as finished".
  final bool reachedEnd;
}

/// Moves a book to [page] and keeps today's reading log in step.
///
/// * One log per book per day: later updates the same day extend it, so
///   `fromPage` is where the day began and `toPage` where it is now.
/// * Going backwards shrinks today's log, and removes it if nothing is left
///   of the day's reading. Logs never go negative, and earlier days are
///   never touched.
/// * A page past the last one is rejected.
/// * Reading from a "want" or "dropped" shelf starts the book.
class UpdateProgress {
  UpdateProgress({
    required this.books,
    required this.readings,
    required this.clock,
    String Function()? newId,
  }) : _newId = newId ?? uuidV7;

  final BookRepository books;
  final ReadingRepository readings;
  final Clock clock;
  final String Function() _newId;

  Future<Result<ProgressUpdate>> call(String bookId, int page) async {
    final found = await books.getById(bookId);
    if (found case Err<Book?>(:final failure)) return Err(failure);
    final current = (found as Ok<Book?>).value;
    if (current == null) return const Err(NotFoundFailure('book'));
    final total = current.pages;
    if (page < 0 || (total != null && page > total)) {
      return const Err(
        ValidationFailure(field: 'page', messageKey: 'failureValidation'),
      );
    }

    final today = clock.today();
    final from = current.currentPage;
    final saved = await books.update(bookId, (b) {
      final moved = withPage(b, page);
      return moved.status == ReadStatus.want ||
              moved.status == ReadStatus.dropped
          ? withStatus(moved, ReadStatus.reading, today)
          : moved;
    });
    if (saved case Err<Book>(:final failure)) return Err(failure);
    final book = (saved as Ok<Book>).value;

    final log = await _syncLog(bookId, today, from, book.currentPage);
    if (log case Err<ReadingLog?>(:final failure)) return Err(failure);

    return Ok(
      ProgressUpdate(
        book: book,
        log: (log as Ok<ReadingLog?>).value,
        reachedEnd:
            total != null &&
            book.currentPage == total &&
            book.status != ReadStatus.finished,
      ),
    );
  }

  Future<Result<ReadingLog?>> _syncLog(
    String bookId,
    DateTime today,
    int from,
    int to,
  ) async {
    final existing = await readings.findForDay(bookId, today);
    if (existing case Err<ReadingLog?>(:final failure)) return Err(failure);
    final log = (existing as Ok<ReadingLog?>).value;

    final start = log?.fromPage ?? from;
    if (to <= start) {
      // Nothing left of today's reading.
      if (log != null) {
        final gone = await readings.softDelete(log.id);
        if (gone case Err<void>(:final failure)) return Err(failure);
      }
      return const Ok(null);
    }

    final next = log == null
        ? ReadingLog.create(
            id: _newId(),
            bookId: bookId,
            date: today,
            fromPage: start,
            toPage: to,
            now: clock.now(),
          )
        : log.copyWith(pagesRead: to - start, toPage: to);
    return readings.upsert(next);
  }
}
