import '../../../core/text/phone.dart';
import '../../../l10n/app_localizations.dart';
import '../../lending/domain/loan.dart';

/// The ways a nudge can leave the app.
abstract interface class NudgeLauncher {
  /// Opens [uri] in another app; false when nothing could handle it.
  Future<bool> open(Uri uri);

  /// Last resort: the system share sheet.
  Future<void> share(String text);
}

/// What happened when a nudge was sent.
enum NudgeResult { whatsApp, sms, shared, noPhone, failed }

/// A polite, pre-filled reminder to the person who has (or lent) a book.
class LoanNudge {
  LoanNudge(this._launcher);

  final NudgeLauncher _launcher;

  static String message(AppLocalizations l10n, Loan loan, String bookTitle) =>
      l10n.nudgeMessage(loan.personName, bookTitle);

  /// WhatsApp first; when it is not installed, SMS; then the share sheet.
  Future<NudgeResult> whatsApp(
    AppLocalizations l10n,
    Loan loan,
    String bookTitle, {
    required String defaultCountryCode,
  }) async {
    final phone = _phone(loan, defaultCountryCode);
    final text = message(l10n, loan, bookTitle);
    if (phone == null) return NudgeResult.noPhone;
    if (await _launcher.open(whatsAppLink(phone, message: text))) {
      return NudgeResult.whatsApp;
    }
    if (await _launcher.open(_sms(phone, text))) return NudgeResult.sms;
    await _launcher.share(text);
    return NudgeResult.shared;
  }

  Future<NudgeResult> sms(
    AppLocalizations l10n,
    Loan loan,
    String bookTitle, {
    required String defaultCountryCode,
  }) async {
    final phone = _phone(loan, defaultCountryCode);
    final text = message(l10n, loan, bookTitle);
    if (phone == null) return NudgeResult.noPhone;
    if (await _launcher.open(_sms(phone, text))) return NudgeResult.sms;
    await _launcher.share(text);
    return NudgeResult.shared;
  }

  String? _phone(Loan loan, String cc) {
    final raw = loan.personPhone;
    return raw == null || raw.isEmpty
        ? null
        : normalizePhone(raw, defaultCountryCode: cc);
  }

  /// `sms:` links want the body percent-encoded (spaces as %20, not +).
  Uri _sms(String digits, String body) =>
      Uri.parse('sms:+$digits?body=${Uri.encodeComponent(body)}');
}
