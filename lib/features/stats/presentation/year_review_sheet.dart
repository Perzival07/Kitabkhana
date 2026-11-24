import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/quote_providers.dart';
import '../../../app/stats_providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/year_review.dart';
import 'year_review_card.dart';

/// The card's words for [r] in the reader's language.
YearReviewCardData yearReviewCardData(AppLocalizations l10n, YearReview r) {
  final number = NumberFormat.decimalPattern(l10n.localeName);
  final narrow = DateFormat('MMMMM', l10n.localeName);
  return YearReviewCardData(
    title: l10n.yearReviewTitle('${r.year}'),
    bigNumber: number.format(r.booksFinished),
    bigLabel: l10n.yearReviewBooks(r.booksFinished),
    figures: <(String, String)>[
      (number.format(r.pagesRead), l10n.yearReviewPages),
      (number.format(r.longestStreak), l10n.yearReviewStreak),
      if (r.goalTarget != null)
        (
          '${number.format(r.booksFinished)}/${number.format(r.goalTarget)}',
          l10n.yearReviewGoal,
        ),
    ],
    monthInitials: <String>[
      for (var m = 1; m <= 12; m++) narrow.format(DateTime(r.year, m)),
    ],
    perMonth: r.perMonth,
    lines: <(String, String)>[
      if (r.topGenre != null) (l10n.yearReviewTopGenre, r.topGenre!),
      if (r.topAuthor != null) (l10n.yearReviewTopAuthor, r.topAuthor!),
      if (r.longest != null)
        (
          l10n.yearReviewLongest,
          l10n.yearReviewLongestValue(r.longest!.title, r.longest!.pages),
        ),
    ],
    footer: l10n.yearReviewFooter,
  );
}

/// Shows the year's card with a Share button.
Future<void> showYearReview(BuildContext context, int year) => showDialog<void>(
  context: context,
  builder: (_) => _YearReviewDialog(year: year),
);

class _YearReviewDialog extends ConsumerStatefulWidget {
  const _YearReviewDialog({required this.year});

  final int year;

  @override
  ConsumerState<_YearReviewDialog> createState() => _YearReviewDialogState();
}

class _YearReviewDialogState extends ConsumerState<_YearReviewDialog> {
  bool _sharing = false;

  Future<void> _share(YearReviewCardData data) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sharing = true);
    try {
      final png = await renderYearReviewPng(data);
      await ref
          .read(shareServiceProvider)
          .shareImage(png, name: 'kitabkhana-${widget.year}.png');
    } on Object {
      KToast.showWith(
        messenger,
        l10n.failureUnexpected,
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final review = ref.watch(yearReviewProvider(widget.year));
    return Dialog(
      insetPadding: const EdgeInsets.all(KSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(KSpacing.lg),
          child: switch (review) {
            AsyncData(:final value) when value.isEmpty => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(l10n.yearReviewEmpty, textAlign: TextAlign.center),
                const SizedBox(height: KSpacing.lg),
                KButton(
                  label: l10n.close,
                  expand: true,
                  variant: KButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            AsyncData(:final value) => _Preview(
              data: yearReviewCardData(l10n, value),
              sharing: _sharing,
              onShare: _share,
            ),
            AsyncError() => Text(l10n.failureUnexpected),
            _ => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          },
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.data,
    required this.sharing,
    required this.onShare,
  });

  final YearReviewCardData data;
  final bool sharing;
  final Future<void> Function(YearReviewCardData) onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(KRadii.card),
            child: Semantics(
              label: '${data.title}. ${data.bigNumber} ${data.bigLabel}.',
              child: YearReviewCard(data: data),
            ),
          ),
        ),
        const SizedBox(height: KSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(
              child: KButton(
                label: l10n.close,
                variant: KButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: KButton(
                label: l10n.yearReviewShare,
                icon: Icons.ios_share_rounded,
                loading: sharing,
                onPressed: sharing ? null : () => onShare(data),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
