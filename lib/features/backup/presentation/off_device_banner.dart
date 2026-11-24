import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/backup_providers.dart';
import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auto_backup.dart';
import 'backup_flows.dart';

/// "Your library is only on this phone": shown in the Library when no copy
/// has left the phone for a month. Automatic backups live on the phone, so
/// they are lost with it.
class OffDeviceBackupBanner extends ConsumerWidget {
  const OffDeviceBackupBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(offDeviceReminderProvider).value != true) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KSpacing.screen,
        KSpacing.sm,
        KSpacing.screen,
        KSpacing.sm,
      ),
      child: Material(
        color: scheme.secondaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(KRadii.button),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KSpacing.md,
            KSpacing.md,
            KSpacing.sm,
            KSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.cloud_upload_outlined, color: scheme.secondary),
                  const SizedBox(width: KSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.offDeviceTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: KSpacing.xs),
                        Text(
                          l10n.offDeviceBody,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Wrap(
                  children: <Widget>[
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(backupPrefsProvider)
                            .setOffDeviceSnoozedUntil(
                              ref
                                  .read(clockProvider)
                                  .now()
                                  .add(offDeviceSnooze),
                            );
                        ref.invalidate(offDeviceReminderProvider);
                      },
                      child: Text(l10n.offDeviceLater),
                    ),
                    TextButton(
                      onPressed: () => saveBackupCopyFlow(context, ref),
                      child: Text(l10n.offDeviceSave),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
