@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/theme/theme_mode_provider.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/features/library/domain/book_info.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/pump_router_app.dart';

import 'package:kitabkhana/core/result.dart';

void main() {
  const sizes = <String, Size>{'360': Size(360, 800), '800': Size(800, 1000)};
  const screens = <String, String>{
    'entry': '/library/add',
    'isbn': '/library/add/isbn',
    'manual': '/library/add/manual',
  };
  for (final dark in <bool>[false, true]) {
    for (final s in sizes.entries) {
      for (final sc in screens.entries) {
        final mode = dark ? 'dark' : 'light';
        testWidgets('add ${sc.key} ${s.key} ($mode)', (t) async {
          final h = AddFlowHarness();
          h.source.onIsbn = () =>
              Ok(BookInfo(title: 'x', isbn13: parseIsbn('9780143127550')));
          final c = await h.pump(t, start: sc.value, size: s.value);
          if (dark) {
            c.read(themeModeControllerProvider.notifier).set(ThemeMode.dark);
            await t.pumpAndSettle();
          }
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/add_${sc.key}_${s.key}_$mode.png'),
          );
          await h.dispose();
        });
      }
    }
  }
  // keep the import used
  test('route helper', () => expect(locationOf, isNotNull));
}
