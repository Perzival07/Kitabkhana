import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

/// How much the app may move. One place that every animation asks, so
/// reduce-motion (`MediaQuery.disableAnimations`, which follows the
/// system's "remove animations" / "reduce motion" setting) is honoured
/// everywhere the same way: movement and scaling stop, durations become zero.
final class MotionPrefs {
  const MotionPrefs({required this.reduce});

  /// Read from the current [MediaQuery].
  factory MotionPrefs.of(BuildContext context) =>
      MotionPrefs(reduce: MediaQuery.disableAnimationsOf(context));

  /// The reader asked for less motion.
  final bool reduce;

  /// [d], or no time at all when motion is reduced.
  Duration duration(Duration d) => reduce ? Duration.zero : d;

  /// [c], or a straight line when motion is reduced.
  Curve curve(Curve c) => reduce ? Curves.linear : c;
}

extension MotionContext on BuildContext {
  /// The reader's motion preferences.
  MotionPrefs get motion => MotionPrefs.of(this);
}

/// Fades and slides its child in, a little later for each [index], so a list
/// or grid appears in a gentle cascade.
///
/// Meant for a screen's first load only: pass `play: false` afterwards (and
/// for rows that scroll in later) and the child is shown as it is. Nothing
/// animates under reduce-motion. Driven by one controller (no timers), so a
/// test can wait for it with `pumpAndSettle`.
class KEnter extends StatefulWidget {
  const KEnter({
    required this.index,
    required this.play,
    required this.child,
    this.maxStagger = 10,
    super.key,
  });

  /// Position in the list; later items start later.
  final int index;

  /// Whether to animate at all.
  final bool play;

  /// Items beyond this index all start together, so a long list does not
  /// take long to appear.
  final int maxStagger;
  final Widget child;

  @override
  State<KEnter> createState() => _KEnterState();
}

class _KEnterState extends State<KEnter> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _curve;
  bool _decided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    if (!widget.play || context.motion.reduce) return;
    final delay = KDurations.stagger * widget.index.clamp(0, widget.maxStagger);
    final total = delay + KDurations.slow;
    final c = AnimationController(vsync: this, duration: total);
    _controller = c;
    _curve = CurvedAnimation(
      parent: c,
      curve: Interval(
        delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: KCurves.standard,
      ),
    );
    c.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = _curve;
    if (curve == null) return widget.child;
    return AnimatedBuilder(
      animation: curve,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, (1 - curve.value) * 14),
          child: child,
        ),
      ),
    );
  }
}

/// Grows its child from a little smaller to full size with a soft overshoot
/// when it first appears (or when [replay] changes): a "pop" for a result.
/// Under reduce-motion it just appears.
class KPop extends StatelessWidget {
  const KPop({required this.child, this.replay, super.key});

  final Widget child;

  /// Change this to play the pop again (for example the kind of result).
  final Object? replay;

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;
    if (motion.reduce) return child;
    return TweenAnimationBuilder<double>(
      key: ValueKey<Object?>(replay),
      tween: Tween<double>(begin: 0.6, end: 1),
      duration: KDurations.slow,
      curve: KCurves.pop,
      child: child,
      builder: (context, scale, child) => Opacity(
        opacity: ((scale - 0.6) / 0.4).clamp(0.0, 1.0),
        child: Transform.scale(scale: scale, child: child),
      ),
    );
  }
}
