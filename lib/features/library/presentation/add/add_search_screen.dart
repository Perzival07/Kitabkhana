import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/lookup_providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../core/failure.dart';
import '../../../../core/result.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../application/add_book.dart';
import '../../domain/book_info.dart';
import 'add_args.dart';

/// Search the catalogue by title; tap a result to preview it.
class AddSearchScreen extends ConsumerStatefulWidget {
  const AddSearchScreen({super.key});

  @override
  ConsumerState<AddSearchScreen> createState() => _AddSearchScreenState();
}

enum _Phase { idle, loading, results, empty, offline, failed }

class _AddSearchScreenState extends ConsumerState<AddSearchScreen> {
  _Phase _phase = _Phase.idle;
  List<BookInfo> _results = const <BookInfo>[];
  String _query = '';
  int _generation = 0;

  Future<void> _search(String text) async {
    _query = text.trim();
    final mine = ++_generation;
    if (_query.isEmpty) {
      setState(() => _phase = _Phase.idle);
      return;
    }
    setState(() => _phase = _Phase.loading);
    final result = await ref
        .read(bookLookupServiceProvider)
        .searchTitle(_query);
    // Ignore answers to queries the user has already replaced.
    if (!mounted || mine != _generation) return;
    setState(() {
      switch (result) {
        case Ok<List<BookInfo>>(:final value):
          _results = value;
          _phase = value.isEmpty ? _Phase.empty : _Phase.results;
        case Err<List<BookInfo>>(:final failure):
          _results = const <BookInfo>[];
          _phase =
              failure is NetworkFailure &&
                  failure.kind == NetworkFailureKind.offline
              ? _Phase.offline
              : _Phase.failed;
      }
    });
  }

  void _openManual() => context.push(
    Routes.libraryAddManual,
    extra: BookFormArgs(draft: BookDraft(title: _query)),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addSearchTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KSpacing.screen,
                    KSpacing.sm,
                    KSpacing.screen,
                    KSpacing.md,
                  ),
                  child: KSearchField(
                    hint: l10n.searchFieldHint,
                    autofocus: true,
                    debounce: const Duration(milliseconds: 350),
                    onChanged: _search,
                    onSubmitted: _search,
                  ),
                ),
                Expanded(child: _body(l10n)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n) {
    switch (_phase) {
      case _Phase.idle:
        return KEmptyState(
          illustration: KIllustration.openBook,
          title: l10n.addSearchTitle,
          body: l10n.searchPrompt,
          illustrationSize: 120,
        );
      case _Phase.loading:
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.screen),
          itemCount: 4,
          itemBuilder: (_, _) => const Padding(
            padding: EdgeInsets.symmetric(vertical: KSpacing.sm),
            child: _ResultSkeleton(),
          ),
        );
      case _Phase.results:
        return ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.screen),
          itemCount: _results.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, i) => _ResultTile(
            info: _results[i],
            onTap: () => context.push(
              Routes.libraryAddPreview,
              extra: BookFormArgs(
                draft: BookDraft.fromInfo(_results[i]),
                info: _results[i],
              ),
            ),
          ),
        );
      case _Phase.empty:
        return KEmptyState(
          illustration: KIllustration.emptyShelf,
          title: l10n.addSearchTitle,
          body: l10n.searchNoResults,
          actionLabel: l10n.enterManually,
          onAction: _openManual,
          illustrationSize: 120,
        );
      case _Phase.offline:
        return KEmptyState(
          illustration: KIllustration.scannerFrame,
          title: l10n.addSearchTitle,
          body: l10n.searchOffline,
          actionLabel: l10n.enterManually,
          onAction: _openManual,
          illustrationSize: 120,
        );
      case _Phase.failed:
        return KEmptyState(
          illustration: KIllustration.scannerFrame,
          title: l10n.addSearchTitle,
          body: l10n.searchFailed,
          actionLabel: l10n.enterManually,
          onAction: _openManual,
          illustrationSize: 120,
        );
    }
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.info, required this.onTap});

  final BookInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final detail = <String>[
      if (info.authors.isNotEmpty) info.authorsText,
      if (info.year != null) '${info.year}',
    ].join(' · ');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KRadii.chip),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: KSpacing.sm),
        child: Row(
          children: <Widget>[
            KBookCover(
              title: info.title,
              author: info.authorsText,
              imageUrl: info.coverUrl,
              size: KCoverSize.xs,
            ),
            const SizedBox(width: KSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    info.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Fraunces',
                    ),
                  ),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (info.pages != null)
                    Text(
                      l10n.pagesCount(info.pages!),
                      style: theme.textTheme.bodySmall,
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

class _ResultSkeleton extends StatelessWidget {
  const _ResultSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        KSkeleton(width: 40, height: 60, radius: KRadii.cover),
        SizedBox(width: KSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              KSkeleton(height: 16),
              SizedBox(height: KSpacing.sm),
              KSkeleton(width: 120, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
