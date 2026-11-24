import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/backup_providers.dart';
import '../../../app/l10n/failure_message.dart';
import '../../../app/app_providers_reset.dart';
import '../../../app/providers.dart';
import '../../../app/quote_providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../../platform/share/share_service.dart';
import '../application/backup_codec.dart';
import '../application/csv_export.dart';
import '../application/erase_all_data.dart';
import '../application/export_backup.dart';
import '../application/reading_app_import.dart';
import '../../library/domain/book_enums.dart';
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
        final now = ref.read(clockProvider).now();
        final prefs = ref.read(backupPrefsProvider);
        await prefs.setLastBackupAt(now);
        // A shared backup has left the phone.
        await prefs.setLastOffDeviceAt(now);
        ref.invalidate(offDeviceReminderProvider);
      } on Object {
        if (context.mounted) _error(context, const UnexpectedFailure('share'));
      }
  }
}

/// Builds a backup and opens the system "Save" dialog, so a copy can live
/// somewhere other than this phone (Google Drive, iCloud Drive, Downloads, a
/// USB stick). Returns true when it was saved.
Future<bool> saveBackupCopyFlow(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final made = await _withProgress(
    context,
    l10n.backupPreparing,
    () => ref.read(exportBackupProvider).call(),
  );
  if (!context.mounted) return false;
  if (made case Err<BackupFile>(:final failure)) {
    _error(context, failure);
    return false;
  }
  final file = (made as Ok<BackupFile>).value;
  bool saved;
  try {
    saved = await ref
        .read(backupFilePickerProvider)
        .save(file.bytes, name: file.name);
  } on Object {
    if (context.mounted) _error(context, const UnexpectedFailure('save'));
    return false;
  }
  if (!saved) return false;
  final now = ref.read(clockProvider).now();
  final prefs = ref.read(backupPrefsProvider);
  await prefs.setLastBackupAt(now);
  await prefs.setLastOffDeviceAt(now);
  ref.invalidate(offDeviceReminderProvider);
  KToast.showWith(messenger, l10n.backupCopySaved, icon: Icons.check_rounded);
  return true;
}

/// Picks a backup, checks it, asks merge or replace, imports it and shows
/// what was imported. Returns true when something was imported.
Future<bool> restoreBackupFlow(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final Uint8List? bytes = await ref.read(backupFilePickerProvider).pick();
  if (bytes == null || !context.mounted) return false;

  final opened = await _withProgress(
    context,
    l10n.backupOpening,
    () => ref.read(importBackupProvider).open(bytes),
  );
  if (!context.mounted) return false;
  if (opened case Err<BackupContents>(:final failure)) {
    _error(context, failure);
    return false;
  }
  final contents = (opened as Ok<BackupContents>).value;

  final mode = await _askMode(context, contents);
  if (mode == null || !context.mounted) return false;
  if (mode == ImportMode.replace) {
    final sure = await showKConfirmDialog(
      context: context,
      title: l10n.backupReplaceConfirmTitle,
      message: l10n.backupReplaceConfirmBody,
      confirmLabel: l10n.backupReplaceConfirm,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (!sure || !context.mounted) return false;
  }

  final done = await _withProgress(
    context,
    l10n.backupRestoring,
    () => ref.read(importBackupProvider).call(contents, mode),
  );
  if (!context.mounted) return false;
  switch (done) {
    case Err<ImportSummary>(:final failure):
      _error(context, failure);
      return false;
    case Ok<ImportSummary>(:final value):
      await _showSummary(context, value);
      return true;
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

/// Builds books.csv and loans.csv and shares them.
Future<void> exportCsvFlow(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showKConfirmDialog(
    context: context,
    title: l10n.csvExportTitle,
    message: l10n.csvExportWarning,
    confirmLabel: l10n.csvExportAction,
    cancelLabel: l10n.cancel,
  );
  if (!ok || !context.mounted) return;
  final made = await _withProgress(
    context,
    l10n.csvPreparing,
    () => ref.read(exportCsvProvider).call(),
  );
  if (!context.mounted) return;
  switch (made) {
    case Err<List<CsvFile>>(:final failure):
      _error(context, failure);
    case Ok<List<CsvFile>>(:final value):
      try {
        await ref.read(shareServiceProvider).shareFiles(<ShareableFile>[
          for (final f in value)
            (bytes: f.bytes, name: f.name, mimeType: 'text/csv'),
        ]);
      } on Object {
        if (context.mounted) _error(context, const UnexpectedFailure('share'));
      }
  }
}

/// Erases everything after two confirmations (the second asks for the word
/// DELETE), then returns to the start of the app.
Future<void> eraseAllDataFlow(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final first = await showKConfirmDialog(
    context: context,
    title: l10n.eraseTitle,
    message: l10n.eraseBody,
    confirmLabel: l10n.eraseContinue,
    cancelLabel: l10n.cancel,
    destructive: true,
  );
  if (!first || !context.mounted) return;
  final typed = await showDialog<bool>(
    context: context,
    builder: (_) => const _TypeToConfirm(),
  );
  if (typed != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final r = await _withProgress(
    context,
    l10n.eraseWorking,
    () => ref.read(eraseAllDataProvider).call(),
  );
  if (!context.mounted) return;
  switch (r) {
    case Err<void>(:final failure):
      _error(context, failure);
    case Ok<void>():
      resetSettingsState(ref);
      router.go(Routes.onboarding);
      KToast.showWith(messenger, l10n.eraseDone, icon: Icons.check_rounded);
  }
}

class _TypeToConfirm extends StatefulWidget {
  const _TypeToConfirm();

  @override
  State<_TypeToConfirm> createState() => _TypeToConfirmState();
}

class _TypeToConfirmState extends State<_TypeToConfirm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final ready = isEraseConfirmed(_controller.text);
    return AlertDialog(
      title: Text(l10n.eraseTypeTitle(eraseConfirmWord)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.characters,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(helperText: l10n.eraseTypeHint),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
          ),
          onPressed: ready ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.eraseAction),
        ),
      ],
    );
  }
}

