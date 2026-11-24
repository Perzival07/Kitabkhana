import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_config.dart';
import '../../../app/app_config_provider.dart';
import '../../../app/backup_providers.dart';
import '../../../app/crash_providers.dart';
import '../../../app/l10n/failure_message.dart';
import '../../../app/lending_providers.dart';
import '../../../app/library_providers.dart';
import '../../../app/providers.dart';
import '../../../app/quote_providers.dart';
import '../../../app/reminder_providers.dart';
import '../../../app/repositories.dart';
import '../../../app/router/routes.dart';
import '../../../app/settings_providers.dart';
import '../../../app/stats_providers.dart';
import '../../../app/theme/theme_mode_provider.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/result.dart';
import '../../../data/db/database_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../backup/presentation/backup_flows.dart';
import '../../crash/presentation/crash_prompt.dart';
import '../../reminders/presentation/reminder_permission.dart';
import '../../stats/presentation/goal_sheet.dart';
import '../application/diagnostics.dart';
import '../domain/app_settings.dart';
import '../../../app/today_provider.dart';

final FutureProvider<DateTime?> _lastBackupProvider =
    FutureProvider.autoDispose<DateTime?>(
      (ref) => ref.watch(backupPrefsProvider).lastBackupAt(),
    );

final FutureProvider<bool> _autoBackupOnProvider =
    FutureProvider.autoDispose<bool>(
      (ref) => ref.watch(backupPrefsProvider).autoEnabled(),
    );

/// `/settings`: appearance, reading, lending, your data, privacy, help and
/// about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.only(bottom: KSpacing.huge),
              children: const <Widget>[
                _Appearance(),
                _ReadingSection(),
                _LendingSection(),
                _DataSection(),
                _PrivacySection(),
                _HelpSection(),
                _AboutRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(
          KSpacing.screen,
          KSpacing.xl,
          KSpacing.screen,
          KSpacing.sm,
        ),
        child: Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
      ...children,
    ],
  );
}

/// A label above a segmented choice.
class _Choice<T> extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> options;
  final void Function(T value) onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: KSpacing.screen,
      vertical: KSpacing.sm,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: KSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<T>(
            showSelectedIcon: false,
            segments: <ButtonSegment<T>>[
              for (final e in options.entries)
                ButtonSegment<T>(value: e.key, label: Text(e.value)),
            ],
            selected: <T>{value},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ),
      ],
    ),
  );
}

class _Appearance extends ConsumerWidget {
  const _Appearance();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(themeModeControllerProvider);
    final view = ref.watch(libraryViewControllerProvider);
    final settings = ref.watch(appSettingsProvider);
    final repo = ref.read(settingsRepositoryProvider);
    return _Section(
      title: l10n.settingsAppearance,
      children: <Widget>[
        _Choice<ThemeMode>(
          label: l10n.settingsTheme,
          value: mode,
          options: <ThemeMode, String>{
            ThemeMode.system: l10n.settingsThemeSystem,
            ThemeMode.light: l10n.settingsThemeLight,
            ThemeMode.dark: l10n.settingsThemeDark,
          },
          onChanged: ref.read(themeModeControllerProvider.notifier).set,
        ),
        _Choice<LibraryView>(
          label: l10n.settingsDefaultView,
          value: view,
          options: <LibraryView, String>{
            LibraryView.grid: l10n.settingsViewGrid,
            LibraryView.list: l10n.settingsViewList,
          },
          onChanged: (v) =>
              ref.read(libraryViewControllerProvider.notifier).set(v),
        ),
        _Choice<GridDensity>(
          label: l10n.settingsDensity,
          value: settings.gridDensity,
          options: <GridDensity, String>{
            GridDensity.comfortable: l10n.settingsDensityComfortable,
            GridDensity.compact: l10n.settingsDensityCompact,
          },
          onChanged: (v) => repo.setGridDensity(v),
        ),
      ],
    );
  }
}

String _time(BuildContext context, DayTime t) =>
    MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: t.hour, minute: t.minute));

Future<DayTime?> _pickTime(BuildContext context, DayTime initial) async {
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
  );
  return t == null ? null : DayTime(t.hour, t.minute);
}

