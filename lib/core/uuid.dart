import 'dart:math';

import 'clock.dart';

/// Generates RFC 9562 UUIDv7 values: 48-bit millisecond timestamp, version,
/// a 12-bit monotonic counter, variant and 62 random bits. IDs sort by
/// creation time, including several created within the same millisecond.
class UuidV7Generator {
  UuidV7Generator({Clock? clock, Random? random})
    : _clock = clock ?? const SystemClock(),
      _random = random ?? Random.secure();

  final Clock _clock;
  final Random _random;

  int _lastMs = -1;
  int _counter = 0;

  String next() {
    var ms = _clock.now().toUtc().millisecondsSinceEpoch;
    if (ms > _lastMs) {
      _lastMs = ms;
      _counter = _random.nextInt(0x800); // leave headroom for increments
    } else {
      // Same millisecond (or the clock went backwards): stay monotonic.
      ms = _lastMs;
      _counter++;
      if (_counter > 0xFFF) {
        _lastMs++;
        ms = _lastMs;
        _counter = 0;
      }
    }

    String hex(int v, int width) => v.toRadixString(16).padLeft(width, '0');

    final timeHex = hex(ms, 12);
    final randA = hex(_counter, 3);
    // Variant 10xx in the top bits of the next group.
    final variantAndRandB1 = hex(0x8000 | _random.nextInt(0x4000), 4);
    final randB2 =
        hex(_random.nextInt(0x10000), 4) +
        hex(_random.nextInt(0x10000), 4) +
        hex(_random.nextInt(0x10000), 4);

    return '${timeHex.substring(0, 8)}-${timeHex.substring(8)}-7$randA-'
        '$variantAndRandB1-$randB2';
  }
}

final UuidV7Generator _default = UuidV7Generator();

/// A fresh UUIDv7 string.
String uuidV7() => _default.next();
