import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/failure_message.dart';
import '../../../app/repositories.dart';
import '../../../app/router/routes.dart';
import '../../../app/stats_providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../library/domain/book.dart';
import '../../library/presentation/book_cover_view.dart';
import '../domain/goal.dart';
import '../domain/goal_progress.dart';
import '../domain/stats.dart';
import 'goal_sheet.dart';
import '../../../app/today_provider.dart';

/// `/stats`: the reading year. Goal ring, books per month, pages per week,
/// top genres and authors, and a few library facts.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final year = ref.watch(statsYearProvider);
    final facts = ref.watch(yearFactsProvider(year)).value;
    final goal = ref.watch(yearGoalProvider(year));

    final Widget body;
    if (facts == null || goal.isLoading) {
      body = const _Loading();
    } else if (facts.totalBooks == 0 && goal.value == null) {
      body = Column(
        children: <Widget>[
          const SizedBox(height: KSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KSpacing.screen),
            child: _TitleRow(year: year),
          ),
          Expanded(
            child: KEmptyState(
              illustration: KIllustration.openBook,
              title: l10n.statsEmptyTitle,
              body: l10n.statsEmptyBody,
              actionLabel: l10n.statsEmptyAdd,
              onAction: () => context.push(Routes.libraryAdd),
            ),
          ),
        ],
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(
          KSpacing.screen,
          KSpacing.xl,
          KSpacing.screen,
          KSpacing.huge,
        ),
        children: <Widget>[
          _TitleRow(year: year),
          const SizedBox(height: KSpacing.lg),
          _GoalCard(year: year, goal: goal.value),
          const SizedBox(height: KSpacing.lg),
          _MonthlyCard(year: year),
          const SizedBox(height: KSpacing.lg),
          _WeeklyCard(year: year),
          const SizedBox(height: KSpacing.lg),
          _TopCard(
            title: l10n.statsGenresTitle,
            items: ref.watch(yearTopGenresProvider(year)).value ?? const [],
          ),
          const SizedBox(height: KSpacing.lg),
          _TopCard(
            title: l10n.statsAuthorsTitle,
            items: ref.watch(yearTopAuthorsProvider(year)).value ?? const [],
          ),
          const SizedBox(height: KSpacing.lg),
          _FactsCard(facts: facts, year: year),
        ],
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: body,
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
        KSkeleton(height: 32, width: 220),
        SizedBox(height: KSpacing.xl),
        KSkeleton(height: 180),
        SizedBox(height: KSpacing.lg),
        KSkeleton(height: 180),
      ],
    ),
  );
}

