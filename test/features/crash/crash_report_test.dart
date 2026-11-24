import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/crash_providers.dart';
import 'package:kitabkhana/app/settings_providers.dart';
import 'package:kitabkhana/core/logger.dart';
import 'package:kitabkhana/features/crash/application/crash_recorder.dart';
import 'package:kitabkhana/features/crash/application/problem_reporter.dart';
import 'package:kitabkhana/features/crash/domain/crash_report.dart';
import 'package:kitabkhana/features/settings/data/drift_settings_repository.dart';
import 'package:kitabkhana/platform/crash/crash_store.dart';

import '../../helpers/add_flow_harness.dart';
import '../../helpers/fake_launcher.dart';
import '../../helpers/fake_report_mailer.dart';
import '../../helpers/fake_share_service.dart';

CrashReport _report({String message = 'Bad state: boom'}) => CrashReport(
  at: DateTime.utc(2026, 11, 24, 10),
  kind: 'flutter',
  errorType: 'StateError',
  message: message,
  stack: '#0 main (file.dart:1)',
  logLines: const <String>['I started'],
  appVersion: '1.0.0',
  platform: 'android',
  osVersion: 'Android 15',
);

final Uint8List _png = Uint8List.fromList(<int>[137, 80, 78, 71]);

void main() {
  group('CrashReport', () {
    test('round-trips through JSON', () {
      final r = _report().withScreenshot(value: true);
      final back = CrashReport.fromJson(
        jsonDecode(jsonEncode(r.toJson())) as Map<String, Object?>,
      );
      expect(back.toJson(), r.toJson());
    });

    test('a damaged file still reads, with blanks', () {
      final r = CrashReport.fromJson(<String, Object?>{'logLines': 3});
      expect(r.errorType, 'Object');
      expect(r.logLines, isEmpty);
    });

    test('the report text carries the error, stack and log', () {
      final text = crashReportText(_report());
      expect(text, contains('StateError'));
      expect(text, contains('Bad state: boom'));
      expect(text, contains('#0 main'));
      expect(text, contains('I started'));
    });

    test('long messages are cut', () {
      expect(clip('x' * 50, 10), startsWith('xxxxxxxxxx'));
      expect(clip('x' * 50, 10), endsWith('(cut)'));
      expect(clip('short', 10), 'short');
    });
  });

  group('FileCrashStore', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('crash'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('keeps a report with its screenshot, then clears it', () async {
      final store = FileCrashStore(() async => dir);
      expect(await store.pending(), isNull);
      await store.save(_report(), screenshot: _png);
      final p = (await store.pending())!;
      expect(p.report.errorType, 'StateError');
      expect(p.report.hasScreenshot, isTrue);
      expect(p.screenshot, _png);
      await store.clear();
      expect(await store.pending(), isNull);
    });

    test(
      'a report saved again without a screenshot drops the old one',
      () async {
        final store = FileCrashStore(() async => dir);
        await store.save(_report(), screenshot: _png);
        await store.save(_report());
        final p = (await store.pending())!;
        expect(p.screenshot, isNull);
        expect(File('${dir.path}/crash/screenshot.png').existsSync(), isFalse);
      },
    );

    test('a broken file is ignored instead of throwing', () async {
      final store = FileCrashStore(() async => dir);
      Directory('${dir.path}/crash').createSync();
      File('${dir.path}/crash/report.json').writeAsStringSync('{not json');
      expect(await store.pending(), isNull);
    });

    test('an unreachable folder is ignored', () async {
      final store = FileCrashStore(() async => throw StateError('no folder'));
      expect(await store.pending(), isNull);
      await store.clear();
    });
  });

  group('CrashRecorder', () {
    CrashRecorder recorder(
      CrashStore store, {
      Future<Uint8List?> Function()? shot,
    }) => CrashRecorder(
      store: store,
      logger: AppLogger()..info('opened the library'),
      appVersion: '1.0.0',
      platform: 'android',
      osVersion: 'Android 15',
      screenshot: shot,
      now: () => DateTime.utc(2026, 11, 24),
    );

    test(
      'keeps the first problem of a run, with the log and a picture',
      () async {
        final store = MemoryCrashStore();
        final r = recorder(store, shot: () async => _png);
        await r.record(
          StateError('first'),
          StackTrace.current,
          kind: 'flutter',
        );
        await r.record(StateError('second'), null, kind: 'uncaught');
        final p = (await store.pending())!;
        expect(p.report.message, contains('first'));
        expect(p.report.logLines.single, contains('opened the library'));
        expect(p.screenshot, _png);
        expect(r.recorded, isTrue);
      },
    );

    test('a failing screenshot still keeps the report', () async {
      final store = MemoryCrashStore();
      await recorder(
        store,
        shot: () async => throw StateError('no picture'),
      ).record(StateError('x'), null, kind: 'flutter');
      final p = (await store.pending())!;
      expect(p.report.errorType, 'StateError');
      expect(p.screenshot, isNull);
    });

    test('image download errors and silent errors are not problems', () {
      expect(
        CrashRecorder.isReportable(
          FlutterErrorDetails(
            exception: StateError('404'),
            library: 'image resource service',
          ),
        ),
        isFalse,
      );
      expect(
        CrashRecorder.isReportable(
          FlutterErrorDetails(exception: StateError('x'), silent: true),
        ),
        isFalse,
      );
      expect(
        CrashRecorder.isReportable(
          FlutterErrorDetails(
            exception: StateError('x'),
            library: 'widgets library',
          ),
        ),
        isTrue,
      );
    });
  });

  group('ProblemReporter', () {
    late FakeReportMailer mailer;
    late FakeLauncher launcher;
    late FakeShareService share;

    ProblemReporter reporter() => ProblemReporter(
      mailer: mailer,
      launcher: launcher,
      share: share,
      to: 'dev@example.com',
      appName: 'Kitabkhana',
      appVersion: '1.0.0',
      platform: 'android',
      osVersion: 'Android 15',
    );

    Future<ReportOutcome> send({CrashReport? report, Uint8List? shot}) =>
        reporter().send(
          report: report,
          screenshot: shot,
          schemaVersion: 2,
          locale: 'en',
          now: DateTime.utc(2026, 11, 24),
          logLines: const <String>['I hello'],
        );

    setUp(() {
      mailer = FakeReportMailer();
      launcher = FakeLauncher();
      share = FakeShareService();
    });

    test('a crash opens the mail app addressed to the developer', () async {
      expect(await send(report: _report(), shot: _png), ReportOutcome.mailApp);
      final d = mailer.drafts.single;
      expect(d.to, 'dev@example.com');
      expect(d.subject, contains('crash report'));
      expect(d.subject, contains('StateError'));
      expect(d.body, contains('Bad state: boom'));
      expect(d.attachments.map((a) => a.name), <String>[
        'kitabkhana-crash.txt',
        'screenshot.png',
      ]);
      expect(
        utf8.decode(d.attachments.first.bytes),
        contains('#0 main (file.dart:1)'),
      );
    });

    test('a report by hand attaches the diagnostics', () async {
      await send();
      final d = mailer.drafts.single;
      expect(d.subject, contains('problem report'));
      expect(d.attachments.single.name, 'kitabkhana-diagnostics.txt');
      expect(utf8.decode(d.attachments.single.bytes), contains('I hello'));
    });

    test('without a mail app it falls back to a mailto link', () async {
      mailer.ok = false;
      expect(await send(report: _report()), ReportOutcome.mailLink);
      final uri = launcher.opened.single;
      expect(uri.scheme, 'mailto');
      expect(uri.path, 'dev@example.com');
      expect(uri.toString(), isNot(contains('+')));
      expect(Uri.decodeComponent(uri.query), contains('Bad state: boom'));
    });

    test('and with nothing at all, to the share sheet', () async {
      mailer.ok = false;
      launcher.ok = false;
      expect(await send(report: _report(), shot: _png), ReportOutcome.shared);
      expect(share.batches.single, hasLength(2));
    });
  });

  group('the prompt', () {
    Future<(AddFlowHarness, MemoryCrashStore, FakeReportMailer)> open(
      WidgetTester t, {
      bool offer = true,
      bool screenshot = true,
    }) async {
      final store = MemoryCrashStore();
      await store.save(_report(), screenshot: screenshot ? _png : null);
      final mailer = FakeReportMailer();
      final h = AddFlowHarness();
      addTearDown(h.dispose);
      h.extra.addAll([
        crashStoreProvider.overrideWithValue(store),
        reportMailerProvider.overrideWithValue(mailer),
      ]);
      if (!offer) {
        await t.runAsync(
          () => DriftSettingsRepository(h.db).setCrashReports(enabled: false),
        );
      }
      final c = await h.pump(t, start: '/library');
      // Settings load and the dialog opens after the first frames.
      await t.runAsync(() => c.read(settingsStreamProvider.future));
      for (var i = 0; i < 5; i++) {
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await t.pumpAndSettle();
      }
      return (h, store, mailer);
    }

    testWidgets('offers a kept report once, and emails it on yes', (t) async {
      final (_, store, mailer) = await open(t);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Include a screenshot'), findsOneWidget);
      await t.tap(find.text('Email report'));
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await t.pumpAndSettle();
      expect(mailer.drafts.single.attachments, hasLength(2));
      expect(await t.runAsync(store.pending), isNull);
    });

    testWidgets('the screenshot can be left out', (t) async {
      final (_, _, mailer) = await open(t);
      await t.tap(find.text('Include a screenshot'));
      await t.pump();
      await t.tap(find.text('Email report'));
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await t.pumpAndSettle();
      expect(
        mailer.drafts.single.attachments.single.name,
        'kitabkhana-crash.txt',
      );
    });

    testWidgets('"Not now" deletes it without sending', (t) async {
      final (_, store, mailer) = await open(t);
      await t.tap(find.text('Not now'));
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await t.pumpAndSettle();
      expect(mailer.drafts, isEmpty);
      expect(await t.runAsync(store.pending), isNull);
    });

    testWidgets('with the offer turned off, nothing is asked', (t) async {
      final (_, store, mailer) = await open(t, offer: false);
      expect(find.text('Something went wrong'), findsNothing);
      expect(mailer.drafts, isEmpty);
      expect(await t.runAsync(store.pending), isNull);
    });
  });
}
