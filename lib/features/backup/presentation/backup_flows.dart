import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/backup_providers.dart';
import '../../../app/l10n/failure_message.dart';
import '../../../app/quote_providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../application/backup_codec.dart';
import '../application/export_backup.dart';
import '../domain/backup_format.dart';

/// Runs [work] behind a small "please wait" dialog the reader cannot dismiss.
Future<T> _withProgress<T>(
  BuildContext context,
  String label,
  Future<T> Function() work,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: <Widget>[
              const SizedBox.square(
                dimension: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(width: KSpacing.lg),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await work();
  } finally {
    if (navigator.mounted && navigator.canPop()) navigator.pop();
  }
}

void _error(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);
  KToast.showWith(
    ScaffoldMessenger.of(context),
    failureMessage(l10n, failure),
    icon: Icons.error_outline_rounded,
  );
}

/// Warns that the file is sensitive, builds the backup and shares it (a
/// download on the web).
Future<void> exportBackupFlow(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showKConfirmDialog(
    context: context,
    title: l10n.backupExportTitle,
    message: l10n.backupExportWarning,
    confirmLabel: l10n.backupExportAction,
    cancelLabel: l10n.cancel,
  );
  if (!ok || !context.mounted) return;

  final made = await _withProgress(
    context,
    l10n.backupPreparing,
    () => ref.read(exportBackupProvider).call(),
  );
  if (!context.mounted) return;
  switch (made) {
    case Err<BackupFile>(:final failure):
      _error(context, failure);
    case Ok<BackupFile>(:final value):
      try {
        await ref
            .read(shareServiceProvider)
            .shareFile(
              value.bytes,
              name: value.name,
              mimeType: 'application/zip',
            );
      } on Object {
        if (context.mounted) _error(context, const UnexpectedFailure('share'));
      }
  }
}

/// Picks a backup, checks it, asks merge or replace, imports it and shows
/// what was imported.
Future<void> restoreBackupFlow(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final Uint8List? bytes = await ref.read(backupFilePickerProvider).pick();
  if (bytes == null || !context.mounted) return;

  final opened = await _withProgress(
    context,
    l10n.backupOpening,
    () => ref.read(importBackupProvider).open(bytes),
  );
  if (!context.mounted) return;
  if (opened case Err<BackupContents>(:final failure)) {
    _error(context, failure);
    return;
  }
  final contents = (opened as Ok<BackupContents>).value;

  final mode = await _askMode(context, contents);
  if (mode == null || !context.mounted) return;
  if (mode == ImportMode.replace) {
    final sure = await showKConfirmDialog(
      context: context,
      title: l10n.backupReplaceConfirmTitle,
      message: l10n.backupReplaceConfirmBody,
      confirmLabel: l10n.backupReplaceConfirm,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!sure || !context.mounted) return;
  }

  final done = await _withProgress(
    context,
    l10n.backupRestoring,
    () => ref.read(importBackupProvider).call(contents, mode),
  );
  if (!context.mounted) return;
  switch (done) {
    case Err<ImportSummary>(:final failure):
      _error(context, failure);
    case Ok<ImportSummary>(:final value):
      await _showSummary(context, value);
  }
}

Future<ImportMode?> _askMode(BuildContext context, BackupContents contents) {
  final l10n = AppLocalizations.of(context);
  final m = contents.manifest;
  int live(String t) => (contents.tables[t] ?? const [])
      .where((r) => r['deletedAt'] == null)
      .length;
  final found = l10n.backupFound(
    DateFormat.yMMMd(l10n.localeName).format(m.exportedAt.toLocal()),
    live('books'),
    live('loans'),
    live('quotes'),
  );
  return showKBottomSheet<ImportMode>(
    context: context,
    builder: (sheet) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.backupRestoreTitle,
          style: Theme.of(sheet).textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.sm),
        Text(found, style: Theme.of(sheet).textTheme.bodyMedium),
        const SizedBox(height: KSpacing.lg),
        KButton(
          label: l10n.backupModeMerge,
          icon: Icons.merge_type_rounded,
          expand: true,
          onPressed: () => Navigator.of(sheet).pop(ImportMode.merge),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KSpacing.xs,
            KSpacing.xs,
            KSpacing.xs,
            KSpacing.md,
          ),
          child: Text(
            l10n.backupModeMergeBody,
            style: Theme.of(sheet).textTheme.bodySmall,
          ),
        ),
        KButton(
          label: l10n.backupModeReplace,
          icon: Icons.restore_rounded,
          variant: KButtonVariant.tonal,
          expand: true,
          onPressed: () => Navigator.of(sheet).pop(ImportMode.replace),
        ),
        Padding(
          padding: const EdgeInsets.all(KSpacing.xs),
          child: Text(
            l10n.backupModeReplaceBody,
            style: Theme.of(sheet).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}

Future<void> _showSummary(BuildContext context, ImportSummary s) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(l10n.backupDoneTitle),
      content: Text(
        <String>[
          l10n.backupImported(s.books, s.loans, s.quotes),
          if (s.coversSkipped > 0) l10n.backupCoversSkipped(s.coversSkipped),
        ].join('\n'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(),
          child: Text(l10n.ok),
        ),
      ],
    ),
  );
}
