import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/add_book_providers.dart';
import '../../../../app/lookup_providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../core/failure.dart';
import '../../../../core/result.dart';
import '../../../../core/text/isbn.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../../locations/presentation/location_name.dart';
import '../../../locations/presentation/location_picker.dart';
import '../../application/add_book.dart';
import '../../domain/book_info.dart';

/// Where one scanned barcode stands.
enum BatchState { lookingUp, found, notFound, failed, owned }

/// One scanned book in a batch.
class BatchEntry {
  BatchEntry(this.isbn);

  final Isbn13 isbn;
  BatchState state = BatchState.lookingUp;
  BookInfo? info;

  /// Chosen to be added (found books not already owned, by default).
  bool selected = false;
}

/// "Scan a shelf": the camera stays open, every ISBN barcode is looked up
/// and queued, and the chosen ones are added in one go, optionally all to
/// the same place.
class AddBatchScreen extends ConsumerStatefulWidget {
  const AddBatchScreen({super.key});

  @override
  ConsumerState<AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends ConsumerState<AddBatchScreen> {
  final List<BatchEntry> _entries = <BatchEntry>[];
  String? _locationId;
  bool _saving = false;

  int get _chosen => _entries.where((e) => e.selected).length;

  void _onCode(String code) {
    final isbn = parseIsbn(code);
    if (isbn == null) return; // not a book barcode
    if (_entries.any((e) => e.isbn == isbn)) return; // already queued
    final entry = BatchEntry(isbn);
    setState(() => _entries.insert(0, entry));
    Haptics.success();
    unawaited(_lookUp(entry));
  }

  Future<void> _lookUp(BatchEntry entry) async {
    final r = await ref.read(bookLookupServiceProvider).lookupIsbn(entry.isbn);
    if (!mounted) return;
    switch (r) {
      case Ok<BookInfo>(:final value):
        entry.info = value;
        final dupes = await ref
            .read(addBookProvider)
            .findDuplicates(BookDraft.fromInfo(value));
        if (!mounted) return;
        final owned = dupes.getOrNull()?.isNotEmpty ?? false;
        entry
          ..state = owned ? BatchState.owned : BatchState.found
          ..selected = !owned;
      case Err<BookInfo>(:final failure):
        entry.state = failure is NotFoundFailure
            ? BatchState.notFound
            : BatchState.failed;
    }
    setState(() {});
  }

  Future<void> _addAll() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    final add = ref.read(addBookProvider);
    var added = 0;
    for (final e in _entries.where((e) => e.selected).toList()) {
      final info = e.info;
      if (info == null) continue;
      final draft = BookDraft.fromInfo(info);
      final r = await add(
        BookDraft(
          title: draft.title,
          authors: draft.authors,
          subtitle: draft.subtitle,
          isbn13: draft.isbn13 ?? e.isbn,
          olWorkKey: draft.olWorkKey,
          pages: draft.pages,
          coverUrl: draft.coverUrl,
          locationId: _locationId,
        ),
        // Checked when it was scanned; the reader chose to add it.
        allowDuplicate: true,
      );
      if (r case Ok<AddBookResult>(value: BookAdded())) added++;
    }
    if (!mounted) return;
    setState(() => _saving = false);
    KToast.showWith(
      messenger,
      l10n.batchAdded(added),
      icon: Icons.check_rounded,
    );
    router.go(Routes.library);
  }

  Widget _unavailable(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KEmptyState(
      illustration: KIllustration.scannerFrame,
      title: l10n.scanUnavailableTitle,
      body: l10n.scanUnavailableBody,
      actionLabel: l10n.addIsbnTitle,
      onAction: () => context.pushReplacement(Routes.libraryAddIsbn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final builder = ref.watch(barcodeViewBuilderProvider);
    final locations = ref.watch(locationsProvider).value ?? const [];
    final place =
        locations
            .where((l) => l.id == _locationId)
            .map((l) => locationPath(l, locations))
            .firstOrNull ??
        l10n.noLocation;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchTitle)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  builder(context, _onCode, _unavailable),
                  IgnorePointer(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(KSpacing.md),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(KRadii.button),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: KSpacing.lg,
                              vertical: KSpacing.sm,
                            ),
                            child: Text(
                              l10n.batchHint,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: _entries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(KSpacing.screen),
                        child: Text(
                          l10n.batchEmpty,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: KSpacing.sm,
                      ),
                      itemCount: _entries.length,
                      itemBuilder: (context, i) => _EntryTile(
                        entry: _entries[i],
                        onChanged: (v) =>
                            setState(() => _entries[i].selected = v),
                        onRemove: () => setState(() => _entries.removeAt(i)),
                      ),
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KSpacing.screen,
                KSpacing.sm,
                KSpacing.screen,
                KSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(l10n.batchPlace),
                    subtitle: Text(place, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.arrow_drop_down_rounded),
                    onTap: () async {
                      final pick = await showLocationPicker(
                        context,
                        selectedId: _locationId,
                      );
                      if (pick != null) setState(() => _locationId = pick.id);
                    },
                  ),
                  KButton(
                    label: l10n.batchAdd(_chosen),
                    icon: Icons.library_add_rounded,
                    expand: true,
                    loading: _saving,
                    onPressed: _chosen == 0 || _saving ? null : _addAll,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.onChanged,
    required this.onRemove,
  });

  final BatchEntry entry;
  final ValueChanged<bool> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = entry.info;
    final title = info?.title ?? entry.isbn.value;
    final note = switch (entry.state) {
      BatchState.lookingUp => l10n.lookingUp,
      BatchState.found => info!.authorsText,
      BatchState.owned => l10n.batchOwned,
      BatchState.notFound => l10n.batchNotFound,
      BatchState.failed => l10n.batchFailed,
    };
    final canAdd =
        entry.state == BatchState.found || entry.state == BatchState.owned;
    return ListTile(
      leading: entry.state == BatchState.lookingUp
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Checkbox(
              value: entry.selected,
              onChanged: canAdd ? (v) => onChanged(v ?? false) : null,
            ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(note, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        tooltip: l10n.batchRemove,
        icon: const Icon(Icons.close_rounded),
        onPressed: onRemove,
      ),
    );
  }
}
