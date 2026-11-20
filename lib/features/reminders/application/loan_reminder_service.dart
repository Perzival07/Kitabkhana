import '../../../core/clock.dart';
import '../../../l10n/app_localizations.dart';
import '../../lending/domain/loan.dart';
import '../../lending/domain/loan_direction.dart';
import '../../lending/domain/loan_repository.dart';
import '../../lending/domain/reminder_service.dart';
import '../../library/domain/book_repository.dart';
import '../domain/notification_scheduler.dart';
import '../domain/reminder_plan.dart';

/// Wording for a planned reminder, in the user's language.
({String title, String body}) reminderText(
  AppLocalizations l10n,
  PlannedReminder r,
  String bookTitle,
) {
  final lent = r.direction == LoanDirection.lent;
  return switch (r.kind) {
    ReminderKind.due => (
      title: l10n.reminderDueTitle(bookTitle),
      body: lent
          ? l10n.reminderLentDueBody(r.personName)
          : l10n.reminderBorrowedDueBody(r.personName),
    ),
    ReminderKind.overdue => (
      title: l10n.reminderOverdueTitle(bookTitle),
      body: lent
          ? l10n.reminderLentOverdueBody(r.personName)
          : l10n.reminderBorrowedOverdueBody(r.personName),
    ),
  };
}

/// Keeps the operating system's notifications in step with loans: the
/// per-loan [ReminderService] used by the lending use cases, plus a
/// [reconcile] that rebuilds everything from the loans themselves.
class LoanReminderService implements ReminderService {
  LoanReminderService({
    required this.scheduler,
    required this.loans,
    required this.books,
    required this.clock,
    required this.l10n,
  });

  final NotificationScheduler scheduler;
  final LoanRepository loans;
  final BookRepository books;
  final Clock clock;

  /// Returns the strings for the current language.
  final AppLocalizations Function() l10n;

  Future<void> _scheduleOne(PlannedReminder r, String bookTitle) {
    final text = reminderText(l10n(), r, bookTitle);
    return scheduler.schedule(
      id: r.id,
      at: r.fireAt,
      title: text.title,
      body: text.body,
      payload: r.bookId,
    );
  }

  @override
  Future<void> schedule(Loan loan, String bookTitle) async {
    if (!scheduler.supported) return;
    for (final kind in ReminderKind.values) {
      await scheduler.cancel(reminderId(loan.id, kind));
    }
    // iOS allows 64 pending reminders: rebuild so the nearest always win.
    await reconcile();
  }

  @override
  Future<void> cancel(String loanId) async {
    if (!scheduler.supported) return;
    for (final kind in ReminderKind.values) {
      await scheduler.cancel(reminderId(loanId, kind));
    }
  }

  /// Makes the pending notifications exactly the nearest 64 that the active
  /// loans call for: cancels stale ones, (re)schedules the rest. Safe to run
  /// on every app start.
  Future<void> reconcile() async {
    if (!scheduler.supported) return;
    final active = await loans.listActive();
    final wanted = planAll(active, clock.now());
    final wantedIds = <int>{for (final r in wanted) r.id};
    for (final id in await scheduler.pendingIds()) {
      if (!wantedIds.contains(id)) await scheduler.cancel(id);
    }
    for (final r in wanted) {
      final book = (await books.getById(r.bookId)).getOrNull();
      await _scheduleOne(r, book?.title ?? '');
    }
  }
}
