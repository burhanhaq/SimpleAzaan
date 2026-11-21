//
//  SharedStorage.swift
//  Shared by Runner, the watch app and the watch complications.
//

import Foundation

/// App Group shared by each app and its widgets. The iPhone and the watch
/// each have their own container; the phone forwards the schedule to the
/// watch over WatchConnectivity.
enum AppGroup {
    static let id = "group.com.dumblemon.SimpleAzaan"

    static var defaults: UserDefaults? { UserDefaults(suiteName: id) }
}

/// Keys in the App Group store. `prayerSchedule` matches `kPrayerScheduleKey`
/// in lib/constants.dart.
enum SharedKey: String {
    case prayerSchedule
}

enum WidgetKind: String {
    case nextPrayer = "NextPrayerComplication"
}
