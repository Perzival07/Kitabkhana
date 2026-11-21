import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/book_detail_providers.dart';
import '../../../app/library_providers.dart';
import '../../../app/providers.dart';
import '../../../app/quote_providers.dart';
import '../../../app/reading_providers.dart';
import '../../../app/repositories.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../book/application/book_progress.dart';
import '../../library/domain/book.dart';
import '../../library/domain/book_enums.dart';
import '../../library/presentation/book_cover_view.dart';
import '../../quotes/domain/quote_repository.dart';
import '../../quotes/presentation/quote_tile.dart';
import '../domain/pace.dart';
import 'update_page_flow.dart';
import '../../../app/today_provider.dart';

/// Which greeting suits the local time of day.
enum DayPart { morning, afternoon, evening }

DayPart dayPartOf(DateTime now) {
  if (now.hour < 12) return DayPart.morning;
  if (now.hour < 17) return DayPart.afternoon;
  return DayPart.evening;
}

/// `/reading`: the daily companion. Greeting and streak, the books in
/// progress, today's pages, overdue loans and what to read next.
class ReadingScreen extends ConsumerWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reading = ref.watch(currentlyReadingProvider).value;
    final upNext = ref.watch(upNextBooksProvider).value ?? const <Book>[];
    final overdue = ref.watch(overdueLoansProvider).value?.length ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: reading == null
                ? const _Loading()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      KSpacing.screen,
                      KSpacing.xl,
                      KSpacing.screen,
                      KSpacing.huge,
                    ),
                    children: <Widget>[
                      const _Header(),
                      const SizedBox(height: KSpacing.xl),
                      if (reading.isEmpty)
                        _PickNext(upNext: upNext)
                      else ...<Widget>[
                        KSectionHeader(title: l10n.readingCurrentlyReading),
                        const SizedBox(height: KSpacing.md),
                        _Carousel(books: reading),
                        const SizedBox(height: KSpacing.xl),
                        const _TodayCard(),
                      ],
                      if (ref.watch(quoteOfWeekProvider)
                          case final qow?) ...<Widget>[
                        const SizedBox(height: KSpacing.xl),
                        _QuoteOfWeekCard(entry: qow),
                      ],
                      if (overdue > 0) ...<Widget>[
                        const SizedBox(height: KSpacing.xl),
                        _OverdueCard(count: overdue),
                      ],
                      if (reading.isNotEmpty && upNext.isNotEmpty) ...<Widget>[
                        const SizedBox(height: KSpacing.xl),
                        _UpNext(books: upNext),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const SingleChildScrollView(
    // Placeholders only: they must fit any window, so let them scroll.
    physics: NeverScrollableScrollPhysics(),
    padding: EdgeInsets.all(KSpacing.screen),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        KSkeleton(height: 32, width: 200),
        SizedBox(height: KSpacing.xl),
        KSkeleton(height: 240),
      ],
    ),
  );
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    ref.watch(todayProvider); // rebuild when the day changes
    final now = ref.watch(clockProvider).now();
    final greeting = switch (dayPartOf(now)) {
      DayPart.morning => l10n.readingGreetingMorning,
      DayPart.afternoon => l10n.readingGreetingAfternoon,
      DayPart.evening => l10n.readingGreetingEvening,
    };
    final streak = ref.watch(readingStreakProvider).value;
    final days = streak?.current ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(greeting, style: theme.textTheme.headlineMedium),
        ),
        if (days > 0) ...<Widget>[
          const SizedBox(height: KSpacing.sm),
          Semantics(
            label:
                '${l10n.readingStreakDays(days)}. '
                '${l10n.readingStreakLongest(streak!.longest)}',
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KSpacing.md,
                vertical: KSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: KSpacing.xs),
                  Text(
                    l10n.readingStreakDays(days),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Carousel extends StatelessWidget {
  const _Carousel({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    // Large text leaves a swipe-sideways card too cramped: stack them.
    if (books.length == 1 || scale >= 1.4) {
      return Column(
        children: <Widget>[
          for (final b in books)
            Padding(
              padding: const EdgeInsets.only(bottom: KSpacing.md),
              child: _ReadingCard(book: b, fillHeight: false),
            ),
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, c) {
        final width = (c.maxWidth * 0.82).clamp(0.0, 340.0);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            // Tall enough for the cover, text and button.
            height: 290,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final b in books)
                  Padding(
                    padding: const EdgeInsets.only(right: KSpacing.md),
                    child: SizedBox(
                      width: width,
                      child: _ReadingCard(book: b),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReadingCard extends ConsumerWidget {
  const _ReadingCard({required this.book, this.fillHeight = true});

  final Book book;

  /// Pushes the button to the bottom of a card of fixed height.
  final bool fillHeight;

  Future<void> _finish(WidgetRef ref, Book b) async {
    final today = ref.read(clockProvider).today();
    await ref
        .read(bookRepositoryProvider)
        .update(b.id, (x) => withStatus(x, ReadStatus.finished, today));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pages = book.pages;
    final progress = book.progress;
    final percent = ((progress ?? 0) * 100).round();
    final pace = pages == null
        ? null
        : ref.watch(
            bookPaceProvider(
              book.id,
              remainingPages: pages - book.currentPage,
              startedOn: book.startedOn,
            ),
          );
    final paceText = pace == null
        ? null
        : pace.daysLeft <= paceWindowDays
        ? l10n.paceDaysLeft(pace.daysLeft)
        : l10n.paceFinishBy(
            DateFormat.MMMEd(l10n.localeName).format(pace.finishBy),
          );
    final pageText = pages == null
        ? '${l10n.detailPageLabel} ${book.currentPage}'
        : l10n.readingPageOf(book.currentPage, pages);

    return KCard(
      onTap: () => context.push(Routes.book(book.id)),
      semanticLabel: book.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BookCoverView(book: book, size: KCoverSize.md),
              const SizedBox(width: KSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (book.authors.isNotEmpty)
                      Text(
                        book.authors,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    const SizedBox(height: KSpacing.md),
                    Row(
                      children: <Widget>[
                        if (progress != null) ...<Widget>[
                          KProgressRing(
                            value: progress,
                            size: 52,
                            strokeWidth: 6,
                            semanticLabel: l10n.detailPercentRead(percent),
                            child: Text(
                              '$percent%',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                          const SizedBox(width: KSpacing.md),
                        ],
                        Expanded(
                          child: Text(
                            pageText,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    if (paceText != null) ...<Widget>[
                      const SizedBox(height: KSpacing.sm),
                      Text(paceText, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (fillHeight) const Spacer(),
          const SizedBox(height: KSpacing.md),
          KButton(
            label: l10n.detailUpdatePage,
            icon: Icons.edit_outlined,
            expand: true,
            onPressed: () => updateBookPage(
              context,
              ref,
              book,
              onMarkFinished: (b) => _finish(ref, b),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends ConsumerWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final totals = ref.watch(pagesLast7DaysProvider).value ?? List.filled(7, 0);
    final today = ref.watch(todayProvider);
    final todayPages = totals.last;
    final maxV = totals.fold<int>(1, (a, b) => b > a ? b : a);
    final sum = totals.fold<int>(0, (a, b) => a + b);

    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.readingToday, style: theme.textTheme.labelLarge),
          const SizedBox(height: KSpacing.xs),
          Text(
            l10n.readingPagesToday(todayPages),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: KSpacing.lg),
          Semantics(
            label: l10n.readingLast7Days(sum),
            excludeSemantics: true,
            child: SizedBox(
              height: 88,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              width: 14,
                              height: totals[i] == 0
                                  ? 4
                                  : 4 + 52.0 * totals[i] / maxV,
                              decoration: BoxDecoration(
                                color: i == 6
                                    ? cs.primary
                                    : totals[i] == 0
                                    ? cs.surfaceContainerHighest
                                    : cs.secondary.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: KSpacing.xs),
                          Text(
                            DateFormat.E(l10n.localeName)
                                .format(
                                  DateTime(
                                    today.year,
                                    today.month,
                                    today.day - (6 - i),
                                  ),
                                )
                                .characters
                                .first,
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// This week's featured quote; opens the Quotes screen.
class _QuoteOfWeekCard extends StatelessWidget {
  const _QuoteOfWeekCard({required this.entry});

  final QuoteWithBook entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return KCard(
      onTap: () => context.push(Routes.quotes),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.quoteOfWeekTitle, style: theme.textTheme.labelLarge),
          const SizedBox(height: KSpacing.sm),
          Text(
            '“${entry.quote.body}”',
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Fraunces',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: KSpacing.sm),
          Text(
            '— ${quoteAttributionOf(l10n, entry)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _OverdueCard extends StatelessWidget {
  const _OverdueCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return KCard(
      onTap: () => context.push(Routes.loans),
      child: Row(
        children: <Widget>[
          Icon(Icons.schedule_rounded, color: theme.colorScheme.error),
          const SizedBox(width: KSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.readingOverdueTitle(count),
                  style: theme.textTheme.titleSmall,
                ),
                Text(l10n.readingOverdueBody, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _UpNext extends ConsumerWidget {
  const _UpNext({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        KSectionHeader(
          title: l10n.readingUpNext,
          onSeeAll: () {
            ref
                .read(libraryQueryControllerProvider.notifier)
                .setStatus(ReadStatus.want);
            context.go(Routes.library);
          },
        ),
        const SizedBox(height: KSpacing.md),
        _CoverRow(books: books),
      ],
    );
  }
}

class _CoverRow extends StatelessWidget {
  const _CoverRow({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final b in books)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: KSpacing.md),
              child: Semantics(
                button: true,
                label: b.title,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.push(Routes.book(b.id)),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: BookCoverView(book: b, size: KCoverSize.sm),
                  ),
                ),
              ),
            ),
          ),
        for (var i = books.length; i < 3; i++)
          const Expanded(child: SizedBox()),
      ],
    );
  }
}

class _PickNext extends StatelessWidget {
  const _PickNext({required this.upNext});

  final List<Book> upNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (upNext.isEmpty) {
      return KEmptyState(
        illustration: KIllustration.openBook,
        title: l10n.readingPickNext,
        body: l10n.readingPickNextEmptyBody,
        actionLabel: l10n.readingAddBook,
        onAction: () => context.push(Routes.libraryAdd),
      );
    }
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.readingPickNext, style: theme.textTheme.titleLarge),
          const SizedBox(height: KSpacing.xs),
          Text(l10n.readingPickNextBody, style: theme.textTheme.bodyMedium),
          const SizedBox(height: KSpacing.lg),
          _CoverRow(books: upNext),
          const SizedBox(height: KSpacing.md),
          KButton(
            label: l10n.readingAddBook,
            icon: Icons.add_rounded,
            variant: KButtonVariant.tonal,
            expand: true,
            onPressed: () => context.push(Routes.libraryAdd),
          ),
        ],
      ),
    );
  }
}
