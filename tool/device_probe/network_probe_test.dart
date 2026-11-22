import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:kitabkhana/core/rate_limiter.dart';
import 'package:kitabkhana/core/text/isbn.dart';
import 'package:kitabkhana/data/open_library/open_library_client.dart';

/// Real network, real device: does the app's Open Library client reach the
/// service from inside Android? Not part of CI (it needs the internet).
///   flutter test tool/device_probe/network_probe_test.dart -d DEVICE --flavor dev
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('looks a book up by ISBN over the real network', (t) async {
    final c = OpenLibraryClient(
      client: http.Client(),
      limiter: RateLimiter(rate: 1, burst: 3),
      userAgent: 'Kitabkhana/1.0.0',
    );
    final r = await c.lookupIsbn(parseIsbn('9780141439518')!);
    // ignore: avoid_print
    print('PROBE RESULT: ${r.getOrNull()?.title ?? r}');
    expect(r.getOrNull()?.title, isNotNull, reason: '$r');
  });
}
