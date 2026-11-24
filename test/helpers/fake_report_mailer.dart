import 'package:kitabkhana/platform/crash/report_mailer.dart';
import 'package:kitabkhana/platform/share/share_service.dart';

/// Records the drafts the mail app would have opened with.
class FakeReportMailer implements ReportMailer {
  bool ok = true;
  final List<
    ({String to, String subject, String body, List<ShareableFile> attachments})
  >
  drafts =
      <
        ({
          String to,
          String subject,
          String body,
          List<ShareableFile> attachments,
        })
      >[];

  @override
  Future<bool> compose({
    required String to,
    required String subject,
    required String body,
    List<ShareableFile> attachments = const <ShareableFile>[],
  }) async {
    if (!ok) return false;
    drafts.add((
      to: to,
      subject: subject,
      body: body,
      attachments: attachments,
    ));
    return true;
  }
}
