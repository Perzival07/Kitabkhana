import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/k_tokens.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/text/isbn.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../library/domain/book.dart';
import '../../library/domain/book_info.dart';
import '../../library/presentation/book_cover_view.dart';
import '../application/check_ownership.dart';
import '../domain/ownership_result.dart';

/// What the user chose on the verdict card.
sealed class VerdictOutcome {
  const VerdictOutcome();
}

final class OpenBookOutcome extends VerdictOutcome {
  const OpenBookOutcome(this.bookId);
  final String bookId;
}

final class ScanAnotherOutcome extends VerdictOutcome {
  const ScanAnotherOutcome();
}

final class MarkBoughtOutcome extends VerdictOutcome {
  const MarkBoughtOutcome(this.book);
  final Book book;
}

final class AddToWishlistOutcome extends VerdictOutcome {
  const AddToWishlistOutcome({this.isbn, this.info});
  final Isbn13? isbn;
  final BookInfo? info;
}

final class AddAsBoughtOutcome extends VerdictOutcome {
  const AddAsBoughtOutcome({this.isbn, this.info});
  final Isbn13? isbn;
  final BookInfo? info;
}

/// Whether a verdict is one of the "you already have it" states (stronger
/// haptic).
bool isOwnedVerdict(OwnershipResult r) =>
    r is Owned || r is OtherEdition || r is LentOut || r is BorrowedIn;

/// Slides the verdict up. Resolves to what the user chose, or null when the
/// sheet was dismissed.
Future<VerdictOutcome?> showVerdictSheet(
  BuildContext context, {
  required OwnershipResult result,
  required CheckOwnership check,
}) => showKBottomSheet<VerdictOutcome>(
  context: context,
  builder: (_) => VerdictCard(result: result, check: check),
);

/// The card inside the sheet. "Did you mean…?" swaps itself for the verdict
/// of the chosen book.
class VerdictCard extends StatefulWidget {
  const VerdictCard({required this.result, required this.check, super.key});

  final OwnershipResult result;
  final CheckOwnership check;

  @override
  State<VerdictCard> createState() => _VerdictCardState();
}

class _VerdictCardState extends State<VerdictCard> {
  late OwnershipResult _result = widget.result;
  bool _busy = false;

  void _pop(VerdictOutcome o) => Navigator.of(context).pop(o);

  Future<void> _pick(Book b) async {
    setState(() => _busy = true);
    final r = await widget.check.resolveBook(b);
    if (mounted) {
      setState(() {
        _result = r;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = context.kTokens;
    final fmt = DateFormat.MMMd(Localizations.localeOf(context).toString());
    final r = _result;

    Widget headline(IconData icon, Color color, String title, {String? sub}) =>
        Column(
          children: <Widget>[
            // The badge pops in, and again when "Did you mean…?" resolves to
            // a different verdict.
            KPop(
              replay: r.runtimeType,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(KSpacing.md),
                  child: Icon(icon, color: color, size: 40),
                ),
              ),
            ),
            const SizedBox(height: KSpacing.md),
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            if (sub != null) ...<Widget>[
              const SizedBox(height: KSpacing.xs),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.mutedText,
                ),
              ),
            ],
          ],
        );

