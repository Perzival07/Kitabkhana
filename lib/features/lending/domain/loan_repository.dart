import '../../../core/result.dart';
import 'loan.dart';

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
}
