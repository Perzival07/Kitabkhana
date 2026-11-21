import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app's own platform files must keep the privacy promises: nothing
/// leaves the device by backup, no plain HTTP, only the permissions the
/// features need, and no tracking. (Plugins add their own entries when the
/// app is built; `docs/PRIVACY.md` says how to check the merged result.)
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();
  final plist = File('ios/Runner/Info.plist').readAsStringSync();

  Set<String> permissions(String xml) =>
      RegExp(r'<uses-permission[^>]*android:name="([^"]+)"')
          .allMatches(xml)
          .map((m) => m.group(1)!)
          .toSet();

  group('Android', () {
    test('asks for exactly the permissions the features need', () {
      expect(permissions(manifest), <String>{
        'android.permission.INTERNET', // Open Library lookups
        'android.permission.CAMERA', // barcode scanning, covers, quotes
        'android.permission.POST_NOTIFICATIONS', // loan and reading reminders
        'android.permission.RECEIVE_BOOT_COMPLETED', // re-arm reminders
      });
    });

    test('never asks for alarms, storage, location, audio or contacts', () {
      const never = <String>[
        'SCHEDULE_EXACT_ALARM',
        'USE_EXACT_ALARM',
        'READ_EXTERNAL_STORAGE',
        'WRITE_EXTERNAL_STORAGE',
        'MANAGE_EXTERNAL_STORAGE',
        'READ_MEDIA',
        'ACCESS_FINE_LOCATION',
        'ACCESS_COARSE_LOCATION',
        'RECORD_AUDIO',
        'READ_CONTACTS',
        'READ_PHONE_STATE',
        'READ_SMS',
        'SEND_SMS',
        'AD_ID',
      ];
      for (final p in never) {
        expect(manifest, isNot(contains(p)), reason: p);
      }
    });

    test('the camera is optional, so non-camera devices can install', () {
      expect(
        manifest,
        contains(
          'android:name="android.hardware.camera" android:required="false"',
        ),
      );
    });

    test('no cloud backup and no device-to-device copy of the library', () {
      expect(manifest, contains('android:allowBackup="false"'));
      expect(manifest, contains('android:fullBackupContent="false"'));
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
      final rules = File(
        'android/app/src/main/res/xml/data_extraction_rules.xml',
      ).readAsStringSync();
      for (final section in <String>['cloud-backup', 'device-transfer']) {
        final block = RegExp(
          '<$section>(.*?)</$section>',
          dotAll: true,
        ).firstMatch(rules)!.group(1)!;
        for (final domain in <String>[
          'root',
          'file',
          'database',
          'sharedpref',
          'external',
        ]) {
          expect(
            block,
            contains('<exclude domain="$domain" />'),
            reason: '$section $domain',
          );
        }
        expect(block, isNot(contains('<include')), reason: section);
      }
    });

    test('HTTPS only', () {
      expect(manifest, contains('android:usesCleartextTraffic="false"'));
      expect(
        manifest,
        contains(
          'android:networkSecurityConfig="@xml/network_security_config"',
        ),
      );
      final config = File(
        'android/app/src/main/res/xml/network_security_config.xml',
      ).readAsStringSync();
      expect(config, contains('cleartextTrafficPermitted="false"'));
      expect(config, isNot(contains('cleartextTrafficPermitted="true"')));
      expect(config, isNot(contains('<domain-config')));
      expect(config, isNot(contains('user"'))); // no user-installed CAs
    });

    test('only the main activity is exported', () {
      final exported = RegExp(r'android:exported="true"').allMatches(manifest);
      expect(exported, hasLength(1));
    });
  });

  group('iOS', () {
    test('plain HTTP is not allowed anywhere', () {
      expect(plist, isNot(contains('NSAppTransportSecurity')));
      expect(plist, isNot(contains('NSAllowsArbitraryLoads')));
    });

    test('only the camera and photo picker strings, in plain words', () {
      final keys = RegExp(r'<key>(NS[A-Za-z]+)</key>')
          .allMatches(plist)
          .map((m) => m.group(1)!)
          .toSet();
      expect(keys, <String>{
        'NSCameraUsageDescription',
        'NSPhotoLibraryUsageDescription',
      });
      for (final k in keys) {
        final text = RegExp('<key>$k</key>\\s*<string>([^<]*)</string>')
            .firstMatch(plist)!
            .group(1)!;
        expect(
          text.length,
          greaterThan(60),
          reason: '$k should explain itself',
        );
        expect(
          text,
          contains('never uploaded').or(contains('stays on your phone')),
          reason: '$k says where the data goes',
        );
      }
    });

    test('no tracking', () {
      expect(plist, isNot(contains('NSUserTrackingUsageDescription')));
      expect(plist, isNot(contains('SKAdNetwork')));
    });
  });
}

extension on Matcher {
  Matcher or(Matcher other) => anyOf(this, other);
}
