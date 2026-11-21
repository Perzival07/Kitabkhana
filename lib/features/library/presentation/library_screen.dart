import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/add_book_providers.dart';
import '../../../app/app_config_provider.dart';
import '../../../app/library_providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/settings_providers.dart';
import '../../../app/shell/adaptive_scaffold.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../settings/domain/app_settings.dart' show GridDensity;
import '../application/library_query.dart';
import '../../locations/domain/location.dart';
import '../domain/book.dart';
import '../domain/book_filter.dart';
import '../../reminders/presentation/overdue_banner.dart';
import 'widgets/book_tiles.dart';
import 'widgets/library_filter_bar.dart';
import 'widgets/quick_actions_sheet.dart';

/// The home of the app: your books as a calm grid or list, with search,
/// filters and sorting.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();
  bool _atTop = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // Restore the search text if the tab was rebuilt with a live query.
    _search.text = ref.read(libraryQueryControllerProvider).filter.query;
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    final atTop = _scroll.offset < 48;
    if (atTop != _atTop) setState(() => _atTop = atTop);
    if (_scroll.position.extentAfter > 900) return;
    final books = ref.read(libraryBooksProvider);
    final count = ref.read(libraryMatchCountProvider).value;
    final pages = ref.read(libraryPagesProvider);
    final loaded = books.value;
    if (books.isLoading || loaded == null || count == null) return;
    if (loaded.length >= pages * kLibraryPageSize && loaded.length < count) {
      ref.read(libraryPagesProvider.notifier).loadMore();
    }
  }

  void _clearAll() {
    _search.clear();
    ref.read(libraryQueryControllerProvider.notifier).clearFilters();
  }

  Future<void> _seed() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final added = await ref.read(demoSeederProvider).seed();
    KToast.showWith(messenger, l10n.seedDemoDone(added));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(libraryQueryControllerProvider);
    final view = ref.watch(libraryViewControllerProvider);
    final isDev = ref.watch(appConfigProvider).isDev;
    // The empty state already offers "Add your first book".
    final shelfEmpty =
        ref.watch(libraryTotalCountProvider).value == 0 && query.filter.isEmpty;

    return Scaffold(
      floatingActionButton: shelfEmpty
          ? null
          : _Fab(
              extended: _atTop,
              label: l10n.addBook,
              onPressed: () => context.push(Routes.libraryAdd),
            ),
      body: CustomScrollView(
        key: const PageStorageKey<String>('library-scroll'),
        controller: _scroll,
        slivers: <Widget>[
          SliverAppBar.large(
            title: Text(l10n.libraryTitle),
            actions: <Widget>[
              if (isDev)
                IconButton(
                  icon: const Icon(Icons.science_outlined),
                  tooltip: l10n.seedDemoData,
                  onPressed: _seed,
                ),
              IconButton(
                icon: Icon(
                  view == LibraryView.grid
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                ),
                tooltip: view == LibraryView.grid
                    ? l10n.viewAsList
                    : l10n.viewAsGrid,
                onPressed: () => ref
                    .read(libraryViewControllerProvider.notifier)
                    .set(
                      view == LibraryView.grid
                          ? LibraryView.list
                          : LibraryView.grid,
                    ),
              ),
              _SortMenu(current: query.sort),
              const SizedBox(width: KSpacing.xs),
            ],
          ),
          const SliverToBoxAdapter(child: _CountLine()),
          const SliverToBoxAdapter(child: OverdueBanner()),
          SliverAppBar(
            primary: false,
            pinned: true,
            automaticallyImplyLeading: false,
            toolbarHeight: 64,
            titleSpacing: KSpacing.screen,
            title: KSearchField(
              controller: _search,
              hint: l10n.librarySearchHint,
              onChanged: (text) => ref
                  .read(libraryQueryControllerProvider.notifier)
                  .setText(text),
              onScanTap: () => context.go(Routes.scan),
              scanTooltip: l10n.libraryScanTooltip,
            ),
          ),
          const SliverToBoxAdapter(child: LibraryFilterBar()),
          const SliverToBoxAdapter(child: SizedBox(height: KSpacing.md)),
          ..._content(context, query, view),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    LibraryQuery query,
    LibraryView view,
  ) {
    final l10n = AppLocalizations.of(context);
    final books = ref.watch(libraryBooksProvider);
    final total = ref.watch(libraryTotalCountProvider).value;
    final matches = ref.watch(libraryMatchCountProvider).value;
    final lentIds = ref.watch(lentBookIdsProvider).value ?? const <String>{};
    final locations = <String, String>{
      for (final l in ref.watch(locationsProvider).value ?? const <Location>[])
        l.id: l.name,
    };

    final loaded = books.value;
    if (loaded == null) {
      if (books.hasError) {
        return <Widget>[
          SliverFillRemaining(
            hasScrollBody: true,
            child: KEmptyState(
              illustration: KIllustration.emptyShelf,
              title: l10n.libraryLoadFailed,
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(libraryBooksProvider),
            ),
          ),
        ];
      }
      return <Widget>[_skeletons(view)];
    }

    if (loaded.isEmpty) {
      final nothingYet = total == 0 && query.filter.isEmpty;
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: true,
          child: nothingYet
              ? KEmptyState(
                  illustration: KIllustration.emptyShelf,
                  title: l10n.libraryEmptyTitle,
                  body: l10n.libraryEmptyBody,
                  actionLabel: l10n.libraryAddFirst,
                  onAction: () => context.push(Routes.libraryAdd),
                  secondaryLabel: l10n.libraryScanBarcode,
                  onSecondary: () => context.go(Routes.scan),
                )
              : KEmptyState(
                  illustration: KIllustration.emptyShelf,
                  title: query.filter.query.trim().isEmpty
                      ? l10n.libraryNoResultsFilters
                      : l10n.libraryNoResultsQuery(query.filter.query.trim()),
                  actionLabel: l10n.libraryClearFilters,
                  onAction: _clearAll,
                ),
        ),
      ];
    }

    final hasMore = matches != null && loaded.length < matches;
    final text = query.filter.query;
    void open(Book b) {
      // In the shell's two-pane layout the book opens beside the list.
      final size = MediaQuery.sizeOf(context);
      final twoPane =
          shellLayoutFor(size.width, height: size.height) ==
          ShellLayout.expanded;
      if (twoPane) {
        ref.read(selectedBookIdProvider.notifier).select(b.id);
      } else {
        context.push(Routes.book(b.id));
      }
    }

    void actions(Book b) => showQuickActions(context, ref, b);
    final compact =
        ref.watch(appSettingsProvider).gridDensity == GridDensity.compact;

    // The first time books appear, they cascade in; never again this run.
    final entering = !ref.watch(libraryEntrancePlayedProvider);
    if (entering) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(libraryEntrancePlayedProvider.notifier).markPlayed();
        }
      });
    }

    if (view == LibraryView.list) {
      final count = loaded.length + (hasMore ? 3 : 0);
      return <Widget>[
        SliverList.builder(
          itemCount: count,
          itemBuilder: (context, i) {
            if (i >= loaded.length) return const BookListTileSkeleton();
            final b = loaded[i];
            return KEnter(
              key: ValueKey<String>(b.id),
              index: i,
              play: entering && i < 14,
              child: BookListTile(
                key: ValueKey<String>(b.id),
                book: b,
                lent: lentIds.contains(b.id),
                query: text,
                locationName: locations[b.locationId],
                onTap: () => open(b),
                onLongPress: () => actions(b),
              ),
            );
          },
        ),
      ];
    }

    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: KSpacing.screen),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent + KSpacing.screen * 2;
            final cols = libraryColumns(width, compact: compact);
            const gap = KSpacing.md;
            final cell =
                (constraints.crossAxisExtent - gap * (cols - 1)) / cols;
            return SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: gap,
                mainAxisSpacing: KSpacing.lg,
                mainAxisExtent: cell * 1.5 + gridTextHeight(context),
              ),
              itemCount: loaded.length + (hasMore ? cols : 0),
              itemBuilder: (context, i) {
                if (i >= loaded.length) return const KBookTileSkeleton();
                final b = loaded[i];
                return KEnter(
                  key: ValueKey<String>(b.id),
                  index: i,
                  play: entering && i < 14,
                  child: BookGridTile(
                    key: ValueKey<String>(b.id),
                    book: b,
                    lent: lentIds.contains(b.id),
                    query: text,
                    onTap: () => open(b),
                    onLongPress: () => actions(b),
                  ),
                );
              },
            );
          },
        ),
      ),
    ];
  }

  Widget _skeletons(LibraryView view) {
    final compact =
        ref.watch(appSettingsProvider).gridDensity == GridDensity.compact;
    if (view == LibraryView.list) {
      return SliverList.builder(
        itemCount: 6,
        itemBuilder: (_, _) => const BookListTileSkeleton(),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: KSpacing.screen),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final cols = libraryColumns(
            constraints.crossAxisExtent + KSpacing.screen * 2,
            compact: compact,
          );
          const gap = KSpacing.md;
          final cell = (constraints.crossAxisExtent - gap * (cols - 1)) / cols;
          return SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: gap,
              mainAxisSpacing: KSpacing.lg,
              mainAxisExtent: cell * 1.5 + gridTextHeight(context),
            ),
            itemCount: cols * 3,
            itemBuilder: (_, _) => const KBookTileSkeleton(),
          );
        },
      ),
    );
  }
}

