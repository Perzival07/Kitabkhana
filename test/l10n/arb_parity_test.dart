import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, String> _messages(String path) => <String, String>{
  for (final e in (jsonDecode(
    File(path).readAsStringSync(),
  ) as Map<String, dynamic>).entries)
    if (!e.key.startsWith('@')) e.key: e.value as String,
};

/// `{name}` and `{name, plural, ...}` arguments of a message.
Set<String> _args(String message) =>
    RegExp(r'\{(\w+)[,}]').allMatches(message).map((m) => m.group(1)!).toSet();

/// The plural cases used (`=0{`, `one{`, `other{`, ...).
List<String> _cases(String message) =>
    RegExp(r'(?:=\d+|zero|one|two|few|many|other)\{')
        .allMatches(message)
        .map((m) => m.group(0)!)
        .toList()
      ..sort();

void main() {
  final en = _messages('lib/l10n/app_en.arb');

  for (final locale in <String>['hi', 'bn']) {
    final tr = _messages('lib/l10n/app_$locale.arb');

    test('app_$locale.arb translates every message', () {
      expect(en.keys.toSet().difference(tr.keys.toSet()), isEmpty);
      expect(tr.keys.toSet().difference(en.keys.toSet()), isEmpty);
    });

    test('app_$locale.arb keeps every placeholder and plural case', () {
      for (final key in en.keys) {
        expect(_args(tr[key]!), _args(en[key]!), reason: '$locale $key');
        expect(_cases(tr[key]!), _cases(en[key]!), reason: '$locale $key');
        expect(tr[key]!.trim(), isNotEmpty, reason: '$locale $key');
      }
    });
  }

  test('every English message has a non-empty string', () {
    for (final e in en.entries) {
      expect(e.value.trim(), isNotEmpty, reason: e.key);
    }
  });
}
