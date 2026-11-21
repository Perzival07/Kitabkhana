import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/quote.dart';

/// The text and page chosen in the edit sheet.
typedef QuoteEdit = ({String body, int? page});

/// Edits a quote's text and page. Resolves to the new values, or null.
Future<QuoteEdit?> showQuoteEditSheet(
  BuildContext context, {
  required Quote quote,
}) => showKBottomSheet<QuoteEdit>(
  context: context,
  builder: (_) => _EditBody(quote: quote),
);

class _EditBody extends StatefulWidget {
  const _EditBody({required this.quote});

  final Quote quote;

  @override
  State<_EditBody> createState() => _EditBodyState();
}

class _EditBodyState extends State<_EditBody> {
  late final TextEditingController _body = TextEditingController(
    text: widget.quote.body,
  );
  late final TextEditingController _page = TextEditingController(
    text: widget.quote.page?.toString() ?? '',
  );
  String? _bodyError;
  String? _pageError;

  @override
  void dispose() {
    _body.dispose();
    _page.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final text = _body.text.trim();
    final pageText = _page.text.trim();
    final page = pageText.isEmpty ? null : int.tryParse(pageText);
    setState(() {
      _bodyError = text.isEmpty ? l10n.quoteBodyRequired : null;
      _pageError = pageText.isNotEmpty && (page == null || page < 1)
          ? l10n.quotePageInvalid
          : null;
    });
    if (_bodyError != null || _pageError != null) return;
    Navigator.of(context).pop((body: text, page: page));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.quoteEditTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.lg),
        TextField(
          controller: _body,
          autofocus: true,
          minLines: 4,
          maxLines: 10,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.quoteBodyLabel,
            alignLabelWithHint: true,
            errorText: _bodyError,
          ),
        ),
        const SizedBox(height: KSpacing.md),
        TextField(
          controller: _page,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: l10n.quotePageLabel,
            errorText: _pageError,
          ),
        ),
        const SizedBox(height: KSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: _save, child: Text(l10n.save)),
        ),
      ],
    );
  }
}
