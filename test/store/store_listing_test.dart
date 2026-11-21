import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String read(String name) => File('docs/store/$name').readAsStringSync().trim();

/// The stores reject listings over these lengths; check them here, not at
/// submission time.
void main() {
  test('title, subtitle and short description fit', () {
    expect(read('title.txt').length, lessThanOrEqualTo(30));
    expect(read('subtitle_ios.txt').length, lessThanOrEqualTo(30));
    expect(read('short_description.txt').length, lessThanOrEqualTo(80));
  });

  test('keywords fit and have no spaces after commas or repeats', () {
    final k = read('keywords_ios.txt');
    expect(k.length, lessThanOrEqualTo(100));
    expect(k, isNot(contains(', ')));
    final words = k.split(',');
    expect(words.toSet().length, words.length, reason: 'no repeats');
    // Words already in the title or subtitle are wasted keyword space.
    for (final w in words) {
      expect(read('title.txt').toLowerCase(), isNot(contains(w)));
    }
  });

  test('the description fits and promises only what the app does', () {
    final d = read('full_description.md');
    expect(d.length, lessThanOrEqualTo(4000));
    expect(d, contains('no account'));
    expect(d.toLowerCase(), isNot(contains('free trial')));
    expect(d.toLowerCase(), isNot(contains('sync')));
    expect(d.toLowerCase(), isNot(contains('cloud')));
  });

  test('release notes: the Play "what is new" fits in 500 characters', () {
    final notes = read('release_notes.md');
    final short = notes
        .split('### Short version')
        .last
        .split('\n')
        .where((l) => l.trim().isNotEmpty && !l.startsWith('('))
        .join(' ')
        .trim();
    expect(short.length, lessThanOrEqualTo(500));
    expect(short, isNotEmpty);
  });

  test('every screenshot size matches what the stores accept', () {
    // PNG header: width and height are big-endian ints at bytes 16 and 20.
    ({int w, int h}) size(File f) {
      final b = f.readAsBytesSync();
      int u32(int o) =>
          (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3];
      return (w: u32(16), h: u32(20));
    }

    const expected = <String, ({int w, int h})>{
      'phone-ios': (w: 1290, h: 2796),
      'phone-play': (w: 1080, h: 1920),
      'tablet': (w: 2048, h: 2732),
    };
    for (final e in expected.entries) {
      final dir = Directory('docs/store/screenshots/${e.key}');
      if (!dir.existsSync()) continue; // generated on demand
      final files = dir.listSync().whereType<File>().where(
        (f) => f.path.endsWith('.png'),
      );
      for (final f in files) {
        expect(size(f), e.value, reason: f.path);
      }
    }
  });
}
