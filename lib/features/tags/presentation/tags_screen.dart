import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/failure_message.dart';
import '../../../app/library_providers.dart';
import '../../../app/repositories.dart';
import '../../../app/router/routes.dart';
import '../../../app/tag_providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/tag.dart';

/// `/tags`: every tag with its book count. Tap one to see its books in the
/// library; rename or delete from the menu.
class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  Future<void> _rename(BuildContext context, WidgetRef ref, Tag tag) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initial: tag.name),
    );
    if (name == null) return;
    final r = await ref.read(tagRepositoryProvider).rename(tag.id, name);
    if (r case Err<Tag>(:final failure)) {
      KToast.showWith(
        messenger,
        failure is ConflictFailure
            ? l10n.tagsNameTaken
            : failureMessage(l10n, failure),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Tag tag) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showKConfirmDialog(
      context: context,
      title: l10n.tagsDeleteTitle,
      message: l10n.tagsDeleteBody,
      confirmLabel: l10n.tagsDelete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!ok) return;
    final r = await ref.read(tagRepositoryProvider).softDelete(tag.id);
    switch (r) {
      case Ok<void>():
        KToast.showWith(
          messenger,
          l10n.tagsDeleted,
          icon: Icons.delete_outline_rounded,
        );
      case Err<void>(:final failure):
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
    final tags = ref.watch(tagsWithCountsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tagsTitle)),
      body: SafeArea(
        child: tags.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(KSpacing.screen),
            child: KSkeleton(height: 56),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (list) => list.isEmpty
              ? KEmptyState(
                  illustration: KIllustration.emptyShelf,
                  title: l10n.tagsEmptyTitle,
                  body: l10n.tagsEmptyBody,
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final t = list[i];
                        return ListTile(
                          key: ValueKey<String>(t.tag.id),
                          leading: const Icon(Icons.sell_outlined),
                          title: Text(t.tag.name),
                          subtitle: Text(l10n.tagsBooks(t.books)),
                          onTap: t.books == 0
                              ? null
                              : () {
                                  ref
                                      .read(
                                        libraryQueryControllerProvider.notifier,
                                      )
                                      .setTag(t.tag.id);
                                  context.go(Routes.library);
                                },
                          trailing: PopupMenuButton<String>(
                            tooltip: l10n.quoteMore,
                            onSelected: (v) => v == 'rename'
                                ? _rename(context, ref, t.tag)
                                : _delete(context, ref, t.tag),
                            itemBuilder: (_) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'rename',
                                child: Text(l10n.tagsRename),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text(l10n.tagsDelete),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _c = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _done() {
    final text = _c.text.trim();
    if (text.isNotEmpty) Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.tagsRenameTitle),
      content: TextField(
        controller: _c,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _done(),
        decoration: InputDecoration(labelText: l10n.tagsNameLabel),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _done, child: Text(l10n.save)),
      ],
    );
  }
}
