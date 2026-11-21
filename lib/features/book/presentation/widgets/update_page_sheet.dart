import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';

/// Asks for the page the reader is on: a stepper plus a number field.
/// Resolves to the chosen page, or null when dismissed.
Future<int?> showUpdatePageSheet(
  BuildContext context, {
  required int current,
  int? pages,
}) => showKBottomSheet<int>(
  context: context,
  builder: (_) => _UpdatePageBody(current: current, pages: pages),
);

class _UpdatePageBody extends StatefulWidget {
  const _UpdatePageBody({required this.current, required this.pages});
  final int current;
  final int? pages;

  @override
  State<_UpdatePageBody> createState() => _UpdatePageBodyState();
}

class _UpdatePageBodyState extends State<_UpdatePageBody> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.current}',
  );
  String? _error;

  int? get _value => int.tryParse(_controller.text.trim());

  void _step(int delta) {
    final next = (_value ?? widget.current) + delta;
    final max = widget.pages;
    final clamped = next < 0 ? 0 : (max != null && next > max ? max : next);
    setState(() {
      _controller.text = '$clamped';
      _error = null;
    });
  }

  void _add(int n) => _step(n);

  void _save() {
    final l10n = AppLocalizations.of(context);
    final v = _value;
    final max = widget.pages;
    if (v == null || v < 0 || (max != null && v > max)) {
      setState(() => _error = l10n.detailPageInvalid(max ?? 99999));
      return;
    }
    Navigator.of(context).pop(v);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.detailUpdatePageTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.lg),
        Row(
          children: <Widget>[
            IconButton.filledTonal(
              tooltip: l10n.detailPageDecrease,
              icon: const Icon(Icons.remove_rounded),
              onPressed: () => _step(-1),
            ),
            const SizedBox(width: KSpacing.md),
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: l10n.detailPageLabel,
                  helperText: widget.pages == null ? null : '/ ${widget.pages}',
                  errorText: _error,
                ),
              ),
            ),
            const SizedBox(width: KSpacing.md),
            IconButton.filledTonal(
              tooltip: l10n.detailPageIncrease,
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _step(1),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.md),
        Wrap(
          spacing: KSpacing.sm,
          children: <Widget>[
            for (final n in const <int>[10, 25])
              ActionChip(
                label: Text('+$n'),
                tooltip: l10n.detailPageAddPages(n),
                onPressed: () => _add(n),
              ),
          ],
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
