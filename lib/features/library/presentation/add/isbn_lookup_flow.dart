import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/failure_message.dart';
import '../../../../app/lookup_providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/failure.dart';
import '../../../../core/result.dart';
import '../../../../core/text/isbn.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/add_book.dart';
import '../../domain/book_info.dart';
import 'add_args.dart';

/// Looks [isbn] up and opens the right next screen. A found book opens the
/// preview; a failure or "not found" opens the manual form pre-filled with
/// whatever is known, so the user is never blocked.
Future<void> lookupIsbnAndContinue({
  required BuildContext context,
  required WidgetRef ref,
  required Isbn13 isbn,
}) async {
  final l10n = AppLocalizations.of(context);
  final router = GoRouter.of(context);
  final result = await ref.read(bookLookupServiceProvider).lookupIsbn(isbn);
  if (!context.mounted) return;
  switch (result) {
    case Ok<BookInfo>(:final value):
      await router.push<void>(
        Routes.libraryAddPreview,
        extra: BookFormArgs(draft: BookDraft.fromInfo(value), info: value),
      );
    case Err<BookInfo>(:final failure):
      await router.push<void>(
        Routes.libraryAddManual,
        extra: BookFormArgs(
          draft: BookDraft(isbn13: isbn),
          notice: failure is NotFoundFailure
              ? l10n.lookupNotFound
              : failureMessage(l10n, failure),
        ),
      );
  }
}
