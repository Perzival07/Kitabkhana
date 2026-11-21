import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/lending/application/lending_use_cases.dart';
import '../features/lending/domain/reminder_service.dart';
import '../features/settings/domain/app_settings.dart';
import 'reminder_providers.dart';
import 'providers.dart';
import 'repositories.dart';
import 'settings_providers.dart';

part 'lending_providers.g.dart';

/// Schedules loan reminders (local notifications; none on the web).
@Riverpod(keepAlive: true)
ReminderService reminderService(Ref ref) =>
    ref.watch(loanReminderServiceProvider);

@Riverpod(keepAlive: true)
LendBook lendBook(Ref ref) => LendBook(
  loans: ref.watch(loanRepositoryProvider),
  books: ref.watch(bookRepositoryProvider),
  clock: ref.watch(clockProvider),
  reminders: ref.watch(reminderServiceProvider),
);

@Riverpod(keepAlive: true)
RecordBorrowedBook recordBorrowedBook(Ref ref) => RecordBorrowedBook(
  loans: ref.watch(loanRepositoryProvider),
  books: ref.watch(bookRepositoryProvider),
  clock: ref.watch(clockProvider),
  reminders: ref.watch(reminderServiceProvider),
);

@Riverpod(keepAlive: true)
ReturnLoan returnLoan(Ref ref) => ReturnLoan(
  loans: ref.watch(loanRepositoryProvider),
  locations: ref.watch(locationRepositoryProvider),
  clock: ref.watch(clockProvider),
  reminders: ref.watch(reminderServiceProvider),
);

@Riverpod(keepAlive: true)
ExtendDueDate extendDueDate(Ref ref) => ExtendDueDate(
  loans: ref.watch(loanRepositoryProvider),
  books: ref.watch(bookRepositoryProvider),
  clock: ref.watch(clockProvider),
  reminders: ref.watch(reminderServiceProvider),
);

/// Names of people from past loans, for autocomplete.
@riverpod
Future<List<String>> recentPeople(Ref ref) =>
    ref.watch(loanRepositoryProvider).recentPeople();

/// The country code (digits only) assumed for phone numbers typed without
/// one. Defaults to India (91); stored on this device.
@Riverpod(keepAlive: true)
class DefaultCountryCode extends _$DefaultCountryCode {
  @override
  String build() {
    _load();
    return AppSettings.defaults.defaultCountryCode;
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(settingsRepositoryProvider).load();
      if (ref.mounted) state = s.defaultCountryCode;
    } on Object catch (e) {
      ref
          .read(appLoggerProvider)
          .warn('Reading country code failed: ${e.runtimeType}');
    }
  }

  Future<void> set(String code) async {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty || digits.length > 4) return;
    state = digits;
    await ref.read(settingsRepositoryProvider).setDefaultCountryCode(digits);
  }
}
