import '../../../core/result.dart';
import 'app_settings.dart';

/// Reads and writes [AppSettings]. Each setter validates its input and
/// returns a `ValidationFailure` for something unusable.
abstract interface class SettingsRepository {
  /// Current settings; emits again after every change.
  Stream<AppSettings> watch();

  /// The settings right now (defaults for anything never set, or stored in a
  /// form that is not understood).
  Future<AppSettings> load();

  Future<Result<void>> setTheme(ThemePreference value);
  Future<Result<void>> setLibraryView(LibraryView value);
  Future<Result<void>> setGridDensity(GridDensity value);

  /// 0 (no due date) to 365.
  Future<Result<void>> setDefaultLoanDays(int days);

  /// Digits only, 1 to 4 of them.
  Future<Result<void>> setDefaultCountryCode(String code);
  Future<Result<void>> setLoanReminderTime(DayTime value);
  Future<Result<void>> setReadingReminderEnabled({required bool enabled});
  Future<Result<void>> setReadingReminderTime(DayTime value);
  Future<Result<void>> setCrashReports({required bool enabled});

  /// Whether the first-run introduction has been seen (or skipped).
  Future<bool> onboardingDone();

  Future<Result<void>> markOnboardingDone();
}
