import 'dart:async';

import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

/// A rounded search field with clear button, debounced callback and an
/// optional trailing scan button.
class KSearchField extends StatefulWidget {
  const KSearchField({
    required this.hint,
    required this.onChanged,
    this.controller,
    this.onSubmitted,
    this.onScanTap,
    this.scanTooltip,
    this.debounce = KDurations.search,
    this.autofocus = false,
    super.key,
  }) : assert(
         onScanTap == null || scanTooltip != null,
         'scanTooltip is required when onScanTap is set',
       );

  final String hint;

  /// Called after the user stops typing for [debounce].
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final VoidCallback? onScanTap;
  final String? scanTooltip;
  final Duration debounce;
  final bool autofocus;

  @override
  State<KSearchField> createState() => _KSearchFieldState();
}

class _KSearchFieldState extends State<KSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
  }

  String _last = '';

  void _onText() {
    // Rebuild for the clear button; debounce only real text changes.
    setState(() {});
    final text = _controller.text;
    if (text == _last) return;
    _last = text;
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(text));
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    _last = '';
    widget.onChanged('');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onText);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasText = _controller.text.isNotEmpty;
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (hasText)
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                onPressed: _clear,
              ),
            if (widget.onScanTap != null)
              IconButton(
                icon: Icon(Icons.qr_code_scanner_rounded, color: cs.primary),
                tooltip: widget.scanTooltip,
                onPressed: widget.onScanTap,
              ),
            const SizedBox(width: KSpacing.xs),
          ],
        ),
      ),
    );
  }
}
