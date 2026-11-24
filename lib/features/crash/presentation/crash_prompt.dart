import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/crash_providers.dart';
import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../data/db/database_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/crash/crash_store.dart';
import '../../../ui/ui.dart';
import '../application/problem_reporter.dart';

/// After a run in which something went wrong, asks once whether to email the
/// kept report to the developer. Sits above the router, so it finds a
/// navigator through [navigatorKey].
class CrashReportPrompt extends ConsumerStatefulWidget {
  const CrashReportPrompt({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<CrashReportPrompt> createState() => _CrashReportPromptState();
}

class _CrashReportPromptState extends ConsumerState<CrashReportPrompt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_check()));
  }

  Future<void> _check() async {
    final store = ref.read(crashStoreProvider);
    final pending = await store.pending();
    if (pending == null || !mounted) return;
    final settings = await ref
        .read(settingsStreamProvider.future)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => ref.read(appSettingsProvider),
        );
    if (!settings.crashReports) {
      await store.clear();
      return;
    }
    // Wait for the first screen to be in place.
    for (var i = 0; i < 20 && widget.navigatorKey.currentContext == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    final context = widget.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    await showCrashReportDialog(context, pending);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The "Something went wrong" dialog. Whatever the answer, the kept report is
/// cleared, so it is offered only once.
Future<void> showCrashReportDialog(
  BuildContext context,
  PendingCrash pending,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  // Null: not now. Otherwise whether to include the screenshot.
  final answer = await showDialog<({bool screenshot})>(
    context: context,
    builder: (_) => _CrashDialog(hasScreenshot: pending.screenshot != null),
  );
  final store = container.read(crashStoreProvider);
  if (answer == null) {
    await store.clear();
    return;
  }
  final includeShot = answer.screenshot;
  final locale = context.mounted
      ? Localizations.localeOf(context).languageCode
      : 'en';
  final outcome = await container
      .read(problemReporterProvider)
      .send(
        report: pending.report,
        screenshot: includeShot ? pending.screenshot : null,
        schemaVersion: container.read(appDatabaseProvider).schemaVersion,
        locale: locale,
        now: container.read(clockProvider).now(),
        logLines: container.read(appLoggerProvider).lines,
      );
  await store.clear();
  if (context.mounted) showReportOutcome(context, outcome);
}

/// A toast for the fallbacks; the mail app speaks for itself.
void showReportOutcome(BuildContext context, ReportOutcome outcome) {
  final l10n = AppLocalizations.of(context);
  final text = switch (outcome) {
    ReportOutcome.mailApp => null,
    ReportOutcome.mailLink => l10n.reportSentMailLink,
    ReportOutcome.shared => l10n.reportShared,
  };
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (text != null && messenger != null) {
    KToast.showWith(messenger, text, icon: Icons.info_outline_rounded);
  }
}

class _CrashDialog extends StatefulWidget {
  const _CrashDialog({required this.hasScreenshot});

  final bool hasScreenshot;

  @override
  State<_CrashDialog> createState() => _CrashDialogState();
}

class _CrashDialogState extends State<_CrashDialog> {
  bool _shot = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.crashPromptTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.crashPromptBody),
            if (widget.hasScreenshot) ...<Widget>[
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _shot,
                onChanged: (v) => setState(() => _shot = v ?? false),
                title: Text(l10n.crashPromptScreenshot),
                subtitle: Text(l10n.crashPromptScreenshotHint),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.crashPromptDismiss),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context)
                  .pop((screenshot: _shot && widget.hasScreenshot)),
          child: Text(l10n.crashPromptSend),
        ),
      ],
    );
  }
}
