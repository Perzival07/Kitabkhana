import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

import '../share/share_service.dart';

/// Opens the reader's own mail app with a filled-in email. The reader sees
/// everything and decides whether to press Send; the app sends nothing itself.
abstract interface class ReportMailer {
  /// False when no mail app could take the email.
  Future<bool> compose({
    required String to,
    required String subject,
    required String body,
    List<ShareableFile> attachments,
  });
}

class PlatformReportMailer implements ReportMailer {
  const PlatformReportMailer();

  @override
  Future<bool> compose({
    required String to,
    required String subject,
    required String body,
    List<ShareableFile> attachments = const <ShareableFile>[],
  }) async {
    // The web cannot attach files to a mail draft; the caller falls back to
    // a mailto link.
    if (kIsWeb) return false;
    try {
      await FlutterEmailSender.send(
        Email(
          recipients: <String>[to],
          subject: subject,
          body: body,
          attachments: <EmailAttachment>[
            for (final f in attachments)
              EmailAttachment.data(
                f.bytes,
                fileName: f.name,
                mimeType: f.mimeType,
              ),
          ],
        ),
      );
      return true;
    } on Object {
      return false;
    }
  }
}
