import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The web build's Content Security Policy must stay tight: no eval, no
/// inline scripts, nothing over plain HTTP, and only the hosts the app talks
/// to. Changing the policy should be a decision, not an accident.
void main() {
  final html = File('web/index.html').readAsStringSync();
  final meta = RegExp(
    r'http-equiv="Content-Security-Policy"\s+content="([^"]*)"',
  ).firstMatch(html);

  Map<String, List<String>> directives() {
    final out = <String, List<String>>{};
    for (final part in meta!.group(1)!.split(';')) {
      final tokens = part.trim().split(RegExp(r'\s+'));
      if (tokens.first.isEmpty) continue;
      out[tokens.first] = tokens.skip(1).toList();
    }
    return out;
  }

  test('index.html carries a policy', () {
    expect(meta, isNotNull);
  });

  test('scripts: this origin and WebAssembly only', () {
    final d = directives();
    expect(d['script-src'], <String>["'self'", "'wasm-unsafe-eval'"]);
    expect(d['default-src'], <String>["'self'"]);
    for (final name in <String>['script-src', 'default-src']) {
      expect(d[name], isNot(contains("'unsafe-eval'")), reason: name);
      expect(d[name], isNot(contains("'unsafe-inline'")), reason: name);
      expect(d[name], isNot(contains('*')), reason: name);
    }
  });

  test('nothing is allowed over plain HTTP, and HTTP is upgraded', () {
    final all = meta!.group(1)!;
    expect(all, isNot(contains('http:')));
    expect(directives().containsKey('upgrade-insecure-requests'), isTrue);
  });

  test('plugins, forms and base tag are shut', () {
    final d = directives();
    expect(d['object-src'], <String>["'none'"]);
    expect(d['form-action'], <String>["'none'"]);
    expect(d['base-uri'], <String>["'self'"]);
  });

  test('the only third parties are Open Library, Google Books and their '
      'cover hosts', () {
    final hosts = RegExp(r'https://[^\s;]+')
        .allMatches(meta!.group(1)!)
        .map((m) => m.group(0)!)
        .toSet();
    expect(hosts, <String>{
      'https://openlibrary.org',
      'https://covers.openlibrary.org',
      'https://*.archive.org',
      // The fallback catalogue, asked only when Open Library has no answer.
      'https://www.googleapis.com',
      'https://books.google.com',
      'https://books.googleusercontent.com',
    });
    expect(directives()['connect-src'], containsAll(hosts));
    expect(directives()['img-src'], contains('https://covers.openlibrary.org'));
  });

  test('every host the app code contacts is allowed to connect', () {
    final allowed = directives()['connect-src']!.join(' ');
    final found = <String>{};
    for (final f
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'),
            )) {
      for (final m in RegExp(
        r'''["']https://([a-z0-9.-]+)''',
      ).allMatches(f.readAsStringSync())) {
        found.add('https://${m.group(1)}');
      }
    }
    expect(found, isNotEmpty);
    for (final host in found) {
      expect(allowed, contains(host), reason: '$host is contacted but blocked');
    }
  });

  test(
    'web/_headers repeats the policy and adds the header-only protections',
    () {
      final headers = File('web/_headers').readAsStringSync();
      expect(headers, contains('Strict-Transport-Security'));
      expect(headers, contains("frame-ancestors 'none'"));
      expect(headers, contains('X-Content-Type-Options: nosniff'));
      expect(headers, contains('camera=(self)'));
      expect(headers, contains(meta!.group(1)!));
    },
  );

  test('the install manifest has the real name and colours', () {
    final m = File('web/manifest.json').readAsStringSync();
    expect(m, contains('"name": "Kitabkhana"'));
    expect(m, isNot(contains('A new Flutter project')));
    expect(html, isNot(contains('A new Flutter project')));
  });
}