/// Picks a Goodreads or StoryGraph export, shows what is in it, and adds the
/// books the library does not have yet.
Future<void> importReadingAppFlow(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final bytes = await ref.read(backupFilePickerProvider).pick();
  if (bytes == null || !context.mounted) return;
  final parsed = parseReadingAppCsv(utf8.decode(bytes, allowMalformed: true));
  if (parsed case Err<ReadingAppExport>()) {
    KToast.showWith(
      messenger,
      l10n.importNotAnExport,
      icon: Icons.error_outline_rounded,
    );
    return;
  }
  final export = (parsed as Ok<ReadingAppExport>).value;
  final use = ref.read(importReadingAppProvider);
  final existing = await use.countExisting(export);
  if (!context.mounted) return;
  final wantAs = await _askReadingAppImport(context, export, existing);
  if (wantAs == null || !context.mounted) return;
  final done = await _withProgress(
    context,
    l10n.importWorking,
    () => use(export, wantToReadAs: wantAs),
  );
  if (!context.mounted) return;
  switch (done) {
    case Err<ReadingAppImportSummary>(:final failure):
      _error(context, failure);
    case Ok<ReadingAppImportSummary>(:final value):
      ref.invalidate(offDeviceReminderProvider);
      KToast.showWith(
        messenger,
        l10n.importDone(value.added),
        icon: Icons.check_rounded,
      );
  }
}

Future<Ownership?> _askReadingAppImport(
  BuildContext context,
  ReadingAppExport export,
  int existing,
) {
  final l10n = AppLocalizations.of(context);
  final name = switch (export.app) {
    ReadingApp.goodreads => 'Goodreads',
    ReadingApp.storygraph => 'StoryGraph',
  };
  final fresh = export.books.length - existing;
  final wants = export.books
      .where((b) => b.status == ReadStatus.want && !b.owned)
      .length;
  return showKBottomSheet<Ownership>(
    context: context,
    builder: (sheet) {
      final text = Theme.of(sheet).textTheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.importTitle(name), style: text.titleLarge),
          const SizedBox(height: KSpacing.sm),
          Text(
            l10n.importFound(export.books.length, existing),
            style: text.bodyMedium,
          ),
          const SizedBox(height: KSpacing.lg),
          if (fresh == 0)
            KButton(
              label: l10n.importNothingNew,
              expand: true,
              onPressed: () => Navigator.of(sheet).pop(),
            )
          else if (wants == 0)
            KButton(
              label: l10n.importAction(fresh),
              icon: Icons.download_rounded,
              expand: true,
              onPressed: () => Navigator.of(sheet).pop(Ownership.owned),
            )
          else ...<Widget>[
            Text(l10n.importWantQuestion(wants), style: text.titleSmall),
            const SizedBox(height: KSpacing.md),
            KButton(
              label: l10n.importWantWishlist,
              icon: Icons.bookmark_add_outlined,
              expand: true,
              onPressed: () => Navigator.of(sheet).pop(Ownership.wishlist),
            ),
            const SizedBox(height: KSpacing.sm),
            KButton(
              label: l10n.importWantOwned,
              icon: Icons.shelves,
              expand: true,
              variant: KButtonVariant.secondary,
              onPressed: () => Navigator.of(sheet).pop(Ownership.owned),
            ),
          ],
        ],
      );
    },
  );
}
