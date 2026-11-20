import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/add_book_providers.dart';
import '../../../app/l10n/failure_message.dart';
import '../../../app/repositories.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../core/uuid.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/location.dart';
import 'location_icons.dart';

/// Add or rename a location (name, icon and optional parent). Resolves to the
/// saved location, or null when dismissed.
Future<Location?> showLocationEditor(
  BuildContext context, {
  Location? existing,
  String initialName = '',
}) => showKBottomSheet<Location>(
  context: context,
  builder: (_) => _EditorBody(existing: existing, initialName: initialName),
);

class _EditorBody extends ConsumerStatefulWidget {
  const _EditorBody({required this.existing, required this.initialName});
  final Location? existing;
  final String initialName;

  @override
  ConsumerState<_EditorBody> createState() => _EditorBodyState();
}

class _EditorBodyState extends ConsumerState<_EditorBody> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? widget.initialName,
  );
  late String _icon = widget.existing?.icon ?? 'shelf';
  late String? _parentId = widget.existing?.parentId;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.locationNameEmpty);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(locationRepositoryProvider);
    final all = ref.read(locationsProvider).value ?? const <Location>[];
    final Location toSave;
    final existing = widget.existing;
    if (existing == null) {
      final next = all.isEmpty
          ? 0
          : all.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
      toSave = Location.create(
        id: uuidV7(),
        name: name,
        now: DateTime.now(),
        parentId: _parentId,
        sortOrder: next,
        icon: _icon,
      );
    } else {
      toSave = existing.copyWith(name: name, icon: _icon, parentId: _parentId);
    }
    final r = await repo.upsert(toSave);
    if (!mounted) return;
    switch (r) {
      case Ok(:final value):
        Navigator.of(context).pop(value);
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure is ConflictFailure
              ? l10n.locationNameExists
              : failureMessage(l10n, failure);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(locationsProvider).value ?? const <Location>[];
    final self = widget.existing;
    // One level deep: a parent must be top level, and a location that already
    // has children cannot itself become a child.
    final hasChildren = self != null && all.any((e) => e.parentId == self.id);
    final parents = hasChildren
        ? const <Location>[]
        : <Location>[
            for (final e in all)
              if (e.parentId == null && e.id != self?.id) e,
          ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          self == null ? l10n.locationAdd : l10n.locationRename,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.lg),
        TextField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
          decoration: InputDecoration(
            labelText: l10n.locationNameLabel,
            errorText: _error,
          ),
        ),
        const SizedBox(height: KSpacing.lg),
        Text(
          l10n.locationIconLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: KSpacing.sm),
        Wrap(
          spacing: KSpacing.sm,
          runSpacing: KSpacing.sm,
          children: <Widget>[
            for (final key in kLocationIconKeys)
              ChoiceChip(
                avatar: Icon(locationIcon(key), size: 18),
                label: Text(locationIconLabel(l10n, key)),
                selected: _icon == key,
                onSelected: (_) => setState(() => _icon = key),
              ),
          ],
        ),
        if (parents.isNotEmpty) ...<Widget>[
          const SizedBox(height: KSpacing.lg),
          DropdownButtonFormField<String?>(
            initialValue: parents.any((e) => e.id == _parentId)
                ? _parentId
                : null,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.locationParentLabel),
            items: <DropdownMenuItem<String?>>[
              DropdownMenuItem<String?>(child: Text(l10n.locationNoParent)),
              for (final p in parents)
                DropdownMenuItem<String?>(value: p.id, child: Text(p.name)),
            ],
            onChanged: (v) => setState(() => _parentId = v),
          ),
        ],
        const SizedBox(height: KSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.save),
          ),
        ),
      ],
    );
  }
}
