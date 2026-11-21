import '../domain/book_filter.dart';

/// Books shown per page; the list loads another page near its end.
const int kLibraryPageSize = 100;

/// Grid or list presentation of the library.
enum LibraryView { grid, list }

/// The library's filter and sort together.
final class LibraryQuery {
  const LibraryQuery({
    this.filter = const BookFilter(),
    this.sort = BookSort.recentlyAdded,
  });

  final BookFilter filter;
  final BookSort sort;

  LibraryQuery copyWith({BookFilter? filter, BookSort? sort}) =>
      LibraryQuery(filter: filter ?? this.filter, sort: sort ?? this.sort);

  @override
  bool operator ==(Object other) =>
      other is LibraryQuery && other.filter == filter && other.sort == sort;

  @override
  int get hashCode => Object.hash(filter, sort);
}

/// Grid column count for a given list width: 2 below 400dp, 3 for 400–600,
/// then one more column per 200dp up to 6. [compact] adds one more column
/// (up to 7) for bigger libraries.
int libraryColumns(double width, {bool compact = false}) {
  final base = width < 400
      ? 2
      : width < 600
      ? 3
      : width < 800
      ? 4
      : width < 1000
      ? 5
      : 6;
  return compact ? base + 1 : base;
}
