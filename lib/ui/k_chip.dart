import 'package:flutter/material.dart';

import '../app/theme/k_tokens.dart';
import '../app/theme/tokens.dart';
import '../l10n/app_localizations.dart';

/// A static chip with an optional leading icon.
class KChip extends StatelessWidget {
  const KChip({required this.label, this.icon, this.onDeleted, super.key});

  final String label;
  final IconData? icon;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: icon == null ? null : Icon(icon, size: 18),
      onDeleted: onDeleted,
      deleteIcon: onDeleted == null ? null : const Icon(Icons.close_rounded),
      visualDensity: VisualDensity.standard,
    );
  }
}

/// A selectable filter chip. Selection is shown by tint and a check icon,
/// never by colour alone.
class KFilterChip extends StatelessWidget {
  const KFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: selected
          ? Icon(Icons.check_rounded, size: 18, color: cs.onPrimaryContainer)
          : (icon == null ? null : Icon(icon, size: 18)),
      side: BorderSide(color: selected ? cs.primary : cs.outlineVariant),
    );
  }
}

/// Reading status shown by [KStatusPill].
enum KStatus { want, reading, finished, dropped }

/// A subtle status pill: icon + text on a soft tint.
class KStatusPill extends StatelessWidget {
  const KStatusPill({required this.status, super.key});

  final KStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.kTokens;
    final cs = Theme.of(context).colorScheme;
    final (String label, IconData icon, Color tone) = switch (status) {
      KStatus.want => (
        l10n.statusWant,
        Icons.bookmark_border_rounded,
        cs.secondary,
      ),
      KStatus.reading => (
        l10n.statusReading,
        Icons.auto_stories_rounded,
        cs.primary,
      ),
      KStatus.finished => (
        l10n.statusFinished,
        Icons.check_circle_outline_rounded,
        tokens.success,
      ),
      KStatus.dropped => (
        l10n.statusDropped,
        Icons.remove_circle_outline_rounded,
        tokens.warning,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(KRadii.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KSpacing.sm,
          vertical: KSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: tone),
            const SizedBox(width: KSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
