import '../../../core/result.dart';
import '../../../core/text/isbn.dart';
import 'book_info.dart';

/// A catalogue that can describe a book by ISBN or find books by title.
abstract interface class BookInfoSource {
  /// Looks up one ISBN. `NotFoundFailure` when the catalogue has no record.
  Future<Result<BookInfo>> lookupIsbn(Isbn13 isbn);

  /// Finds up to [limit] books by title (and optionally author).
  Future<Result<List<BookInfo>>> searchTitle(
    String title, {
    String? author,
    int limit = 10,
  });
}

/// A stored lookup result.
final class LookupCacheEntry {
  const LookupCacheEntry({
    required this.key,
    required this.payloadJson,
    required this.fetchedAt,
    required this.isNotFound,
  });

  final String key;
  final String payloadJson;
  final DateTime fetchedAt;
  final bool isNotFound;
}

/// Device-local cache of lookups.
abstract interface class LookupCacheStore {
  Future<LookupCacheEntry?> get(String key);

  Future<void> put(LookupCacheEntry entry);
}
