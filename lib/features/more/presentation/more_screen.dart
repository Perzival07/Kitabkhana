import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_config_provider.dart';
import '../../../app/reminder_providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../backup/presentation/backup_flows.dart';

/// The More tab: places to manage the library. More entries arrive with their
/// phases (loans, quotes, settings).
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: KSpacing.lg),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KSpacing.screen,
                vertical: KSpacing.md,
              ),
              child: Text(
                l10n.moreTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded),
              title: Text(l10n.loansTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(Routes.loans),
            ),
            ListTile(
              leading: const Icon(Icons.format_quote_rounded),
              title: Text(l10n.quotesTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(Routes.quotes),
            ),
            ListTile(
              leading: const Icon(Icons.ios_share_rounded),
              title: Text(l10n.moreBackup),
              onTap: () => exportBackupFlow(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore_rounded),
              title: Text(l10n.moreRestore),
              onTap: () => restoreBackupFlow(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: Text(l10n.moreExportCsv),
              onTap: () => exportCsvFlow(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.shelves),
              title: Text(l10n.locationsManage),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(Routes.locations),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.moreEraseAll,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => eraseAllDataFlow(context, ref),
            ),
            if (ref.watch(appConfigProvider).isDev)
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(l10n.devTestReminder),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final scheduler = ref.read(notificationSchedulerProvider);
                  if (!await scheduler.hasPermission()) {
                    await scheduler.requestPermission();
                  }
                  await scheduler.schedule(
                    id: 1,
                    at: DateTime.now().add(const Duration(minutes: 2)),
                    title: 'Kitabkhana',
                    body: 'Test reminder',
                    payload: '',
                  );
                  KToast.showWith(messenger, l10n.devTestReminderSet);
                },
              ),
          ],
        ),
      ),
    );
  }
}
