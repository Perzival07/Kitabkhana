import '../../../core/result.dart';
import 'quote.dart';

/// A quote with the title and authors of its book, for lists and cards.
final class QuoteWithBook {
  const QuoteWithBook(this.quote, this.bookTitle, this.bookAuthors);

  final Quote quote;
  final String bookTitle;
  final String bookAuthors;

  @override
  bool operator ==(Object other) =>
      other is QuoteWithBook &&
      other.quote == quote &&
      other.bookTitle == bookTitle &&
      other.bookAuthors == bookAuthors;

  @override
  int get hashCode => Object.hash(quote, bookTitle, bookAuthors);
}

abstract interface class QuoteRepository {
  /// Like [watchAll], with each quote's book title and authors.
  Stream<List<QuoteWithBook>> watchWithBooks({
    String? bookId,
    bool favouritesOnly = false,
  });

  /// Live quotes (of existing books), newest first. Optionally limited to one
  /// book and/or favourites.
  Stream<List<Quote>> watchAll({String? bookId, bool favouritesOnly = false});

  Future<Result<Quote?>> getById(String id);

  /// Inserts or updates; stamps `updatedAt`, bumps `rev`.
  Future<Result<Quote>> upsert(Quote quote);

  Future<Result<void>> softDelete(String id);

  /// Undoes [softDelete].
  Future<Result<void>> restore(String id);
}
