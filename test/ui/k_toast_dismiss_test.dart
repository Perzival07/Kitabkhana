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
}
