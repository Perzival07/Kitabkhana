import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/app_config.dart';
import 'package:kitabkhana/features/backup/application/auto_backup.dart';
import 'package:kitabkhana/features/settings/domain/app_settings.dart';

import '../../tool/privacy_page.dart';

/// The policy page is a promise. These tests tie its concrete claims to the
/// code, so the page and the app cannot drift apart without a test failing.
void main() {
  final policy = File('docs/privacy/privacy-policy.md').readAsStringSync();

  test('the published HTML is built from the current policy', () {
    expect(
      File('docs/privacy/index.html').readAsStringSync(),
      buildPrivacyPage(policy),
      reason: 'run: dart run tool/build_privacy_page.dart',
    );
  });

  test('the page is self-contained: no scripts, no outside resources', () {
    final html = buildPrivacyPage(policy);
    expect(html, isNot(contains('<script')));
    expect(html, isNot(contains('<link')));
    expect(html, isNot(contains('<img')));
    expect(html, contains("default-src 'none'"));
  });

  test('it names the hosts the app talks to, and the app version it sends', () {
    expect(policy, contains('openlibrary.org'));
    expect(policy, contains('covers.openlibrary.org'));
    expect(policy, contains('archive.org'));
    expect(policy, contains('Kitabkhana/$kAppVersion'));
  });

  test('crash reports are said to be off, and are', () {
    expect(policy, contains('off by default'));
    expect(AppSettings.defaults.crashReports, isFalse);
  });

  test('the automatic backup count in the policy is the real one', () {
    expect(policy, contains('newest three'));
    expect(autoBackupKeep, 3);
  });

  test('the controls it points to exist in Settings', () {
    final strings = File('lib/l10n/app_en.arb').readAsStringSync();
    for (final label in <String>[
      'Erase all data',
      'Share a backup',
      'Export as spreadsheet',
      'Send crash reports',
    ]) {
      expect(strings, contains('"$label'), reason: label);
    }
    expect(policy, contains('Erase all data'));
    expect(policy, contains('Share a backup'));
  });

  test('it makes no promise the app does not keep', () {
    // Words that would mean a server or a tracker exists.
    for (final w in <String>['sync across', 'we collect', 'we store your']) {
      expect(policy.toLowerCase(), isNot(contains(w)), reason: w);
    }
  });
}
