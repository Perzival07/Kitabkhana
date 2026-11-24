import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/reading_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../library/domain/book.dart';
import '../domain/reading_timer.dart';

/// "35 min", "2 h", "2 h 5 min".
String minutesText(AppLocalizations l10n, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.durationMinutes(m);
  if (m == 0) return l10n.durationHours(h);
  return l10n.durationHoursMinutes(h, m);
}

/// `12:34`, or `1:02:03` past an hour.
String clockText(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// Starts or stops the reading timer for [book]. While it runs for this book
/// it shows the time read so far. Stopping logs the minutes and then calls
/// [onStopped] (the Reading tab asks for the page reached).
class ReadingTimerButton extends ConsumerStatefulWidget {
  const ReadingTimerButton({
    super.key,
    required this.book,
    required this.onStopped,
  });

  final Book book;
  final Future<void> Function(int? minutes) onStopped;

  @override
  ConsumerState<ReadingTimerButton> createState() => _ReadingTimerButtonState();
}

class _ReadingTimerButtonState extends ConsumerState<ReadingTimerButton> {
  Timer? _tick;

  void _sync(bool running) {
    if (running && _tick == null) {
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!running) {
      _tick?.cancel();
      _tick = null;
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _toggle(bool running) async {
    final timer = ref.read(readingTimerProvider.notifier);
    if (!running) {
      Haptics.light();
      await timer.start(widget.book.id);
      return;
    }
    Haptics.success();
    final minutes = await timer.stop();
    await widget.onStopped(minutes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final RunningTimer? t = ref.watch(readingTimerProvider).value;
    final running = t != null && t.bookId == widget.book.id;
    _sync(running);
    final elapsed = running
        ? t.elapsed(ref.read(clockProvider).now())
        : Duration.zero;
    return IconButton.filledTonal(
      tooltip: running ? l10n.timerStop(clockText(elapsed)) : l10n.timerStart,
      isSelected: running,
      icon: const Icon(Icons.timer_outlined),
      selectedIcon: const Icon(Icons.stop_rounded),
      onPressed: () => _toggle(running),
    );
  }
}

/// "Reading for 12:34" under a book while its timer runs.
class ReadingTimerElapsed extends ConsumerStatefulWidget {
  const ReadingTimerElapsed({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<ReadingTimerElapsed> createState() =>
      _ReadingTimerElapsedState();
}

class _ReadingTimerElapsedState extends ConsumerState<ReadingTimerElapsed> {
  Timer? _tick;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(readingTimerProvider).value;
    if (t == null || t.bookId != widget.bookId) {
      _tick?.cancel();
      _tick = null;
      return const SizedBox.shrink();
    }
    _tick ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Text(
      l10n.timerRunning(clockText(t.elapsed(ref.read(clockProvider).now()))),
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
      ),
    );
  }
}
