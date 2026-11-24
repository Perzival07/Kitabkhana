import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/data/db/app_database.dart';
import 'package:kitabkhana/features/settings/data/drift_settings_repository.dart';
import 'package:kitabkhana/features/settings/domain/app_settings.dart';

import '../../helpers/test_db.dart';

void main() {
  late DriftSettingsRepository repo;
  late AppDatabase db;

  setUp(() {
    db = createTestDb();
    repo = DriftSettingsRepository(db);
  });
  tearDown(() => db.close());

  Future<void> raw(String key, String value) => db.customStatement(
    "INSERT OR REPLACE INTO app_meta (key, value) VALUES ('$key', '$value')",
  );

  test('a fresh install has the defaults', () async {
    expect(await repo.load(), AppSettings.defaults);
    expect(AppSettings.defaults.defaultLoanDays, 0);
    expect(AppSettings.defaults.defaultCountryCode, '91');
    expect(AppSettings.defaults.loanReminderTime, const DayTime(10, 0));
    expect(AppSettings.defaults.readingReminderEnabled, isFalse);
    expect(AppSettings.defaults.crashReports, isTrue);
  });

  test('every setting round-trips', () async {
    await repo.setTheme(ThemePreference.dark);
    await repo.setLibraryView(LibraryView.list);
    await repo.setGridDensity(GridDensity.compact);
    await repo.setDefaultLoanDays(21);
    await repo.setDefaultCountryCode('44');
    await repo.setLoanReminderTime(const DayTime(8, 5));
    await repo.setReadingReminderEnabled(enabled: true);
    await repo.setReadingReminderTime(const DayTime(21, 30));
    await repo.setCrashReports(enabled: false);
    expect(
      await repo.load(),
      const AppSettings(
        theme: ThemePreference.dark,
        libraryView: LibraryView.list,
        gridDensity: GridDensity.compact,
        defaultLoanDays: 21,
        defaultCountryCode: '44',
        loanReminderTime: DayTime(8, 5),
        readingReminderEnabled: true,
        readingReminderTime: DayTime(21, 30),
        crashReports: false,
      ),
    );
  });

  test(
    'settings survive a restart (a new repository over the same data)',
    () async {
      await repo.setTheme(ThemePreference.light);
      await repo.setDefaultLoanDays(7);
      final again = DriftSettingsRepository(db);
      final s = await again.load();
      expect(s.theme, ThemePreference.light);
      expect(s.defaultLoanDays, 7);
    },
  );

  test('watch emits again after each change', () async {
    final seen = <AppSettings>[];
    final sub = repo.watch().listen(seen.add);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await repo.setGridDensity(GridDensity.compact);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await repo.setTheme(ThemePreference.dark);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub.cancel();
    expect(seen.first, AppSettings.defaults);
    expect(seen.last.gridDensity, GridDensity.compact);
    expect(seen.last.theme, ThemePreference.dark);
  });

  test('earlier phases keep their keys', () async {
    await raw('library.view', 'list');
    await raw('phone.default_cc', '1');
    final s = await repo.load();
    expect(s.libraryView, LibraryView.list);
    expect(s.defaultCountryCode, '1');
  });

  test('unreadable stored values fall back to the defaults', () async {
    await raw('settings.theme', 'neon');
    await raw('settings.density', '');
    await raw('settings.loan_days', 'many');
    await raw('settings.loan_reminder_time', '25:99');
    await raw('settings.reading_reminder_time', 'noon');
    await raw('phone.default_cc', 'abc');
    expect(await repo.load(), AppSettings.defaults);
  });

  test('out-of-range loan days are refused', () async {
    for (final d in [-1, 366, 10000]) {
      final r = await repo.setDefaultLoanDays(d);
      expect((r as Err).failure, isA<ValidationFailure>(), reason: '$d');
    }
    expect((await repo.setDefaultLoanDays(0)).isOk, isTrue);
    expect((await repo.setDefaultLoanDays(365)).isOk, isTrue);
  });

  test('country code keeps only digits, 1 to 4 of them', () async {
    expect((await repo.setDefaultCountryCode('+44')).isOk, isTrue);
    expect((await repo.load()).defaultCountryCode, '44');
    for (final bad in ['', 'abc', '12345', '+']) {
      expect(
        (await repo.setDefaultCountryCode(bad)).isOk,
        isFalse,
        reason: bad,
      );
    }
    expect((await repo.load()).defaultCountryCode, '44');
  });

  test('DayTime parses and prints HH:mm', () {
    expect(DayTime.parse('9:05'), const DayTime(9, 5));
    expect(DayTime.parse('09:05'), const DayTime(9, 5));
    expect(const DayTime(9, 5).text, '09:05');
    for (final bad in [null, '', '24:00', '12:60', '1230', 'a:b']) {
      expect(DayTime.parse(bad), isNull, reason: '$bad');
    }
  });
}
