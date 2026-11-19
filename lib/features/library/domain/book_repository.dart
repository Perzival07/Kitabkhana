import '../../../core/result.dart';
import '../../../core/text/isbn.dart';
import '../../../core/text/title_key.dart';
import 'book.dart';
import 'book_filter.dart';

abstract interface class BookRepository {
  /// Live, paged list of non-deleted books.
  Stream<List<Book>> watchAll({
    BookFilter filter = const BookFilter(),
    BookSort sort = BookSort.recentlyAdded,
    int limit = 100,
    int offset = 0,
  });

  /// Live number of books matching [filter].
  Stream<int> watchCount({BookFilter filter = const BookFilter()});

  /// Live single book; emits null if missing or deleted.
  Stream<Book?> watchById(String id);

  Future<Result<Book?>> getById(String id);

  /// Full-text search over title, subtitle and authors (prefix matching).
  Future<Result<List<Book>>> search(String query, {int limit = 20});

  /// All non-deleted copies with this ISBN.
  Future<Result<List<Book>>> findByIsbn(Isbn13 isbn);

  Future<Result<List<Book>>> findByWorkKey(String workKey);

  Future<Result<List<Book>>> findByTitleKey(TitleKey key);

  /// Inserts or updates [book]. Sets `updatedAt` from the clock and
  /// increments `rev`; returns the stored book.
  Future<Result<Book>> upsert(Book book);

  Future<Result<void>> softDelete(String id);

  /// Undoes [softDelete].
  Future<Result<void>> restore(String id);
}
