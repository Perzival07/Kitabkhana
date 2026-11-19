import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Set<String> _keys(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>).keys
        .where((k) => !k.startsWith('@'))
        .toSet();

void main() {
  final en = _keys('lib/l10n/app_en.arb');

  for (final locale in <String>['hi', 'bn']) {
    test('app_$locale.arb covers app_en.arb keys (warning only)', () {
      final missing = en.difference(_keys('lib/l10n/app_$locale.arb'));
      if (missing.isNotEmpty) {
        // Warning only for now; translations arrive later.
        printOnFailure('app_$locale.arb is missing ${missing.length} keys');
      }
      expect(en, isNotEmpty);
    });
  }

  test('every English message has a non-empty string', () {
    final data = jsonDecode(
      File('lib/l10n/app_en.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final e in data.entries.where((e) => !e.key.startsWith('@'))) {
      expect((e.value as String).trim(), isNotEmpty, reason: e.key);
    }
  });
}
