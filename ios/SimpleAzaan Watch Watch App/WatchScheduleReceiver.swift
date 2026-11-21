//
//  WatchScheduleReceiver.swift
//  SimpleAzaan Watch Watch App
//
//  Receives the prayer schedule from the iPhone (see
//  Runner/WatchScheduleSender.swift), saves it to the watch's App Group
//  store for the complications, and refreshes the screen.
//

import Foundation
import Observation
import WatchConnectivity
import WatchKit
import WidgetKit

@Observable
final class PrayerScheduleStore {
    static let shared = PrayerScheduleStore()

    private(set) var schedule: PrayerSchedule? = PrayerSchedule.load()

    func reload() {
        schedule = PrayerSchedule.load()
    }
}

final class WatchScheduleReceiver: NSObject, WCSessionDelegate {
    static let shared = WatchScheduleReceiver()

    /// Background tasks to complete once WatchConnectivity has delivered
    /// everything. Only touched on the main queue.
    private var pendingTasks: [WKWatchConnectivityRefreshBackgroundTask] = []
    private var contentPendingObservation: NSKeyValueObservation?

    func start() {
        guard WCSession.isSupported(), WCSession.default.delegate == nil else { return }
        let session = WCSession.default
        session.delegate = self
        contentPendingObservation = session.observe(\.hasContentPending) { [weak self] _, _ in
            DispatchQueue.main.async { self?.completeTasksIfIdle() }
        }
        session.activate()
    }

    func completeWhenReceived(_ task: WKWatchConnectivityRefreshBackgroundTask) {
        start()
        pendingTasks.append(task)
        completeTasksIfIdle()
    }

    private func completeTasksIfIdle() {
        let session = WCSession.default
        guard session.activationState == .activated, !session.hasContentPending else { return }
        pendingTasks.forEach { $0.setTaskCompletedWithSnapshot(false) }
        pendingTasks.removeAll()
    }

    private func save(_ payload: [String: Any]) {
        let key = SharedKey.prayerSchedule.rawValue
        guard let json = payload[key] as? String else { return }
        DispatchQueue.main.async {
            let defaults = AppGroup.defaults
            if defaults?.string(forKey: key) != json {
                defaults?.set(json, forKey: key)
                WidgetCenter.shared.reloadAllTimelines()
                PrayerScheduleStore.shared.reload()
            }
            self.completeTasksIfIdle()
        }
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        // Picks up a schedule that arrived while the app wasn't running.
        save(session.receivedApplicationContext)
        DispatchQueue.main.async { self.completeTasksIfIdle() }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        save(applicationContext)
    }

    /// Complication transfers from `transferCurrentComplicationUserInfo`.
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        save(userInfo)
    }
}
