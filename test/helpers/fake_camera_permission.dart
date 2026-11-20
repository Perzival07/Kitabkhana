import 'package:kitabkhana/platform/camera_permission/camera_permission.dart';

class FakeCameraPermission implements CameraPermissionService {
  FakeCameraPermission({this.current = CameraAccess.granted});

  CameraAccess current;

  /// What a request resolves to.
  CameraAccess onRequest = CameraAccess.granted;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<CameraAccess> status() async => current;

  @override
  Future<CameraAccess> request() async {
    requests++;
    current = onRequest;
    return current;
  }

  @override
  Future<void> openSettings() async => settingsOpened++;
}
