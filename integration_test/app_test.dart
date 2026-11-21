import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'flows.dart';
import 'support.dart';

/// The core journeys on a real device, emulator or browser:
///
///   flutter test integration_test -d DEVICE
///   flutter drive --driver=test_driver/integration_test.dart \
///       --target=integration_test/app_test.dart -d chrome
///
/// Camera, text reading, notifications, Open Library, sharing and the file
/// picker are fakes, so the run needs no permissions and no network.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final journey in journeys) {
    testWidgets(journey.name, (t) async {
      final e = E2e(t, scanCodes: journey.scanCodes);
      addTearDown(e.dispose);
      await journey.run(e);
      await e.end();
    });
  }
}
