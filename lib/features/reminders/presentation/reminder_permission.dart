import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/reminder_providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

const String _askedKey = 'reminder.perm_asked';

/// Before the first loan with a due date is saved: explain, then ask for
/// notification permission. Asks at most once; never blocks saving.
Future<void> ensureReminderPermission(
  BuildContext context,
  WidgetRef ref,
) async {
  final scheduler = ref.read(notificationSchedulerProvider);
  if (!scheduler.supported) return;
  try {
    if (await scheduler.hasPermission()) return;
    final db = ref.read(appDatabaseProvider);
    final asked = await (db.select(
      db.appMeta,
    )..where((t) => t.key.equals(_askedKey))).getSingleOrNull();
    if (asked != null) return;
    if (!context.mounted) return;
    final allow = await showKBottomSheet<bool>(
      context: context,
      builder: (_) => const _ExplainBody(),
    );
    await db
        .into(db.appMeta)
        .insertOnConflictUpdate(
          const AppMetaCompanion(key: Value(_askedKey), value: Value('1')),
        );
    if (allow ?? false) await scheduler.requestPermission();
  } on Object {
    // Notifications are optional: never let them get in the way.
  }
}

class _ExplainBody extends StatelessWidget {
  const _ExplainBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.reminderPermTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.sm),
        Text(l10n.reminderPermBody),
        const SizedBox(height: KSpacing.xl),
        KButton(
          label: l10n.reminderPermAllow,
          expand: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: KSpacing.sm),
        KButton(
          label: l10n.reminderPermLater,
          variant: KButtonVariant.text,
          expand: true,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
