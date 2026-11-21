import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/book_detail_providers.dart';
import '../../../app/l10n/failure_message.dart';
import '../../../app/lending_providers.dart';
import '../../../app/providers.dart';
import '../../../app/reminder_providers.dart';
import '../../../app/repositories.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/k_tokens.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../library/domain/book.dart';
import '../../library/presentation/book_cover_view.dart';
import '../../reminders/application/loan_nudge.dart';
import '../domain/due_state.dart';
import '../domain/loan.dart';
import '../domain/loan_direction.dart';
import 'extend_sheet.dart';
import 'return_flow.dart';

/// `/loans`: what you lent, what you borrowed, what is overdue, and history.
class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  /// Loans swiped away and waiting out the undo window.
  final Set<String> _pending = <String>{};

  Future<void> _nudge(Loan loan, Book book, {required bool sms}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final nudge = ref.read(loanNudgeProvider);
    final cc = ref.read(defaultCountryCodeProvider);
    final r = sms
        ? await nudge.sms(l10n, loan, book.title, defaultCountryCode: cc)
        : await nudge.whatsApp(l10n, loan, book.title, defaultCountryCode: cc);
    if (r == NudgeResult.noPhone) {
      KToast.showWith(
        messenger,
        l10n.nudgeNoPhone,
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _extend(Loan loan) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = ref.read(clockProvider).today();
    final date = await showExtendSheet(context, loan: loan, today: today);
    if (date == null) return;
    final r = await ref.read(extendDueDateProvider)(loan, date);
    switch (r) {
      case Ok<Loan>():
        KToast.showWith(
          messenger,
          l10n.extendDone(DateFormat.MMMd(locale).format(date)),
        );
      case Err<Loan>(:final failure):
        KToast.showWith(
          messenger,
          failureMessage(l10n, failure),
          icon: Icons.error_outline_rounded,
        );
    }
  }

  /// Swipe to return. A lent book whose old spot still exists is returned
  /// after a short undo window; everything else asks its questions first.
  Future<bool> _swipeReturn(Loan loan) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final useCase = ref.read(returnLoanProvider);
    final locations = ref.read(locationRepositoryProvider);

    var simple = loan.direction == LoanDirection.lent;
    final previous = loan.previousLocationId;
    if (simple && previous != null) {
      final found = (await locations.getById(previous)).getOrNull();
      simple = found != null;
    }
    if (!simple) {
      if (mounted) await returnLoanFlow(context, ref, loan);
      return false;
    }

    setState(() => _pending.add(loan.id));
    var undone = false;
    final controller = messenger.showSnackBar(
      SnackBar(
        duration: KDurations.toast,
        persist: false,
        content: Text(l10n.loanReturnedToast),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () {
            undone = true;
            if (mounted) setState(() => _pending.remove(loan.id));
          },
        ),
      ),
    );
    unawaited(
      controller.closed.then((_) async {
        if (undone) return;
        await useCase(loan);
        if (mounted) setState(() => _pending.remove(loan.id));
      }),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(clockProvider).today();
    final active = ref.watch(activeLoansProvider).value ?? const <Loan>[];
    final history = ref.watch(loanHistoryProvider).value ?? const <Loan>[];
    final visible = <Loan>[
      for (final l in active)
        if (!_pending.contains(l.id)) l,
    ];
    final lent = <Loan>[
      for (final l in visible)
        if (l.direction == LoanDirection.lent) l,
    ];
    final borrowed = <Loan>[
      for (final l in visible)
        if (l.direction == LoanDirection.borrowed) l,
    ];
    final overdue = <Loan>[
      for (final l in visible)
        if (dueStateOf(l, today) == DueState.overdue) l,
    ];

    Widget tabLabel(String text, int count) => Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(text),
          if (count > 0) ...<Widget>[
            const SizedBox(width: KSpacing.xs),
            Badge(label: Text('$count')),
          ],
        ],
      ),
    );

    final scrollTabs =
        MediaQuery.textScalerOf(context).scale(1) > 1.2 ||
        MediaQuery.sizeOf(context).width < 360;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.loansTitle),
          bottom: TabBar(
            // With big text or a narrow screen four tabs cannot share the
            // width, so let them scroll instead of being squeezed.
            isScrollable: scrollTabs,
            tabAlignment: scrollTabs ? TabAlignment.start : TabAlignment.fill,
            labelPadding: EdgeInsets.symmetric(
              horizontal: scrollTabs ? KSpacing.md : KSpacing.xs,
            ),
            tabs: <Widget>[
              tabLabel(l10n.loansTabLent, lent.length),
              tabLabel(l10n.loansTabBorrowed, borrowed.length),
              tabLabel(l10n.loansTabOverdue, overdue.length),
              Tab(text: l10n.loansTabHistory),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _LoanList(
              loans: lent,
              empty: l10n.loansEmptyLent,
              today: today,
              onReturn: (l) => returnLoanFlow(context, ref, l),
              onNudge: _nudge,
              onExtend: _extend,
              onSwipeReturn: _swipeReturn,
            ),
            _LoanList(
              loans: borrowed,
              empty: l10n.loansEmptyBorrowed,
              today: today,
              onReturn: (l) => returnLoanFlow(context, ref, l),
              onNudge: _nudge,
              onExtend: _extend,
              onSwipeReturn: _swipeReturn,
            ),
            _LoanList(
              loans: overdue,
              empty: l10n.loansEmptyOverdue,
              today: today,
              onReturn: (l) => returnLoanFlow(context, ref, l),
              onNudge: _nudge,
              onExtend: _extend,
              onSwipeReturn: _swipeReturn,
            ),
            _HistoryList(loans: history, empty: l10n.loansEmptyHistory),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      KEmptyState(illustration: KIllustration.openBook, title: text);
}

class _LoanList extends StatelessWidget {
  const _LoanList({
    required this.loans,
    required this.empty,
    required this.today,
    required this.onReturn,
    required this.onNudge,
    required this.onExtend,
    required this.onSwipeReturn,
  });

  final List<Loan> loans;
  final String empty;
  final DateTime today;
  final Future<bool> Function(Loan) onReturn;
  final Future<void> Function(Loan, Book, {required bool sms}) onNudge;
  final Future<void> Function(Loan) onExtend;
  final Future<bool> Function(Loan) onSwipeReturn;

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) return _Empty(empty);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: KSpacing.sm),
          itemCount: loans.length,
          itemBuilder: (context, i) => _LoanTile(
            key: ValueKey<String>(loans[i].id),
            loan: loans[i],
            today: today,
            onReturn: onReturn,
            onNudge: onNudge,
            onExtend: onExtend,
            onSwipeReturn: onSwipeReturn,
          ),
        ),
      ),
    );
  }
}

