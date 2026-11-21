import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/quote_providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../library/presentation/book_picker.dart';
import '../domain/quote_repository.dart';
import 'quote_tile.dart';

/// `/quotes`: every saved quote, searchable, filterable by book and
/// favourites.
class QuotesScreen extends ConsumerWidget {
  const QuotesScreen({super.key});

  Future<void> _snap(BuildContext context) async {
    final book = await showBookPicker(context);
    if (book == null || !context.mounted) return;
    await context.push(Routes.quoteCapture(book.id));
  }

  Future<void> _filterBook(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final book = await showBookPicker(
      context,
      title: l10n.quotesBookFilterTitle,
    );
    if (book != null) ref.read(quotesFilterProvider.notifier).setBook(book.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(quotesFilterProvider);
    final all = ref.watch(allQuotesProvider);
    final shown = ref.watch(filteredQuotesProvider);
    final notifier = ref.read(quotesFilterProvider.notifier);
    final hasAny = all.value?.isNotEmpty ?? false;

    // The chip names the chosen book, found among the quotes.
    String? bookName;
    if (filter.bookId != null) {
      bookName = all.value
          ?.where((e) => e.quote.bookId == filter.bookId)
          .map((e) => e.bookTitle)
          .firstOrNull;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quotesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'quotes-snap',
        onPressed: () => _snap(context),
        icon: const Icon(Icons.format_quote_rounded),
        label: Text(l10n.quoteSnap),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (hasAny) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KSpacing.screen,
                      KSpacing.sm,
                      KSpacing.screen,
                      KSpacing.sm,
                    ),
                    child: KSearchField(
                      hint: l10n.quotesSearchHint,
                      onChanged: notifier.setQuery,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: KSpacing.screen,
                    ),
                    child: Row(
                      children: <Widget>[
                        FilterChip(
                          label: Text(l10n.quotesFavourites),
                          avatar: const Icon(
                            Icons.favorite_border_rounded,
                            size: 18,
                          ),
                          selected: filter.favourites,
                          onSelected: (_) => notifier.toggleFavourites(),
                        ),
                        const SizedBox(width: KSpacing.sm),
                        InputChip(
                          label: Text(bookName ?? l10n.quotesAllBooks),
                          selected: filter.bookId != null,
                          onPressed: () => _filterBook(context, ref),
                          onDeleted: filter.bookId == null
                              ? null
                              : () => notifier.setBook(null),
                        ),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: shown.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(KSpacing.screen),
                      child: KSkeleton(height: 160),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (list) => _body(context, list, hasAny),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, List<QuoteWithBook> list, bool hasAny) {
    final l10n = AppLocalizations.of(context);
    if (!hasAny) {
      return KEmptyState(
        illustration: KIllustration.quoteMarks,
        title: l10n.quotesEmptyTitle,
        body: l10n.quotesEmptyBody,
      );
    }
    if (list.isEmpty) {
      return KEmptyState(
        illustration: KIllustration.quoteMarks,
        title: l10n.quotesNoMatch,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        KSpacing.screen,
        KSpacing.lg,
        KSpacing.screen,
        96,
      ),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: KSpacing.md),
      itemBuilder: (_, i) =>
          QuoteTile(key: ValueKey<String>(list[i].quote.id), entry: list[i]),
    );
  }
}
