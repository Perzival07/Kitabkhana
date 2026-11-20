import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../l10n/app_localizations.dart';
import 'k_book_cover.dart';

/// A shimmering placeholder block. The shimmer is static when the user has
/// reduce-motion enabled.
class KSkeleton extends StatefulWidget {
  const KSkeleton({
    this.width,
    this.height = 16,
    this.radius = KRadii.chip / 2,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<KSkeleton> createState() => _KSkeletonState();
}

class _KSkeletonState extends State<KSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: KDurations.shimmer,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = cs.surfaceContainerHighest;
    final hi = Color.lerp(base, cs.surface, 0.6) ?? base;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment(-1.5 + 3 * t, 0),
                end: Alignment(-0.5 + 3 * t, 0),
                colors: <Color>[base, hi, base],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Placeholder for a book tile: cover shape plus two text lines.
class KBookTileSkeleton extends StatelessWidget {
  const KBookTileSkeleton({this.size, super.key});

  /// Fixed cover size; fills the available width when null.
  final KCoverSize? size;

  @override
  Widget build(BuildContext context) {
    final cover = AspectRatio(
      aspectRatio: 2 / 3,
      child: KSkeleton(
        width: size?.width,
        height: double.infinity,
        radius: KRadii.cover,
      ),
    );
    return Semantics(
      label: AppLocalizations.of(context).loading,
      excludeSemantics: true,
      child: SizedBox(
        width: size?.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            cover,
            const SizedBox(height: KSpacing.sm),
            const KSkeleton(height: 14),
            const SizedBox(height: KSpacing.xs),
            const KSkeleton(width: 60, height: 12),
          ],
        ),
      ),
    );
  }
}

/// A page-sized skeleton: a title bar and a few lines, for screens whose
/// content is still loading.
class KPageSkeleton extends StatelessWidget {
  const KPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(KSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          KSkeleton(width: 160, height: 24),
          SizedBox(height: KSpacing.lg),
          KSkeleton(height: 16),
          SizedBox(height: KSpacing.sm),
          KSkeleton(height: 16),
          SizedBox(height: KSpacing.sm),
          KSkeleton(width: 200, height: 16),
        ],
      ),
    );
  }
}
