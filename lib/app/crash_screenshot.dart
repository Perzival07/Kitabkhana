import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Wraps the whole app (see `AppRoot`) so a problem report can include a
/// picture of the screen.
final GlobalKey crashScreenshotKey = GlobalKey(debugLabel: 'crash-screenshot');

/// A PNG of the app as it is drawn after the current frame, or null.
Future<Uint8List?> captureAppScreenshot() async {
  final frame = Completer<void>();
  SchedulerBinding.instance
    ..addPostFrameCallback((_) {
      if (!frame.isCompleted) frame.complete();
    })
    ..scheduleFrame();
  await frame.future.timeout(const Duration(seconds: 2), onTimeout: () {});
  final box = crashScreenshotKey.currentContext?.findRenderObject();
  if (box is! RenderRepaintBoundary || box.debugNeedsPaint) return null;
  final ratio = math.min(
    2,
    ui.PlatformDispatcher.instance.views.first.devicePixelRatio,
  );
  final image = await box.toImage(pixelRatio: ratio.toDouble());
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
