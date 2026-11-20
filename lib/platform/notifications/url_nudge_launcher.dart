import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/reminders/application/loan_nudge.dart';

/// Opens messaging apps through the system, and shares as a last resort.
class UrlNudgeLauncher implements NudgeLauncher {
  const UrlNudgeLauncher();

  @override
  Future<bool> open(Uri uri) async {
    try {
      // "Not installed" shows up as false (or an exception on some devices).
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }

  @override
  Future<void> share(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
