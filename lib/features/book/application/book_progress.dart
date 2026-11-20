import '../../library/domain/book.dart';
import '../../library/domain/book_enums.dart';

/// The book after its reading status is set to [status] on [today].
///
/// Reading stamps `startedOn` (kept if already set) and clears any finish
/// date. Finished stamps `finishedOn` and moves `currentPage` to the last
/// page when the page count is known. Other statuses leave dates alone.
Book withStatus(Book book, ReadStatus status, DateTime today) {
  if (status == book.status) return book;
  switch (status) {
    case ReadStatus.reading:
      return book.copyWith(
        status: status,
        startedOn: book.startedOn ?? today,
        finishedOn: null,
      );
    case ReadStatus.finished:
      return book.copyWith(
        status: status,
        startedOn: book.startedOn ?? today,
        finishedOn: today,
        currentPage: book.pages ?? book.currentPage,
      );
    case ReadStatus.want:
    case ReadStatus.dropped:
      return book.copyWith(status: status);
  }
}

/// The book with its current page set to [page], kept within 0..pages.
Book withPage(Book book, int page) {
  final max = book.pages;
  final clamped = page < 0 ? 0 : (max != null && page > max ? max : page);
  return book.copyWith(currentPage: clamped);
}
