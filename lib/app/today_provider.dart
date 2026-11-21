import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// The calendar day, kept current. Anything that depends on "today" (the
/// reading streak, today's pages, loan due labels, the goal year) should
/// `ref.watch(todayProvider)` rather than read the clock once, so an app left
/// open past midnight, or resumed the next morning, shows the new day without a
/// restart. It changes at local midnight and when the app returns to the
/// foreground (a phone that slept through midnight may have skipped the timer).
/// Whether `todayProvider` arms a timer for midnight. The app turns it on in
/// `bootstrap`; it is off by default so widget tests do not end with a pending
/// timer (the resume hook works either way).
final Provider<bool> midnightTimerProvider = Provider<bool>((ref) => false);

final NotifierProvider<TodayNotifier, DateTime> todayProvider =
    NotifierProvider<TodayNotifier, DateTime>(TodayNotifier.new);

class TodayNotifier extends Notifier<DateTime> {
  Timer? _timer;
  AppLifecycleListener? _lifecycle;

  @override
  DateTime build() {
    final clock = ref.watch(clockProvider);
    _lifecycle = AppLifecycleListener(
      onResume: () => _refresh(clock.today(), clock.now()),
    );
    ref.onDispose(() {
      _timer?.cancel();
      _lifecycle?.dispose();
    });
    final today = clock.today();
    if (ref.watch(midnightTimerProvider)) _arm(clock.now(), today);
    return today;
  }

  void _arm(DateTime now, DateTime today) {
    _timer?.cancel();
    final nextMidnight = DateTime(today.year, today.month, today.day + 1);
    // A second of slack so the timer never fires just before midnight.
    final wait = nextMidnight.difference(now) + const Duration(seconds: 1);
    _timer = Timer(wait, () {
      final clock = ref.read(clockProvider);
      _refresh(clock.today(), clock.now());
    });
  }

  void _refresh(DateTime today, DateTime now) {
    if (today != state) state = today;
    if (ref.read(midnightTimerProvider)) _arm(now, today);
  }
}
