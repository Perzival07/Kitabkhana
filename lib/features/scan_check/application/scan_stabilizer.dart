import '../../../core/clock.dart';
import '../../../core/text/isbn.dart';

/// Turns a noisy stream of camera detections into clean "this is the book"
/// events: only book barcodes (EAN-13 starting 978 or 979, valid check digit),
/// seen on two detections in a row, and not repeated within [quietPeriod].
class ScanStabilizer {
  ScanStabilizer(this._clock, {this.quietPeriod = const Duration(seconds: 3)});

  final Clock _clock;
  final Duration quietPeriod;

  String? _pending;
  String? _lastAccepted;
  DateTime? _lastAcceptedAt;

  /// Feed one detection. Returns the ISBN-13 digits when it is confirmed,
  /// otherwise null.
  String? accept(String raw) {
    final code = raw.trim();
    if (code.length != 13 ||
        !(code.startsWith('978') || code.startsWith('979'))) {
      _pending = null;
      return null;
    }
    final isbn = parseIsbn(code);
    if (isbn == null) {
      _pending = null;
      return null;
    }
    final now = _clock.now();
    if (code == _lastAccepted &&
        _lastAcceptedAt != null &&
        now.difference(_lastAcceptedAt!) < quietPeriod) {
      return null;
    }
    if (_pending != code) {
      _pending = code;
      return null;
    }
    _pending = null;
    _lastAccepted = code;
    _lastAcceptedAt = now;
    return isbn.value;
  }

  /// Forget everything (e.g. after the camera was paused).
  void reset() {
    _pending = null;
    _lastAccepted = null;
    _lastAcceptedAt = null;
  }
}
