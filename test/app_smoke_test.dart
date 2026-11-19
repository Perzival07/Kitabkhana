import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/app_config.dart';
import 'package:kitabkhana/app/app_root.dart';

void main() {
  testWidgets('shows the app name centred', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AppRoot(config: AppConfig.dev())),
    );
    expect(find.text('Kitabkhana'), findsOneWidget);
  });

  test('flavors expose the expected names', () {
    expect(const AppConfig.dev().appName, 'Kitabkhana Dev');
    expect(const AppConfig.prod().appName, 'Kitabkhana');
    expect(const AppConfig.dev().enableVerboseLogs, isTrue);
    expect(const AppConfig.prod().enableVerboseLogs, isFalse);
  });
}
