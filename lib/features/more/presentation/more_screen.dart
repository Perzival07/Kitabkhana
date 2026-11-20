import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';

/// The More tab: places to manage the library. More entries arrive with their
/// phases (loans, quotes, settings).
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              leading: const Icon(Icons.shelves),
              title: Text(l10n.locationsManage),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(Routes.locations),
            ),
          ],
        ),
      ),
    );
  }
}
