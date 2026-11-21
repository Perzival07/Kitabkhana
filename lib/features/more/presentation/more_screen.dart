import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_config_provider.dart';
import '../../../app/book_detail_providers.dart';
import '../../../app/library_providers.dart';
import '../../../app/add_book_providers.dart';
import '../../../app/quote_providers.dart';
import '../../../app/reminder_providers.dart';
import '../../../app/tag_providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

/// The More tab: places to manage the library. More entries arrive with their
/// phases (loans, quotes, settings).
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final loansOut = ref.watch(activeLoansProvider).value?.length ?? 0;
    final quotes = ref.watch(allQuotesProvider).value?.length ?? 0;
    final locations = ref.watch(locationsProvider).value?.length ?? 0;
    final tags = ref.watch(tagsWithCountsProvider).value?.length ?? 0;
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
            _Group(title: l10n.moreGroupLibrary),
            _Entry(
              icon: Icons.swap_horiz_rounded,
              title: l10n.moreLoans,
              trailing: loansOut > 0 ? l10n.moreCountOut(loansOut) : null,
              route: Routes.loans,
            ),
            _Entry(
              icon: Icons.format_quote_rounded,
              title: l10n.moreQuotes,
              trailing: quotes > 0 ? '$quotes' : null,
              route: Routes.quotes,
            ),
            _Entry(
              icon: Icons.shelves,
              title: l10n.moreLocations,
              trailing: locations > 0 ? '$locations' : null,
              route: Routes.locations,
            ),
            _Entry(
              icon: Icons.sell_outlined,
              title: l10n.moreTags,
              trailing: tags > 0 ? '$tags' : null,
              route: Routes.tags,
            ),
            _Group(title: l10n.moreGroupApp),
            _Entry(
              icon: Icons.settings_outlined,
              title: l10n.moreSettings,
              route: Routes.settings,
            ),
            _Entry(
              icon: Icons.info_outline_rounded,
              title: l10n.moreAbout,
              route: Routes.about,
            ),
            if (ref.watch(appConfigProvider).isDev)
              ListTile(
                leading: const Icon(Icons.dataset_outlined),
                title: Text(l10n.devSeedPerf),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  KToast.showWith(messenger, l10n.devSeedPerfBusy);
                  final summary = await ref.read(perfSeederProvider).seed();
                  KToast.showWith(
                    messenger,
                    l10n.devSeedPerfDone(summary.toString()),
                  );
                },
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

class _Group extends StatelessWidget {
  const _Group({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      KSpacing.screen,
      KSpacing.lg,
      KSpacing.screen,
      KSpacing.xs,
    ),
    child: Semantics(
      header: true,
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    ),
  );
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.icon,
    required this.title,
    required this.route,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String route;

  /// A live count or status shown before the chevron.
  final String? trailing;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (trailing != null)
          Text(trailing!, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: KSpacing.xs),
        const Icon(Icons.chevron_right_rounded),
      ],
    ),
    onTap: () => context.push(route),
  );
}
