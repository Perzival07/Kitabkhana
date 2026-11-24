import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludeLibraryFromDeviceBackup()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  /// Keeps the library (the database, covers and backups in Documents, and
  /// problem reports in Application Support) out of iCloud and computer
  /// backups of the device, matching Android's allowBackup="false". The
  /// reader keeps copies with Settings > Save a copy to… instead.
  /// Marking a folder excludes everything inside it, now and later.
  private func excludeLibraryFromDeviceBackup() {
    let fm = FileManager.default
    let dirs: [FileManager.SearchPathDirectory] = [.documentDirectory, .applicationSupportDirectory]
    for dir in dirs {
      guard var url = fm.urls(for: dir, in: .userDomainMask).first else { continue }
      try? fm.createDirectory(at: url, withIntermediateDirectories: true)
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      try? url.setResourceValues(values)
    }
  }
}
