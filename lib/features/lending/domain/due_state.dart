import 'loan.dart';

/// How urgent a loan's due date is.
enum DueState { none, normal, soon, overdue }

/// Days from [today] to the due date (negative when past).
int? daysUntilDue(Loan loan, DateTime today) {
  final due = loan.dueOn;
  if (due == null) return null;
  final a = DateTime.utc(due.year, due.month, due.day);
  final b = DateTime.utc(today.year, today.month, today.day);
  return a.difference(b).inDays;
}

/// Overdue once the due date has passed; "soon" within [soonDays] days
/// (including today); otherwise normal.
DueState dueStateOf(Loan loan, DateTime today, {int soonDays = 3}) {
  final d = daysUntilDue(loan, today);
  if (d == null) return DueState.none;
  if (d < 0) return DueState.overdue;
  if (d <= soonDays) return DueState.soon;
  return DueState.normal;
}
