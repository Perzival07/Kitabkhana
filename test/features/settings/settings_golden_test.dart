@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';

import '../../helpers/add_flow_harness.dart';

void main() {
  final now = DateTime(2025, 3, 10);
  for (final dark in <bool>[false, true]) {
    final mode = dark ? 'dark' : 'light';
    for (final (name, path, height) in <(String, String, double)>[
      ('settings', '/settings', 2300),
      ('more', '/more', 780),
    ]) {
      testWidgets('$name ($mode)', (t) async {
        final h = AddFlowHarness();
        addTearDown(h.dispose);
        await h.repos.books.upsert(
          Book.create(id: 'a', title: 'Emma', now: now),
        );
        await h.repos.loans.startLoan(
          Loan.create(
            id: 'l',
            bookId: 'a',
            direction: LoanDirection.lent,
            personName: 'Priya',
            startedOn: now,
            now: now,
          ),
        );
        await h.repos.tags.createIfAbsent('Classic');
        final c = await h.pump(
          t,
          start: path,
          size: Size(360, height),
          disableAnimations: true,
        );
        if (dark) {
          c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
          await t.pumpAndSettle();
        }
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${name}_$mode.png'),
        );
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(milliseconds: 400));
      });
    }
  }
}
