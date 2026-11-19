import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_config_provider.dart';
import '../../app/l10n/failure_message.dart';
import '../../app/lookup_providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/result.dart';
import '../../core/text/isbn.dart';
import '../../features/library/domain/book_info.dart';
import '../../l10n/app_localizations.dart';

/// Dev-only screen to try Open Library lookups. Strings are not localised
/// because it never ships in prod.
class DevLookupScreen extends ConsumerStatefulWidget {
  const DevLookupScreen({super.key});

  @override
  ConsumerState<DevLookupScreen> createState() => _DevLookupScreenState();
}

class _DevLookupScreenState extends ConsumerState<DevLookupScreen> {
  final TextEditingController _controller = TextEditingController(
    text: '9780143127550',
  );
  String _output = '';
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String> Function() job) async {
    setState(() {
      _busy = true;
      _output = '';
    });
    final started = DateTime.now();
    final text = await job();
    final ms = DateTime.now().difference(started).inMilliseconds;
    if (mounted) {
      setState(() {
        _busy = false;
        _output = '$text\n\n($ms ms)';
      });
    }
  }

  String _describe(Result<Object> r, AppLocalizations l10n) => r.fold(
    (v) => v is List<BookInfo>
        ? v
              .map(
                (b) =>
                    '${b.title} | ${b.authorsText} | ${b.pages} p | '
                    '${b.isbn13} | ${b.olWorkKey} | ${b.year}',
              )
              .join('\n')
        : v is BookInfo
        ? 'title: ${v.title}\nsubtitle: ${v.subtitle}\n'
              'authors: ${v.authors}\npages: ${v.pages}\n'
              'isbn13: ${v.isbn13}\nwork: ${v.olWorkKey}\n'
              'cover: ${v.coverUrl}\nyear: ${v.year}\n'
              'complete: ${v.isComplete}'
        : '$v',
    (f) => 'FAILED: ${f.runtimeType} / ${failureMessage(l10n, f)}',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final service = ref.watch(bookLookupServiceProvider);
    final config = ref.watch(appConfigProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lookup debug')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(KSpacing.screen),
          children: <Widget>[
            Text(
              'User-Agent: ${config.userAgent}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: KSpacing.md),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'ISBN or title'),
            ),
            const SizedBox(height: KSpacing.md),
            Wrap(
              spacing: KSpacing.sm,
              runSpacing: KSpacing.sm,
              children: <Widget>[
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() async {
                          final isbn = parseIsbn(_controller.text);
                          if (isbn == null) return 'Not a valid ISBN';
                          return _describe(
                            await service.lookupIsbn(isbn),
                            l10n,
                          );
                        }),
                  child: const Text('Look up ISBN'),
                ),
                FilledButton.tonal(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          () async => _describe(
                            await service.searchTitle(_controller.text),
                            l10n,
                          ),
                        ),
                  child: const Text('Search title'),
                ),
              ],
            ),
            const SizedBox(height: KSpacing.lg),
            if (_busy) const LinearProgressIndicator(),
            SelectableText(_output),
          ],
        ),
      ),
    );
  }
}
