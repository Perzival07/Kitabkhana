import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'routes.dart';

/// Friendly 404 for unknown routes.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: KEmptyState(
          illustration: KIllustration.openBook,
          title: l10n.notFoundTitle,
          body: l10n.notFoundBody,
          actionLabel: l10n.goToLibrary,
          onAction: () => context.go(Routes.library),
        ),
      ),
    );
  }
}
