import '../../library/application/library_query.dart' show LibraryView;

export '../../library/application/library_query.dart' show LibraryView;

enum ThemePreference { system, light, dark }

enum GridDensity {
  /// The usual cover size.
  comfortable,

  /// One more column, for bigger libraries.
  compact,
}

/// A time of day without a date or zone.
final class DayTime {
  const DayTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  final int hour;
  final int minute;

  /// `HH:mm`, or null when [text] is not a valid time.
  static DayTime? parse(String? text) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text ?? '');
    if (m == null) return null;
    final h = int.parse(m[1]!);
    final min = int.parse(m[2]!);
    if (h > 23 || min > 59) return null;
    return DayTime(h, min);
  }

  String get text =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is DayTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => text;
}

/// Everything the reader can set in Settings, with its default.
final class AppSettings {
  const AppSettings({
    this.theme = ThemePreference.system,
    this.libraryView = LibraryView.grid,
    this.gridDensity = GridDensity.comfortable,
    this.defaultLoanDays = 0,
    this.defaultCountryCode = '91',
    this.loanReminderTime = const DayTime(10, 0),
    this.readingReminderEnabled = false,
    this.readingReminderTime = const DayTime(20, 0),
    this.crashReports = true,
  });

  static const defaults = AppSettings();

  final ThemePreference theme;
  final LibraryView libraryView;
  final GridDensity gridDensity;

  /// Days a new loan is due after it starts; 0 means no due date.
  final int defaultLoanDays;

  /// Digits only, assumed for phone numbers typed without one.
  final String defaultCountryCode;

  /// When loan reminders arrive on their day.
  final DayTime loanReminderTime;

  /// A daily nudge to read.
  final bool readingReminderEnabled;
  final DayTime readingReminderTime;

  /// Whether to offer, after a problem, to email a report to the developer.
  /// On by default: the offer is only an offer, and nothing leaves the device
  /// unless the reader presses Send in their own mail app.
  final bool crashReports;

  AppSettings copyWith({
    ThemePreference? theme,
    LibraryView? libraryView,
    GridDensity? gridDensity,
    int? defaultLoanDays,
    String? defaultCountryCode,
    DayTime? loanReminderTime,
    bool? readingReminderEnabled,
    DayTime? readingReminderTime,
    bool? crashReports,
  }) => AppSettings(
    theme: theme ?? this.theme,
    libraryView: libraryView ?? this.libraryView,
    gridDensity: gridDensity ?? this.gridDensity,
    defaultLoanDays: defaultLoanDays ?? this.defaultLoanDays,
    defaultCountryCode: defaultCountryCode ?? this.defaultCountryCode,
    loanReminderTime: loanReminderTime ?? this.loanReminderTime,
    readingReminderEnabled:
        readingReminderEnabled ?? this.readingReminderEnabled,
    readingReminderTime: readingReminderTime ?? this.readingReminderTime,
    crashReports: crashReports ?? this.crashReports,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.theme == theme &&
      other.libraryView == libraryView &&
      other.gridDensity == gridDensity &&
      other.defaultLoanDays == defaultLoanDays &&
      other.defaultCountryCode == defaultCountryCode &&
      other.loanReminderTime == loanReminderTime &&
      other.readingReminderEnabled == readingReminderEnabled &&
      other.readingReminderTime == readingReminderTime &&
      other.crashReports == crashReports;

  @override
  int get hashCode => Object.hash(
    theme,
    libraryView,
    gridDensity,
    defaultLoanDays,
    defaultCountryCode,
    loanReminderTime,
    readingReminderEnabled,
    readingReminderTime,
    crashReports,
  );
}
