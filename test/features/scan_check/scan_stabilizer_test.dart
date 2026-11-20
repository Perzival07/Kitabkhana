import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/scan_check/application/scan_stabilizer.dart';

import 'package:kitabkhana/core/clock.dart';

void main() {
  late FakeClock clock;
  late ScanStabilizer s;
  const dune = '9780441013593';
  const other = '9780143127550';

  setUp(() {
    clock = FakeClock(DateTime(2025, 3, 10, 9));
    s = ScanStabilizer(clock);
  });

  test('needs the same code on two detections in a row', () {
    expect(s.accept(dune), isNull);
    expect(s.accept(dune), dune);
  });

  test('a different code in between restarts the count', () {
    expect(s.accept(dune), isNull);
    expect(s.accept(other), isNull);
    expect(s.accept(dune), isNull);
    expect(s.accept(dune), dune);
  });

  test('ignores a repeat for three seconds, then accepts again', () {
    s.accept(dune);
    expect(s.accept(dune), dune);
    s.accept(dune);
    expect(s.accept(dune), isNull);
    clock.advance(const Duration(seconds: 2));
    expect(s.accept(dune), isNull);
    clock.advance(const Duration(seconds: 2));
    s.accept(dune);
    expect(s.accept(dune), dune);
  });

  test('a different book is accepted during the quiet period', () {
    s.accept(dune);
    s.accept(dune);
    s.accept(other);
    expect(s.accept(other), other);
  });

  test('only 978/979 EAN-13 with a valid check digit', () {
    for (final bad in <String>[
      '5012345678900', // not a book prefix
      '9780441013594', // bad check digit
      '978044101359', // too short
      '97804410135933', // too long
      'hello',
      '',
    ]) {
      expect(s.accept(bad), isNull, reason: bad);
      expect(s.accept(bad), isNull, reason: bad);
    }
    expect(s.accept('9791090636071'), isNull);
    expect(s.accept('9791090636071'), '9791090636071');
  });

  test('reset forgets everything', () {
    s.accept(dune);
    s.accept(dune);
    s.reset();
    expect(s.accept(dune), isNull);
    expect(s.accept(dune), dune);
  });
}
