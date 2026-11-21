import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/repositories.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/book.dart';
import 'book_cover_view.dart';

/// Lets the reader choose one of their books by searching or scrolling the
/// latest. Resolves to the book, or null when dismissed.
Future<Book?> showBookPicker(BuildContext context, {String? title}) =>
    showKBottomSheet<Book>(
      context: context,
      builder: (_) => _BookPickerBody(title: title),
    );

class _BookPickerBody extends ConsumerStatefulWidget {
  const _BookPickerBody({this.title});

  final String? title;

  @override
  ConsumerState<_BookPickerBody> createState() => _BookPickerBodyState();
}

class _BookPickerBodyState extends ConsumerState<_BookPickerBody> {
  List<Book> _books = const <Book>[];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load('');
  }

  Future<void> _load(String query) async {
    final repo = ref.read(bookRepositoryProvider);
    final List<Book> found;
    if (query.trim().isEmpty) {
      found = await repo.watchAll(limit: 30).first;
    } else {
      found = (await repo.search(query.trim(), limit: 30)).getOrNull() ?? [];
    }
    if (mounted) {
      setState(() {
        _books = found;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.title ?? l10n.quotesPickBook,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.md),
        KSearchField(hint: l10n.librarySearchHint, onChanged: _load),
        const SizedBox(height: KSpacing.md),
        if (_loaded && _books.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: KSpacing.lg),
            child: Text(l10n.quotesNoBooksYet),
          ),
        for (final b in _books)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: BookCoverView(book: b, size: KCoverSize.xs),
            title: Text(b.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: b.authors.isEmpty
                ? null
                : Text(b.authors, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => Navigator.of(context).pop(b),
          ),
      ],
    );
  }
}
