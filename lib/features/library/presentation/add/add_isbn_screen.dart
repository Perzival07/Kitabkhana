import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/k_tokens.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../core/text/isbn.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import 'isbn_lookup_flow.dart';

/// Type or paste an ISBN, with live validation, then look it up.
class AddIsbnScreen extends ConsumerStatefulWidget {
  const AddIsbnScreen({super.key});

  @override
  ConsumerState<AddIsbnScreen> createState() => _AddIsbnScreenState();
}

enum _IsbnState { empty, incomplete, invalid, valid }

class _AddIsbnScreenState extends ConsumerState<AddIsbnScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _digits =>
      _controller.text.toUpperCase().replaceAll(RegExp(r'[^0-9X]'), '');

  _IsbnState get _state {
    if (_digits.isEmpty) return _IsbnState.empty;
    if (parseIsbn(_controller.text) != null) return _IsbnState.valid;
    // Still typing toward 10 or 13 digits (an 18-digit scan with add-on also
    // counts as complete input).
    if (_digits.length < 10 || (_digits.length > 10 && _digits.length < 13)) {
      return _IsbnState.incomplete;
    }
    return _IsbnState.invalid;
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || !mounted) return;
    _controller
      ..text = text.trim()
      ..selection = TextSelection.collapsed(offset: text.trim().length);
  }

  Future<void> _lookUp() async {
    final isbn = parseIsbn(_controller.text);
    if (isbn == null || _busy) return;
    setState(() => _busy = true);
    await lookupIsbnAndContinue(context: context, ref: ref, isbn: isbn);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = _state;
    final (String? helper, bool isError) = switch (state) {
      _IsbnState.empty => (null, false),
      _IsbnState.incomplete => (l10n.isbnIncomplete, false),
      _IsbnState.invalid => (l10n.isbnInvalid, true),
      _IsbnState.valid => (l10n.isbnValid, false),
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addIsbnTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(KSpacing.screen),
              children: <Widget>[
                TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9Xx\- ]')),
                  ],
                  onSubmitted: (_) => _lookUp(),
                  decoration: InputDecoration(
                    labelText: l10n.isbnFieldLabel,
                    hintText: l10n.isbnFieldHint,
                    errorText: isError ? helper : null,
                    helperText: isError ? null : helper,
                    helperStyle: state == _IsbnState.valid
                        ? theme.textTheme.bodySmall?.copyWith(
                            color: context.kTokens.success,
                          )
                        : null,
                    suffixIcon: state == _IsbnState.valid
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: context.kTokens.success,
                          )
                        : IconButton(
                            icon: const Icon(Icons.content_paste_rounded),
                            tooltip: l10n.pasteFromClipboard,
                            onPressed: _paste,
                          ),
                  ),
                ),
                const SizedBox(height: KSpacing.lg),
                KButton(
                  label: _busy ? l10n.lookingUp : l10n.lookUp,
                  loading: _busy,
                  expand: true,
                  onPressed: state == _IsbnState.valid ? _lookUp : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
