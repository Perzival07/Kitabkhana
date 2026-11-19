import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';
import 'package:kitabkhana/features/library/domain/book_info_source.dart';

/// A catalogue that returns canned answers and counts calls.
class FakeSource implements BookInfoSource {
  int isbnCalls = 0;
  int searchCalls = 0;
  String? lastSearch;
  Result<BookInfo> Function() onIsbn = () =>
      const Err<BookInfo>(NotFoundFailure());
  Result<List<BookInfo>> Function() onSearch = () =>
      const Ok<List<BookInfo>>(<BookInfo>[]);

  @override
  Future<Result<BookInfo>> lookupIsbn(Isbn13 isbn) async {
    isbnCalls++;
    return onIsbn();
  }

  @override
  Future<Result<List<BookInfo>>> searchTitle(
    String title, {
    String? author,
    int limit = 10,
  }) async {
    searchCalls++;
    lastSearch = title;
    return onSearch();
  }
}
