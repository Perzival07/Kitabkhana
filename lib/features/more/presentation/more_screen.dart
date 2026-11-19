import 'package:flutter/material.dart';

import '../../../app/shell/placeholder_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

/// Placeholder until this tab is built.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderScreen(
      illustration: KIllustration.quoteMarks,
      title: l10n.moreTitle,
      body: l10n.moreEmptyBody,
    );
  }
}
