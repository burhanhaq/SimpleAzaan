//
//  WatchScheduleSender.swift
//  Runner
//
//  Forwards the prayer schedule that Flutter saves in the App Group on to
//  the watch app. Flutter writes it through flutter_widgetkit from both the
//  foreground app and the background sync, and both run in this process, so
//  observing UserDefaults here catches every update without any Dart changes.
//

import Foundation
import WatchConnectivity

final class WatchScheduleSender: NSObject, WCSessionDelegate {
    static let shared = WatchScheduleSender()

    private var defaultsObserver: NSObjectProtocol?

    func start() {
        guard WCSession.isSupported(), defaultsObserver == nil else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()

        defaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.sendSchedule(force: false)
        }
    }

    /// Sends the saved schedule unless the watch already has it. `force`
    /// re-sends anyway, e.g. right after a complication is added.
    private func sendSchedule(force: Bool) {
        let session = WCSession.default
        guard session.activationState == .activated,
              session.isPaired,
              session.isWatchAppInstalled,
              let schedule = AppGroup.defaults?.string(forKey: SharedKey.prayerSchedule.rawValue) else {
            return
        }

        let key = SharedKey.prayerSchedule.rawValue
        guard force || session.applicationContext[key] as? String != schedule else { return }

        let payload = [key: schedule]
        do {
            try session.updateApplicationContext(payload)
        } catch {
            return
        }

        // Wakes the watch app in the background so complications refresh now
        // instead of the next time the app is opened.
        if session.isComplicationEnabled, session.remainingComplicationUserInfoTransfers > 0 {
            session.transferCurrentComplicationUserInfo(payload)
        }
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async { self.sendSchedule(force: false) }
    }

    /// Called when the watch app is installed or a complication is added.
    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.sendSchedule(force: true) }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    /// Happens when the user switches to another watch; activate again for it.
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
