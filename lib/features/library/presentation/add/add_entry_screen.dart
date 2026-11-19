import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';

/// First step of adding a book: four friendly ways in.
class AddEntryScreen extends StatelessWidget {
  const AddEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <_Option>[
      _Option(
        icon: Icons.qr_code_scanner_rounded,
        title: l10n.addScanTitle,
        body: l10n.addScanBody,
        route: Routes.libraryAddScan,
      ),
      _Option(
        icon: Icons.pin_outlined,
        title: l10n.addIsbnTitle,
        body: l10n.addIsbnBody,
        route: Routes.libraryAddIsbn,
      ),
      _Option(
        icon: Icons.search_rounded,
        title: l10n.addSearchTitle,
        body: l10n.addSearchBody,
        route: Routes.libraryAddSearch,
      ),
      _Option(
        icon: Icons.edit_note_rounded,
        title: l10n.addManualTitle,
        body: l10n.addManualBody,
        route: Routes.libraryAddManual,
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addBookTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView.separated(
              padding: const EdgeInsets.all(KSpacing.screen),
              itemCount: options.length,
              separatorBuilder: (_, _) => const SizedBox(height: KSpacing.md),
              itemBuilder: (context, i) => _OptionCard(option: options[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Option {
  const _Option({
    required this.icon,
    required this.title,
    required this.body,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String body;
  final String route;
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.option});

  final _Option option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return KCard(
      onTap: () => context.push(option.route),
      semanticLabel: '${option.title}. ${option.body}',
      child: Row(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(KRadii.button),
            ),
            child: Padding(
              padding: const EdgeInsets.all(KSpacing.md),
              child: Icon(
                option.icon,
                size: 28,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: KSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(option.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: KSpacing.xs),
                Text(
                  option.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
