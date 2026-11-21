//
//  PrayerSchedule.swift
//  Shared by Runner, the watch app and the watch complications.
//
//  Decodes the JSON written by `PrayerSchedule.toJson()` in
//  lib/models/prayer_schedule.dart.
//

import Foundation

struct PrayerTime: Equatable, Hashable {
    let kind: PrayerKind
    let date: Date
}

struct PrayerDay: Equatable {
    /// Always six entries, ordered Fajr…Isha.
    let prayers: [PrayerTime]

    var fajr: PrayerTime { prayers[PrayerKind.fajr.rawValue] }

    func time(of kind: PrayerKind) -> PrayerTime { prayers[kind.rawValue] }
}

struct PrayerLocation: Decodable, Equatable {
    let city: String
    let state: String
    let country: String

    /// Same as `Location.displayName` in lib/models/location.dart.
    var displayName: String {
        [city, state.isEmpty ? country : state]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    private enum CodingKeys: String, CodingKey {
        case city, state, country
    }

    init(city: String, state: String, country: String) {
        self.city = city
        self.state = state
        self.country = country
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
    }
}

struct PrayerSchedule: Equatable {
    let generatedAt: Date
    let location: PrayerLocation
    let days: [PrayerDay]

    /// Every time in the schedule, oldest first.
    var prayers: [PrayerTime] { days.flatMap(\.prayers) }

    enum DecodingFailure: Error {
        case invalidDate(String)
    }

    init(generatedAt: Date, location: PrayerLocation, days: [PrayerDay]) {
        self.generatedAt = generatedAt
        self.location = location
        self.days = days.sorted { $0.fajr.date < $1.fajr.date }
    }

    init(jsonData: Data) throws {
        let raw = try JSONDecoder().decode(RawSchedule.self, from: jsonData)
        let days = try raw.days.map { rawDay in
            let times = [rawDay.time1, rawDay.time2, rawDay.time3,
                         rawDay.time4, rawDay.time5, rawDay.time6]
            let prayers = try zip(PrayerKind.allCases, times).map { kind, value in
                PrayerTime(kind: kind, date: try Self.parseDate(value))
            }
            return PrayerDay(prayers: prayers)
        }
        self.init(
            generatedAt: try Self.parseDate(raw.generatedAt),
            location: raw.location,
            days: days
        )
    }

    /// Reads the schedule from the App Group store, or nil if none is saved
    /// or it can't be decoded.
    static func load(from defaults: UserDefaults? = AppGroup.defaults) -> PrayerSchedule? {
        guard let json = defaults?.string(forKey: SharedKey.prayerSchedule.rawValue),
              let data = json.data(using: .utf8) else {
            return nil
        }
        return try? PrayerSchedule(jsonData: data)
    }

    // MARK: - Parsing

    private struct RawSchedule: Decodable {
        let generatedAt: String
        let location: PrayerLocation
        let days: [RawDay]
    }

    private struct RawDay: Decodable {
        let time1: String
        let time2: String
        let time3: String
        let time4: String
        let time5: String
        let time6: String
    }

    private static let isoWithFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoWithoutFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    /// Dart's `toIso8601String()` writes milliseconds, or microseconds when
    /// they are non-zero, so fall back to dropping the fraction.
    static func parseDate(_ value: String) throws -> Date {
        if let date = isoWithFraction.date(from: value) ?? isoWithoutFraction.date(from: value) {
            return date
        }
        if let fraction = value.range(of: #"\.\d+"#, options: .regularExpression),
           let date = isoWithoutFraction.date(from: value.replacingCharacters(in: fraction, with: "")) {
            return date
        }
        throw DecodingFailure.invalidDate(value)
    }
}
