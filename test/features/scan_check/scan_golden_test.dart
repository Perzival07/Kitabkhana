@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/core/result.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/library/domain/book.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';
import 'package:kitabkhana/platform/camera_permission/camera_permission.dart';

import '../../helpers/add_flow_harness.dart';

void main() {
  const dune = '9780441013593';
  const other = '9780143127550';
  for (final dark in <bool>[false, true]) {
    final mode = dark ? 'dark' : 'light';
    for (final scene in <String>['permission', 'owned', 'notinlibrary']) {
      testWidgets('scan $scene ($mode)', (t) async {
        final h = AddFlowHarness(scanCodes: <String>[dune, other]);
        addTearDown(h.dispose);
        if (scene == 'permission') h.camera.current = CameraAccess.notAsked;
        await h.repos.books.upsert(
          Book.create(
            id: 'b1',
            title: 'Dune',
            authors: 'Frank Herbert',
            now: h.clock.now(),
            isbn13: parseIsbn(dune),
          ),
        );
        h.source.onIsbn = () => Ok(
          BookInfo(
            title: 'Sapiens',
            authors: const <String>['Yuval Noah Harari'],
            isbn13: parseIsbn(other),
          ),
        );
        final c = await h.pump(
          t,
          start: '/scan',
          size: const Size(360, 780),
          disableAnimations: true,
        );
        if (dark) {
          c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
          await t.pumpAndSettle();
        }
        if (scene != 'permission') {
          final code = scene == 'owned' ? dune : other;
          await t.tap(find.text('scan $code'));
          await t.pump(const Duration(milliseconds: 300));
          await t.tap(find.text('scan $code'));
          await t.pump(const Duration(milliseconds: 300));
          await t.pump(const Duration(milliseconds: 600));
        }
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/scan_${scene}_$mode.png'),
        );
        await t.pumpWidget(const SizedBox());
        await t.pump(const Duration(milliseconds: 400));
      });
    }
  }
}
