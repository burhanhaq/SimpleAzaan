import UIKit
import Flutter
import UserNotifications
import workmanager

/// Background task identifiers. Each must also be listed under
/// `BGTaskSchedulerPermittedIdentifiers` in Info.plist and match
/// `BackgroundPrayerSync.taskIdentifier` in Dart.
private enum BackgroundTaskIdentifier {
  static let dailyPrayerSync = "com.dumblemon.simpleAzaan.dailyPrayerSync"
}

/// Uses the UIScene life cycle (FlutterSceneDelegate in Info.plist), which apps built
/// with the iOS 27 SDK require in order to launch. The Flutter engine is created after
/// launch, so plugins are registered in `didInitializeImplicitFlutterEngine`.
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // BGTaskScheduler requires task registration before launch finishes.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerTask(withIdentifier: BackgroundTaskIdentifier.dailyPrayerSync)

    // Show notifications while the app is in the foreground.
    UNUserNotificationCenter.current().delegate = self

    // Forward the prayer schedule to the Apple Watch whenever Flutter saves it.
    WatchScheduleSender.shared.start()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
