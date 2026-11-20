import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart' as ph;

/// Where camera access stands.
enum CameraAccess {
  /// Never asked: explain first, then request.
  notAsked,
  granted,
  denied,
  permanentlyDenied,

  /// No usable camera (web without HTTPS, desktop, or no hardware).
  unavailable,
}

/// Reads and requests camera permission. Overridden in tests.
abstract interface class CameraPermissionService {
  Future<CameraAccess> status();
  Future<CameraAccess> request();
  Future<void> openSettings();
}

/// Mobile: asks the OS through `permission_handler`. On the web and desktop
/// the browser or the scanner plugin handles the prompt, so access is
/// reported as granted and a failure to start shows the title-search view.
class SystemCameraPermissionService implements CameraPermissionService {
  const SystemCameraPermissionService();

  bool get _usesOsPermission => !kIsWeb;

  CameraAccess _map(ph.PermissionStatus s) => switch (s) {
    ph.PermissionStatus.granted ||
    ph.PermissionStatus.limited => CameraAccess.granted,
    ph.PermissionStatus.permanentlyDenied ||
    ph.PermissionStatus.restricted => CameraAccess.permanentlyDenied,
    ph.PermissionStatus.denied => CameraAccess.notAsked,
    ph.PermissionStatus.provisional => CameraAccess.granted,
  };

  @override
  Future<CameraAccess> status() async {
    if (!_usesOsPermission) return CameraAccess.granted;
    try {
      return _map(await ph.Permission.camera.status);
    } on Object {
      return CameraAccess.unavailable;
    }
  }

  @override
  Future<CameraAccess> request() async {
    if (!_usesOsPermission) return CameraAccess.granted;
    try {
      final s = await ph.Permission.camera.request();
      final mapped = _map(s);
      // After a request, "denied" means the user said no (not "never asked").
      return mapped == CameraAccess.notAsked ? CameraAccess.denied : mapped;
    } on Object {
      return CameraAccess.unavailable;
    }
  }

  @override
  Future<void> openSettings() async {
    await ph.openAppSettings();
  }
}