class _ReadingSection extends ConsumerWidget {
  const _ReadingSection();

  Future<void> _goal(BuildContext context, WidgetRef ref, int year) async {
    final current = ref.read(yearGoalProvider(year)).value;
    final choice = await showGoalSheet(
      context,
      year: year,
      current: current?.targetBooks,
    );
    if (choice == null) return;
    final repo = ref.read(goalRepositoryProvider);
    switch (choice) {
      case GoalSet(:final target):
        await repo.setTarget(year, target);
      case GoalRemoved():
        await repo.clear(year);
    }
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool on) async {
    if (on) await ensureReminderPermission(context, ref);
    await ref
        .read(settingsRepositoryProvider)
        .setReadingReminderEnabled(enabled: on);
    await ref.read(readingReminderServiceProvider).reconcile();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final year = ref.watch(todayProvider).year;
    final goal = ref.watch(yearGoalProvider(year)).value;
    return _Section(
      title: l10n.settingsReading,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: Text(l10n.settingsGoal),
          subtitle: Text(
            goal == null
                ? l10n.settingsGoalNone(year)
                : l10n.settingsGoalValue(goal.targetBooks, year),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _goal(context, ref, year),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_none_rounded),
          title: Text(l10n.settingsReadingReminder),
          subtitle: Text(l10n.settingsReadingReminderBody),
          value: settings.readingReminderEnabled,
          onChanged: (on) => _toggle(context, ref, on),
        ),
        if (settings.readingReminderEnabled)
          ListTile(
            leading: const SizedBox(width: 24),
            title: Text(l10n.settingsReminderTime),
            trailing: Text(_time(context, settings.readingReminderTime)),
            onTap: () async {
              final t = await _pickTime(context, settings.readingReminderTime);
              if (t == null) return;
              await ref
                  .read(settingsRepositoryProvider)
                  .setReadingReminderTime(t);
              await ref.read(readingReminderServiceProvider).reconcile();
            },
          ),
      ],
    );
  }
}

class _LendingSection extends ConsumerWidget {
  const _LendingSection();

  Future<void> _loanLength(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final days = await showKBottomSheet<int>(
      context: context,
      builder: (_) => _NumberSheet(
        title: AppLocalizations.of(context).settingsLoanLengthSheet,
        help: AppLocalizations.of(context).settingsLoanLengthHelp,
        initial: current,
        max: 365,
      ),
    );
    if (days != null) {
      await ref.read(settingsRepositoryProvider).setDefaultLoanDays(days);
    }
  }

  Future<void> _countryCode(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final code = await showKBottomSheet<String>(
      context: context,
      builder: (_) => _TextSheet(
        title: l10n.settingsCountryCodeSheet,
        help: l10n.settingsCountryCodeHelp,
        initial: current,
        maxLength: 4,
      ),
    );
    if (code != null) {
      await ref.read(defaultCountryCodeProvider.notifier).set(code);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(appSettingsProvider);
    final cc = ref.watch(defaultCountryCodeProvider);
    return _Section(
      title: l10n.settingsLending,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.event_available_outlined),
          title: Text(l10n.settingsLoanLength),
          trailing: Text(
            s.defaultLoanDays == 0
                ? l10n.settingsLoanLengthNone
                : l10n.settingsLoanLengthDays(s.defaultLoanDays),
          ),
          onTap: () => _loanLength(context, ref, s.defaultLoanDays),
        ),
        ListTile(
          leading: const Icon(Icons.dialpad_rounded),
          title: Text(l10n.settingsCountryCode),
          trailing: Text(l10n.settingsCountryCodeValue(cc)),
          onTap: () => _countryCode(context, ref, cc),
        ),
        ListTile(
          leading: const Icon(Icons.schedule_rounded),
          title: Text(l10n.settingsLoanReminderTime),
          trailing: Text(_time(context, s.loanReminderTime)),
          onTap: () async {
            final t = await _pickTime(context, s.loanReminderTime);
            if (t == null) return;
            await ref.read(settingsRepositoryProvider).setLoanReminderTime(t);
            await ref.read(loanReminderServiceProvider).reconcile();
          },
        ),
      ],
    );
  }
}

