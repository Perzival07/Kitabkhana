import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/add_book_providers.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../domain/book.dart';
import '../book_cover_view.dart';

/// What the user chose in the duplicate sheet.
sealed class DuplicateChoice {
  const DuplicateChoice();
}

final class OpenExisting extends DuplicateChoice {
  const OpenExisting(this.bookId);

  final String bookId;
}

final class AddAnotherCopy extends DuplicateChoice {
  const AddAnotherCopy();
}

/// Shows "You may already have this" with the matching books. Resolves to the
/// user's choice, or null if dismissed (same as cancel).
Future<DuplicateChoice?> showDuplicateSheet(
  BuildContext context,
  List<Book> books,
) {
  return showKBottomSheet<DuplicateChoice>(
    context: context,
    builder: (_) => _DuplicateSheet(books: books),
  );
}

class _DuplicateSheet extends ConsumerWidget {
  const _DuplicateSheet({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locations = ref.watch(locationsProvider).value ?? const [];
    String? locationName(String? id) {
      if (id == null) return null;
      for (final l in locations) {
        if (l.id == id) return l.name;
      }
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(l10n.duplicateTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: KSpacing.sm),
        Text(
          l10n.duplicateBody(books.length),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: KSpacing.lg),
        for (final b in books)
          _DuplicateRow(
            book: b,
            location: locationName(b.locationId),
            onTap: () => Navigator.of(context).pop(OpenExisting(b.id)),
          ),
        const SizedBox(height: KSpacing.lg),
        KButton(
          label: l10n.openExisting,
          expand: true,
          onPressed: () =>
              Navigator.of(context).pop(OpenExisting(books.first.id)),
        ),
        const SizedBox(height: KSpacing.sm),
        KButton(
          label: l10n.addAnotherCopy,
          variant: KButtonVariant.secondary,
          expand: true,
          onPressed: () => Navigator.of(context).pop(const AddAnotherCopy()),
        ),
        const SizedBox(height: KSpacing.xs),
        KButton(
          label: l10n.cancel,
          variant: KButtonVariant.text,
          expand: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _DuplicateRow extends StatelessWidget {
  const _DuplicateRow({
    required this.book,
    required this.location,
    required this.onTap,
  });

  final Book book;
  final String? location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KRadii.chip),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: KSpacing.sm),
          child: Row(
            children: <Widget>[
              BookCoverView(book: book, size: KCoverSize.xs),
              const SizedBox(width: KSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      book.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'Fraunces',
                      ),
                    ),
                    if (book.authors.isNotEmpty)
                      Text(book.authors, style: theme.textTheme.bodyMedium),
                    if (location != null)
                      Text(
                        l10n.inLocation(location!),
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
