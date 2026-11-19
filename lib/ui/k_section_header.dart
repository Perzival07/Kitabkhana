import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// A Fraunces section title with an optional "See all" action.
class KSectionHeader extends StatelessWidget {
  const KSectionHeader({
    required this.title,
    this.onSeeAll,
    this.actionLabel,
    super.key,
  });

  final String title;
  final VoidCallback? onSeeAll;

  /// Defaults to the localised "See all".
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(actionLabel ?? AppLocalizations.of(context).seeAll),
          ),
      ],
    );
  }
}
