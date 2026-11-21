import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../app/theme/tokens.dart';
import '../../../core/image/page_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

/// What the reader chose in the crop step.
final class PageChoice {
  const PageChoice(this.quarterTurns, this.crop);

  final int quarterTurns;
  final CropRect crop;
}

/// A simple built-in cropper: rotate in quarter turns, drag the corners (or
/// the box) to frame the text. Reports the choice; the caller applies it.
class CropStep extends StatefulWidget {
  const CropStep({required this.image, required this.onDone, super.key});

  final Uint8List image;
  final void Function(PageChoice choice) onDone;

  @override
  State<CropStep> createState() => _CropStepState();
}

class _CropStepState extends State<CropStep> {
  static const double _min = 0.12;
  static const double _handle = 28;

  Size? _size;
  int _turns = 0;
  CropRect _crop = CropRect.full;

  @override
  void initState() {
    super.initState();
    _measure();
  }

  Future<void> _measure() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.image);
      final frame = await codec.getNextFrame();
      final size = Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
      frame.image.dispose();
      codec.dispose();
      if (mounted) setState(() => _size = size);
    } on Object {
      // Undecodable here: show it uncropped; the editor reports the error.
      if (mounted) setState(() => _size = const Size(3, 4));
    }
  }

  void _rotate(int by) => setState(() {
    _turns = (_turns + by) % 4;
    _crop = CropRect.full;
  });

  /// Moves one edge or corner; fractions stay in 0..1 and keep a minimum size.
  void _drag(
    Offset delta,
    Size box, {
    bool l = false,
    bool t = false,
    bool r = false,
    bool b = false,
  }) {
    final dx = delta.dx / box.width;
    final dy = delta.dy / box.height;
    var left = _crop.left;
    var top = _crop.top;
    var right = _crop.right;
    var bottom = _crop.bottom;
    if (l) left = (left + dx).clamp(0.0, right - _min);
    if (r) right = (right + dx).clamp(left + _min, 1.0);
    if (t) top = (top + dy).clamp(0.0, bottom - _min);
    if (b) bottom = (bottom + dy).clamp(top + _min, 1.0);
    setState(() => _crop = CropRect(left, top, right, bottom));
  }

  void _move(Offset delta, Size box) {
    final w = _crop.right - _crop.left;
    final h = _crop.bottom - _crop.top;
    final left = (_crop.left + delta.dx / box.width).clamp(0.0, 1 - w);
    final top = (_crop.top + delta.dy / box.height).clamp(0.0, 1 - h);
    setState(() => _crop = CropRect(left, top, left + w, top + h));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final size = _size;
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(KSpacing.lg),
            child: size == null
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, c) {
                      final odd = _turns.isOdd;
                      final aspect = odd
                          ? size.height / size.width
                          : size.width / size.height;
                      var w = c.maxWidth;
                      var h = w / aspect;
                      if (h > c.maxHeight) {
                        h = c.maxHeight;
                        w = h * aspect;
                      }
                      final box = Size(w, h);
                      final r = Rect.fromLTRB(
                        _crop.left * w,
                        _crop.top * h,
                        _crop.right * w,
                        _crop.bottom * h,
                      );
                      return Center(
                        child: SizedBox(
                          width: w,
                          height: h,
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: RotatedBox(
                                  quarterTurns: _turns,
                                  child: Image.memory(
                                    widget.image,
                                    fit: BoxFit.fill,
                                    gaplessPlayback: true,
                                    errorBuilder: (_, _, _) => const Center(
                                      child: Icon(Icons.broken_image_outlined),
                                    ),
                                  ),
                                ),
                              ),
                              // Dim everything outside the crop box.
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: _DimPainter(r, cs.scrim),
                                  ),
                                ),
                              ),
                              Positioned.fromRect(
                                rect: r,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onPanUpdate: (d) => _move(d.delta, box),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: cs.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              for (final (a, b, dl, dt, dr, db)
                                  in <(double, double, bool, bool, bool, bool)>[
                                    (r.left, r.top, true, true, false, false),
                                    (r.right, r.top, false, true, true, false),
                                    (
                                      r.left,
                                      r.bottom,
                                      true,
                                      false,
                                      false,
                                      true,
                                    ),
                                    (
                                      r.right,
                                      r.bottom,
                                      false,
                                      false,
                                      true,
                                      true,
                                    ),
                                  ])
                                Positioned(
                                  left: a - _handle / 2,
                                  top: b - _handle / 2,
                                  width: _handle,
                                  height: _handle,
                                  child: GestureDetector(
                                    onPanUpdate: (d) => _drag(
                                      d.delta,
                                      box,
                                      l: dl,
                                      t: dt,
                                      r: dr,
                                      b: db,
                                    ),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: cs.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: cs.onPrimary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KSpacing.screen,
            0,
            KSpacing.screen,
            KSpacing.lg,
          ),
          child: Row(
            children: <Widget>[
              IconButton.filledTonal(
                tooltip: l10n.quoteRotateLeft,
                icon: const Icon(Icons.rotate_left_rounded),
                onPressed: size == null ? null : () => _rotate(3),
              ),
              const SizedBox(width: KSpacing.sm),
              IconButton.filledTonal(
                tooltip: l10n.quoteRotateRight,
                icon: const Icon(Icons.rotate_right_rounded),
                onPressed: size == null ? null : () => _rotate(1),
              ),
              const SizedBox(width: KSpacing.lg),
              Expanded(
                child: KButton(
                  label: l10n.quoteReadText,
                  icon: Icons.text_fields_rounded,
                  expand: true,
                  onPressed: size == null
                      ? null
                      : () => widget.onDone(PageChoice(_turns, _crop)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DimPainter extends CustomPainter {
  const _DimPainter(this.hole, this.color);

  final Rect hole;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRect(hole)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(_DimPainter old) => old.hole != hole || old.color != color;
}