class _DataSection extends ConsumerWidget {
  const _DataSection();

  Future<void> _backupNow(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final auto = ref.read(autoBackupProvider);
    if (!ref.read(backupFolderProvider).supported) {
      // The web has no app folder: hand the file over instead.
      await exportBackupFlow(context, ref);
      ref.invalidate(_lastBackupProvider);
      return;
    }
    final r = await auto.backUpNow();
    ref.invalidate(_lastBackupProvider);
    switch (r) {
      case Ok<String>():
        KToast.showWith(
          messenger,
          l10n.settingsBackupSaved,
          icon: Icons.check_rounded,
        );
      case Err<String>(:final failure):
        KToast.showWith(
          messenger,
          failureMessage(l10n, failure),
          icon: Icons.error_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final last = ref.watch(_lastBackupProvider).value;
    final autoOn = ref.watch(_autoBackupOnProvider).value ?? true;
    final canAuto = ref.watch(backupFolderProvider).supported;
    final since = daysSince(last, ref.watch(todayProvider));
    final when = since == null
        ? null
        : switch (since.days) {
            0 => l10n.settingsBackupToday,
            1 => l10n.settingsBackupYesterday,
            final n => l10n.settingsBackupDaysAgo(n),
          };
    return _Section(
      title: l10n.settingsData,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: Text(l10n.settingsBackupNow),
          subtitle: Text(
            when == null
                ? l10n.settingsBackupNever
                : l10n.settingsBackupLast(when),
          ),
          onTap: () => _backupNow(context, ref),
        ),
        if (canAuto)
          SwitchListTile(
            secondary: const Icon(Icons.autorenew_rounded),
            title: Text(l10n.settingsAutoBackup),
            subtitle: Text(l10n.settingsAutoBackupBody),
            value: autoOn,
            onChanged: (on) async {
              await ref.read(backupPrefsProvider).setAutoEnabled(enabled: on);
              ref.invalidate(_autoBackupOnProvider);
            },
          ),
        ListTile(
          leading: const Icon(Icons.ios_share_rounded),
          title: Text(l10n.settingsShareBackup),
          onTap: () async {
            await exportBackupFlow(context, ref);
            ref.invalidate(_lastBackupProvider);
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_backup_restore_rounded),
          title: Text(l10n.settingsRestore),
          onTap: () => restoreBackupFlow(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.table_chart_outlined),
          title: Text(l10n.settingsExportCsv),
          onTap: () => exportCsvFlow(context, ref),
        ),
        ListTile(
          leading: Icon(
            Icons.delete_forever_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            l10n.settingsErase,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          onTap: () => eraseAllDataFlow(context, ref),
        ),
      ],
    );
  }
}

class _PrivacySection extends ConsumerWidget {
  const _PrivacySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(appSettingsProvider);
    return _Section(
      title: l10n.settingsPrivacy,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.screen),
          child: Text(
            l10n.settingsPrivacyBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.bug_report_outlined),
          title: Text(l10n.settingsCrashReports),
          subtitle: Text(l10n.settingsCrashReportsBody),
          value: s.crashReports,
          onChanged: (on) =>
              ref.read(settingsRepositoryProvider).setCrashReports(enabled: on),
        ),
      ],
    );
  }
}

class _HelpSection extends ConsumerWidget {
  const _HelpSection();

  Future<void> _diagnostics(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final config = ref.read(appConfigProvider);
    final text = buildDiagnostics(
      appName: config.appName,
      appVersion: config.version,
      schemaVersion: ref.read(appDatabaseProvider).schemaVersion,
      platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
      locale: l10n.localeName,
      generatedAt: ref.read(clockProvider).now(),
      logLines: ref.read(appLoggerProvider).lines,
    );
    await ref
        .read(shareServiceProvider)
        .shareFile(
          Uint8List.fromList(utf8.encode(text)),
          name: 'kitabkhana-diagnostics.txt',
          mimeType: 'text/plain',
        );
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final outcome = await ref
        .read(problemReporterProvider)
        .send(
          schemaVersion: ref.read(appDatabaseProvider).schemaVersion,
          locale: AppLocalizations.of(context).localeName,
          now: ref.read(clockProvider).now(),
          logLines: ref.read(appLoggerProvider).lines,
        );
    if (context.mounted) showReportOutcome(context, outcome);
  }

