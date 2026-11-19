import 'dart:async';

/// Runs the most recent action once calls have been quiet for [delay].
class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;

  bool get isPending => _timer?.isActive ?? false;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() => _timer?.cancel();

  void dispose() => cancel();
}
