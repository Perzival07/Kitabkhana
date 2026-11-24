import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/db_guard.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Settings stored as text in the device-local `app_meta` table (never
/// synced or backed up). Keys that earlier phases already used keep their
/// names, so nothing is lost on upgrade.
class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  static const themeKey = 'settings.theme';
  static const viewKey = 'library.view';
  static const densityKey = 'settings.density';
  static const loanDaysKey = 'settings.loan_days';
  static const countryKey = 'phone.default_cc';
  static const loanTimeKey = 'settings.loan_reminder_time';
  static const readingOnKey = 'settings.reading_reminder';
  static const readingTimeKey = 'settings.reading_reminder_time';
  static const crashKey = 'settings.crash_reports';
  static const onboardingKey = 'onboarding.done';

  AppSettings _from(Map<String, String> m) {
    T pick<T extends Enum>(List<T> values, String? name, T fallback) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    final days = int.tryParse(m[loanDaysKey] ?? '');
    final cc = m[countryKey];
    return AppSettings(
      theme: pick(ThemePreference.values, m[themeKey], ThemePreference.system),
      libraryView: pick(LibraryView.values, m[viewKey], LibraryView.grid),
      gridDensity: pick(
        GridDensity.values,
        m[densityKey],
        GridDensity.comfortable,
      ),
      defaultLoanDays: days != null && days >= 0 && days <= 365 ? days : 0,
      defaultCountryCode: cc != null && RegExp(r'^\d{1,4}$').hasMatch(cc)
          ? cc
          : AppSettings.defaults.defaultCountryCode,
      loanReminderTime:
          DayTime.parse(m[loanTimeKey]) ??
          AppSettings.defaults.loanReminderTime,
      readingReminderEnabled: m[readingOnKey] == 'on',
      readingReminderTime:
          DayTime.parse(m[readingTimeKey]) ??
          AppSettings.defaults.readingReminderTime,
      crashReports: m[crashKey] != 'off',
    );
  }

  static const _keys = <String>{
    themeKey,
    viewKey,
    densityKey,
    loanDaysKey,
    countryKey,
    loanTimeKey,
    readingOnKey,
    readingTimeKey,
    crashKey,
  };

  Map<String, String> _map(List<AppMetaRow> rows) => <String, String>{
    for (final r in rows)
      if (_keys.contains(r.key)) r.key: r.value,
  };

  @override
  Future<AppSettings> load() async =>
      _from(_map(await _db.select(_db.appMeta).get()));

  @override
  Stream<AppSettings> watch() =>
      _db.select(_db.appMeta).watch().map((rows) => _from(_map(rows)));

  Future<Result<void>> _put(String key, String value) => dbGuard(
    () => _db
        .into(_db.appMeta)
        .insertOnConflictUpdate(
          AppMetaCompanion.insert(key: key, value: value),
        ),
  );

  Result<void> _bad(String field) =>
      Err(ValidationFailure(field: field, messageKey: 'failureValidation'));

  @override
  Future<Result<void>> setTheme(ThemePreference value) =>
      _put(themeKey, value.name);

  @override
  Future<Result<void>> setLibraryView(LibraryView value) =>
      _put(viewKey, value.name);

  @override
  Future<Result<void>> setGridDensity(GridDensity value) =>
      _put(densityKey, value.name);

  @override
  Future<Result<void>> setDefaultLoanDays(int days) async =>
      days < 0 || days > 365
      ? _bad('defaultLoanDays')
      : _put(loanDaysKey, '$days');

  @override
  Future<Result<void>> setDefaultCountryCode(String code) async {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty || digits.length > 4) return _bad('defaultCountryCode');
    return _put(countryKey, digits);
  }

  @override
  Future<Result<void>> setLoanReminderTime(DayTime value) =>
      _put(loanTimeKey, value.text);

  @override
  Future<Result<void>> setReadingReminderEnabled({required bool enabled}) =>
      _put(readingOnKey, enabled ? 'on' : 'off');

  @override
  Future<Result<void>> setReadingReminderTime(DayTime value) =>
      _put(readingTimeKey, value.text);

  @override
  Future<Result<void>> setCrashReports({required bool enabled}) =>
      _put(crashKey, enabled ? 'on' : 'off');

  @override
  Future<bool> onboardingDone() async {
    final row = await (_db.select(
      _db.appMeta,
    )..where((t) => t.key.equals(onboardingKey))).getSingleOrNull();
    return row?.value == '1';
  }

  @override
  Future<Result<void>> markOnboardingDone() => _put(onboardingKey, '1');
}