  Future<void> _feedback(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final config = ref.read(appConfigProvider);
    final uri = Uri(
      scheme: 'mailto',
      path: kFeedbackEmail,
      queryParameters: <String, String>{
        'subject': l10n.settingsFeedbackSubject,
        'body': '\n\n${config.appName} ${config.version}',
      },
    );
    final ok = await ref.read(externalLauncherProvider).open(uri);
    if (!ok && context.mounted) {
      KToast.showWith(
        ScaffoldMessenger.of(context),
        l10n.failureUnexpected,
        icon: Icons.error_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      title: l10n.settingsHelp,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(l10n.settingsDiagnostics),
          subtitle: Text(l10n.settingsDiagnosticsBody),
          onTap: () => _diagnostics(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.bug_report_outlined),
          title: Text(l10n.settingsReportProblem),
          subtitle: Text(l10n.settingsReportProblemBody),
          onTap: () => _report(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.mail_outline_rounded),
          title: Text(l10n.settingsFeedback),
          onTap: () => _feedback(context, ref),
        ),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      title: l10n.settingsAbout,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.info_outline_rounded),
          title: Text(l10n.aboutTitle),
          subtitle: Text(l10n.aboutVersion(kAppVersion)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(Routes.about),
        ),
      ],
    );
  }
}

/// A stepper for a whole number from 0 to [max].
class _NumberSheet extends StatefulWidget {
  const _NumberSheet({
    required this.title,
    required this.help,
    required this.initial,
    required this.max,
  });

  final String title;
  final String help;
  final int initial;
  final int max;

  @override
  State<_NumberSheet> createState() => _NumberSheetState();
}

class _NumberSheetState extends State<_NumberSheet> {
  late final TextEditingController _c = TextEditingController(
    text: '${widget.initial}',
  );
  String? _error;

  int? get _v => int.tryParse(_c.text.trim());

  void _step(int by) => setState(() {
    final next = ((_v ?? 0) + by).clamp(0, widget.max);
    _c.text = '$next';
    _error = null;
  });

  void _save() {
    final v = _v;
    if (v == null || v < 0 || v > widget.max) {
      setState(
        () =>
            _error = AppLocalizations.of(context).detailPageInvalid(widget.max),
      );
      return;
    }
    Navigator.of(context).pop(v);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: KSpacing.lg),
        Row(
          children: <Widget>[
            IconButton.filledTonal(
              tooltip: l10n.statsGoalFewer,
              icon: const Icon(Icons.remove_rounded),
              onPressed: () => _step(-1),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: TextField(
                controller: _c,
                autofocus: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  helperText: widget.help,
                  errorText: _error,
                ),
              ),
            ),
            const SizedBox(width: KSpacing.md),
            IconButton.filledTonal(
              tooltip: l10n.statsGoalMore,
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _step(1),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: _save, child: Text(l10n.save)),
        ),
      ],
    );
  }
}

/// A short digits-only text entry.
class _TextSheet extends StatefulWidget {
  const _TextSheet({
    required this.title,
    required this.help,
    required this.initial,
    required this.maxLength,
  });

  final String title;
  final String help;
  final String initial;
  final int maxLength;

  @override
  State<_TextSheet> createState() => _TextSheetState();
}

class _TextSheetState extends State<_TextSheet> {
  late final TextEditingController _c = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _save() {
    final digits = _c.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty) Navigator.of(context).pop(digits);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: KSpacing.lg),
        TextField(
          controller: _c,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: widget.maxLength,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onSubmitted: (_) => _save(),
          decoration: InputDecoration(
            prefixText: '+',
            helperText: widget.help,
            helperMaxLines: 3,
          ),
        ),
        const SizedBox(height: KSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: _save, child: Text(l10n.save)),
        ),
      ],
    );
  }
}
