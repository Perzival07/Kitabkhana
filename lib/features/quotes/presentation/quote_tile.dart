import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/failure_message.dart';
import '../../../app/quote_providers.dart';
import '../../../app/repositories.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/quote.dart';
import '../domain/quote_repository.dart';
import 'quote_card.dart';
import 'quote_edit_sheet.dart';

/// "Title, p. 42" (or just the title), in the reader's language.
String quoteAttributionOf(AppLocalizations l10n, QuoteWithBook e) =>
    e.quote.page == null
    ? l10n.quoteAttribution(e.bookTitle)
    : l10n.quoteAttributionPage(e.bookTitle, e.quote.page!);

/// The quote as an elegant card: big opening mark, Fraunces italic body,
/// "— Title, p. 42" in Inter. Favourite star and a menu (edit, share, delete).
class QuoteTile extends ConsumerWidget {
  const QuoteTile({required this.entry, super.key});

  final QuoteWithBook entry;

  Quote get quote => entry.quote;

  Future<void> _favourite(WidgetRef ref) => ref
      .read(quoteRepositoryProvider)
      .upsert(quote.copyWith(isFavourite: !quote.isFavourite));

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await showQuoteEditSheet(context, quote: quote);
    if (result == null) return;
    final r = await ref
        .read(editQuoteProvider)
        .call(quote, body: result.body, page: result.page);
    if (r case Err<Quote>(:final failure)) {
      KToast.showWith(
        messenger,
        failureMessage(l10n, failure),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(quoteRepositoryProvider);
    final r = await repo.softDelete(quote.id);
    if (r case Err<void>(:final failure)) {
      KToast.showWith(
        messenger,
        failureMessage(l10n, failure),
        icon: Icons.error_outline_rounded,
      );
      return;
    }
    KToast.showWith(
      messenger,
      l10n.quoteDeleted,
      icon: Icons.delete_outline_rounded,
      actionLabel: l10n.undo,
      onAction: () => repo.restore(quote.id),
    );
  }

  Future<void> _shareImage(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final png = await renderQuoteCardPng(
        QuoteCardData(
          body: quote.body,
          attribution: quoteAttributionOf(l10n, entry),
        ),
      );
      await ref
          .read(shareServiceProvider)
          .shareImage(png, name: 'kitabkhana-quote.png');
    } on Object {
      KToast.showWith(
        messenger,
        l10n.failureUnexpected,
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _shareText(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref
        .read(shareServiceProvider)
        .shareText(
          l10n.quoteShareTextBody(quote.body, quoteAttributionOf(l10n, entry)),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final attribution = quoteAttributionOf(l10n, entry);
    return KCard(
      padding: const EdgeInsets.fromLTRB(
        KSpacing.lg,
        KSpacing.sm,
        KSpacing.sm,
        KSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExcludeSemantics(
            child: Text(
              '“',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 56,
                height: 1,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: KSpacing.md),
            child: Text(
              quote.body,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Fraunces',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: KSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '— $attribution',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                tooltip: quote.isFavourite
                    ? l10n.quoteUnfavourite
                    : l10n.quoteFavourite,
                isSelected: quote.isFavourite,
                icon: const Icon(Icons.favorite_border_rounded),
                selectedIcon: Icon(Icons.favorite_rounded, color: cs.primary),
                onPressed: () => _favourite(ref),
              ),
              PopupMenuButton<String>(
                tooltip: l10n.quoteMore,
                onSelected: (v) => switch (v) {
                  'edit' => _edit(context, ref),
                  'image' => _shareImage(context, ref),
                  'text' => _shareText(context, ref),
                  _ => _delete(context, ref),
                },
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text(l10n.quoteEdit),
                  ),
                  PopupMenuItem<String>(
                    value: 'image',
                    child: Text(l10n.quoteShareImage),
                  ),
                  PopupMenuItem<String>(
                    value: 'text',
                    child: Text(l10n.quoteShareText),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(l10n.quoteDelete),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
