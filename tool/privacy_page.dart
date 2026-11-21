import 'package:markdown/markdown.dart' as md;

/// Turns the privacy policy (Markdown) into one self-contained HTML page:
/// no scripts, no external fonts or images, light and dark colours.
String buildPrivacyPage(String markdown) {
  final body = md.markdownToHtml(
    markdown,
    extensionSet: md.ExtensionSet.gitHubWeb,
  );
  final title =
      RegExp(r'^# (.+)$', multiLine: true).firstMatch(markdown)?.group(1) ??
      'Privacy policy';
  return '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="referrer" content="no-referrer">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'">
<title>${_escape(title)}</title>
<style>
  :root { color-scheme: light dark; --bg:#FBF7F0; --text:#1F1B16; --muted:#6B6259; --accent:#A64A24; --rule:#E5DDD0; }
  @media (prefers-color-scheme: dark) { :root { --bg:#15120F; --text:#F2EBE1; --muted:#B3A89A; --accent:#E08A5B; --rule:#3A322A; } }
  body { margin:0; background:var(--bg); color:var(--text); font:17px/1.65 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; }
  main { max-width: 42rem; margin: 0 auto; padding: 2.5rem 1.25rem 4rem; }
  h1, h2 { font-family: Georgia, "Times New Roman", serif; line-height: 1.25; }
  h1 { font-size: 2rem; margin: 0 0 .25rem; }
  h2 { font-size: 1.35rem; margin: 2.2rem 0 .5rem; padding-top: 1rem; border-top: 1px solid var(--rule); }
  a { color: var(--accent); }
  code { background: var(--rule); padding: .05em .35em; border-radius: 4px; font-size: .92em; }
  em { color: var(--muted); }
  li { margin: .35rem 0; }
</style>
</head>
<body>
<main>
$body
</main>
</body>
</html>
''';
}

String _escape(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
