//
//  SimpleAzaan_Watch_Watch_AppTests.swift
//  SimpleAzaan Watch Watch AppTests
//
//  Tests the shared schedule decoding and status logic in ios/Shared.
//

import Foundation
import Testing
@testable import SimpleAzaan_Watch_Watch_App

/// Builds schedules in the JSON format `PrayerSchedule.toJson()` writes in
/// lib/models/prayer_schedule.dart, for Bellevue (America/Los_Angeles).
private enum Fixture {
    static let timeZone = TimeZone(identifier: "America/Los_Angeles")!

    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    /// Local times for each day: Fajr 05:00, Sunrise 06:30, Zuhr 13:00,
    /// Asr 16:30, Maghrib 18:30, Isha 20:00.
    static let localTimes = [(5, 0), (6, 30), (13, 0), (16, 30), (18, 30), (20, 0)]

    static func date(day: Int, hour: Int, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))!
    }

    /// Dart writes UTC with milliseconds, e.g. 2026-10-18T12:00:00.000Z.
    static func dartISO(_ date: Date, fraction: String = ".000") -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date).replacingOccurrences(of: "Z", with: "\(fraction)Z")
    }

    static func json(days: ClosedRange<Int>, fraction: String = ".000") -> Data {
        let dayObjects = days.map { day in
            let times = localTimes.enumerated().map { index, time in
                "\"time\(index + 1)\":\"\(dartISO(date(day: day, hour: time.0, minute: time.1), fraction: fraction))\""
            }
            return "{\(times.joined(separator: ","))}"
        }
        return """
        {"schemaVersion":1,"generatedAt":"2026-10-18T08:00:00.000Z",
         "location":{"city":"Bellevue","state":"WA","country":"United States","latitude":47.61,"longitude":null},
         "calculationMethod":"2","days":[\(dayObjects.joined(separator: ","))]}
        """.data(using: .utf8)!
    }

    static func schedule(days: ClosedRange<Int> = 18...19) throws -> PrayerSchedule {
        try PrayerSchedule(jsonData: json(days: days))
    }
}

struct PrayerScheduleDecodingTests {
    @Test func decodesFlutterSchedule() throws {
        let schedule = try Fixture.schedule()

        #expect(schedule.days.count == 2)
        #expect(schedule.prayers.count == 12)
        #expect(schedule.location.displayName == "Bellevue, WA")
        #expect(schedule.days[0].time(of: .dhuhr).date == Fixture.date(day: 18, hour: 13))
        #expect(schedule.days[1].fajr.date == Fixture.date(day: 19, hour: 5))
    }

    @Test(arguments: ["", ".000", ".123456"])
    func parsesDatesWithAnyFraction(fraction: String) throws {
        let schedule = try PrayerSchedule(jsonData: Fixture.json(days: 18...18, fraction: fraction))
        let fajr = schedule.days[0].fajr.date.timeIntervalSince(Fixture.date(day: 18, hour: 5))
        #expect(abs(fajr) < 1)
    }

    @Test func rejectsInvalidDates() {
        let json = Data(#"{"generatedAt":"nope","location":{},"days":[]}"#.utf8)
        #expect(throws: PrayerSchedule.DecodingFailure.self) {
            try PrayerSchedule(jsonData: json)
        }
    }
}

struct PrayerStatusTests {
    private func status(day: Int, hour: Int, minute: Int = 0, days: ClosedRange<Int> = 18...19) throws -> PrayerStatus? {
        PrayerStatus(
            at: Fixture.date(day: day, hour: hour, minute: minute),
            schedule: try Fixture.schedule(days: days),
            calendar: Fixture.calendar
        )
    }

    @Test func beforeFajrOnFirstDay() throws {
        let status = try #require(try status(day: 18, hour: 3))
        #expect(status.current == nil)
        #expect(status.next.kind == .fajr)
        #expect(status.today.first?.date == Fixture.date(day: 18, hour: 5))
    }

    @Test func beforeFajrCurrentIsYesterdaysIsha() throws {
        let status = try #require(try status(day: 19, hour: 3))
        #expect(status.current?.kind == .isha)
        #expect(status.current?.date == Fixture.date(day: 18, hour: 20))
        #expect(status.next == PrayerTime(kind: .fajr, date: Fixture.date(day: 19, hour: 5)))
    }

    @Test func betweenPrayers() throws {
        let status = try #require(try status(day: 18, hour: 14))
        #expect(status.current?.kind == .dhuhr)
        #expect(status.next.kind == .asr)
        #expect(status.today.map(\.kind) == PrayerKind.allCases)
    }

    @Test func exactlyAtPrayerTimeThatPrayerIsCurrent() throws {
        let status = try #require(try status(day: 18, hour: 16, minute: 30))
        #expect(status.current?.kind == .asr)
        #expect(status.next.kind == .maghrib)
    }

    @Test func afterIshaNextIsTomorrowsFajrAndTodayStays() throws {
        let status = try #require(try status(day: 18, hour: 22))
        #expect(status.current?.kind == .isha)
        #expect(status.next == PrayerTime(kind: .fajr, date: Fixture.date(day: 19, hour: 5)))
        #expect(status.today.first?.date == Fixture.date(day: 18, hour: 5))
    }

    @Test func includesTomorrowsFajrAndSunrise() throws {
        let status = try #require(try status(day: 18, hour: 14))
        #expect(status.tomorrowFajr?.date == Fixture.date(day: 19, hour: 5))
        #expect(status.tomorrowSunrise?.date == Fixture.date(day: 19, hour: 6, minute: 30))
    }

    @Test func noTomorrowOnLastDay() throws {
        let status = try #require(try status(day: 19, hour: 14))
        #expect(status.tomorrowFajr == nil)
        #expect(status.tomorrowSunrise == nil)
    }

    @Test func nilWhenScheduleHasRunOut() throws {
        #expect(try status(day: 19, hour: 21) == nil)
    }
}

struct PrayerIntervalTests {
    @Test func startsNowThenAtEachPrayer() throws {
        let schedule = try Fixture.schedule()
        let now = Fixture.date(day: 18, hour: 14)
        let intervals = schedule.intervals(from: now)

        #expect(intervals.first == PrayerInterval(
            start: now,
            previous: schedule.days[0].time(of: .dhuhr),
            next: schedule.days[0].time(of: .asr)
        ))
        // Asr→Maghrib … Maghrib(19th)→Isha(19th): 8 more after the first.
        #expect(intervals.count == 9)
        #expect(intervals.dropFirst().allSatisfy { $0.start > now && $0.start == $0.previous?.date })
        #expect(zip(intervals, intervals.dropFirst()).allSatisfy { $0.start < $1.start })
        #expect(intervals.last?.next.kind == .isha)
    }

    @Test func emptyWhenScheduleHasRunOut() throws {
        let schedule = try Fixture.schedule()
        #expect(schedule.intervals(from: Fixture.date(day: 19, hour: 21)).isEmpty)
    }
}
