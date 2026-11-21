import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/book/presentation/book_detail_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../theme/tokens.dart';
import '../library_providers.dart';

/// Tab layout kinds by window width.
enum ShellLayout { compact, medium, expanded }

/// A navigation rail needs room for its five destinations; windows shorter
/// than this (a phone on its side, a split-screen strip) use the bottom bar
/// whatever their width.
const double kMinRailHeight = 500;

/// The shell layout for a window of [width] (and [height], when known).
ShellLayout shellLayoutFor(double width, {double? height}) {
  if (height != null && height < kMinRailHeight) return ShellLayout.compact;
  if (width < KBreakpoints.compact) return ShellLayout.compact;
  if (width <= KBreakpoints.expanded) return ShellLayout.medium;
  return ShellLayout.expanded;
}

/// Index of the Scan tab, which is visually emphasised.
const int kScanTabIndex = 1;

/// Width of the list pane in the expanded two-pane layout.
const double kListPaneWidth = 400;

/// Widest content on non-list tabs in wide layouts.
const double kMaxContentWidth = 720;

/// The app shell: bottom bar on phones, rail on tablets, extended rail plus a
/// two-pane list/detail layout on large screens.
class AdaptiveScaffold extends ConsumerWidget {
  const AdaptiveScaffold({
    required this.navigationShell,
    this.detail,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  /// Detail pane content in the expanded layout; a calm placeholder if null.
  final Widget? detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = navigationShell.currentIndex;
    return PopScope(
      // Back on a non-first tab returns to the first tab before leaving.
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: DisplayFeatureSubScreen(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final layout = shellLayoutFor(
              constraints.maxWidth,
              height: constraints.maxHeight,
            );
            return switch (layout) {
              ShellLayout.compact => _compact(context, index),
              ShellLayout.medium => _rail(context, index, extended: false),
              ShellLayout.expanded => _rail(context, index, extended: true),
            };
          },
        ),
      ),
    );
  }

  void _select(int i) => navigationShell.goBranch(
    i,
    initialLocation: i == navigationShell.currentIndex,
  );

  List<(String, IconData, IconData)> _tabs(
    AppLocalizations l10n,
  ) => <(String, IconData, IconData)>[
    (
      l10n.navLibrary,
      Icons.collections_bookmark_outlined,
      Icons.collections_bookmark_rounded,
    ),
    (
      l10n.navScan,
      Icons.qr_code_scanner_rounded,
      Icons.qr_code_scanner_rounded,
    ),
    (l10n.navReading, Icons.auto_stories_outlined, Icons.auto_stories_rounded),
    (l10n.navStats, Icons.bar_chart_outlined, Icons.bar_chart_rounded),
    (l10n.navMore, Icons.more_horiz_rounded, Icons.more_horiz_rounded),
  ];

  Widget _icon(
    BuildContext context,
    int i,
    IconData data, {
    required bool selected,
  }) {
    if (i != kScanTabIndex) return Icon(data);
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(KRadii.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSpacing.xs),
        child: Icon(data, color: cs.onPrimary, size: 22),
      ),
    );
  }

  Widget _compact(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context);
    final tabs = _tabs(l10n);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _select,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: <Widget>[
          for (var i = 0; i < tabs.length; i++)
            NavigationDestination(
              icon: _icon(context, i, tabs[i].$2, selected: false),
              selectedIcon: _icon(context, i, tabs[i].$3, selected: true),
              label: tabs[i].$1,
            ),
        ],
      ),
    );
  }

  Widget _rail(BuildContext context, int index, {required bool extended}) {
    final l10n = AppLocalizations.of(context);
    final tabs = _tabs(l10n);
    final twoPane = extended && index == 0;
    final Widget body = twoPane
        ? Row(
            children: <Widget>[
              SizedBox(width: kListPaneWidth, child: navigationShell),
              const VerticalDivider(),
              Expanded(child: detail ?? const _SelectedBookPane()),
            ],
          )
        : Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: navigationShell,
            ),
          );
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: <Widget>[
            NavigationRail(
              extended: extended,
              selectedIndex: index,
              onDestinationSelected: _select,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              minExtendedWidth: 200,
              leading: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: KSpacing.lg,
                  horizontal: KSpacing.sm,
                ),
                child: KWordmark(showGlyph: extended, size: extended ? 22 : 16),
              ),
              destinations: <NavigationRailDestination>[
                for (var i = 0; i < tabs.length; i++)
                  NavigationRailDestination(
                    icon: _icon(context, i, tabs[i].$2, selected: false),
                    selectedIcon: _icon(context, i, tabs[i].$3, selected: true),
                    label: Text(tabs[i].$1),
                  ),
              ],
            ),
            const VerticalDivider(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KEmptyState(
      illustration: KIllustration.openBook,
      title: l10n.detailPlaceholderTitle,
      body: l10n.detailPlaceholderBody,
    );
  }
}

/// The book chosen in the list, or a calm placeholder.
class _SelectedBookPane extends ConsumerWidget {
  const _SelectedBookPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(selectedBookIdProvider);
    if (id == null) return const _DetailPlaceholder();
    return BookDetailScreen(
      key: ValueKey<String>(id),
      bookId: id,
      embedded: true,
      onClosed: () => ref.read(selectedBookIdProvider.notifier).select(null),
    );
  }
}
