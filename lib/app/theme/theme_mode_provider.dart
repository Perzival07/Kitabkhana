import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/domain/app_settings.dart';
import '../providers.dart';
import '../settings_providers.dart';

part 'theme_mode_provider.g.dart';

ThemeMode _toMode(ThemePreference p) => switch (p) {
  ThemePreference.system => ThemeMode.system,
  ThemePreference.light => ThemeMode.light,
  ThemePreference.dark => ThemeMode.dark,
};

ThemePreference _toPreference(ThemeMode m) => switch (m) {
  ThemeMode.system => ThemePreference.system,
  ThemeMode.light => ThemePreference.light,
  ThemeMode.dark => ThemePreference.dark,
};

/// The theme the app shows. Changes apply at once and are remembered on this
/// device.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(settingsRepositoryProvider).load();
      if (ref.mounted) state = _toMode(s.theme);
    } on Object catch (e) {
      ref
          .read(appLoggerProvider)
          .warn('Reading theme failed: ${e.runtimeType}');
    }
  }

  void set(ThemeMode mode) {
    state = mode;
    unawaited(
      ref.read(settingsRepositoryProvider).setTheme(_toPreference(mode)),
    );
  }
}
