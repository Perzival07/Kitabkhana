import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/app/app_config.dart';

import 'helpers/pump_router_app.dart';

void main() {
  testWidgets('app boots into the Library tab', (tester) async {
    final c = await pumpRouterApp(tester);
    expect(locationOf(c), '/library');
    // The large app bar shows the title in its expanded and collapsed forms.
    expect(find.text('Your library'), findsWidgets);
  });

  test('flavors expose the expected names', () {
    expect(const AppConfig.dev().appName, 'Kitabkhana Dev');
    expect(const AppConfig.prod().appName, 'Kitabkhana');
    expect(const AppConfig.dev().enableVerboseLogs, isTrue);
    expect(const AppConfig.prod().enableVerboseLogs, isFalse);
  });
}
