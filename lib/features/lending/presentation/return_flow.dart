import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/failure_message.dart';
import '../../../app/lending_providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../locations/presentation/location_picker.dart';
import '../application/lending_use_cases.dart';
import '../domain/loan.dart';
import '../domain/loan_direction.dart';
import '../domain/loan_repository.dart';

/// Returns [loan], asking the user whatever is needed: a new location when
/// the old one is gone, or what to do with a borrowed book. Shows a toast and
/// resolves to true when the loan was closed.
Future<bool> returnLoanFlow(
  BuildContext context,
  WidgetRef ref,
  Loan loan,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final useCase = ref.read(returnLoanProvider);

  var action = BorrowedReturnAction.removeFromLibrary;
  if (loan.direction == LoanDirection.borrowed) {
    final choice = await showKBottomSheet<BorrowedReturnAction>(
      context: context,
      builder: (_) => _BorrowedChoice(name: loan.personName),
    );
    if (choice == null) return false;
    action = choice;
  }

  var r = await useCase(loan, borrowedAction: action);
  if (r case Ok<ReturnOutcome>(:final value) when value is NeedsLocation) {
    if (!context.mounted) return false;
    final pick = await showLocationPicker(context);
    if (pick == null) return false;
    r = await useCase(
      loan,
      chosenLocationId: pick.id,
      askedForLocation: true,
      borrowedAction: action,
    );
  }
  switch (r) {
    case Ok<ReturnOutcome>():
      KToast.showWith(messenger, l10n.detailReturned);
      return true;
    case Err<ReturnOutcome>(:final failure):
      KToast.showWith(
        messenger,
        failureMessage(l10n, failure),
        icon: Icons.error_outline_rounded,
      );
      return false;
  }
}

class _BorrowedChoice extends StatelessWidget {
  const _BorrowedChoice({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.returnBorrowedTitle(name),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.md),
        ListTile(
          leading: const Icon(Icons.delete_outline_rounded),
          title: Text(l10n.returnBorrowedRemove),
          onTap: () =>
              Navigator.of(context).pop(BorrowedReturnAction.removeFromLibrary),
        ),
        ListTile(
          leading: const Icon(Icons.favorite_border_rounded),
          title: Text(l10n.returnBorrowedKeep),
          onTap: () =>
              Navigator.of(context).pop(BorrowedReturnAction.keepAsWishlist),
        ),
      ],
    );
  }
}
