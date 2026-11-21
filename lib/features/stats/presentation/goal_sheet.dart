import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

/// What the reader chose in the goal sheet.
sealed class GoalChoice {
  const GoalChoice();
}

final class GoalSet extends GoalChoice {
  const GoalSet(this.target);
  final int target;
}

final class GoalRemoved extends GoalChoice {
  const GoalRemoved();
}

/// Sets or edits the book goal for [year]. Resolves to the choice, or null
/// when dismissed. [current] is the existing target, if any.
Future<GoalChoice?> showGoalSheet(
  BuildContext context, {
  required int year,
  int? current,
}) => showKBottomSheet<GoalChoice>(
  context: context,
  builder: (_) => _GoalBody(year: year, current: current),
);

class _GoalBody extends StatefulWidget {
  const _GoalBody({required this.year, required this.current});

  final int year;
  final int? current;

  @override
  State<_GoalBody> createState() => _GoalBodyState();
}

class _GoalBodyState extends State<_GoalBody> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.current ?? 12}',
  );
  String? _error;

  int? get _value => int.tryParse(_controller.text.trim());

  void _step(int delta) {
    final next = ((_value ?? 0) + delta).clamp(1, 999);
    setState(() {
      _controller.text = '$next';
      _error = null;
    });
  }

  void _save() {
    final v = _value;
    if (v == null || v < 1 || v > 999) {
      setState(() => _error = AppLocalizations.of(context).statsGoalInvalid);
      return;
    }
    Navigator.of(context).pop(GoalSet(v));
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
          l10n.statsGoalSheetTitle(widget.year),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.lg),
        Row(
          children: <Widget>[
            IconButton.filledTonal(
              tooltip: l10n.statsGoalFewer,
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
                decoration: InputDecoration(errorText: _error),
              ),
            ),
            const SizedBox(width: KSpacing.md),
            IconButton.filledTonal(
              tooltip: l10n.statsGoalMore,
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _step(1),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: _save, child: Text(l10n.save)),
        ),
        if (widget.current != null)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(const GoalRemoved()),
              child: Text(l10n.statsGoalRemove),
            ),
          ),
      ],
    );
  }
}
