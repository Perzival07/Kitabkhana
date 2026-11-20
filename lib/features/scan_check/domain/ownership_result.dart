import '../../../core/text/isbn.dart';
import '../../lending/domain/loan.dart';
import '../../library/domain/book.dart';
import '../../library/domain/book_info.dart';

/// The answer to "do I already have this book?".
sealed class OwnershipResult {
  const OwnershipResult();
}

/// This exact edition is in the library and on the shelf.
final class Owned extends OwnershipResult {
  const Owned(this.book, this.locationLabel);
  final Book book;

  /// "Bedroom › Shelf 2", or null when the book has no location.
  final String? locationLabel;
}

/// A different edition of the same book is in the library.
final class OtherEdition extends OwnershipResult {
  const OtherEdition(this.book, this.locationLabel);
  final Book book;
  final String? locationLabel;
}

/// The book is on the wishlist, not yet owned.
final class OnWishlist extends OwnershipResult {
  const OnWishlist(this.book);
  final Book book;
}

/// The book is owned but currently lent to someone.
final class LentOut extends OwnershipResult {
  const LentOut(this.book, this.loan);
  final Book book;
  final Loan loan;
}

/// The book is someone else's, borrowed in. [loan] is null when it was only
/// marked as borrowed.
final class BorrowedIn extends OwnershipResult {
  const BorrowedIn(this.book, this.loan);
  final Book book;
  final Loan? loan;
}

/// A candidate for [PossibleMatch].
final class MatchCandidate {
  const MatchCandidate(this.book, this.score);
  final Book book;

  /// Trigram similarity, 0..1.
  final double score;
}

/// Nothing exact, but up to three books look very similar.
final class PossibleMatch extends OwnershipResult {
  const PossibleMatch(this.candidates);
  final List<MatchCandidate> candidates;
}

/// Not in the library. [info] (when found) makes "Add to wishlist" one tap.
final class NotInLibrary extends OwnershipResult {
  const NotInLibrary({this.isbn, this.info});
  final Isbn13? isbn;
  final BookInfo? info;
}
