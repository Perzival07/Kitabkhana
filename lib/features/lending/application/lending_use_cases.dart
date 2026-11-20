import '../../../core/clock.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../core/uuid.dart';
import '../../library/domain/book.dart';
import '../../library/domain/book_repository.dart';
import '../../locations/domain/location_repository.dart';
import '../domain/loan.dart';
import '../domain/loan_direction.dart';
import '../domain/loan_repository.dart';
import '../domain/reminder_service.dart';

ValidationFailure _bad(String field) =>
    ValidationFailure(field: field, messageKey: 'failureValidation');

/// Lends a book to someone. Fails with a ConflictFailure when it is already
/// out. In one transaction the loan is created and the book leaves its
/// location (remembered for the return).
class LendBook {
  LendBook({
    required this.loans,
    required this.books,
    required this.clock,
    this.reminders = const NoopReminderService(),
    String Function()? newId,
  }) : _newId = newId ?? uuidV7;

  final LoanRepository loans;
  final BookRepository books;
  final Clock clock;
  final ReminderService reminders;
  final String Function() _newId;

  Future<Result<Loan>> call({
    required String bookId,
    required String personName,
    String? personPhone,
    DateTime? startedOn,
    DateTime? dueOn,
    String? note,
  }) async {
    final name = personName.trim();
    if (name.isEmpty) return Err(_bad('personName'));
    final start = startedOn ?? clock.today();
    if (dueOn != null && dueOn.isBefore(start)) return Err(_bad('dueOn'));
    final r = await loans.startLoan(
      Loan.create(
        id: _newId(),
        bookId: bookId,
        direction: LoanDirection.lent,
        personName: name,
        personPhone: _blank(personPhone),
        startedOn: start,
        dueOn: dueOn,
        note: _blank(note),
        now: clock.now(),
      ),
    );
    return _schedule(r, books, reminders);
  }
}

/// Records that a book was borrowed from someone.
class RecordBorrowedBook {
  RecordBorrowedBook({
    required this.loans,
    required this.books,
    required this.clock,
    this.reminders = const NoopReminderService(),
    String Function()? newId,
  }) : _newId = newId ?? uuidV7;

  final LoanRepository loans;
  final BookRepository books;
  final Clock clock;
  final ReminderService reminders;
  final String Function() _newId;

  Future<Result<Loan>> call({
    required String bookId,
    required String personName,
    String? personPhone,
    DateTime? startedOn,
    DateTime? dueOn,
    String? note,
  }) async {
    final name = personName.trim();
    if (name.isEmpty) return Err(_bad('personName'));
    final start = startedOn ?? clock.today();
    if (dueOn != null && dueOn.isBefore(start)) return Err(_bad('dueOn'));
    final r = await loans.startLoan(
      Loan.create(
        id: _newId(),
        bookId: bookId,
        direction: LoanDirection.borrowed,
        personName: name,
        personPhone: _blank(personPhone),
        startedOn: start,
        dueOn: dueOn,
        note: _blank(note),
        now: clock.now(),
      ),
    );
    return _schedule(r, books, reminders);
  }
}

/// What returning a loan needs from the user.
sealed class ReturnOutcome {
  const ReturnOutcome();
}

/// The loan was closed.
final class Returned extends ReturnOutcome {
  const Returned(this.loan);
  final Loan loan;
}

/// The book's old location no longer exists: ask the user where it goes, then
/// call again with that location (or none). Nothing has been saved yet.
final class NeedsLocation extends ReturnOutcome {
  const NeedsLocation(this.loan);
  final Loan loan;
}

/// Marks a loan returned. A lent book goes back where it was; if that place
/// was deleted the caller is asked to choose ([NeedsLocation]).
class ReturnLoan {
  ReturnLoan({
    required this.loans,
    required this.locations,
    required this.clock,
    this.reminders = const NoopReminderService(),
  });

  final LoanRepository loans;
  final LocationRepository locations;
  final Clock clock;
  final ReminderService reminders;

  /// [chosenLocationId] answers a [NeedsLocation] (null: no location).
  /// [askedForLocation] must be true when [chosenLocationId] is an answer.
  /// [borrowedAction] applies to borrowed books.
  Future<Result<ReturnOutcome>> call(
    Loan loan, {
    String? chosenLocationId,
    bool askedForLocation = false,
    BorrowedReturnAction borrowedAction =
        BorrowedReturnAction.removeFromLibrary,
  }) async {
    String? restore;
    if (loan.direction == LoanDirection.lent) {
      if (askedForLocation) {
        restore = chosenLocationId;
      } else {
        final previous = loan.previousLocationId;
        if (previous != null) {
          final found = await locations.getById(previous);
          switch (found) {
            case Err<dynamic>(:final failure):
              return Err(failure);
            case Ok<dynamic>(:final value):
              if (value == null) return Ok(NeedsLocation(loan));
              restore = previous;
          }
        }
      }
    }
    final r = await loans.finishLoan(
      loan.id,
      clock.today(),
      restoreLocationId: restore,
      borrowedAction: borrowedAction,
    );
    switch (r) {
      case Ok<Loan>(:final value):
        await reminders.cancel(loan.id);
        return Ok(Returned(value));
      case Err<Loan>(:final failure):
        return Err(failure);
    }
  }
}

/// Moves a loan's due date and reschedules its reminder.
class ExtendDueDate {
  ExtendDueDate({
    required this.loans,
    required this.books,
    required this.clock,
    this.reminders = const NoopReminderService(),
  });

  final LoanRepository loans;
  final BookRepository books;
  final Clock clock;
  final ReminderService reminders;

  Future<Result<Loan>> call(Loan loan, DateTime newDue) async {
    if (newDue.isBefore(loan.startedOn)) return Err(_bad('dueOn'));
    final r = await loans.update(loan.copyWith(dueOn: newDue));
    return _schedule(r, books, reminders);
  }
}

Future<Result<Loan>> _schedule(
  Result<Loan> r,
  BookRepository books,
  ReminderService reminders,
) async {
  if (r case Ok<Loan>(:final value)) {
    final book = (await books.getById(value.bookId)).getOrNull();
    await _remind(reminders, value, book);
  }
  return r;
}

Future<void> _remind(ReminderService reminders, Loan loan, Book? book) async {
  try {
    await reminders.schedule(loan, book?.title ?? '');
  } on Object {
    // A reminder that cannot be scheduled must never fail the loan.
  }
}

String? _blank(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}
