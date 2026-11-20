import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/reminders/application/loan_nudge.dart';
import '../features/reminders/application/loan_reminder_service.dart';
import '../features/reminders/domain/notification_scheduler.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../platform/notifications/mobile_notification_scheduler.dart';
import '../platform/notifications/url_nudge_launcher.dart';
import 'providers.dart';
import 'repositories.dart';

part 'reminder_providers.g.dart';

/// The book id of a notification the user just tapped, for the router.
@Riverpod(keepAlive: true)
class NotificationTap extends _$NotificationTap {
  @override
  String? build() => null;

  void tapped(String bookId) => state = bookId;
  void handled() => state = null;
}

AppLocalizations _currentL10n() {
  try {
    return lookupAppLocalizations(PlatformDispatcher.instance.locale);
  } on Object {
    return AppLocalizationsEn();
  }
}

/// Local notifications on phones; nothing on the web.
@Riverpod(keepAlive: true)
NotificationScheduler notificationScheduler(Ref ref) {
  if (kIsWeb) return const UnsupportedNotificationScheduler();
  final l10n = _currentL10n();
  return MobileNotificationScheduler(
    channelName: l10n.reminderChannelName,
    channelDescription: l10n.reminderChannelDesc,
    onTap: (bookId) =>
        ref.read(notificationTapProvider.notifier).tapped(bookId),
  );
}

@Riverpod(keepAlive: true)
LoanReminderService loanReminderService(Ref ref) => LoanReminderService(
  scheduler: ref.watch(notificationSchedulerProvider),
  loans: ref.watch(loanRepositoryProvider),
  books: ref.watch(bookRepositoryProvider),
  clock: ref.watch(clockProvider),
  l10n: _currentL10n,
);

@Riverpod(keepAlive: true)
LoanNudge loanNudge(Ref ref) => LoanNudge(const UrlNudgeLauncher());