/// The screen title with the year selector.
class _TitleRow extends ConsumerWidget {
  const _TitleRow({required this.year});

  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final years = ref.watch(statsYearsProvider).value ?? <int>[year];
    final sorted = <int>{...years, year}.toList()
      ..sort((a, b) => b.compareTo(a));
    final i = sorted.indexOf(year);
    void go(int to) => ref.read(statsYearProvider.notifier).set(to);
    return Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            header: true,
            child: Text(l10n.statsTitle, style: theme.textTheme.headlineMedium),
          ),
        ),
        IconButton(
          tooltip: l10n.statsYearPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: i < sorted.length - 1 ? () => go(sorted[i + 1]) : null,
        ),
        Text('$year', style: theme.textTheme.titleMedium),
        IconButton(
          tooltip: l10n.statsYearNext,
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: i > 0 ? () => go(sorted[i - 1]) : null,
        ),
      ],
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.year, required this.goal});

  final int year;
  final Goal? goal;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final choice = await showGoalSheet(
      context,
      year: year,
      current: goal?.targetBooks,
    );
    if (choice == null) return;
    final repo = ref.read(goalRepositoryProvider);
    final r = switch (choice) {
      GoalSet(:final target) => await repo.setTarget(year, target),
      GoalRemoved() => await repo.clear(year),
    };
    if (r case Err(:final failure)) {
      KToast.showWith(
        messenger,
        failureMessage(l10n, failure),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final g = goal;
    if (g == null) {
      return KCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.statsGoalSetTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: KSpacing.xs),
            Text(
              l10n.statsGoalSetBody(year),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: KSpacing.lg),
            KButton(
              label: l10n.statsGoalCta,
              icon: Icons.flag_outlined,
              variant: KButtonVariant.tonal,
              onPressed: () => _edit(context, ref),
            ),
          ],
        ),
      );
    }
    final finished = ref.watch(yearFinishedCountProvider(year)).value ?? 0;
    final today = ref.watch(todayProvider);
    final p = goalProgress(
      year: year,
      target: g.targetBooks,
      finished: finished,
      today: today,
    );
    final status = switch (p.status) {
      GoalStatus.reached => l10n.statsGoalReached,
      GoalStatus.ahead => l10n.statsGoalAhead(p.books),
      GoalStatus.behind => l10n.statsGoalBehind(p.books),
      GoalStatus.onPace => l10n.statsGoalOnPace,
      GoalStatus.missed => l10n.statsGoalMissed(p.books),
      GoalStatus.upcoming => l10n.statsGoalUpcoming,
    };
    final summary = l10n.statsGoalOf(finished, g.targetBooks);
    return KCard(
      child: Row(
        children: <Widget>[
          KProgressRing(
            value: p.fraction,
            size: 96,
            strokeWidth: 10,
            semanticLabel:
                '$summary, ${l10n.percentSemantics((p.fraction * 100).round())}',
            child: Text('$finished', style: theme.textTheme.headlineMedium),
          ),
          const SizedBox(width: KSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.statsGoalTitle, style: theme.textTheme.labelLarge),
                Text(summary, style: theme.textTheme.titleLarge),
                const SizedBox(height: KSpacing.xs),
                Text(
                  status,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: switch (p.status) {
                      GoalStatus.reached ||
                      GoalStatus.ahead => theme.colorScheme.secondary,
                      _ => theme.colorScheme.onSurfaceVariant,
                    },
                  ),
                ),
                TextButton(
                  onPressed: () => _edit(context, ref),
                  child: Text(l10n.statsGoalEdit),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled card with a chart area, or a warm sentence when [empty].
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.empty,
    required this.emptyText,
    required this.child,
    this.caption,
  });

  final String title;
  final bool empty;
  final String emptyText;
  final String? caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: theme.textTheme.titleMedium),
          if (caption != null && !empty)
            Text(caption!, style: theme.textTheme.bodySmall),
          const SizedBox(height: KSpacing.lg),
          if (empty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: KSpacing.lg),
              child: Text(emptyText, style: theme.textTheme.bodyMedium),
            )
          else
            child,
        ],
      ),
    );
  }
}

FlGridData _grid(BuildContext context) => FlGridData(
  drawVerticalLine: false,
  horizontalInterval: null,
  getDrawingHorizontalLine: (_) => FlLine(
    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
    strokeWidth: 1,
    dashArray: const <int>[3, 4],
  ),
);

class _MonthlyCard extends ConsumerWidget {
  const _MonthlyCard({required this.year});

  final int year;

