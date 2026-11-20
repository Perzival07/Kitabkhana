import '../../../core/result.dart';
import 'loan.dart';

/// What to do with a borrowed book once it goes back to its owner.
enum BorrowedReturnAction { removeFromLibrary, keepAsWishlist }

abstract interface class LoanRepository {
  /// Live loans not yet returned (for books that still exist), soonest due
  /// first, loans without a due date last.
  Stream<List<Loan>> watchActive();

  /// Live active loans past their due date.
  Stream<List<Loan>> watchOverdue();

  /// Live returned loans, most recently returned first.
  Stream<List<Loan>> watchHistory();

  /// The active loan for a book, if any.
  Future<Result<Loan?>> activeFor(String bookId);

  /// Creates a loan. Fails with a ConflictFailure (`failureBookAlreadyLent`)
  /// when the book already has an active loan.
  Future<Result<Loan>> create(Loan loan);

  /// Updates an existing loan (e.g. a new due date).
  Future<Result<Loan>> update(Loan loan);

  /// Marks the loan returned on [returnedOn].
  Future<Result<Loan>> markReturned(String loanId, DateTime returnedOn);

  /// Starts a loan and updates the book, all in one transaction.
  ///
  /// Lending: fails with a ConflictFailure when the book already has an
  /// active loan; remembers the book's location in `previousLocationId` and
  /// clears the book's location. Borrowing: marks the book as borrowed.
  Future<Result<Loan>> startLoan(Loan loan);

  /// Marks the loan returned and fixes up the book, all in one transaction.
  ///
  /// A lent book goes back to [restoreLocationId] (null for no location).
  /// A borrowed book is removed or turned into a wishlist entry, as chosen
  /// by [borrowedAction] (default: remove).
  Future<Result<Loan>> finishLoan(
    String loanId,
    DateTime returnedOn, {
    String? restoreLocationId,
    BorrowedReturnAction borrowedAction =
        BorrowedReturnAction.removeFromLibrary,
  });

  /// Names of people from past loans, most recent first (for autocomplete).
  Future<List<String>> recentPeople({int limit = 20});
}
