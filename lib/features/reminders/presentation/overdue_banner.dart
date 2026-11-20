import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/book_detail_providers.dart';
import '../../../app/reminder_providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/k_tokens.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';

/// "N books are overdue", shown where notifications cannot be scheduled (the
/// web), so overdue loans are never invisible.
class OverdueBanner extends ConsumerWidget {
  const OverdueBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(notificationSchedulerProvider).supported) {
      return const SizedBox.shrink();
    }
    final n = ref.watch(overdueLoansProvider).value?.length ?? 0;
    if (n == 0) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final tokens = context.kTokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KSpacing.screen,
        KSpacing.sm,
        KSpacing.screen,
        KSpacing.sm,
      ),
      child: Material(
        color: tokens.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(KRadii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(KRadii.button),
          onTap: () => context.push(Routes.loans),
          child: Padding(
            padding: const EdgeInsets.all(KSpacing.md),
            child: Row(
              children: <Widget>[
                Icon(Icons.schedule_rounded, color: tokens.warning),
                const SizedBox(width: KSpacing.md),
                Expanded(
                  child: Text(
                    n == 1 ? l10n.overdueBannerOne : l10n.overdueBannerMany(n),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