/// "128 books · 6 lent out".
class _CountLine extends ConsumerWidget {
  const _CountLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final total = ref.watch(libraryTotalCountProvider).value;
    final lent = ref.watch(libraryLentCountProvider).value ?? 0;
    final text = total == null
        ? ''
        : <String>[
            l10n.libraryBooksCount(total),
            if (lent > 0) l10n.libraryLentOutCount(lent),
          ].join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KSpacing.screen,
        0,
        KSpacing.screen,
        KSpacing.sm,
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _SortMenu extends ConsumerWidget {
  const _SortMenu({required this.current});

  final BookSort current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    String label(BookSort s) => switch (s) {
      BookSort.recentlyAdded => l10n.sortRecentlyAdded,
      BookSort.title => l10n.sortTitle,
      BookSort.author => l10n.sortAuthor,
      BookSort.recentlyRead => l10n.sortRecentlyRead,
      BookSort.rating => l10n.sortRating,
    };
    return PopupMenuButton<BookSort>(
      tooltip: l10n.sortTooltip,
      icon: const Icon(Icons.sort_rounded),
      initialValue: current,
      onSelected: ref.read(libraryQueryControllerProvider.notifier).setSort,
      itemBuilder: (_) => <PopupMenuEntry<BookSort>>[
        for (final s in BookSort.values)
          CheckedPopupMenuItem<BookSort>(
            value: s,
            checked: s == current,
            child: Text(label(s)),
          ),
      ],
    );
  }
}

/// Extended while the list is at the top; shrinks to an icon once scrolled.
class _Fab extends StatelessWidget {
  const _Fab({
    required this.extended,
    required this.label,
    required this.onPressed,
  });

  final bool extended;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return AnimatedSize(
      duration: reduce ? Duration.zero : KDurations.normal,
      curve: KCurves.standard,
      alignment: Alignment.centerRight,
      child: extended
          ? FloatingActionButton.extended(
              heroTag: 'library-add',
              onPressed: onPressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(label),
            )
          : FloatingActionButton(
              heroTag: 'library-add',
              tooltip: label,
              onPressed: onPressed,
              child: const Icon(Icons.add_rounded),
            ),
    );
  }
}