class _LoanTile extends ConsumerWidget {
  const _LoanTile({
    required this.loan,
    required this.today,
    required this.onReturn,
    required this.onNudge,
    required this.onExtend,
    required this.onSwipeReturn,
    super.key,
  });

  final Loan loan;
  final DateTime today;
  final Future<bool> Function(Loan) onReturn;
  final Future<void> Function(Loan, Book, {required bool sms}) onNudge;
  final Future<void> Function(Loan) onExtend;
  final Future<bool> Function(Loan) onSwipeReturn;

  String _dueText(AppLocalizations l10n, String locale) {
    final d = daysUntilDue(loan, today);
    if (d == null) return l10n.loanNoDue;
    if (d < 0) return l10n.loanOverdueDays(-d);
    if (d == 0) return l10n.loanDueToday;
    if (d <= 3) return l10n.loanDueInDays(d);
    return l10n.loanDueOn(DateFormat.MMMd(locale).format(loan.dueOn!));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = context.kTokens;
    final locale = Localizations.localeOf(context).toString();
    final book = ref.watch(bookByIdProvider(loan.bookId)).value;
    if (book == null) return const SizedBox.shrink();
    final state = dueStateOf(loan, today);
    final dueColor = switch (state) {
      DueState.overdue => theme.colorScheme.error,
      DueState.soon => tokens.warning,
      _ => tokens.mutedText,
    };
    final lent = loan.direction == LoanDirection.lent;

    final tile = ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KSpacing.screen,
        vertical: KSpacing.xs,
      ),
      onTap: () => context.push(Routes.book(book.id)),
      leading: BookCoverView(book: book, size: KCoverSize.sm),
      title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: KSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                KAvatarInitials(name: loan.personName, size: 20),
                const SizedBox(width: KSpacing.sm),
                Expanded(
                  child: Text(
                    loan.personName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text:
                        '${l10n.loanSince(DateFormat.MMMd(locale).format(loan.startedOn))} · ',
                    style: TextStyle(color: tokens.mutedText),
                  ),
                  TextSpan(
                    text: _dueText(l10n, locale),
                    style: TextStyle(
                      color: dueColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      trailing: PopupMenuButton<String>(
        tooltip: l10n.detailMore,
        onSelected: (v) {
          switch (v) {
            case 'return':
              onReturn(loan);
            case 'wa':
              onNudge(loan, book, sms: false);
            case 'sms':
              onNudge(loan, book, sms: true);
            case 'extend':
              onExtend(loan);
          }
        },
        itemBuilder: (_) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'return',
            child: Text(l10n.loanActionReturn),
          ),
          if (lent) ...<PopupMenuEntry<String>>[
            PopupMenuItem<String>(value: 'wa', child: Text(l10n.nudgeWhatsApp)),
            PopupMenuItem<String>(value: 'sms', child: Text(l10n.nudgeSms)),
          ],
          PopupMenuItem<String>(
            value: 'extend',
            child: Text(l10n.loanActionExtend),
          ),
        ],
      ),
    );

