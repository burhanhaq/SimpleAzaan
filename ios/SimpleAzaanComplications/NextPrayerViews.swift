//
//  NextPrayerViews.swift
//  SimpleAzaanComplications
//

import SwiftUI
import WidgetKit

struct NextPrayerView: View {
    @Environment(\.widgetFamily) private var family
    let entry: NextPrayerEntry

    var body: some View {
        if let interval = entry.interval {
            switch family {
            case .accessoryCircular:
                CircularNextPrayer(interval: interval)
            case .accessoryCorner:
                CornerNextPrayer(interval: interval)
            case .accessoryRectangular:
                RectangularNextPrayer(interval: interval)
            default:
                InlineNextPrayer(interval: interval)
            }
        } else {
            SyncNeeded(family: family)
        }
    }
}

private extension PrayerInterval {
    var name: String { next.kind.displayName }
    var time: String { PrayerTimeFormat.string(from: next.date) }

    /// From the previous prayer to the next one, for progress indicators.
    var progressRange: ClosedRange<Date> {
        let from = previous?.date ?? start
        return min(from, next.date)...next.date
    }
}

private struct CircularNextPrayer: View {
    let interval: PrayerInterval

    var body: some View {
        ProgressView(timerInterval: interval.progressRange, countsDown: false) {
            EmptyView()
        } currentValueLabel: {
            VStack(spacing: 1) {
                PrayerIcon(kind: interval.next.kind, size: 13)
                    .widgetAccentable()
                Text(interval.time)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
            }
        }
        .progressViewStyle(.circular)
    }
}

private struct CornerNextPrayer: View {
    let interval: PrayerInterval

    var body: some View {
        PrayerIcon(kind: interval.next.kind, size: 20)
            .widgetAccentable()
            .widgetLabel {
                Text("\(interval.name) \(interval.time)")
            }
    }
}

private struct RectangularNextPrayer: View {
    let interval: PrayerInterval

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                PrayerIcon(kind: interval.next.kind, size: 14)
                Text(interval.name)
                    .font(.headline)
            }
            .widgetAccentable()

            HStack(alignment: .firstTextBaseline) {
                Text(interval.time)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                Spacer(minLength: 4)
                Text("in \(Text(interval.next.date, style: .relative))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            ProgressView(timerInterval: interval.progressRange, countsDown: false) {
                EmptyView()
            } currentValueLabel: {
                EmptyView()
            }
            .progressViewStyle(.linear)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Inline complications only render text (plus an SF Symbol), so no custom icon.
private struct InlineNextPrayer: View {
    let interval: PrayerInterval

    var body: some View {
        Text("\(interval.name) \(interval.time)")
    }
}

private struct SyncNeeded: View {
    let family: WidgetFamily

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("Simple Azaan")
                    .font(.headline)
                    .widgetAccentable()
                Text("Open on iPhone to sync")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .accessoryInline:
            Text("Open Simple Azaan on iPhone")
        default:
            Image(systemName: "iphone")
                .font(.title3)
                .widgetAccentable()
                .widgetLabel("Sync on iPhone")
        }
    }
}

#Preview("Circular", as: .accessoryCircular) {
    NextPrayerComplication()
} timeline: {
    NextPrayerEntry.sample
    NextPrayerEntry(date: .now, interval: nil)
}

#Preview("Corner", as: .accessoryCorner) {
    NextPrayerComplication()
} timeline: {
    NextPrayerEntry.sample
}

#Preview("Rectangular", as: .accessoryRectangular) {
    NextPrayerComplication()
} timeline: {
    NextPrayerEntry.sample
    NextPrayerEntry(date: .now, interval: nil)
}

#Preview("Inline", as: .accessoryInline) {
    NextPrayerComplication()
} timeline: {
    NextPrayerEntry.sample
}
