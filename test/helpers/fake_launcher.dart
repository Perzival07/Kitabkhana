import 'package:kitabkhana/features/reminders/application/loan_nudge.dart';

/// Records the links "opened" instead of leaving the app.
class FakeLauncher implements NudgeLauncher {
  final List<Uri> opened = <Uri>[];
  bool ok = true;

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return ok;
  }

  @override
  Future<void> share(String text) async {}
}
