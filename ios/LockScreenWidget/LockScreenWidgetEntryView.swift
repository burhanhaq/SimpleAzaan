//
//  LockScreenWidgetEntryView.swift
//  LockScreenWidgetExtension
//
//  Created by Burhan Ul Haq on 3/11/23.
//

import SwiftUI
import WidgetKit

struct LockScreenWidgetEntryView : View {
    var entry: PrayerEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch (widgetFamily) {
        case .accessoryCircular:
            IconAndTimeCircularWidget(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        case .accessoryInline:
            NameAndTimeInlineWidget(entry: entry)
        default:
            Text(entry.date, style: .time)
        }
    }
}

struct NameAndTimeInlineWidget: View {
    let entry: PrayerEntry
    var body: some View {
        // iOS picks the inline widget's font, so only the text matters here.
        Text("\(entry.prayerConfig.prayerType) \(entry.prayerConfig.prayerTime.formatted(PrayerTimeStyle.inline))" as String)
    }
}

struct IconAndTimeCircularWidget: View {
    private enum Layout {
        /// The prayer shapes are drawn for this frame size.
        static let iconDesignSize: CGFloat = 15
        static let iconSize: CGFloat = 18
        static let timeFontSize: CGFloat = 15
        static let timeMinimumScale: CGFloat = 0.6
        /// Keeps the time inside the circle's narrower lower half; longer times shrink instead.
        static let timeHorizontalInset: CGFloat = 12
        static let spacing: CGFloat = 2
    }

    let entry: PrayerEntry
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: Layout.spacing) {
                PrayerView(entry: entry)
                    .frame(width: Layout.iconDesignSize, height: Layout.iconDesignSize)
                    .scaleEffect(Layout.iconSize / Layout.iconDesignSize)
                    .frame(width: Layout.iconSize, height: Layout.iconSize)
                    .widgetAccentable()
                Text(entry.prayerConfig.prayerTime, format: PrayerTimeStyle.circular)
                    .font(.system(size: Layout.timeFontSize, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(Layout.timeMinimumScale)
                    .padding(.horizontal, Layout.timeHorizontalInset)
            }
        }
    }
}

/// Times follow the phone's 12/24-hour setting.
enum PrayerTimeStyle {
    /// "5:42 PM" or "17:42".
    static let inline = Date.FormatStyle(date: .omitted, time: .shortened)
    /// "5:42" or "17:42": no AM/PM, which would not fit in the circle.
    static let circular = Date.FormatStyle()
        .hour(.defaultDigits(amPM: .omitted))
        .minute(.twoDigits)
}

struct PrayerView: View {
    var entry: PrayerEntry
    var body: some View {
        switch (entry.prayerConfig.prayerType) {
        case Prayer.Fajr:
            FajrView()
        case Prayer.Sunrise:
            SunriseView()
        case Prayer.Zuhr:
            ZuhrView()
        case Prayer.Asr:
            AsrView()
        case Prayer.Maghrib:
            MaghribView()
        case Prayer.Isha:
            IshaView()
        default:
            MosqueView()
        }
    }
}
