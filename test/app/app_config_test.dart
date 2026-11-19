import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/app_config.dart';

void main() {
  test('kAppVersion matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(match, isNotNull);
    expect(kAppVersion, match!.group(1));
  });

  test('user agent omits the contact when none is configured', () {
    const config = AppConfig(
      flavor: Flavor.prod,
      appName: 'Kitabkhana',
      enableVerboseLogs: false,
      contactEmail: '',
      version: '1.2.3',
    );
    expect(config.userAgent, 'Kitabkhana/1.2.3');
  });

  test('user agent includes the configured contact', () {
    const config = AppConfig(
      flavor: Flavor.prod,
      appName: 'Kitabkhana',
      enableVerboseLogs: false,
      contactEmail: 'hello@example.org',
      version: '1.2.3',
    );
    expect(config.userAgent, 'Kitabkhana/1.2.3 (hello@example.org)');
  });

  test('no personal address is baked into the default config', () {
    expect(const AppConfig.prod().contactEmail, kContactEmail);
    expect(kContactEmail, isEmpty);
  });
}
