/// Turns a phone number as people type it into international digits only
/// (no `+`, spaces or dashes), ready for `wa.me/<digits>` links.
///
/// - `+91 98765-43210`, `0091 98765 43210`, `91 98765 43210` → `919876543210`
/// - `098765 43210` (national format with a trunk `0`) → `919876543210`
/// - `9876543210` (just the national number) → `919876543210`
///
/// [defaultCountryCode] is digits only (e.g. `91`). Returns null when too few
/// digits remain to be a real number.
String? normalizePhone(String raw, {String defaultCountryCode = '91'}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final hadPlus = trimmed.startsWith('+');
  var digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  final cc = defaultCountryCode.replaceAll(RegExp(r'\D'), '');

  if (hadPlus) {
    // Already international.
  } else if (digits.startsWith('00')) {
    digits = digits.substring(2);
  } else if (digits.startsWith('0')) {
    digits = '$cc${digits.substring(1)}';
  } else if (cc.isNotEmpty &&
      digits.startsWith(cc) &&
      digits.length > cc.length + 6) {
    // Written with the country code but without a plus.
  } else {
    digits = '$cc$digits';
  }
  return digits.length >= 8 && digits.length <= 15 ? digits : null;
}

/// The `wa.me` link for [digits] (from [normalizePhone]), with an optional
/// pre-filled message.
Uri whatsAppLink(String digits, {String? message}) => Uri(
  scheme: 'https',
  host: 'wa.me',
  path: digits,
  queryParameters: message == null ? null : <String, String>{'text': message},
);
