//
//  SimpleAzaanWatchApp.swift
//  SimpleAzaan Watch Watch App
//

import SwiftUI
import WatchKit

@main
struct SimpleAzaanWatchApp: App {
    @WKApplicationDelegateAdaptor private var appDelegate: WatchAppDelegate

    var body: some Scene {
        WindowGroup {
            PrayerScreen(store: .shared)
        }
    }
}

final class WatchAppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        WatchScheduleReceiver.shared.start()
    }

    /// The system wakes the app in the background when the iPhone sends a
    /// new schedule for the complications.
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let connectivityTask = task as? WKWatchConnectivityRefreshBackgroundTask {
                WatchScheduleReceiver.shared.completeWhenReceived(connectivityTask)
            } else {
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}
