import '../../lending/domain/loan.dart';
import '../../lending/domain/loan_direction.dart';
import '../../../core/stable_hash.dart';

/// Which reminder of a loan this is.
enum ReminderKind { due, overdue }

/// Default time of day (local) reminders fire at; changeable in Settings.
const int kReminderHour = 10;
const int kReminderMinute = 0;

/// Days after the due date for the one overdue follow-up.
const int kOverdueFollowUpDays = 3;

/// iOS keeps at most 64 pending local notifications.
const int kMaxPendingReminders = 64;

/// One notification to be scheduled.
final class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.loanId,
    required this.bookId,
    required this.kind,
    required this.fireAt,
    required this.direction,
    required this.personName,
  });

  /// The notification id (stable for a loan and kind).
  final int id;
  final String loanId;
  final String bookId;
  final ReminderKind kind;

  /// Local time to fire at.
  final DateTime fireAt;
  final LoanDirection direction;
  final String personName;
}

/// First notification id of the daily reading reminder. Loan reminder ids
/// stay below it (see [reminderId]), so the two never collide.
const int kReadingReminderIdBase = 1500000000;

/// How many days ahead the reading reminder is scheduled.
const int kReadingReminderDays = 14;

bool isReadingReminderId(int id) =>
    id >= kReadingReminderIdBase &&
    id < kReadingReminderIdBase + kReadingReminderDays;

/// The notification id for [loanId] and [kind]: stable across runs, below
/// [kReadingReminderIdBase] and within the range the platforms accept.
int reminderId(String loanId, ReminderKind kind) =>
    (stableHash('$loanId#${kind.name}') & 0x1fffffff) * 2 +
    (kind == ReminderKind.overdue ? 1 : 0);

/// The reminders [loan] needs as of [now]: at [hour]:[minute] (10:00 unless
/// set otherwise) on the due date, and once more three days later. Past times
/// are skipped, and loans without a due date, returned loans and deleted
/// loans have none.
List<PlannedReminder> planFor(
  Loan loan,
  DateTime now, {
  int hour = kReminderHour,
  int minute = kReminderMinute,
}) {
  final due = loan.dueOn;
  if (!loan.isActive || due == null) return const <PlannedReminder>[];
  final out = <PlannedReminder>[];
  void add(ReminderKind kind, DateTime day) {
    final at = DateTime(day.year, day.month, day.day, hour, minute);
    if (at.isAfter(now)) {
      out.add(
        PlannedReminder(
          id: reminderId(loan.id, kind),
          loanId: loan.id,
          bookId: loan.bookId,
          kind: kind,
          fireAt: at,
          direction: loan.direction,
          personName: loan.personName,
        ),
      );
    }
  }

  add(ReminderKind.due, due);
  add(
    ReminderKind.overdue,
    DateTime(due.year, due.month, due.day + kOverdueFollowUpDays),
  );
  return out;
}

/// The nearest [limit] reminders across all [loans], soonest first.
List<PlannedReminder> planAll(
  Iterable<Loan> loans,
  DateTime now, {
  int limit = kMaxPendingReminders,
  int hour = kReminderHour,
  int minute = kReminderMinute,
}) {
  final all = <PlannedReminder>[
    for (final l in loans) ...planFor(l, now, hour: hour, minute: minute),
  ]..sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return all.take(limit).toList();
}
