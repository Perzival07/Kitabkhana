import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/app_theme.dart';
import 'package:kitabkhana/features/book/presentation/book_detail_screen.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';
import 'package:kitabkhana/l10n/app_localizations.dart';

import '../../helpers/add_flow_harness.dart';

void main() {
  late AddFlowHarness h;

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<void> advance(WidgetTester t) async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 1));
  }

  void flowTest(String name, Future<void> Function(WidgetTester t) body) {
    testWidgets(name, (t) async {
      h = AddFlowHarness();
      await body(t);
      await t.pumpWidget(const SizedBox());
      await advance(t);
    });
  }

  Future<void> seed({String? locationId, Ownership o = Ownership.owned}) =>
      h.repos.books.upsert(
        Book.create(
          id: 'b1',
          title: 'Dune',
          now: h.clock.now(),
          locationId: locationId,
          ownership: o,
        ),
      );

  Future<void> pumpDetail(WidgetTester t) async {
    t.view
      ..physicalSize = const Size(400, 1400)
      ..devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: h.overrides,
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: Text('home')),
        ),
      ),
    );
    await advance(t);
    Navigator.of(t.element(find.text('home'))).push(
      MaterialPageRoute<void>(
        builder: (_) => const BookDetailScreen(bookId: 'b1'),
      ),
    );
    await advance(t);
  }

  Future<dynamic> activeLoan(WidgetTester t) async =>
      (await t.runAsync(() => h.repos.loans.activeFor('b1')))!.getOrNull();

  flowTest('lend from the detail page with a 2-week due date', (t) async {
    await seed();
    await pumpDetail(t);
    await t.tap(find.text('Lend'));
    await advance(t);
    await t.enterText(find.widgetWithText(TextField, 'Lent to'), 'Priya');
    await t.enterText(
      find.widgetWithText(TextField, 'Phone (optional)'),
      '98765 43210',
    );
    await t.tap(find.text('2 weeks'));
    await advance(t);
    await t.tap(find.text('Save'));
    await advance(t);
    final loan = await activeLoan(t);
    expect(loan.personName, 'Priya');
    expect(loan.personPhone, '919876543210');
    expect(loan.dueOn, DateTime(2025, 3, 24));
    expect(find.textContaining('Lent to Priya since'), findsOneWidget);
    expect(find.text('Lend'), findsNothing, reason: 'already lent');
  });

  flowTest('the borrower can be picked from contacts', (t) async {
    await seed();
    h.contacts.next = (name: 'Rahul Verma', phone: '+44 7700 900123');
    await pumpDetail(t);
    await t.tap(find.text('Lend'));
    await advance(t);
    await t.tap(find.byTooltip('Choose from contacts'));
    await advance(t);
    expect(find.text('Rahul Verma'), findsOneWidget);
    expect(find.text('+44 7700 900123'), findsOneWidget);
    await t.tap(find.text('Save'));
    await advance(t);
    final loan = await activeLoan(t);
    expect(loan.personName, 'Rahul Verma');
    expect(loan.personPhone, '447700900123');
  });

  flowTest('a cancelled contact pick changes nothing', (t) async {
    await seed();
    await pumpDetail(t);
    await t.tap(find.text('Lend'));
    await advance(t);
    await t.enterText(find.widgetWithText(TextField, 'Lent to'), 'Priya');
    await t.tap(find.byTooltip('Choose from contacts'));
    await advance(t);
    expect(h.contacts.asked, 1);
    expect(find.text('Priya'), findsOneWidget);
  });

  flowTest('a name is required and a bad phone is refused', (t) async {
    await seed();
    await pumpDetail(t);
    await t.tap(find.text('Lend'));
    await advance(t);
    await t.tap(find.text('Save'));
    await advance(t);
    expect(find.text('Who has it?'), findsOneWidget);
    await t.enterText(find.widgetWithText(TextField, 'Lent to'), 'Priya');
    await t.enterText(find.widgetWithText(TextField, 'Phone (optional)'), '12');
    await t.tap(find.text('Save'));
    await advance(t);
    expect(find.text("That doesn't look like a phone number."), findsOneWidget);
    expect(await activeLoan(t), isNull);
  });

  flowTest('past people are suggested', (t) async {
    await seed();
    await h.repos.books.upsert(
      Book.create(id: 'b2', title: 'Emma', now: h.clock.now()),
    );
    await t.runAsync(() async {
      // An earlier loan to Rahul.
      final lend = await h.repos.loans.startLoan(
        _loan('old', 'b2', 'Rahul', h),
      );
      await h.repos.loans.finishLoan('old', DateTime(2025, 3, 1));
      return lend;
    });
    await pumpDetail(t);
    await t.tap(find.text('Lend'));
    await advance(t);
    expect(find.widgetWithText(ActionChip, 'Rahul'), findsOneWidget);
    await t.tap(find.widgetWithText(ActionChip, 'Rahul'));
    await advance(t);
    expect(find.widgetWithText(TextField, 'Rahul'), findsOneWidget);
  });

  flowTest('the borrow toggle records a borrowed book', (t) async {
    await seed();
    await pumpDetail(t);
    await t.tap(find.text('Lend'));
    await advance(t);
    await t.tap(find.text('Borrow'));
    await advance(t);
    await t.enterText(find.widgetWithText(TextField, 'Borrowed from'), 'Rahul');
    await t.tap(find.text('Save'));
    await advance(t);
    final loan = await activeLoan(t);
    expect(loan.direction, LoanDirection.borrowed);
    expect(find.textContaining('Borrowed from Rahul since'), findsOneWidget);
  });

  flowTest('return restores the location', (t) async {
    await h.repos.locations.upsert(
      Location.create(id: 'l', name: 'Hall', now: h.clock.now()),
    );
    await seed(locationId: 'l');
    await t.runAsync(
      () => h.repos.loans.startLoan(_loan('x', 'b1', 'Priya', h)),
    );
    await pumpDetail(t);
    await t.tap(find.text('Return'));
    await advance(t);
    final b = (await t.runAsync(() => h.repos.books.getById('b1')))!
        .getOrNull()!;
    expect(b.locationId, 'l');
    expect(find.text('Hall'), findsOneWidget);
  });

  flowTest('return with a deleted old location asks for a new one', (t) async {
    await h.repos.locations.upsert(
      Location.create(id: 'l', name: 'Hall', now: h.clock.now()),
    );
    await h.repos.locations.upsert(
      Location.create(id: 'm', name: 'Attic', now: h.clock.now(), sortOrder: 1),
    );
    await seed(locationId: 'l');
    await t.runAsync(() async {
      await h.repos.loans.startLoan(_loan('x', 'b1', 'Priya', h));
      await h.repos.locations.softDelete('l');
    });
    await pumpDetail(t);
    await t.tap(find.text('Return'));
    await advance(t);
    expect(find.text('Choose a location'), findsOneWidget);
    await t.tap(find.text('Attic').last);
    await advance(t);
    final b = (await t.runAsync(() => h.repos.books.getById('b1')))!
        .getOrNull()!;
    expect(b.locationId, 'm');
  });

  flowTest('returning a borrowed book asks what to do with it', (t) async {
    await seed();
    await t.runAsync(
      () => h.repos.loans.startLoan(
        _loan('x', 'b1', 'Rahul', h, direction: LoanDirection.borrowed),
      ),
    );
    await pumpDetail(t);
    await t.tap(find.text('Return'));
    await advance(t);
    expect(find.text('Returned to Rahul'), findsOneWidget);
    await t.tap(find.text('Keep it on my wishlist'));
    await advance(t);
    final b = (await t.runAsync(() => h.repos.books.getById('b1')))!
        .getOrNull()!;
    expect(b.ownership, Ownership.wishlist);
  });
}

Loan _loan(
  String id,
  String bookId,
  String person,
  AddFlowHarness h, {
  LoanDirection direction = LoanDirection.lent,
}) => Loan.create(
  id: id,
  bookId: bookId,
  direction: direction,
  personName: person,
  startedOn: DateTime(2025, 3, 3),
  now: h.clock.now(),
);
