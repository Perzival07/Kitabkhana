import 'dart:io';

import 'privacy_page.dart';

/// `dart run tool/build_privacy_page.dart` writes `docs/privacy/index.html`
/// from `docs/privacy/privacy-policy.md`. Host that one file anywhere that
/// serves static pages over HTTPS; its address is the "privacy policy URL" for
/// the stores and for `--dart-define=PRIVACY_URL=...`.
void main() {
  final source = File('docs/privacy/privacy-policy.md').readAsStringSync();
  File('docs/privacy/index.html').writeAsStringSync(buildPrivacyPage(source));
  stdout.writeln('Wrote docs/privacy/index.html');
}