    return Dismissible(
      key: ValueKey<String>('dismiss-${loan.id}'),
      direction: lent
          ? DismissDirection.horizontal
          : DismissDirection.startToEnd,
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          return onSwipeReturn(loan);
        }
        await onNudge(loan, book, sms: false);
        return false;
      },
      background: _SwipeBackground(
        icon: Icons.assignment_returned_outlined,
        label: l10n.loanActionReturn,
        alignment: Alignment.centerLeft,
        color: tokens.success,
      ),
      secondaryBackground: _SwipeBackground(
        icon: Icons.notifications_none_rounded,
        label: l10n.detailRemind,
        alignment: Alignment.centerRight,
        color: theme.colorScheme.primary,
      ),
      child: tile,
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.icon,
    required this.label,
    required this.alignment,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color.withValues(alpha: 0.16),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: color),
              Text(label, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.loans, required this.empty});

  final List<Loan> loans;
  final String empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loans.isEmpty) return _Empty(empty);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final monthFmt = DateFormat.yMMMM(locale);
    final dayFmt = DateFormat.MMMd(locale);

    final children = <Widget>[];
    String? currentMonth;
    for (final loan in loans) {
      final when = loan.returnedOn ?? loan.startedOn;
      final month = monthFmt.format(when);
      if (month != currentMonth) {
        currentMonth = month;
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KSpacing.screen,
              KSpacing.lg,
              KSpacing.screen,
              KSpacing.xs,
            ),
            child: Semantics(
              header: true,
              child: Text(month, style: theme.textTheme.titleSmall),
            ),
          ),
        );
      }
      final book = ref.watch(bookByIdProvider(loan.bookId)).value;
      if (book == null) continue;
      children.add(
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: KSpacing.screen,
            vertical: KSpacing.xs,
          ),
          onTap: () => context.push(Routes.book(book.id)),
          leading: BookCoverView(book: book, size: KCoverSize.xs),
          title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Row(
            children: <Widget>[
              KAvatarInitials(name: loan.personName, size: 20),
              const SizedBox(width: KSpacing.sm),
              Expanded(
                child: Text(
                  '${loan.personName} · '
                  '${l10n.loanReturnedOn(dayFmt.format(when))}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(children: children),
      ),
    );
  }
}
