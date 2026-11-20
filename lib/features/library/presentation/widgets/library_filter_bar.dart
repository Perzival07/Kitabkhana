import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/add_book_providers.dart';
import '../../../../app/library_providers.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../domain/book_enums.dart';

/// Horizontal filter chips: status, wishlist, lent, borrowed, then Location
/// and Tag menus. Status chips are exclusive; the rest combine.
class LibraryFilterBar extends ConsumerWidget {
  const LibraryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(libraryQueryControllerProvider).filter;
    final controller = ref.read(libraryQueryControllerProvider.notifier);
    final locations = ref.watch(locationsProvider).value ?? const [];
    final tags = ref.watch(libraryTagsProvider).value ?? const [];

    final noStatusFilters =
        filter.status == null &&
        filter.ownership == null &&
        !filter.lentOut &&
        !filter.borrowed;

    Widget chip(String label, bool selected, VoidCallback onTap) => KFilterChip(
      label: label,
      selected: selected,
      onSelected: (_) => onTap(),
    );

    String? locationName;
    for (final l in locations) {
      if (l.id == filter.locationId) locationName = l.name;
    }
    String? tagName;
    for (final t in tags) {
      if (t.id == filter.tagId) tagName = t.name;
    }

    final items = <Widget>[
      chip(l10n.filterAll, noStatusFilters, controller.showAll),
      chip(
        l10n.statusReading,
        filter.status == ReadStatus.reading,
        () => controller.setStatus(
          filter.status == ReadStatus.reading ? null : ReadStatus.reading,
        ),
      ),
      chip(
        l10n.statusWant,
        filter.status == ReadStatus.want,
        () => controller.setStatus(
          filter.status == ReadStatus.want ? null : ReadStatus.want,
        ),
      ),
      chip(
        l10n.statusFinished,
        filter.status == ReadStatus.finished,
        () => controller.setStatus(
          filter.status == ReadStatus.finished ? null : ReadStatus.finished,
        ),
      ),
      chip(
        l10n.filterWishlist,
        filter.ownership == Ownership.wishlist,
        controller.toggleWishlist,
      ),
      chip(l10n.filterLentOut, filter.lentOut, controller.toggleLentOut),
      chip(l10n.filterBorrowed, filter.borrowed, controller.toggleBorrowed),
      _MenuChip(
        label: locationName ?? l10n.filterLocation,
        selected: filter.locationId != null,
        anyLabel: l10n.filterAnyLocation,
        options: <(String, String)>[for (final l in locations) (l.id, l.name)],
        selectedId: filter.locationId,
        onPick: controller.setLocation,
      ),
      _MenuChip(
        label: tagName ?? l10n.filterTag,
        selected: filter.tagId != null,
        anyLabel: l10n.filterAnyTag,
        emptyLabel: l10n.filterNoTags,
        options: <(String, String)>[for (final t in tags) (t.id, t.name)],
        selectedId: filter.tagId,
        onPick: controller.setTag,
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: KSpacing.screen),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: KSpacing.sm),
        itemBuilder: (_, i) => Center(child: items[i]),
      ),
    );
  }
}

/// A chip that opens a menu of choices (a location or a tag).
class _MenuChip extends StatelessWidget {
  const _MenuChip({
    required this.label,
    required this.selected,
    required this.anyLabel,
    required this.options,
    required this.selectedId,
    required this.onPick,
    this.emptyLabel,
  });

  final String label;
  final bool selected;
  final String anyLabel;
  final String? emptyLabel;
  final List<(String, String)> options;
  final String? selectedId;
  final ValueChanged<String?> onPick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MenuAnchor(
      menuChildren: <Widget>[
        MenuItemButton(
          onPressed: () => onPick(null),
          leadingIcon: selectedId == null
              ? const Icon(Icons.check_rounded)
              : const SizedBox(width: 24),
          child: Text(anyLabel),
        ),
        if (options.isEmpty && emptyLabel != null)
          MenuItemButton(onPressed: null, child: Text(emptyLabel!)),
        for (final (id, name) in options)
          MenuItemButton(
            onPressed: () => onPick(id),
            leadingIcon: selectedId == id
                ? const Icon(Icons.check_rounded)
                : const SizedBox(width: 24),
            child: Text(name),
          ),
      ],
      builder: (context, menu, _) => ActionChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(label),
            const Icon(Icons.arrow_drop_down_rounded, size: 20),
          ],
        ),
        avatar: selected
            ? Icon(Icons.check_rounded, size: 18, color: cs.onPrimaryContainer)
            : null,
        side: BorderSide(color: selected ? cs.primary : cs.outlineVariant),
        backgroundColor: selected ? cs.primaryContainer : null,
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      ),
    );
  }
}
