import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/features/lending/domain/due_state.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

void main() {
  late AddFlowHarness h;
  // The harness clock: 10 March 2025, 09:00.
  final today = DateTime(2025, 3, 10);

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Loan loan(
    String id, {
    DateTime? due,
    LoanDirection d = LoanDirection.lent,
    DateTime? returned,
  }) {
    final l = Loan.create(
      id: id,
      bookId: 'b-$id',
      direction: d,
      personName: 'Priya $id',
      startedOn: DateTime(2025, 3, 1),
      dueOn: due,
      now: today,
    );
    return returned == null ? l : l.copyWith(returnedOn: returned);
  }

  Future<void> add(Loan l, {bool close = false}) async {
    await h.repos.books.upsert(
      Book.create(id: 'b-${l.id}', title: 'Title ${l.id}', now: today),
    );
    await h.repos.loans.startLoan(l);
    if (close) await h.repos.loans.finishLoan(l.id, DateTime(2025, 3, 5));
  }

  /// A book's title in a row (the generated cover repeats it).
  Finder title(String text) => find.byWidgetPredicate(
    (w) => w is Text && w.data == text && w.maxLines == 2,
  );

  Future<void> open(WidgetTester t) async {
    final c = await pumpRouterApp(
      t,
      size: const Size(420, 900),
      overrides: h.overrides,
    );
    routerOf(c).go('/loans');
    await t.pumpAndSettle();
  }

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  group('dueStateOf', () {
    test('none, normal, soon and overdue around the boundaries', () {
      expect(dueStateOf(loan('a'), today), DueState.none);
      expect(
        dueStateOf(loan('a', due: DateTime(2025, 3, 9)), today),
        DueState.overdue,
      );
      expect(
        dueStateOf(loan('a', due: DateTime(2025, 3, 10)), today),
        DueState.soon,
      );
      expect(
        dueStateOf(loan('a', due: DateTime(2025, 3, 13)), today),
        DueState.soon,
      );
      expect(
        dueStateOf(loan('a', due: DateTime(2025, 3, 14)), today),
        DueState.normal,
      );
    });

    test('daysUntilDue ignores the time of day', () {
      expect(
        daysUntilDue(
          loan('a', due: DateTime(2025, 3, 11)),
          DateTime(2025, 3, 10, 23, 59),
        ),
        1,
      );
      expect(daysUntilDue(loan('a'), today), isNull);
    });
  });

  testWidgets('tab counts follow the loans', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() async {
      await add(loan('a', due: DateTime(2025, 3, 20)));
      await add(loan('b', due: DateTime(2025, 3, 5)));
      await add(loan('c', d: LoanDirection.borrowed));
      await add(loan('d'), close: true);
    });
    await open(t);
    Finder badge(String tab) => find.descendant(
      of: find.widgetWithText(Tab, tab),
      matching: find.byType(Badge),
    );
    expect(
      find.descendant(of: badge('Lent out'), matching: find.text('2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: badge('Borrowed'), matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: badge('Overdue'), matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(Tab, 'History'),
        matching: find.byType(Badge),
      ),
      findsNothing,
    );
    await end(t);
  });

  testWidgets('due dates are worded and coloured by urgency', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() async {
      await add(loan('a', due: DateTime(2025, 3, 7)));
      await add(loan('b', due: DateTime(2025, 3, 10)));
      await add(loan('c', due: DateTime(2025, 3, 12)));
      await add(loan('d', due: DateTime(2025, 3, 25)));
      await add(loan('e'));
    });
    await open(t);
    TextStyle? styleOf(String text) {
      for (final w in t.widgetList<RichText>(find.byType(RichText))) {
        TextStyle? found;
        w.text.visitChildren((span) {
          if (span is TextSpan && span.text == text) found = span.style;
          return true;
        });
        if (found != null) return found;
      }
      return null;
    }

    final overdue = styleOf('3 days overdue');
    final soon = styleOf('Due in 2 days');
    final normal = styleOf('Due Mar 25');
    expect(styleOf('Due today'), isNotNull);
    expect(styleOf('No due date'), isNotNull);
    final scheme = Theme.of(t.element(find.byType(Scaffold).first)).colorScheme;
    expect(overdue!.color, scheme.error);
    expect(soon!.color, isNot(scheme.error));
    expect(soon.color, isNot(normal!.color));
    await end(t);
  });

  testWidgets('the Overdue tab lists only overdue loans', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() async {
      await add(loan('a', due: DateTime(2025, 3, 20)));
      await add(loan('b', due: DateTime(2025, 3, 5)));
    });
    await open(t);
    await t.tap(find.widgetWithText(Tab, 'Overdue'));
    await t.pumpAndSettle();
    expect(title('Title b'), findsOneWidget);
    expect(title('Title a'), findsNothing);
    await end(t);
  });

  testWidgets('empty states are warm and per tab', (t) async {
    h = AddFlowHarness();
    await open(t);
    expect(
      find.text('Everyone has returned your books. Nice.'),
      findsOneWidget,
    );
    await t.tap(find.widgetWithText(Tab, 'Borrowed'));
    await t.pumpAndSettle();
    expect(
      find.text("You haven't borrowed any books right now."),
      findsOneWidget,
    );
    await t.tap(find.widgetWithText(Tab, 'Overdue'));
    await t.pumpAndSettle();
    expect(find.text('Nothing is overdue. Lovely.'), findsOneWidget);
    await t.tap(find.widgetWithText(Tab, 'History'));
    await t.pumpAndSettle();
    expect(find.text('Returned books will show up here.'), findsOneWidget);
    await end(t);
  });

  testWidgets('history is grouped by month', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() async {
      await add(loan('a'));
      await h.repos.loans.finishLoan('a', DateTime(2025, 3, 5));
      await add(loan('b'));
      await h.repos.loans.finishLoan('b', DateTime(2025, 2, 20));
    });
    await open(t);
    await t.tap(find.widgetWithText(Tab, 'History'));
    await t.pumpAndSettle();
    expect(find.text('March 2025'), findsOneWidget);
    expect(find.text('February 2025'), findsOneWidget);
    expect(title('Title a'), findsOneWidget);
    await end(t);
  });

  testWidgets('Return from the menu closes the loan', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() => add(loan('a', due: DateTime(2025, 3, 20))));
    await open(t);
    await t.tap(find.byTooltip('More'));
    await t.pumpAndSettle();
    await t.tap(find.text('Return').last);
    await t.pumpAndSettle();
    final active = await t.runAsync(() => h.repos.loans.activeFor('b-a'));
    expect(active!.getOrNull(), isNull);
    expect(title('Title a'), findsNothing);
    await end(t);
  });

  testWidgets('Extend moves the due date', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() => add(loan('a', due: DateTime(2025, 3, 20))));
    await open(t);
    await t.tap(find.byTooltip('More'));
    await t.pumpAndSettle();
    await t.tap(find.text('Extend'));
    await t.pumpAndSettle();
    await t.tap(find.text('+2 weeks'));
    await t.pumpAndSettle();
    final a = (await t.runAsync(() => h.repos.loans.activeFor('b-a')))!
        .getOrNull()!;
    expect(a.dueOn, DateTime(2025, 4, 3));
    await end(t);
  });

  testWidgets('swiping to return can be undone', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() => add(loan('a', due: DateTime(2025, 3, 20))));
    await open(t);
    await t.drag(title('Title a'), const Offset(500, 0));
    await t.pumpAndSettle();
    expect(find.text('Marked as returned'), findsOneWidget);
    expect(title('Title a'), findsNothing);
    await t.tap(find.text('Undo'));
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    expect(title('Title a'), findsOneWidget);
    final a = await t.runAsync(() => h.repos.loans.activeFor('b-a'));
    expect(a!.getOrNull(), isNotNull);
    await end(t);
  });

  testWidgets('swiping to return commits after the undo window', (t) async {
    h = AddFlowHarness();
    await t.runAsync(() => add(loan('a', due: DateTime(2025, 3, 20))));
    await open(t);
    await t.drag(title('Title a'), const Offset(500, 0));
    await t.pumpAndSettle();
    await t.pump(const Duration(seconds: 8));
    await t.pumpAndSettle();
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await t.pumpAndSettle();
    final a = await t.runAsync(() => h.repos.loans.activeFor('b-a'));
    expect(a!.getOrNull(), isNull);
    await end(t);
  });

  testWidgets('swiping a borrowed loan asks what to do with the book', (
    t,
  ) async {
    h = AddFlowHarness();
    await t.runAsync(() => add(loan('a', d: LoanDirection.borrowed)));
    await open(t);
    await t.tap(find.widgetWithText(Tab, 'Borrowed'));
    await t.pumpAndSettle();
    await t.drag(title('Title a'), const Offset(500, 0));
    await t.pumpAndSettle();
    expect(find.text('Returned to Priya a'), findsOneWidget);
    await end(t);
  });
}
