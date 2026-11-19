import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/debouncer.dart';

void main() {
  test('runs once after the quiet period with the latest action', () {
    fakeAsync((async) {
      final d = Debouncer(const Duration(milliseconds: 300));
      final calls = <int>[];
      d.run(() => calls.add(1));
      async.elapse(const Duration(milliseconds: 200));
      d.run(() => calls.add(2));
      async.elapse(const Duration(milliseconds: 299));
      expect(calls, isEmpty);
      expect(d.isPending, isTrue);
      async.elapse(const Duration(milliseconds: 2));
      expect(calls, <int>[2]);
      expect(d.isPending, isFalse);
    });
  });

  test('cancel and dispose drop the pending action', () {
    fakeAsync((async) {
      final d = Debouncer(const Duration(milliseconds: 100));
      var n = 0;
      d.run(() => n++);
      d.cancel();
      async.elapse(const Duration(seconds: 1));
      expect(n, 0);
      d.run(() => n++);
      d.dispose();
      async.elapse(const Duration(seconds: 1));
      expect(n, 0);
    });
  });
}
