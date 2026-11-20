import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/add_book_providers.dart';
import '../../../../app/repositories.dart';
import '../../../../app/l10n/failure_message.dart';
import '../../../../core/failure.dart';
import '../../../../core/result.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../domain/book.dart';
import '../../domain/book_enums.dart';
import 'book_tiles.dart';

/// Long-press menu for a book: change status, move, delete (with undo).
Future<void> showQuickActions(
  BuildContext context,
  WidgetRef ref,
  Book book,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final action = await showKBottomSheet<_Action>(
    context: context,
    builder: (_) => _ActionsList(book: book),
  );
  if (action == null) return;
  final repo = ref.read(bookRepositoryProvider);

  void failed(Failure f) => KToast.showWith(
    messenger,
    failureMessage(l10n, f),
    icon: Icons.error_outline_rounded,
  );

  switch (action) {
    case _ChangeStatus(:final status):
      final r = await repo.update(book.id, (b) => b.copyWith(status: status));
      switch (r) {
        case Ok():
          KToast.showWith(
            messenger,
            l10n.bookStatusChanged(book.title, statusLabel(l10n, status)),
          );
        case Err(:final failure):
          failed(failure);
      }
    case _Move(:final locationId):
      final r = await repo.update(
        book.id,
        (b) => b.copyWith(locationId: locationId),
      );
      switch (r) {
        case Ok():
          KToast.showWith(messenger, l10n.bookMoved(book.title));
        case Err(:final failure):
          failed(failure);
      }
    case _Delete():
      final r = await repo.softDelete(book.id);
      switch (r) {
        case Ok():
          KToast.showWith(
            messenger,
            l10n.bookDeleted(book.title),
            icon: Icons.delete_outline_rounded,
            actionLabel: l10n.undo,
            onAction: () => repo.restore(book.id),
          );
        case Err(:final failure):
          failed(failure);
      }
  }
}

sealed class _Action {
  const _Action();
}

final class _ChangeStatus extends _Action {
  const _ChangeStatus(this.status);
  final ReadStatus status;
}

final class _Move extends _Action {
  const _Move(this.locationId);
  final String? locationId;
}

final class _Delete extends _Action {
  const _Delete();
}

enum _Page { actions, status, move }

class _ActionsList extends ConsumerStatefulWidget {
  const _ActionsList({required this.book});

  final Book book;

  @override
  ConsumerState<_ActionsList> createState() => _ActionsListState();
}

class _ActionsListState extends ConsumerState<_ActionsList> {
  _Page _page = _Page.actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final book = widget.book;
    final cs = theme.colorScheme;

    Widget header(String text) => Padding(
      padding: const EdgeInsets.only(bottom: KSpacing.sm),
      child: Text(text, style: theme.textTheme.titleLarge, maxLines: 2),
    );

    switch (_page) {
      case _Page.actions:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            header(book.title),
            ListTile(
              leading: const Icon(Icons.auto_stories_outlined),
              title: Text(l10n.quickChangeStatus),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => setState(() => _page = _Page.status),
            ),
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(l10n.quickMove),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => setState(() => _page = _Page.move),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: cs.error),
              title: Text(l10n.quickDelete, style: TextStyle(color: cs.error)),
              onTap: () => Navigator.of(context).pop(const _Delete()),
            ),
          ],
        );
      case _Page.status:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            header(l10n.quickChangeStatus),
            for (final s in ReadStatus.values)
              ListTile(
                leading: Icon(
                  s == book.status
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
                title: Text(statusLabel(l10n, s)),
                onTap: () => Navigator.of(context).pop(_ChangeStatus(s)),
              ),
          ],
        );
      case _Page.move:
        final locations = ref.watch(locationsProvider).value ?? const [];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            header(l10n.quickMove),
            ListTile(
              leading: Icon(
                book.locationId == null
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
              ),
              title: Text(l10n.noLocation),
              onTap: () => Navigator.of(context).pop(const _Move(null)),
            ),
            for (final loc in locations)
              ListTile(
                leading: Icon(
                  loc.id == book.locationId
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
                title: Text(loc.name),
                onTap: () => Navigator.of(context).pop(_Move(loc.id)),
              ),
          ],
        );
    }
  }
}
