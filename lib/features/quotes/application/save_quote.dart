import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../core/uuid.dart';
import '../../library/domain/book_repository.dart';
import '../domain/quote.dart';
import '../domain/quote_repository.dart';

/// Saves a quote from a book. Only text is kept; the photo it came from is
/// never stored.
class SaveQuote {
  SaveQuote({
    required this.quotes,
    required this.books,
    required this.clock,
    String Function()? newId,
  }) : _newId = newId ?? uuidV7;

  final QuoteRepository quotes;
  final BookRepository books;
  final Clock clock;
  final String Function() _newId;

  /// [page] is optional; when given it must be at least 1 (and within the
  /// book's page count when that is known).
  Future<Result<Quote>> call({
    required String bookId,
    required String body,
    int? page,
  }) async {
    final text = body.trim();
    if (text.isEmpty) return Err(_bad('body'));
    if (page != null && page < 1) return Err(_bad('page'));

    final book = await books.getById(bookId);
    if (book case Err(:final failure)) return Err(failure);
    final found = book.getOrNull();
    if (found == null) return const Err(NotFoundFailure('book'));
    final total = found.pages;
    if (page != null && total != null && page > total) {
      return Err(_bad('page'));
    }

    return quotes.upsert(
      Quote.create(
        id: _newId(),
        bookId: bookId,
        body: text,
        page: page,
        now: clock.now(),
      ),
    );
  }
}

ValidationFailure _bad(String field) =>
    ValidationFailure(field: field, messageKey: 'failureValidation');
