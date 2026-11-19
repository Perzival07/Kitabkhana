import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _controller,
      onDetect: (capture) {
        for (final barcode in capture.barcodes) {
          final value = barcode.rawValue;
          if (value != null) {
            widget.onCode(value);
            return;
          }
        }
      },
      errorBuilder: (context, error) => widget.unavailable(context),
    );
  }
}
