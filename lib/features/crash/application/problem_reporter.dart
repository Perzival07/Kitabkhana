import 'dart:convert';
import 'dart:typed_data';

import '../../../platform/crash/report_mailer.dart';
import '../../../platform/share/share_service.dart';
import '../../reminders/application/loan_nudge.dart';
import '../../settings/application/diagnostics.dart';
import '../domain/crash_report.dart';

/// How a report left the app.
enum ReportOutcome {
  /// The mail app opened with the report attached.
  mailApp,

  /// Only a plain `mailto:` link could be opened (no attachments).
  mailLink,

  /// No mail app at all: the files went to the share sheet.
  shared,
}

/// Puts a problem report into the reader's mail app, addressed to the
/// developer. Falls back to a `mailto:` link (the web), then to the share
/// sheet, so a report is never simply lost.
class ProblemReporter {
  const ProblemReporter({
    required this.mailer,
    required this.launcher,
    required this.share,
    required this.to,
    required this.appName,
    required this.appVersion,
    required this.platform,
    required this.osVersion,
  });

  final ReportMailer mailer;
  final NudgeLauncher launcher;
  final ShareService share;
  final String to;
  final String appName;
  final String appVersion;
  final String platform;
  final String osVersion;

  /// [report] is null for a report started by hand; then [logLines] and the
  /// other diagnostics fields describe the app as it is now.
  Future<ReportOutcome> send({
    CrashReport? report,
    Uint8List? screenshot,
    required int schemaVersion,
    required String locale,
    required DateTime now,
    required List<String> logLines,
  }) async {
    final text = problemEmailText(
      report: report,
      appName: appName,
      appVersion: appVersion,
      platform: platform,
      osVersion: osVersion,
    );
    final details = report != null
        ? crashReportText(report)
        : buildDiagnostics(
            appName: appName,
            appVersion: appVersion,
            schemaVersion: schemaVersion,
            platform: platform,
            locale: locale,
            generatedAt: now,
            logLines: logLines,
          );
    final files = <ShareableFile>[
      (
        bytes: Uint8List.fromList(utf8.encode(details)),
        name: report != null
            ? 'kitabkhana-crash.txt'
            : 'kitabkhana-diagnostics.txt',
        mimeType: 'text/plain',
      ),
      if (screenshot != null)
        (bytes: screenshot, name: 'screenshot.png', mimeType: 'image/png'),
    ];

    if (await mailer.compose(
      to: to,
      subject: text.subject,
      body: text.body,
      attachments: files,
    )) {
      return ReportOutcome.mailApp;
    }

    // A link cannot carry files, so the details go in the body, kept short
    // enough for every mail app to accept.
    final link = Uri(
      scheme: 'mailto',
      path: to,
      query: _query(<String, String>{
        'subject': text.subject,
        'body': clip('${text.body}\n$details', 1800),
      }),
    );
    if (await launcher.open(link)) return ReportOutcome.mailLink;

    await share.shareFiles(files);
    return ReportOutcome.shared;
  }

  // `Uri(queryParameters:)` encodes spaces as `+`, which mail apps show
  // literally; mailto wants `%20`.
  static String _query(Map<String, String> params) => params.entries
      .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
