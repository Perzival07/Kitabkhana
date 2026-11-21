import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/app_config.dart';
import 'package:kitabkhana/app/error_fallback.dart';
import 'package:kitabkhana/app/error_handling.dart';
import 'package:kitabkhana/core/logger.dart';

void main() {
  late FlutterExceptionHandler? savedFlutter;
  late ErrorCallback? savedPlatform;
  late ErrorWidgetBuilder savedBuilder;

  setUp(() {
    savedFlutter = FlutterError.onError;
    savedPlatform = PlatformDispatcher.instance.onError;
    savedBuilder = ErrorWidget.builder;
  });

  tearDown(() {
    FlutterError.onError = savedFlutter;
    PlatformDispatcher.instance.onError = savedPlatform;
    ErrorWidget.builder = savedBuilder;
  });

  test('framework errors are logged (prod does not re-throw)', () {
    final log = AppLogger();
    installGlobalErrorHandlers(const AppConfig.prod(), log);
    FlutterError.onError!(
      FlutterErrorDetails(
        exception: StateError('Dune by Frank Herbert\nsecond line'),
      ),
    );
    // The type is logged; what the message says (it can quote the screen) is not.
    expect(log.lines.single, contains('FlutterError'));
    expect(log.lines.single, contains('StateError'));
    expect(log.lines.single, isNot(contains('Dune')));
    expect(log.lines.single, isNot(contains('Herbert')));
    expect(log.lines.single, isNot(contains('second')));
  });

  test('uncaught async errors are logged and handled', () {
    final log = AppLogger();
    installGlobalErrorHandlers(const AppConfig.prod(), log);
    final handled = PlatformDispatcher.instance.onError!(
      ArgumentError('x'),
      StackTrace.current,
    );
    expect(handled, isTrue);
    expect(log.lines.single, contains('Uncaught error'));
    expect(log.lines.single, contains('[ArgumentError]'));
  });

  test('prod swaps in the friendly ErrorWidget, dev keeps the default', () {
    installGlobalErrorHandlers(const AppConfig.dev(), AppLogger());
    expect(ErrorWidget.builder, same(savedBuilder));
    installGlobalErrorHandlers(const AppConfig.prod(), AppLogger());
    expect(ErrorWidget.builder, same(buildErrorFallback));
  });

  testWidgets('fallback renders friendly localised copy without ancestors', (
    t,
  ) async {
    await t.pumpWidget(
      buildErrorFallback(FlutterErrorDetails(exception: StateError('x'))),
    );
    expect(find.text('Something went wrong here'), findsOneWidget);
    expect(find.textContaining('Your library is safe'), findsOneWidget);
  });
}
