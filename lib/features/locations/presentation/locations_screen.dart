import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/add_book_providers.dart';
import '../../../app/l10n/failure_message.dart';
import '../../../app/library_providers.dart';
import '../../../app/location_providers.dart';
import '../../../app/repositories.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/result.dart';
import '../../../core/uuid.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/location.dart';
import 'location_editor_sheet.dart';
import 'location_icons.dart';
import 'location_name.dart';
import 'location_picker.dart';

/// Manage locations: list with live book counts, drag to reorder, add,
/// rename, delete with reassignment. Tapping one opens the filtered library.
class LocationsScreen extends ConsumerStatefulWidget {
  const LocationsScreen({super.key});

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> {
  /// Order shown while a reorder is being saved.
  List<String>? _pendingOrder;

  void _toast(String message, {bool error = false}) => KToast.showWith(
    ScaffoldMessenger.of(context),
    message,
    icon: error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
  );

  Future<void> _reorder(List<Location> items, int from, int to) async {
    final ids = <String>[for (final l in items) l.id];
    ids.insert(to, ids.removeAt(from));
    setState(() => _pendingOrder = ids);
    final r = await ref.read(locationRepositoryProvider).reorder(ids);
    if (!mounted) return;
    setState(() => _pendingOrder = null);
    if (r is Err<void>) {
      _toast(
        failureMessage(AppLocalizations.of(context), r.failure),
        error: true,
      );
    }
  }

  Future<void> _delete(Location loc, int count) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(locationRepositoryProvider);
    String? moveTo;
    if (count == 0) {
      final ok = await showKConfirmDialog(
        context: context,
        title: l10n.locationDeleteTitle(loc.name),
        message: l10n.locationDeleteEmpty,
        confirmLabel: l10n.locationDelete,
        cancelLabel: l10n.cancel,
        destructive: true,
      );
      if (!ok) return;
    } else {
      final pick = await showKBottomSheet<LocationPick>(
        context: context,
        builder: (_) => _MoveBooksBody(loc: loc, count: count),
      );
      if (pick == null) return;
      moveTo = pick.id;
    }
    final r = await repo.softDelete(loc.id, moveBooksTo: moveTo);
    if (!mounted) return;
    switch (r) {
      case Ok():
        ref.invalidate(libraryBooksProvider);
        _toast(l10n.locationDeleted);
      case Err(:final failure):
        _toast(failureMessage(l10n, failure), error: true);
    }
  }

  Future<void> _addStarters() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(locationRepositoryProvider);
    final names = <(String, String)>[
      (l10n.starterLivingRoom, 'shelf'),
      (l10n.starterBedroom, 'shelf'),
      (l10n.starterStorage, 'box'),
    ];
    for (var i = 0; i < names.length; i++) {
      await repo.upsert(
        Location.create(
          id: uuidV7(),
          name: names[i].$1,
          now: DateTime.now(),
          sortOrder: i,
          icon: names[i].$2,
        ),
      );
    }
    await ref.read(starterLocationsDoneProvider.notifier).markDone();
  }

  void _open(Location loc) {
    ref.read(libraryQueryControllerProvider.notifier)
      ..clearFilters()
      ..setLocation(loc.id);
    context.go(Routes.library);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locations = ref.watch(locationsProvider);
    final counts = ref.watch(locationBookCountsProvider).value ?? const {};
    final starterDone = ref.watch(starterLocationsDoneProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.locationsTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.locationAdd,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => showLocationEditor(context),
          ),
        ],
      ),
      body: locations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.libraryLoadFailed)),
        data: (list) {
          if (list.isEmpty) {
            return KEmptyState(
              illustration: KIllustration.emptyShelf,
              title: starterDone
                  ? l10n.locationsEmptyTitle
                  : l10n.locationsStarterTitle,
              body: starterDone
                  ? l10n.locationsEmptyBody
                  : '${l10n.starterLivingRoom} · ${l10n.starterBedroom} · '
                        '${l10n.starterStorage}',
              actionLabel: starterDone
                  ? l10n.locationAdd
                  : l10n.locationsStarterAccept,
              onAction: starterDone
                  ? () => showLocationEditor(context)
                  : _addStarters,
              secondaryLabel: starterDone ? null : l10n.locationsStarterSkip,
              onSecondary: starterDone
                  ? null
                  : () => ref
                        .read(starterLocationsDoneProvider.notifier)
                        .markDone(),
            );
          }
          final byId = <String, Location>{for (final l in list) l.id: l};
          final order = _pendingOrder;
          final items = order == null || order.length != list.length
              ? list
              : <Location>[
                  for (final id in order)
                    if (byId[id] != null) byId[id]!,
                ];
          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.only(bottom: KSpacing.xxl),
            itemCount: items.length,
            onReorderItem: (a, b) => _reorder(items, a, b),
            itemBuilder: (context, i) {
              final loc = items[i];
              final count = counts[loc.id] ?? 0;
              return ListTile(
                key: ValueKey<String>(loc.id),
                leading: Icon(locationIcon(loc.icon)),
                title: Text(locationPath(loc, list)),
                subtitle: Text(l10n.locationsBookCount(count)),
                onTap: () => _open(loc),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    PopupMenuButton<String>(
                      tooltip: l10n.locationEdit,
                      onSelected: (v) {
                        if (v == 'edit') {
                          showLocationEditor(context, existing: loc);
                        } else {
                          _delete(loc, count);
                        }
                      },
                      itemBuilder: (_) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(l10n.locationRename),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(l10n.locationDelete),
                        ),
                      ],
                    ),
                    ReorderableDragStartListener(
                      index: i,
                      child: Tooltip(
                        message: l10n.locationReorderHint,
                        child: const Padding(
                          padding: EdgeInsets.all(KSpacing.sm),
                          child: Icon(Icons.drag_handle_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MoveBooksBody extends ConsumerWidget {
  const _MoveBooksBody({required this.loc, required this.count});
  final Location loc;
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final others = <Location>[
      for (final l in ref.watch(locationsProvider).value ?? const <Location>[])
        if (l.id != loc.id) l,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.locationMoveBooksTitle(count),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.sm),
        ListTile(
          leading: const Icon(Icons.block_rounded),
          title: Text(l10n.noLocation),
          onTap: () => Navigator.of(context).pop(const LocationPick(null)),
        ),
        for (final l in others)
          ListTile(
            leading: Icon(locationIcon(l.icon)),
            title: Text(locationPath(l, others)),
            onTap: () => Navigator.of(context).pop(LocationPick(l.id)),
          ),
      ],
    );
  }
}
