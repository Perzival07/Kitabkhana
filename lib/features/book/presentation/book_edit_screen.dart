import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/book_detail_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../library/domain/book.dart';
import '../../library/presentation/add/add_args.dart';
import '../../library/presentation/add/book_form_screen.dart';

/// `/book/:id/edit`: the manual form, pre-filled with the book.
class BookEditScreen extends ConsumerWidget {
  const BookEditScreen({required this.bookId, super.key});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bookByIdProvider(bookId));
    final book = async.value;
    if (book != null) {
      // Built once from the book as it is when the screen opens; later live
      // changes must not overwrite what the user is typing.
      return _Once(book: book);
    }
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: async.isLoading
          ? const Center(child: CircularProgressIndicator())
          : KEmptyState(
              illustration: KIllustration.openBook,
              title: l10n.bookNotFound,
            ),
    );
  }
}

class _Once extends StatefulWidget {
  const _Once({required this.book});
  final Book book;

  @override
  State<_Once> createState() => _OnceState();
}

class _OnceState extends State<_Once> {
  late final BookFormArgs _args = BookFormArgs.edit(widget.book);

  @override
  Widget build(BuildContext context) => BookFormScreen(args: _args);
}
