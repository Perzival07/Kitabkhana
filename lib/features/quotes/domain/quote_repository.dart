import '../../../core/result.dart';
import 'quote.dart';

abstract interface class QuoteRepository {
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
