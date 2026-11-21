import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/ui/ui.dart';

void main() {
  testWidgets('a toast with an action still leaves on its own', (t) async {
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    KToast.show(ctx, 'Deleted', actionLabel: 'Undo', onAction: () {});
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Deleted'), findsOneWidget);
    await t.pump(const Duration(seconds: 10));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Deleted'), findsNothing);
  });

  testWidgets('KToast.visible is true only while a toast is on screen', (
    t,
  ) async {
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(KToast.visible.value, isFalse);

    KToast.show(ctx, 'One');
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(KToast.visible.value, isTrue);

    // A second toast replaces the first: still one on screen, not two.
    KToast.show(ctx, 'Two');
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(KToast.visible.value, isTrue);

    // Let the toast time out and slide away (in steps, so each timer and
    // animation gets its turn).
    for (var i = 0; i < 8; i++) {
      await t.pump(const Duration(seconds: 1));
    }
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Two'), findsNothing);
    expect(KToast.visible.value, isFalse);
  });
}
