import UIKit
import Flutter
import UserNotifications
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register WorkManager for background tasks
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
    }
    
    // Register background task identifier
    WorkmanagerPlugin.registerTask(withIdentifier: "dailyPrayerSync")
    
    // Ensure notifications show in the foreground on iOS 10+
    UNUserNotificationCenter.current().delegate = self
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
