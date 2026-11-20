@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

void main() {
  final today = DateTime(2025, 3, 10);
  for (final dark in <bool>[false, true]) {
    final mode = dark ? 'dark' : 'light';
    for (final scene in <String>['loans', 'lend']) {
      testWidgets('lending $scene ($mode)', (t) async {
        final h = AddFlowHarness();
        addTearDown(h.dispose);
        Future<void> add(
          String id,
          String title,
          String who,
          DateTime? due, {
          LoanDirection d = LoanDirection.lent,
        }) async {
          await h.repos.books.upsert(
            Book.create(
              id: 'b-$id',
              title: title,
              authors: 'Author $id',
              now: today,
            ),
          );
          await h.repos.loans.startLoan(
            Loan.create(
              id: id,
              bookId: 'b-$id',
              direction: d,
              personName: who,
              startedOn: DateTime(2025, 3, 1),
              dueOn: due,
              now: today,
            ),
          );
        }

        await add('a', 'Dune', 'Priya Sharma', DateTime(2025, 3, 6));
        await add(
          'b',
          'The Remains of the Day',
          'Rahul Verma',
          DateTime(2025, 3, 12),
        );
        await add('c', 'Sapiens', 'Anita', DateTime(2025, 4, 2));
        await add('d', 'Emma', 'Kabir', null);
        final c = await h.pump(
          t,
          start: '/loans',
          size: const Size(360, 780),
          disableAnimations: true,
        );
        if (dark) {
          c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
          await t.pumpAndSettle();
        }
        if (scene == 'lend') {
          await h.repos.books.upsert(
            Book.create(id: 'free', title: 'Emma', now: today),
          );
          routerOf(c).go('/book/free');
          await t.pumpAndSettle();
          await t.ensureVisible(find.text('Lend'));
          await t.pumpAndSettle();
          await t.tap(find.text('Lend'));
          await t.pumpAndSettle();
          await t.enterText(find.byType(TextField).first, 'Pri');
          await t.pumpAndSettle();
        }
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/lending_${scene}_$mode.png'),
        );
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(milliseconds: 400));
      });
    }
  }
}
