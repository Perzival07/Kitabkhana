import 'package:flutter/material.dart';

import '../../../../app/theme/k_tokens.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../domain/book.dart';
import '../../domain/book_enums.dart';
import '../book_cover_view.dart';
import 'highlight_text.dart';

/// The status colour used for the small dot on grid tiles.
Color statusDotColor(BuildContext context, ReadStatus status) {
  final cs = Theme.of(context).colorScheme;
  final tokens = context.kTokens;
  return switch (status) {
    ReadStatus.want => cs.secondary,
    ReadStatus.reading => cs.primary,
    ReadStatus.finished => tokens.success,
    ReadStatus.dropped => tokens.warning,
  };
}

/// The Hero tag shared by a book's cover in the library and on its page.
String bookHeroTag(String id) => 'book-cover-$id';

/// An icon for a reading status: outlined when not chosen, filled when it is.
IconData statusIcon(
  ReadStatus status, {
  required bool selected,
}) => switch (status) {
  ReadStatus.want =>
    selected ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
  ReadStatus.reading =>
    selected ? Icons.auto_stories_rounded : Icons.auto_stories_outlined,
  ReadStatus.finished =>
    selected ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
  ReadStatus.dropped => selected ? Icons.cancel_rounded : Icons.cancel_outlined,
};

String statusLabel(AppLocalizations l10n, ReadStatus status) =>
    switch (status) {
      ReadStatus.want => l10n.statusWant,
      ReadStatus.reading => l10n.statusReading,
      ReadStatus.finished => l10n.statusFinished,
      ReadStatus.dropped => l10n.statusDropped,
    };

TextStyle _titleStyle(BuildContext context, {double size = 14}) =>
    Theme.of(context).textTheme.titleLarge!
        .copyWith(fontSize: size, height: 1.25);

/// Height of the text under a grid cover (two title lines, one author line),
/// honouring the user's text scale.
double gridTextHeight(BuildContext context) {
  final scaler = MediaQuery.textScalerOf(context);
  return scaler.scale(14 * 1.25 * 2) + scaler.scale(12 * 1.4) + KSpacing.sm + 4;
}

/// A book in the grid: cover, two-line title, one-line author, a status dot
/// and a "Lent" ribbon when it is out.
/// What a screen reader says for a book in a list or grid: title, authors,
/// status, whether it is lent out, and where it is.
String bookTileLabel(
  AppLocalizations l10n,
  Book book, {
  required bool lent,
  String? locationName,
}) => <String>[
  book.title,
  if (book.authors.isNotEmpty) l10n.bookTileByAuthor(book.authors),
  statusLabel(l10n, book.status),
  if (lent) l10n.lentRibbon,
  if (locationName != null) l10n.bookTileAt(locationName),
].join(', ');

class BookGridTile extends StatelessWidget {
  const BookGridTile({
    required this.book,
    required this.lent,
    required this.query,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final Book book;
  final bool lent;
  final String query;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      button: true,
      label: bookTileLabel(l10n, book, lent: lent),
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(KRadii.cover + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                BookCoverView(book: book, heroTag: bookHeroTag(book.id)),
                if (lent)
                  Positioned(
                    top: KSpacing.sm,
                    left: 0,
                    child: _Ribbon(label: l10n.lentRibbon),
                  ),
                Positioned(
                  right: KSpacing.sm,
                  bottom: KSpacing.sm,
                  child: _StatusDot(
                    color: statusDotColor(context, book.status),
                    status: book.status,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KSpacing.sm),
            HighlightText(
              book.title,
              query: query,
              style: _titleStyle(context),
              maxLines: 2,
            ),
            if (book.authors.isNotEmpty)
              HighlightText(
                book.authors,
                query: query,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, required this.status});

  final Color color;
  final ReadStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Dark icon on a light dot and the other way round, so it always reads.
    final ink = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        shape: BoxShape.circle,
        boxShadow: context.kTokens.shadows,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        // The icon says the status as well as the colour does.
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: SizedBox.square(
            dimension: 20,
            child: Icon(
              statusIcon(status, selected: true),
              size: 13,
              color: ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _Ribbon extends StatelessWidget {
  const _Ribbon({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(KRadii.chip),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KSpacing.sm,
          vertical: KSpacing.xs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: cs.onSecondary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// A book in the list: small cover, title, author, location, status pill and
/// a progress bar while reading.
class BookListTile extends StatelessWidget {
  const BookListTile({
    required this.book,
    required this.lent,
    required this.query,
    required this.locationName,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final Book book;
  final bool lent;
  final String query;
  final String? locationName;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final progress = book.status == ReadStatus.reading ? book.progress : null;
    return Semantics(
      container: true,
      button: true,
      label: bookTileLabel(l10n, book, lent: lent, locationName: locationName),
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KSpacing.screen,
            vertical: KSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BookCoverView(book: book, size: KCoverSize.sm),
              const SizedBox(width: KSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    HighlightText(
                      book.title,
                      query: query,
                      style: _titleStyle(context, size: 16),
                      maxLines: 2,
                    ),
                    if (book.authors.isNotEmpty)
                      HighlightText(
                        book.authors,
                        query: query,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                      ),
                    if (locationName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: KSpacing.xs),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.place_outlined,
                              size: 14,
                              color: context.kTokens.mutedText,
                            ),
                            const SizedBox(width: KSpacing.xs),
                            Expanded(
                              child: Text(
                                locationName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: KSpacing.sm),
                    Wrap(
                      spacing: KSpacing.sm,
                      runSpacing: KSpacing.xs,
                      children: <Widget>[
                        KStatusPill(
                          status: KStatus.values.byName(book.status.name),
                        ),
                        if (lent) KChip(label: l10n.lentRibbon),
                      ],
                    ),
                    if (progress != null) ...<Widget>[
                      const SizedBox(height: KSpacing.sm),
                      KProgressBar(value: progress),
                    ],
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

/// Placeholder rows while the first page loads.
class BookListTileSkeleton extends StatelessWidget {
  const BookListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: KSpacing.screen,
        vertical: KSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          KSkeleton(width: 72, height: 108, radius: KRadii.cover),
          SizedBox(width: KSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                KSkeleton(height: 16),
                SizedBox(height: KSpacing.sm),
                KSkeleton(width: 120, height: 12),
                SizedBox(height: KSpacing.md),
                KSkeleton(width: 80, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
