/// A label with how many times it appears (a genre or an author).
final class LabelCount {
  const LabelCount(this.label, this.count);

  final String label;
  final int count;

  @override
  bool operator ==(Object other) =>
      other is LabelCount && other.label == label && other.count == count;

  @override
  int get hashCode => Object.hash(label, count);

  @override
  String toString() => 'LabelCount($label, $count)';
}

/// Pages read in the 7 days starting at [start] (local midnight).
final class WeekPages {
  const WeekPages(this.start, this.pages);

  final DateTime start;
  final int pages;

  @override
  bool operator ==(Object other) =>
      other is WeekPages && other.start == start && other.pages == pages;

  @override
  int get hashCode => Object.hash(start, pages);

  @override
  String toString() => 'WeekPages($start, $pages)';
}

/// The longest book finished in a year.
final class LongestBook {
  const LongestBook(this.title, this.pages);

  final String title;
  final int pages;

  @override
  bool operator ==(Object other) =>
      other is LongestBook && other.title == title && other.pages == pages;

  @override
  int get hashCode => Object.hash(title, pages);
}

/// Counts about the whole library, plus the year's longest read.
final class LibraryFacts {
  const LibraryFacts({
    required this.totalBooks,
    required this.owned,
    required this.wishlist,
    required this.lentOut,
    required this.averageRating,
    required this.longest,
  });

  static const empty = LibraryFacts(
    totalBooks: 0,
    owned: 0,
    wishlist: 0,
    lentOut: 0,
    averageRating: null,
    longest: null,
  );

  final int totalBooks;
  final int owned;
  final int wishlist;

  /// Books currently lent to someone.
  final int lentOut;

  /// Mean of all ratings, or null when nothing is rated.
  final double? averageRating;

  /// Longest book finished in the chosen year; null when none has a page
  /// count.
  final LongestBook? longest;

  @override
  bool operator ==(Object other) =>
      other is LibraryFacts &&
      other.totalBooks == totalBooks &&
      other.owned == owned &&
      other.wishlist == wishlist &&
      other.lentOut == lentOut &&
      other.averageRating == averageRating &&
      other.longest == longest;

  @override
  int get hashCode =>
      Object.hash(totalBooks, owned, wishlist, lentOut, averageRating, longest);
}
