import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/add_book_providers.dart';
import 'package:kitabkhana/app/cover_providers.dart';
import 'package:kitabkhana/app/lookup_providers.dart';
import 'package:kitabkhana/app/providers.dart';
import 'package:kitabkhana/core/clock.dart';
import 'package:kitabkhana/data/db/app_database.dart';
import 'package:kitabkhana/data/db/database_provider.dart';
import 'package:kitabkhana/platform/photo_picker/photo_picker.dart';

import 'fake_book_info_source.dart';
import 'fake_cover_store.dart';
import 'pump_router_app.dart';
import 'repo_harness.dart';
import 'test_db.dart';

class FakePhotoPicker implements PhotoPicker {
  Uint8List? next;
  final List<PhotoSource> asked = <PhotoSource>[];

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    asked.add(source);
    return next;
  }
}

/// Everything the add-book screens need, backed by an in-memory database.
class AddFlowHarness {
  AddFlowHarness({this.scanCodes = const <String>[], this.cameraOk = true})
    : clock = FakeClock(DateTime(2025, 3, 10, 9)) {
    db = createTestDb();
    repos = RepoHarnessForDb(db, clock);
  }

  final FakeClock clock;
  late final AppDatabase db;
  late final RepoHarnessForDb repos;
  final FakeSource source = FakeSource();
  final FakeCoverStore covers = FakeCoverStore();
  final FakePhotoPicker picker = FakePhotoPicker();
  final List<String> scanCodes;
  final bool cameraOk;

  List<Override> get overrides => <Override>[
    appDatabaseProvider.overrideWithValue(db),
    clockProvider.overrideWithValue(clock),
    bookInfoSourceProvider.overrideWithValue(source),
    coverStoreProvider.overrideWithValue(covers),
    photoPickerProvider.overrideWithValue(picker),
    barcodeViewBuilderProvider.overrideWithValue((
      context,
      onCode,
      unavailable,
    ) {
      if (!cameraOk) return unavailable(context);
      return Column(
        children: <Widget>[
          for (final code in scanCodes)
            TextButton(
              onPressed: () => onCode(code),
              child: Text('scan $code'),
            ),
        ],
      );
    }),
  ];

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    String start = '/library/add',
    Size size = const Size(400, 900),
    double textScale = 1,
  }) async {
    final c = await pumpRouterApp(
      tester,
      size: size,
      textScale: textScale,
      overrides: overrides,
    );
    routerOf(c).go(start);
    await tester.pumpAndSettle();
    return c;
  }

  Future<void> dispose() => db.close();
}
