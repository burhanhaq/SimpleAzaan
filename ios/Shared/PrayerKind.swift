//
//  PrayerKind.swift
//  Shared by Runner, the watch app and the watch complications.
//

import Foundation

/// The six daily times, in the order of `time1`…`time6` in the stored schedule.
enum PrayerKind: Int, CaseIterable {
    case fajr
    case sunrise
    case dhuhr
    case asr
    case maghrib
    case isha

    /// Spelled the same way as the iPhone app and lock screen widget.
    var displayName: String {
        switch self {
        case .fajr: return "Fajr"
        case .sunrise: return "Sunrise"
        case .dhuhr: return "Zuhr"
        case .asr: return "Asr"
        case .maghrib: return "Maghrib"
        case .isha: return "Isha"
        }
    }
}
