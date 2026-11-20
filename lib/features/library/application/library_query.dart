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
/// then one more column per 200dp up to 6.
int libraryColumns(double width) {
  if (width < 400) return 2;
  if (width < 600) return 3;
  if (width < 800) return 4;
  if (width < 1000) return 5;
  return 6;
}
