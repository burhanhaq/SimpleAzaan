//
//  NextPrayerComplication.swift
//  SimpleAzaanComplications
//

import SwiftUI
import WidgetKit

@main
struct NextPrayerComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetKind.nextPrayer.rawValue, provider: NextPrayerProvider()) { entry in
            NextPrayerView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName("Next Prayer")
        .description("The next prayer and its time.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline])
    }
}

struct NextPrayerEntry: TimelineEntry {
    let date: Date
    /// Nil when the iPhone hasn't synced a schedule, or it has run out.
    let interval: PrayerInterval?

    static var sample: NextPrayerEntry {
        let now = Date()
        return NextPrayerEntry(date: now, interval: PrayerInterval(
            start: now,
            previous: PrayerTime(kind: .asr, date: now.addingTimeInterval(-90 * 60)),
            next: PrayerTime(kind: .maghrib, date: now.addingTimeInterval(72 * 60))
        ))
    }
}

struct NextPrayerProvider: TimelineProvider {
    /// How long to wait before checking again when there is nothing to show.
    /// A new schedule from the iPhone reloads the timeline sooner.
    private static let retryInterval: TimeInterval = 60 * 60

    func placeholder(in context: Context) -> NextPrayerEntry {
        .sample
    }

    func getSnapshot(in context: Context, completion: @escaping (NextPrayerEntry) -> Void) {
        let now = Date()
        let interval = PrayerSchedule.load()?.intervals(from: now).first
        completion(interval.map { NextPrayerEntry(date: now, interval: $0) } ?? .sample)
    }

    /// One entry now, then one at every prayer change in the saved schedule.
    func getTimeline(in context: Context, completion: @escaping (Timeline<NextPrayerEntry>) -> Void) {
        let now = Date()
        let entries = (PrayerSchedule.load()?.intervals(from: now) ?? [])
            .map { NextPrayerEntry(date: $0.start, interval: $0) }

        if entries.isEmpty {
            completion(Timeline(
                entries: [NextPrayerEntry(date: now, interval: nil)],
                policy: .after(now.addingTimeInterval(Self.retryInterval))
            ))
        } else {
            completion(Timeline(entries: entries, policy: .atEnd))
        }
    }
}
