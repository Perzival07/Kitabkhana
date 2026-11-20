import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/lending/domain/loan.dart';
import 'package:kitabkhana/features/lending/domain/loan_direction.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_enums.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';
import 'package:kitabkhana/features/locations/domain/location.dart';
import 'package:kitabkhana/platform/camera_permission/camera_permission.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

void main() {
  late AddFlowHarness h;
  const dune = '9780441013593';
  const other = '9780143127550';

  tearDown(() async {
    try {
      await h.dispose();
    } on Error {
      // Not initialised.
    }
  });

  Future<void> end(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 400));
  }

  Future<void> settle(WidgetTester t) async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 1));
  }

  Future<void> seed({
    String id = 'b1',
    String title = 'Dune',
    String? isbn = dune,
    Ownership ownership = Ownership.owned,
    String? locationId,
  }) => h.repos.books.upsert(
    Book.create(
      id: id,
      title: title,
      authors: 'Frank Herbert',
      now: h.clock.now(),
      isbn13: isbn == null ? null : parseIsbn(isbn),
      ownership: ownership,
      locationId: locationId,
    ),
  );

  Future<void> scan(WidgetTester t, String code) async {
    await t.tap(find.text('scan $code'));
    await settle(t);
    // The second detection confirms it.
    await t.tap(find.text('scan $code'));
    await settle(t);
  }

  testWidgets('camera granted shows the camera and the search below', (
    t,
  ) async {
    h = AddFlowHarness(scanCodes: const <String>[dune]);
    await h.pump(t, start: '/scan', disableAnimations: true);
    expect(find.text('scan $dune'), findsOneWidget);
    expect(find.text('Point at the barcode on the back cover'), findsOneWidget);
    expect(find.text('Search by title'), findsOneWidget);
    expect(find.text('Type ISBN'), findsOneWidget);
    await end(t);
  });

  group('permission states', () {
    testWidgets('not asked: explains first, then requests', (t) async {
      h = AddFlowHarness(scanCodes: const <String>[dune]);
      h.camera.current = CameraAccess.notAsked;
      await h.pump(t, start: '/scan', disableAnimations: true);
      expect(find.text('Let Kitabkhana use the camera'), findsOneWidget);
      expect(h.camera.requests, 0);
      expect(find.text('scan $dune'), findsNothing);
      await t.tap(find.text('Allow camera'));
      await settle(t);
      expect(h.camera.requests, 1);
      expect(find.text('scan $dune'), findsOneWidget);
      await end(t);
    });

    testWidgets('denied: friendly screen, try again', (t) async {
      h = AddFlowHarness();
      h.camera.current = CameraAccess.denied;
      h.camera.onRequest = CameraAccess.denied;
      await h.pump(t, start: '/scan', disableAnimations: true);
      expect(find.text('The camera is off'), findsOneWidget);
      await t.tap(find.text('Try again'));
      await settle(t);
      expect(h.camera.requests, 1);
      expect(find.text('Search by title'), findsOneWidget);
      await end(t);
    });

    testWidgets('permanently denied: open settings', (t) async {
      h = AddFlowHarness();
      h.camera.current = CameraAccess.permanentlyDenied;
      await h.pump(t, start: '/scan', disableAnimations: true);
      expect(find.text('Camera access is blocked'), findsOneWidget);
      await t.tap(find.text('Open settings'));
      await settle(t);
      expect(h.camera.settingsOpened, 1);
      await end(t);
    });

    testWidgets('no camera: search and ISBN only', (t) async {
      h = AddFlowHarness();
      h.camera.current = CameraAccess.unavailable;
      await h.pump(t, start: '/scan', disableAnimations: true);
      expect(find.text("Camera scanning isn't available here"), findsOneWidget);
      expect(find.text('Search by title'), findsOneWidget);
      expect(find.text('Type ISBN'), findsOneWidget);
      await end(t);
    });

    testWidgets('a camera that fails to start falls back to search', (t) async {
      h = AddFlowHarness(cameraOk: false);
      await h.pump(t, start: '/scan', disableAnimations: true);
      await settle(t);
      expect(find.text("Camera scanning isn't available here"), findsOneWidget);
      await end(t);
    });
  });

  group('verdict cards', () {
    testWidgets('Owned shows the place and Open book', (t) async {
      h = AddFlowHarness(scanCodes: const <String>[dune]);
      await h.repos.locations.upsert(
        Location.create(id: 'l', name: 'Hall', now: h.clock.now()),
      );
      await seed(locationId: 'l');
      await h.pump(t, start: '/scan', disableAnimations: true);
      await scan(t, dune);
      expect(find.text('You own this'), findsOneWidget);
      expect(find.text('On Hall'), findsOneWidget);
      await t.tap(find.text('Open book'));
      await t.pumpAndSettle();
      expect(locationOf(_c(t)), '/book/b1');
      await end(t);
    });

    testWidgets('one detection alone does not trigger', (t) async {
      h = AddFlowHarness(scanCodes: const <String>[dune]);
      await seed();
      await h.pump(t, start: '/scan', disableAnimations: true);
      await t.tap(find.text('scan $dune'));
      await settle(t);
      expect(find.text('You own this'), findsNothing);
      await end(t);
    });

    testWidgets('OtherEdition', (t) async {
      h = AddFlowHarness(scanCodes: const <String>[other]);
      await seed();
      h.source.onIsbn = () => Ok(
        BookInfo(
          title: 'Dune',
          authors: const <String>['Frank Herbert'],
          isbn13: parseIsbn(other),
        ),
      );
      await h.pump(t, start: '/scan', disableAnimations: true);
      await scan(t, other);
      expect(find.text('You own another edition'), findsOneWidget);
      await end(t);
    });

    testWidgets('OnWishlist: Mark as bought asks for a location', (t) async {
      h = AddFlowHarness(scanCodes: const <String>[dune]);
      await h.repos.locations.upsert(
        Location.create(id: 'l', name: 'Hall', now: h.clock.now()),
      );
      await seed(ownership: Ownership.wishlist);
      await h.pump(t, start: '/scan', disableAnimations: true);
      await scan(t, dune);
      expect(find.text('On your wishlist'), findsOneWidget);
      await t.tap(find.text('Mark as bought'));
      await settle(t);
      expect(find.text('Choose a location'), findsOneWidget);
      await t.tap(find.text('Hall').last);
      await settle(t);
      final b = (await t.runAsync(() => h.repos.books.getById('b1')))!
          .getOrNull()!;
      expect(b.ownership, Ownership.owned);
      expect(b.locationId, 'l');
      expect(find.text('Marked as bought'), findsOneWidget);
      await end(t);
    });

    testWidgets('LentOut names the borrower', (t) async {
      h = AddFlowHarness(scanCodes: const <String>[dune]);
      await seed();
      await t.runAsync(
        () => h.repos.loans.create(
          Loan.create(
            id: 'l1',
            bookId: 'b1',
            direction: LoanDirection.lent,
            personName: 'Priya',
            startedOn: DateTime(2025, 3, 3),
            now: h.clock.now(),
          ),
        ),
      );
      await h.pump(t, start: '/scan', disableAnimations: true);
      await scan(t, dune);
      expect(find.text('Lent to Priya'), findsOneWidget);
      expect(find.text('Since Mar 3'), findsOneWidget);
      await end(t);
    });

    testWidgets('BorrowedIn names the lender', (t) async {
      h = AddFlowHarness(scanCodes: const <String>[dune]);
      await seed(ownership: Ownership.borrowed);
      await t.runAsync(
        () => h.repos.loans.create(
          Loan.create(
            id: 'l1',
            bookId: 'b1',
            direction: LoanDirection.borrowed,
            personName: 'Rahul',
            startedOn: DateTime(2025, 3, 3),
            now: h.clock.now(),
          ),
        ),
      );
      await h.pump(t, start: '/scan', disableAnimations: true);
      await scan(t, dune);
      expect(find.text('Borrowed from Rahul'), findsOneWidget);
      await end(t);
    });

    testWidgets('PossibleMatch: pick one to see its verdict', (t) async {
      h = AddFlowHarness();
      await seed(title: "The Hitchhiker's Guide to the Galaxy", isbn: null);
      await h.pump(t, start: '/scan', disableAnimations: true);
      await t.enterText(
        find.byType(TextField),
        'hitchhikers guide to the galxy',
      );
      await t.testTextInput.receiveAction(TextInputAction.done);
      await settle(t);
      expect(find.text('Did you mean…?'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget, reason: 'one candidate');
      await t.tap(
        find
            .widgetWithText(ListTile, "The Hitchhiker's Guide to the Galaxy")
            .first,
      );
      await settle(t);
      expect(find.text('You own this'), findsOneWidget);
      await end(t);
    });

    testWidgets('PossibleMatch: none of these shows not in library', (t) async {
      h = AddFlowHarness();
      await seed(title: "The Hitchhiker's Guide to the Galaxy", isbn: null);
      await h.pump(t, start: '/scan', disableAnimations: true);
      await t.enterText(
        find.byType(TextField),
        'hitchhikers guide to the galxy',
      );
      await t.testTextInput.receiveAction(TextInputAction.done);
      await settle(t);
      await t.tap(find.text('None of these'));
      await settle(t);
      expect(find.text('Not in your library'), findsOneWidget);
      await end(t);
    });

    testWidgets('NotInLibrary: add to wishlist saves it', (t) async {
      h = AddFlowHarness(scanCodes: const <String>[other]);
      h.source.onIsbn = () => Ok(
        BookInfo(
          title: 'Sapiens',
          authors: const <String>['Yuval Noah Harari'],
          isbn13: parseIsbn(other),
        ),
      );
      await h.pump(t, start: '/scan', disableAnimations: true);
      await scan(t, other);
      expect(find.text('Not in your library'), findsOneWidget);
      expect(find.text('Sapiens'), findsWidgets);
      await t.tap(find.text('Add to wishlist'));
      await settle(t);
      final all = await t.runAsync(() => h.repos.allBooks());
      expect(all!.single.title, 'Sapiens');
      expect(all.single.ownership, Ownership.wishlist);
      expect(find.text('Added to your wishlist'), findsOneWidget);
      await end(t);
    });

    testWidgets('NotInLibrary: bought it opens the pre-filled preview', (
      t,
    ) async {
      h = AddFlowHarness(scanCodes: const <String>[other]);
      h.source.onIsbn = () =>
          Ok(BookInfo(title: 'Sapiens', isbn13: parseIsbn(other)));
      final c = await h.pump(t, start: '/scan', disableAnimations: true);
      await scan(t, other);
      await t.tap(find.text('I bought it — add to library'));
      await t.pumpAndSettle();
      expect(locationOf(c), '/library/add/preview');
      await end(t);
    });

    testWidgets('NotInLibrary with nothing known opens the form', (t) async {
      h = AddFlowHarness(scanCodes: const <String>[other]);
      h.source.onIsbn = () => const Err(NetworkFailure.offline());
      final c = await h.pump(t, start: '/scan', disableAnimations: true);
      await scan(t, other);
      expect(find.text('Not in your library'), findsOneWidget);
      await t.tap(find.text('Add to wishlist'));
      await t.pumpAndSettle();
      expect(locationOf(c), '/library/add/manual');
      await end(t);
    });

    testWidgets('title search on an owned book', (t) async {
      h = AddFlowHarness();
      await seed(isbn: null);
      await h.pump(t, start: '/scan', disableAnimations: true);
      await t.enterText(find.byType(TextField), 'dune');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await settle(t);
      expect(find.text('You own this'), findsOneWidget);
      await end(t);
    });
  });
}

ProviderContainer _c(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(Scaffold).first));
