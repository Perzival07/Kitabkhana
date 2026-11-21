import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/failure_message.dart';
import '../../../app/reading_providers.dart';
import '../../../app/reminder_providers.dart';
import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../book/presentation/widgets/update_page_sheet.dart';
import '../../library/domain/book.dart';
import '../application/update_progress.dart';

/// Asks where the reader is, saves it (with today's reading log), and offers
/// "Mark as finished" on the last page. Shared by the Detail page and the
/// Reading tab.
Future<void> updateBookPage(
  BuildContext context,
  WidgetRef ref,
  Book book, {
  required Future<void> Function(Book book) onMarkFinished,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final page = await showUpdatePageSheet(
    context,
    current: book.currentPage,
    pages: book.pages,
  );
  if (page == null) return;
  final r = await ref.read(updateProgressProvider).call(book.id, page);
  // Having read today, today's reading nudge is not needed.
  if (r.isOk) unawaited(ref.read(readingReminderServiceProvider).reconcile());
  switch (r) {
    case Err<ProgressUpdate>(:final failure):
      KToast.showWith(
        messenger,
        failureMessage(l10n, failure),
        icon: Icons.error_outline_rounded,
      );
    case Ok<ProgressUpdate>(:final value) when value.reachedEnd:
      KToast.showWith(
        messenger,
        l10n.progressReachedEnd,
        icon: Icons.auto_stories_rounded,
        actionLabel: l10n.progressMarkFinished,
        onAction: () => onMarkFinished(value.book),
      );
    case Ok<ProgressUpdate>():
      break;
  }
}
