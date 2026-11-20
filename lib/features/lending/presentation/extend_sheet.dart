import 'package:flutter/material.dart';

import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/loan.dart';

/// Picks a new due date for [loan]: +1 week, +2 weeks, +1 month, or a date.
/// Counts from the current due date (or today when there is none).
Future<DateTime?> showExtendSheet(
  BuildContext context, {
  required Loan loan,
  required DateTime today,
}) => showKBottomSheet<DateTime>(
  context: context,
  builder: (_) => _ExtendBody(loan: loan, today: today),
);

class _ExtendBody extends StatelessWidget {
  const _ExtendBody({required this.loan, required this.today});
  final Loan loan;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final base = loan.dueOn ?? today;
    // From today if the date has already passed: extending an overdue loan
    // should give real time, not another overdue date.
    final from = base.isBefore(today) ? today : base;
    DateTime plusDays(int n) => DateTime(from.year, from.month, from.day + n);
    Widget option(String label, DateTime date) => ListTile(
      leading: const Icon(Icons.event_repeat_rounded),
      title: Text(label),
      onTap: () => Navigator.of(context).pop(date),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.extendTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: KSpacing.sm),
        option(l10n.extend1w, plusDays(7)),
        option(l10n.extend2w, plusDays(14)),
        option(l10n.extend1m, DateTime(from.year, from.month + 1, from.day)),
        ListTile(
          leading: const Icon(Icons.edit_calendar_outlined),
          title: Text(l10n.lendDueCustom),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: from,
              firstDate: loan.startedOn,
              lastDate: DateTime(today.year + 5),
            );
            if (picked != null && context.mounted) {
              Navigator.of(context).pop(picked);
            }
          },
        ),
      ],
    );
  }
}
