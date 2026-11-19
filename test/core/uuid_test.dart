import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/clock.dart';
import 'package:kitabkhana/core/uuid.dart';

final RegExp _v7 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  test('has the UUIDv7 shape (version 7, RFC variant)', () {
    for (var i = 0; i < 200; i++) {
      expect(uuidV7(), matches(_v7));
    }
  });

  test('embeds the millisecond timestamp', () {
    final clock = FakeClock(DateTime.utc(2025, 6, 1, 10, 30));
    final gen = UuidV7Generator(clock: clock, random: Random(1));
    final id = gen.next();
    final hex = id.replaceAll('-', '').substring(0, 12);
    expect(
      int.parse(hex, radix: 16),
      DateTime.utc(2025, 6, 1, 10, 30).millisecondsSinceEpoch,
    );
  });

  test('is strictly increasing within one millisecond', () {
    final gen = UuidV7Generator(
      clock: FakeClock(DateTime.utc(2025)),
      random: Random(2),
    );
    final ids = List<String>.generate(3000, (_) => gen.next());
    final sorted = List<String>.of(ids)..sort();
    expect(ids, sorted);
    expect(ids.toSet().length, ids.length);
  });

  test('stays ordered across milliseconds', () {
    final clock = FakeClock(DateTime.utc(2025));
    final gen = UuidV7Generator(clock: clock, random: Random(3));
    final ids = <String>[];
    for (var i = 0; i < 50; i++) {
      ids.add(gen.next());
      clock.advance(const Duration(milliseconds: 1));
    }
    expect(ids, List<String>.of(ids)..sort());
  });

  test('stays ordered if the clock goes backwards', () {
    final clock = FakeClock(DateTime.utc(2025, 1, 1, 0, 0, 10));
    final gen = UuidV7Generator(clock: clock, random: Random(4));
    final a = gen.next();
    clock.set(DateTime.utc(2025, 1, 1, 0, 0, 5));
    final b = gen.next();
    expect(a.compareTo(b), lessThan(0));
  });

  test('counter overflow rolls into the next millisecond', () {
    final gen = UuidV7Generator(
      clock: FakeClock(DateTime.utc(2025)),
      random: Random(5),
    );
    final ids = List<String>.generate(10000, (_) => gen.next());
    expect(ids, List<String>.of(ids)..sort());
    expect(ids.toSet().length, 10000);
    expect(ids.every(_v7.hasMatch), isTrue);
  });

  test('default generator yields unique ids', () {
    final ids = <String>{for (var i = 0; i < 5000; i++) uuidV7()};
    expect(ids.length, 5000);
  });
}
