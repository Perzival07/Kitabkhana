import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/app_localizations.dart';

/// Builds a live camera view that reports raw barcode values. The default
/// uses `mobile_scanner`; tests substitute a fake. (P05.2 replaces this with
/// the full scanner service: debouncing, torch, lifecycle.)
typedef BarcodeViewBuilder = Widget Function(
  BuildContext context,
  void Function(String code) onCode,
  Widget Function(BuildContext context) unavailable,
);

Widget mobileScannerView(
  BuildContext context,
  void Function(String code) onCode,
  Widget Function(BuildContext context) unavailable,
) {
  return _MobileScannerView(onCode: onCode, unavailable: unavailable);
}

class _MobileScannerView extends StatefulWidget {
  const _MobileScannerView({required this.onCode, required this.unavailable});

  final void Function(String code) onCode;
  final Widget Function(BuildContext context) unavailable;

  @override
  State<_MobileScannerView> createState() => _MobileScannerViewState();
}

class _MobileScannerViewState extends State<_MobileScannerView> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const <BarcodeFormat>[BarcodeFormat.ean13],
    detectionSpeed: DetectionSpeed.normal,
    autoStart: false,
  );
  late final AppLifecycleListener _lifecycle;
  bool _tabActive = true;
  bool _foreground = true;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        _foreground = state == AppLifecycleState.resumed;
        _sync();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tabs that are not showing keep their state but stop ticking.
    _tabActive = TickerMode.valuesOf(context).enabled;
    _sync();
  }

  /// Runs the camera only while the tab is visible and the app is in front.
  void _sync() {
    if (!mounted) return;
    final shouldRun = _tabActive && _foreground;
    if (shouldRun == _running) return;
    _running = shouldRun;
    if (shouldRun) {
      unawaited(_controller.start().catchError((Object _) {}));
    } else {
      unawaited(_controller.stop().catchError((Object _) {}));
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            for (final barcode in capture.barcodes) {
              final value = barcode.rawValue;
              if (value != null) widget.onCode(value);
            }
          },
          errorBuilder: (context, error) => widget.unavailable(context),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: <Widget>[
              _RoundButton(
                icon: Icons.flashlight_on_rounded,
                tooltip: l10n.scanTorch,
                onPressed: () => unawaited(_controller.toggleTorch()),
              ),
              const SizedBox(width: 8),
              _RoundButton(
                icon: Icons.cameraswitch_rounded,
                tooltip: l10n.scanSwitchCamera,
                onPressed: () => unawaited(_controller.switchCamera()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}
