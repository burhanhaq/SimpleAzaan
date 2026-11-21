//
//  PrayerTimeFormat.swift
//  Shared by Runner, the watch app and the watch complications.
//

import Foundation

/// 24-hour times, matching the iPhone app's `kk:mm` format.
enum PrayerTimeFormat {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