    Widget bookLine(Book b) => Padding(
      padding: const EdgeInsets.symmetric(vertical: KSpacing.lg),
      child: Row(
        children: <Widget>[
          BookCoverView(book: b, size: KCoverSize.sm),
          const SizedBox(width: KSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  b.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                if (b.authors.isNotEmpty)
                  Text(
                    b.authors,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget openAndScan(Book b) => Column(
      children: <Widget>[
        KButton(
          label: l10n.verdictOpenBook,
          expand: true,
          onPressed: () => _pop(OpenBookOutcome(b.id)),
        ),
        const SizedBox(height: KSpacing.sm),
        KButton(
          label: l10n.verdictScanAnother,
          variant: KButtonVariant.text,
          expand: true,
          onPressed: () => _pop(const ScanAnotherOutcome()),
        ),
      ],
    );

    Widget scanAnother() => KButton(
      label: l10n.verdictScanAnother,
      variant: KButtonVariant.text,
      expand: true,
      onPressed: () => _pop(const ScanAnotherOutcome()),
    );

    final Widget body;
    switch (r) {
      case Owned(:final book, :final locationLabel):
        body = Column(
          children: <Widget>[
            headline(
              Icons.check_circle_rounded,
              tokens.success,
              l10n.verdictOwned,
              sub: locationLabel == null
                  ? l10n.verdictNoPlace
                  : l10n.verdictOwnedWhere(locationLabel),
            ),
            bookLine(book),
            openAndScan(book),
          ],
        );
      case OtherEdition(:final book, :final locationLabel):
        body = Column(
          children: <Widget>[
            headline(
              Icons.library_books_rounded,
              tokens.success,
              l10n.verdictOtherEdition,
              sub: locationLabel == null
                  ? l10n.verdictNoPlace
                  : l10n.verdictOwnedWhere(locationLabel),
            ),
            bookLine(book),
            openAndScan(book),
          ],
        );
      case OnWishlist(:final book):
        body = Column(
          children: <Widget>[
            headline(
              Icons.favorite_rounded,
              theme.colorScheme.primary,
              l10n.verdictWishlist,
            ),
            bookLine(book),
            KButton(
              label: l10n.verdictMarkBought,
              expand: true,
              onPressed: () => _pop(MarkBoughtOutcome(book)),
            ),
            const SizedBox(height: KSpacing.sm),
            KButton(
              label: l10n.verdictOpenBook,
              variant: KButtonVariant.tonal,
              expand: true,
              onPressed: () => _pop(OpenBookOutcome(book.id)),
            ),
            scanAnother(),
          ],
        );
      case LentOut(:final book, :final loan):
        body = Column(
          children: <Widget>[
            headline(
              Icons.swap_horiz_rounded,
              tokens.warning,
              l10n.verdictLentTo(loan.personName),
              sub: l10n.verdictSince(fmt.format(loan.startedOn)),
            ),
            bookLine(book),
            openAndScan(book),
          ],
        );
      case BorrowedIn(:final book, :final loan):
        body = Column(
          children: <Widget>[
            headline(
              Icons.move_to_inbox_rounded,
              tokens.warning,
              loan == null
                  ? l10n.verdictBorrowed
                  : l10n.verdictBorrowedFrom(loan.personName),
              sub: loan == null
                  ? null
                  : l10n.verdictSince(fmt.format(loan.startedOn)),
            ),
            bookLine(book),
            openAndScan(book),
          ],
        );
      case PossibleMatch(:final candidates):
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            headline(
              Icons.help_outline_rounded,
              theme.colorScheme.secondary,
              l10n.verdictDidYouMean,
            ),
            const SizedBox(height: KSpacing.md),
            for (final c in candidates)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: BookCoverView(book: c.book, size: KCoverSize.xs),
                title: Text(
                  c.book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  c.book.authors.isEmpty
                      ? l10n.verdictMatch((c.score * 100).round())
                      : '${c.book.authors} · '
                            '${l10n.verdictMatch((c.score * 100).round())}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: _busy ? null : () => _pick(c.book),
              ),
            const SizedBox(height: KSpacing.sm),
            KButton(
              label: l10n.verdictNoneOfThese,
              variant: KButtonVariant.tonal,
              expand: true,
              onPressed: () => setState(() => _result = const NotInLibrary()),
            ),
          ],
        );
      case NotInLibrary(:final isbn, :final info):
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            headline(
              Icons.add_circle_outline_rounded,
              theme.colorScheme.primary,
              l10n.verdictNotInLibrary,
            ),
            if (info != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: KSpacing.lg),
                child: Row(
                  children: <Widget>[
                    KBookCover(
                      title: info.title,
                      author: info.authorsText,
                      imageUrl: info.coverUrl,
                      size: KCoverSize.sm,
                    ),
                    const SizedBox(width: KSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            info.title.isEmpty
                                ? l10n.verdictUnknownTitle
                                : info.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          if (info.authors.isNotEmpty)
                            Text(
                              info.authorsText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: KSpacing.lg),
            KButton(
              label: l10n.verdictAddWishlist,
              expand: true,
              onPressed: () =>
                  _pop(AddToWishlistOutcome(isbn: isbn, info: info)),
            ),
            const SizedBox(height: KSpacing.sm),
            KButton(
              label: l10n.verdictBoughtIt,
              variant: KButtonVariant.tonal,
              expand: true,
              onPressed: () => _pop(AddAsBoughtOutcome(isbn: isbn, info: info)),
            ),
            scanAnother(),
          ],
        );
    }

    return body;
  }
}
