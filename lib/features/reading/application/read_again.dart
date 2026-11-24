import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../library/domain/book.dart';
import '../../library/domain/book_enums.dart';
import '../../library/domain/book_repository.dart';
import '../domain/read_through.dart';

/// The book as a fresh read started on [today]: reading, from page 0.
Book startedAgain(Book book, DateTime today) => book.copyWith(
  status: ReadStatus.reading,
  startedOn: today,
  finishedOn: null,
  currentPage: 0,
);

/// "Read again": keeps the finished read as an earlier read-through and
/// starts a new one today.
class ReadAgain {
  ReadAgain({required this.books, required this.reads, required this.clock});

  final BookRepository books;
  final ReadThroughRepository reads;
  final Clock clock;

  Future<Result<Book>> call(String bookId) async {
    final found = await books.getById(bookId);
    final book = found.getOrNull();
    if (book == null) return const Err(NotFoundFailure('book'));
    if (book.status == ReadStatus.finished) {
      final kept = await reads.add(
        bookId,
        startedOn: book.startedOn,
        finishedOn: book.finishedOn,
      );
      if (kept case Err(:final failure)) return Err(failure);
    }
    final today = clock.today();
    return books.update(bookId, (b) => startedAgain(b, today));
  }
}