  Future<void> _openMonth(BuildContext context, int month) {
    final l10n = AppLocalizations.of(context);
    final name = DateFormat.MMMM(l10n.localeName).format(DateTime(year, month));
    return showKBottomSheet<void>(
      context: context,
      builder: (_) => _MonthBooks(year: year, month: month, title: name),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.labelSmall;
    final counts =
        ref.watch(yearFinishedPerMonthProvider(year)).value ??
        List<int>.filled(12, 0);
    final maxV = counts.fold<int>(0, (a, b) => b > a ? b : a);
    final total = counts.fold<int>(0, (a, b) => a + b);
    final locale = l10n.localeName;

    return _ChartCard(
      title: l10n.statsMonthlyTitle,
      empty: total == 0,
      emptyText: l10n.statsMonthlyEmpty,
      child: Semantics(
        label:
            '${l10n.statsMonthlyTitle}: '
            '${l10n.statsMonthBooks(total)}',
        child: SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: (maxV < 3 ? 3 : maxV + 1).toDouble(),
              alignment: BarChartAlignment.spaceAround,
              gridData: _grid(context),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: maxV < 5 ? 1 : null,
                    getTitlesWidget: (v, meta) =>
                        v == meta.max || v != v.roundToDouble()
                        ? const SizedBox.shrink()
                        : Text('${v.toInt()}', style: small),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (v, meta) => Padding(
                      padding: const EdgeInsets.only(top: KSpacing.xs),
                      child: Text(
                        DateFormat.MMM(locale)
                            .format(DateTime(year, v.toInt() + 1))
                            .characters
                            .first,
                        style: small,
                      ),
                    ),
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (_, _, _, _) => null,
                ),
                touchCallback: (event, response) {
                  final spot = response?.spot;
                  if (event is FlTapUpEvent && spot != null) {
                    final month = spot.touchedBarGroupIndex + 1;
                    if (counts[month - 1] > 0) _openMonth(context, month);
                  }
                },
              ),
              barGroups: <BarChartGroupData>[
                for (var i = 0; i < 12; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: <BarChartRodData>[
                      BarChartRodData(
                        toY: counts[i].toDouble(),
                        width: 14,
                        color: cs.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (maxV < 3 ? 3 : maxV + 1).toDouble(),
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthBooks extends ConsumerWidget {
  const _MonthBooks({
    required this.year,
    required this.month,
    required this.title,
  });

  final int year;
  final int month;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final books =
        ref.watch(booksFinishedInMonthProvider(year, month)).value ??
        const <Book>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.statsMonthSheetTitle(title),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.md),
        for (final b in books)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: BookCoverView(book: b, size: KCoverSize.xs),
            title: Text(b.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: b.authors.isEmpty ? null : Text(b.authors, maxLines: 1),
            onTap: () {
              Navigator.of(context).pop();
              context.push(Routes.book(b.id));
            },
          ),
      ],
    );
  }
}

class _WeeklyCard extends ConsumerWidget {
  const _WeeklyCard({required this.year});

  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.labelSmall;
    final weeks = ref.watch(yearPagesPerWeekProvider(year)).value ?? const [];
    final total = weeks.fold<int>(0, (a, w) => a + w.pages);
    final maxV = weeks.fold<int>(0, (a, w) => w.pages > a ? w.pages : a);
    final locale = l10n.localeName;
    final top = (maxV < 10 ? 10 : maxV * 1.2).toDouble();

    return _ChartCard(
      title: l10n.statsWeeklyTitle,
      caption: l10n.statsWeeklyTotal(total),
      empty: total == 0,
      emptyText: l10n.statsWeeklyEmpty,
      child: Semantics(
        label: '${l10n.statsWeeklyTitle}: ${l10n.statsWeeklyTotal(total)}',
        child: Padding(
          // Room for the first and last date labels.
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.lg),
          child: SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: top,
                minX: 0,
                maxX: (weeks.length - 1).toDouble(),
                gridData: _grid(context),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (v != i.toDouble() ||
                            i % 4 != 0 && i != weeks.length - 1) {
                          return const SizedBox.shrink();
                        }
                        if (i != weeks.length - 1 && weeks.length - 1 - i < 3) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: KSpacing.xs),
                          child: Text(
                            DateFormat.MMMd(locale).format(weeks[i].start),
                            style: small,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: <LineChartBarData>[
                  LineChartBarData(
                    spots: <FlSpot>[
                      for (var i = 0; i < weeks.length; i++)
                        FlSpot(i.toDouble(), weeks[i].pages.toDouble()),
                    ],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    barWidth: 3,
                    color: cs.secondary,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          cs.secondary.withValues(alpha: 0.28),
                          cs.secondary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  const _TopCard({required this.title, required this.items});

  final String title;
  final List<LabelCount> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final maxV = items.fold<int>(1, (a, i) => i.count > a ? i.count : a);
    return _ChartCard(
      title: title,
      empty: items.isEmpty,
      emptyText: l10n.statsTopEmpty,
      child: Column(
        children: <Widget>[
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: KSpacing.md),
              child: Semantics(
                label: '${item.label}: ${item.count}',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '${item.count}',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: KSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: item.count / maxV,
                        minHeight: 8,
                        backgroundColor: theme
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.6),
                        color: theme.colorScheme.primary,
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

class _FactsCard extends StatelessWidget {
  const _FactsCard({required this.facts, required this.year});

  final LibraryFacts facts;
  final int year;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rating = facts.averageRating;
    final longest = facts.longest;
    final tiles = <(String, String, String?)>[
      (l10n.statsFactTotal, '${facts.totalBooks}', null),
      (l10n.statsFactOwned, '${facts.owned}', null),
      (l10n.statsFactWishlist, '${facts.wishlist}', null),
      (l10n.statsFactLent, '${facts.lentOut}', null),
      (
        l10n.statsFactRating,
        rating == null ? '–' : rating.toStringAsFixed(1),
        null,
      ),
      (
        l10n.statsFactLongest,
        longest == null ? '–' : l10n.statsFactPages(longest.pages),
        longest?.title,
      ),
    ];
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.statsFactsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: KSpacing.lg),
          LayoutBuilder(
            builder: (context, c) {
              final w = (c.maxWidth - KSpacing.lg) / 2;
              return Wrap(
                spacing: KSpacing.lg,
                runSpacing: KSpacing.lg,
                children: <Widget>[
                  for (final t in tiles)
                    SizedBox(
                      width: w,
                      child: _Fact(label: t.$1, value: t.$2, note: t.$3),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.note});

  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label: $value${note == null ? '' : ', $note'}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: theme.textTheme.headlineSmall),
          Text(label, style: theme.textTheme.bodySmall),
          if (note != null)
            Text(
              note!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
