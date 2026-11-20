import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/add_book_providers.dart';
import '../../../app/location_providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/location.dart';
import 'location_editor_sheet.dart';
import 'location_icons.dart';
import 'location_name.dart';

/// What the picker resolved to. [id] is null for "No location".
class LocationPick {
  const LocationPick(this.id);
  final String? id;
}

/// Searchable location picker: recent first, with inline "Create new".
/// Resolves to null when dismissed.
Future<LocationPick?> showLocationPicker(
  BuildContext context, {
  String? selectedId,
  bool allowNone = true,
}) => showKBottomSheet<LocationPick>(
  context: context,
  builder: (_) => _PickerBody(selectedId: selectedId, allowNone: allowNone),
);

class _PickerBody extends ConsumerStatefulWidget {
  const _PickerBody({required this.selectedId, required this.allowNone});
  final String? selectedId;
  final bool allowNone;

  @override
  ConsumerState<_PickerBody> createState() => _PickerBodyState();
}

class _PickerBodyState extends ConsumerState<_PickerBody> {
  String _query = '';

  Future<void> _create() async {
    final saved = await showLocationEditor(context, initialName: _query.trim());
    if (saved == null || !mounted) return;
    await ref.read(recentLocationsProvider.notifier).touch(saved.id);
    if (mounted) Navigator.of(context).pop(LocationPick(saved.id));
  }

  Future<void> _pick(String? id) async {
    if (id != null) {
      await ref.read(recentLocationsProvider.notifier).touch(id);
    }
    if (mounted) Navigator.of(context).pop(LocationPick(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(locationsProvider).value ?? const <Location>[];
    final recentIds = ref.watch(recentLocationsProvider);
    final q = _query.trim().toLowerCase();
    bool matches(Location l) =>
        q.isEmpty || locationPath(l, all).toLowerCase().contains(q);

    final byId = <String, Location>{for (final l in all) l.id: l};
    final recent = <Location>[
      if (q.isEmpty)
        for (final id in recentIds)
          if (byId[id] != null) byId[id]!,
    ];
    final rest = <Location>[
      for (final l in all)
        if (matches(l) && !recent.contains(l)) l,
    ];
    final exact = all.any((l) => l.name.trim().toLowerCase() == q);

    Widget tile(Location l) => ListTile(
      leading: Icon(locationIcon(l.icon)),
      title: Text(locationPath(l, all)),
      trailing: l.id == widget.selectedId
          ? const Icon(Icons.check_rounded)
          : null,
      onTap: () => _pick(l.id),
    );

    Widget header(String text) => Padding(
      padding: const EdgeInsets.only(top: KSpacing.md, bottom: KSpacing.xs),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.locationPickerTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.md),
        KSearchField(
          hint: l10n.locationPickerSearch,
          debounce: Duration.zero,
          onChanged: (v) => setState(() => _query = v),
        ),
        if (widget.allowNone && q.isEmpty)
          ListTile(
            leading: const Icon(Icons.block_rounded),
            title: Text(l10n.noLocation),
            trailing: widget.selectedId == null
                ? const Icon(Icons.check_rounded)
                : null,
            onTap: () => _pick(null),
          ),
        if (recent.isNotEmpty) ...<Widget>[
          header(l10n.locationPickerRecent),
          for (final l in recent) tile(l),
        ],
        if (rest.isNotEmpty) ...<Widget>[
          if (recent.isNotEmpty) header(l10n.locationPickerAll),
          for (final l in rest) tile(l),
        ],
        if (!exact)
          ListTile(
            leading: const Icon(Icons.add_rounded),
            title: Text(
              q.isEmpty
                  ? l10n.locationCreateNewPlain
                  : l10n.locationCreateNew(_query.trim()),
            ),
            onTap: _create,
          ),
      ],
    );
  }
}
