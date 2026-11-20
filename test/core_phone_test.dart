import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/text/phone.dart';

void main() {
  group('normalizePhone', () {
    test('international forms', () {
      expect(normalizePhone('+91 98765-43210'), '919876543210');
      expect(normalizePhone('0091 98765 43210'), '919876543210');
      expect(normalizePhone('+44 7911 123456'), '447911123456');
    });
    test('national forms get the default country code', () {
      expect(normalizePhone('9876543210'), '919876543210');
      expect(normalizePhone('09876543210'), '919876543210');
      expect(normalizePhone('98765 43210'), '919876543210');
    });
    test('country code written without a plus is kept', () {
      expect(normalizePhone('919876543210'), '919876543210');
    });
    test('another default country code', () {
      expect(
        normalizePhone('7911123456', defaultCountryCode: '+44'),
        '447911123456',
      );
    });
    test('rejects junk and too-short numbers', () {
      expect(normalizePhone(''), isNull);
      expect(normalizePhone('abc'), isNull);
      expect(normalizePhone('123'), isNull);
      expect(normalizePhone('+1234567890123456789'), isNull);
    });
  });

  test('whatsAppLink encodes the message (emoji, quotes, Hindi)', () {
    final u = whatsAppLink('919876543210', message: 'Hi "Priya" 📚 किताब');
    expect(u.host, 'wa.me');
    expect(u.path, '/919876543210');
    expect(u.queryParameters['text'], 'Hi "Priya" 📚 किताब');
    expect(u.toString(), contains('text='));
    expect(u.toString().contains(' '), isFalse);
  });
}
