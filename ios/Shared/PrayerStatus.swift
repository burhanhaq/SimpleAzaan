//
//  PrayerStatus.swift
//  Shared by Runner, the watch app and the watch complications.
//

import Foundation

/// What the watch shows at a given moment: the prayer in progress, the one
/// coming up, today's times and tomorrow's Fajr and Sunrise.
struct PrayerStatus: Equatable {
    /// The latest time that has started. Can be yesterday's Isha before Fajr,
    /// and is nil only if the schedule starts in the future.
    let current: PrayerTime?
    let next: PrayerTime
    let today: [PrayerTime]
    let tomorrowFajr: PrayerTime?
    let tomorrowSunrise: PrayerTime?

    /// Nil when the schedule has no time left after `now`, meaning the
    /// iPhone needs to sync a fresh schedule.
    init?(at now: Date, schedule: PrayerSchedule, calendar: Calendar = .current) {
        let prayers = schedule.prayers
        guard let next = prayers.first(where: { $0.date > now }) else { return nil }

        let todayIndex = schedule.days.firstIndex { calendar.isDate($0.fajr.date, inSameDayAs: now) }
            ?? schedule.days.firstIndex { $0.prayers.contains(next) }
        guard let todayIndex else { return nil }

        let today = schedule.days[todayIndex]
        let tomorrowIndex = todayIndex + 1
        let tomorrow = schedule.days.indices.contains(tomorrowIndex) ? schedule.days[tomorrowIndex] : nil

        self.current = prayers.last { $0.date <= now }
        self.next = next
        self.today = today.prayers
        self.tomorrowFajr = tomorrow?.time(of: .fajr)
        self.tomorrowSunrise = tomorrow?.time(of: .sunrise)
    }
}

/// The stretch between two consecutive times, used for complication timeline
/// entries and progress rings.
struct PrayerInterval: Equatable {
    /// When this interval starts showing on the watch.
    let start: Date
    let previous: PrayerTime?
    let next: PrayerTime
}

extension PrayerSchedule {
    /// One interval starting at `now`, then one starting at each later time,
    /// up to the last time that still has a next one.
    func intervals(from now: Date) -> [PrayerInterval] {
        let prayers = self.prayers
        guard let firstNext = prayers.firstIndex(where: { $0.date > now }) else { return [] }

        var intervals = [PrayerInterval(
            start: now,
            previous: firstNext > 0 ? prayers[firstNext - 1] : nil,
            next: prayers[firstNext]
        )]
        for index in prayers.indices.dropFirst(firstNext + 1) {
            intervals.append(PrayerInterval(
                start: prayers[index - 1].date,
                previous: prayers[index - 1],
                next: prayers[index]
            ))
        }
        return intervals
    }
}
