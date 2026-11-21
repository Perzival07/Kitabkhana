@Tags(<String>['e2e'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/flows.dart';
import '../../integration_test/support.dart';

/// The core journeys, run in the ordinary test runner. The very same journeys
/// run on a device or in a browser from `integration_test/app_test.dart`.
void main() {
  for (final journey in journeys) {
    testWidgets(journey.name, (t) async {
      final e = E2e(t, scanCodes: journey.scanCodes);
      addTearDown(e.dispose);
      await journey.run(e);
      await e.end();
    });
  }
}
