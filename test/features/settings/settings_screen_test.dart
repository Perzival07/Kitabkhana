import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/backup_providers.dart';
import 'package:kitabkhana/app/library_providers.dart';
import 'package:kitabkhana/app/settings_providers.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/features/backup/application/auto_backup.dart';
import 'package:kitabkhana/features/backup/application/export_backup.dart';
import 'package:kitabkhana/features/backup/data/backup_store.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/reminders/domain/reminder_plan.dart';
import 'package:kitabkhana/features/settings/application/diagnostics.dart';
import 'package:kitabkhana/features/settings/data/drift_settings_repository.dart';
import 'package:kitabkhana/features/settings/domain/app_settings.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/fake_backup_folder.dart';
import '../../helpers/fake_launcher.dart';
import '../../helpers/pump_router_app.dart';

void main() {
  late AddFlowHarness h;
  late FakeBackupFolder folder;
  late FakeLauncher launcher;

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  List<Override> overrides() => <Override>[
    ...h.overrides,
    backupFolderProvider.overrideWithValue(folder),
    externalLauncherProvider.overrideWithValue(launcher),
    exportBackupProvider.overrideWithValue(
      ExportBackup(
        store: BackupStore(h.db),
        covers: h.covers,
        clock: h.clock,
        appVersion: '1.0.0',
      ),
    ),
  ];

  Future<ProviderContainer> open(
    WidgetTester t, {
    String at = '/settings',
    Size size = const Size(420, 900),
  }) async {
    final c = await pumpRouterApp(t, size: size, overrides: overrides());
    routerOf(c).go(at);
    await t.pumpAndSettle();
    return c;
  }

  Future<void> reveal(WidgetTester t, String text) async {
    await t.scrollUntilVisible(
      find.text(text),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await t.pumpAndSettle();
  }

  Future<AppSettings> stored(WidgetTester t) async =>
      (await t.runAsync(() => DriftSettingsRepository(h.db).load()))!;

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  setUp(() {
    folder = FakeBackupFolder();
    launcher = FakeLauncher();
  });

  testWidgets('shows every section with its settings', (t) async {
    h = AddFlowHarness();
    await open(t, size: const Size(420, 3200));
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Default library view'), findsOneWidget);
    expect(find.text('Grid density'), findsOneWidget);
    await reveal(t, 'Default loan length');
    for (final s in [
      'Reading',
      'Yearly goal',
      'Daily reading reminder',
      'Lending',
      'Default country code',
      'Loan reminder time',
    ]) {
      expect(find.text(s), findsOneWidget, reason: s);
    }
    await reveal(t, 'Erase all data');
    for (final s in [
      'Your data',
      'Back up now',
      'Automatic weekly backup',
      'Share a backup',
      'Restore from backup',
      'Export as spreadsheet (CSV)',
    ]) {
      expect(find.text(s), findsOneWidget, reason: s);
    }
    await reveal(t, 'Send feedback');
    for (final s in [
      'Privacy',
      'Send crash reports',
      'Help',
      'Export diagnostics',
    ]) {
      expect(find.text(s), findsOneWidget, reason: s);
    }
    await end(t);
  });

  testWidgets('changing the theme applies at once and is remembered', (
    t,
  ) async {
    h = AddFlowHarness();
    final c = await open(t);
    expect(c.read(themeModeControllerProvider), ThemeMode.system);
    expect(
      t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );

    await t.tap(find.text('Dark'));
    await t.pumpAndSettle();
    expect(c.read(themeModeControllerProvider), ThemeMode.dark);
    expect(
      t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect((await stored(t)).theme, ThemePreference.dark);

    await t.tap(find.text('Light'));
    await t.pumpAndSettle();
    expect(
      t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    expect((await stored(t)).theme, ThemePreference.light);
    await end(t);
  });

  testWidgets('settings persist across a restart', (t) async {
    h = AddFlowHarness();
    await open(t);
    await t.tap(find.text('Dark'));
    await t.pumpAndSettle();
    await t.tap(find.text('List'));
    await t.pumpAndSettle();
    await t.tap(find.text('Compact'));
    await t.pumpAndSettle();
    await end(t);

    // A brand-new app over the same database: the choices are still there.
    final c = await open(t);
    await t.pump(const Duration(milliseconds: 100));
    expect(c.read(themeModeControllerProvider), ThemeMode.dark);
    expect(c.read(libraryViewControllerProvider), LibraryView.list);
    expect(c.read(appSettingsProvider).gridDensity, GridDensity.compact);
    await end(t);
  });

  testWidgets('default loan length is saved and the Lend sheet starts there', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(id: 'b', title: 'Emma', now: DateTime(2025, 3, 10)),
      ),
    );
    await open(t);
    await reveal(t, 'Default loan length');
    expect(find.text('No due date'), findsOneWidget);
    await t.tap(find.text('Default loan length'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '14');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(find.text('14 days'), findsOneWidget);
    expect((await stored(t)).defaultLoanDays, 14);
    await end(t);
  });

  testWidgets('a loan length out of range is refused', (t) async {
    h = AddFlowHarness();
    await open(t);
    await reveal(t, 'Default loan length');
    await t.tap(find.text('Default loan length'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '999');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(find.text('Enter a number from 0 to 365'), findsOneWidget);
    expect((await stored(t)).defaultLoanDays, 0);
    await end(t);
  });

  testWidgets('the default country code is saved', (t) async {
    h = AddFlowHarness();
    final c = await open(t);
    await reveal(t, 'Default country code');
    expect(find.text('+91'), findsOneWidget);
    await t.tap(find.text('Default country code'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '44');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(find.text('+44'), findsOneWidget);
    expect((await stored(t)).defaultCountryCode, '44');
    expect(c.read(appSettingsProvider).defaultCountryCode, '44');
    await end(t);
  });

  testWidgets(
    'the daily reading reminder schedules, and turning it off clears',
    (t) async {
      h = AddFlowHarness();
      await open(t);
      await reveal(t, 'Daily reading reminder');
      expect(find.text('Reminder time'), findsNothing);
      await t.tap(find.byType(Switch).first);
      await t.pumpAndSettle();
      // The permission explanation may appear; accept it if so.
      if (find.text('Allow').evaluate().isNotEmpty) {
        await t.tap(find.text('Allow'));
        await t.pumpAndSettle();
      }
      expect((await stored(t)).readingReminderEnabled, isTrue);
      await t.pump(const Duration(milliseconds: 200));
      expect(
        h.scheduler.pending.keys.where(isReadingReminderId),
        hasLength(kReadingReminderDays),
      );
      expect(find.text('Reminder time'), findsOneWidget);

      await t.tap(find.byType(Switch).first);
      await t.pumpAndSettle();
      expect((await stored(t)).readingReminderEnabled, isFalse);
      expect(h.scheduler.pending.keys.where(isReadingReminderId), isEmpty);
      await end(t);
    },
  );

  testWidgets('the yearly goal can be set from here', (t) async {
    h = AddFlowHarness();
    await open(t);
    await reveal(t, 'Yearly goal');
    expect(find.text('Not set for 2025'), findsOneWidget);
    await t.tap(find.text('Yearly goal'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '24');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(find.text('24 books in 2025'), findsOneWidget);
    await end(t);
  });

  testWidgets('Back up now saves to the device and shows when', (t) async {
    h = AddFlowHarness();
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(id: 'b', title: 'Emma', now: DateTime(2025, 3, 10)),
      ),
    );
    await open(t);
    await reveal(t, 'Back up now');
    expect(find.text('Not backed up yet'), findsOneWidget);
    await t.tap(find.text('Back up now'));
    await t.pumpAndSettle();
    expect(find.text('Backup saved on this device.'), findsOneWidget);
    expect(folder.files.keys.single, startsWith(autoBackupPrefix));
    expect(find.text('Last backup: today'), findsOneWidget);

    h.clock.advance(const Duration(days: 4));
    await end(t);
    await open(t);
    await reveal(t, 'Back up now');
    expect(find.text('Last backup: 4 days ago'), findsOneWidget);
    await end(t);
  });

  testWidgets('the automatic backup switch is remembered', (t) async {
    h = AddFlowHarness();
    await open(t);
    await reveal(t, 'Automatic weekly backup');
    Switch sw() => t.widget<Switch>(
      find.descendant(
        of: find.widgetWithText(SwitchListTile, 'Automatic weekly backup'),
        matching: find.byType(Switch),
      ),
    );
    expect(sw().value, isTrue);
    await t.tap(find.text('Automatic weekly backup'));
    await t.pumpAndSettle();
    expect(sw().value, isFalse);
    final off = await t.runAsync(() async {
      return !(await DbBackupPrefsProbe(h).autoEnabled());
    });
    expect(off, isTrue);
    await end(t);
  });

  testWidgets('no automatic-backup switch where there is no folder', (t) async {
    h = AddFlowHarness();
    folder = FakeBackupFolder(supported: false);
    await open(t);
    await reveal(t, 'Back up now');
    expect(find.text('Automatic weekly backup'), findsNothing);
    await end(t);
  });

  testWidgets('crash reports are off by default and can be turned on', (
    t,
  ) async {
    h = AddFlowHarness();
    await open(t);
    await reveal(t, 'Send crash reports');
    Switch sw() => t.widget<Switch>(
      find.descendant(
        of: find.widgetWithText(SwitchListTile, 'Send crash reports'),
        matching: find.byType(Switch),
      ),
    );
    expect(sw().value, isFalse);
    await t.tap(find.text('Send crash reports'));
    await t.pumpAndSettle();
    expect(sw().value, isTrue);
    expect((await stored(t)).crashReports, isTrue);
    await end(t);
  });

  testWidgets('diagnostics hold versions and no library contents', (t) async {
    h = AddFlowHarness();
    await t.runAsync(
      () => h.repos.books.upsert(
        Book.create(
          id: 'b',
          title: 'Secret Title',
          authors: 'Secret Author',
          now: DateTime(2025, 3, 10),
        ),
      ),
    );
    await open(t);
    await reveal(t, 'Export diagnostics');
    await t.tap(find.text('Export diagnostics'));
    await t.pumpAndSettle();
    final file = h.share.files.single;
    expect(file.name, 'kitabkhana-diagnostics.txt');
    final text = utf8.decode(file.bytes);
    expect(text, contains('diagnostics'));
    expect(text, contains('App version: 1.0.0'));
    expect(text, contains('Database schema:'));
    expect(text, contains('No library contents'));
    expect(text, isNot(contains('Secret')));
    await end(t);
  });

  testWidgets('Send feedback opens the mail app', (t) async {
    h = AddFlowHarness();
    await open(t);
    await reveal(t, 'Send feedback');
    await t.tap(find.text('Send feedback'));
    await t.pumpAndSettle();
    final uri = launcher.opened.single;
    expect(uri.scheme, 'mailto');
    expect(uri.queryParameters['subject'], 'Kitabkhana feedback');
    expect(uri.queryParameters['body'], contains('1.0.0'));
    await end(t);
  });

  testWidgets('a mail app that cannot open says so', (t) async {
    h = AddFlowHarness();
    launcher.ok = false;
    await open(t);
    await reveal(t, 'Send feedback');
    await t.tap(find.text('Send feedback'));
    await t.pumpAndSettle();
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    await end(t);
  });

  testWidgets('no overflow at 320dp and 200% text', (t) async {
    h = AddFlowHarness();
    final c = await pumpRouterApp(
      t,
      size: const Size(320, 640),
      textScale: 2,
      overrides: overrides(),
    );
    routerOf(c).go('/settings');
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    await end(t);
  });

  group('diagnostics helpers', () {
    test('daysSince counts calendar days', () {
      final today = DateTime(2025, 3, 10, 0, 5);
      expect(daysSince(null, today), isNull);
      expect(daysSince(DateTime(2025, 3, 10, 23, 59), today)!.days, 0);
      expect(daysSince(DateTime(2025, 3, 9, 23, 59), today)!.days, 1);
      expect(daysSince(DateTime(2025, 3, 3), today)!.days, 7);
      expect(
        daysSince(DateTime(2025, 3, 20), today)!.days,
        0,
        reason: 'future',
      );
    });

    test('the report lists lines and warns nothing private is inside', () {
      final text = buildDiagnostics(
        appName: 'Kitabkhana',
        appVersion: '1.0.0',
        schemaVersion: 2,
        platform: 'android',
        locale: 'en',
        generatedAt: DateTime.utc(2025, 3, 10),
        logLines: <String>['a', 'b'],
      );
      expect(text, contains('Recent messages (2):\na\nb'));
      expect(text, contains('Generated: 2025-03-10T00:00:00.000Z'));
    });
  });
}

/// Reads the stored automatic-backup flag the way the app does.
class DbBackupPrefsProbe {
  DbBackupPrefsProbe(this.h);
  final AddFlowHarness h;
  Future<bool> autoEnabled() async {
    final row = await h.db
        .customSelect("SELECT value FROM app_meta WHERE key = 'backup.auto'")
        .getSingleOrNull();
    return row?.read<String>('value') != 'off';
  }
}
