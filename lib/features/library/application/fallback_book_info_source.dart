import '../../../core/result.dart';
import '../../../core/text/isbn.dart';
import '../domain/book_info.dart';
import '../domain/book_info_source.dart';

/// Asks [primary] (Open Library) first and [fallback] (Google Books) only when
/// the primary has no answer: not found, an empty search, or the primary
/// being unreachable. So the fallback sees as little as possible.
class FallbackBookInfoSource implements BookInfoSource {
  const FallbackBookInfoSource({required this.primary, required this.fallback});

  final BookInfoSource primary;
  final BookInfoSource fallback;

  @override
  Future<Result<BookInfo>> lookupIsbn(Isbn13 isbn) async {
    final first = await primary.lookupIsbn(isbn);
    if (first is Ok<BookInfo>) return first;
    final second = await fallback.lookupIsbn(isbn);
    if (second is Ok<BookInfo>) return second;
    // Neither knows it: the primary's answer (its failure is the one the
    // rest of the app is written around) stands.
    return first;
  }

  @override
  Future<Result<List<BookInfo>>> searchTitle(
    String title, {
    String? author,
    int limit = 10,
  }) async {
    final first = await primary.searchTitle(
      title,
      author: author,
      limit: limit,
    );
    if (first is Ok<List<BookInfo>> && first.value.isNotEmpty) return first;
    final second = await fallback.searchTitle(
      title,
      author: author,
      limit: limit,
    );
    if (second is Ok<List<BookInfo>> && second.value.isNotEmpty) return second;
    return first is Ok<List<BookInfo>> ? first : second;
  }
}
