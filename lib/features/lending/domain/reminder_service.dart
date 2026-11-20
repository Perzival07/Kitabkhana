import 'loan.dart';

/// Schedules a nudge for a loan's due date. The real implementation arrives
/// with reminders; until then nothing is scheduled.
abstract interface class ReminderService {
  /// Schedules (or reschedules) the reminder for [loan]; does nothing when the
  /// loan has no due date.
  Future<void> schedule(Loan loan, String bookTitle);

  /// Cancels any reminder for [loanId].
  Future<void> cancel(String loanId);
}

class NoopReminderService implements ReminderService {
  const NoopReminderService();

  @override
  Future<void> schedule(Loan loan, String bookTitle) async {}

  @override
  Future<void> cancel(String loanId) async {}
}
