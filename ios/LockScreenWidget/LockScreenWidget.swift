//
//  LockScreenWidget.swift
//  LockScreenWidget
//
//  Created by Burhan Ul Haq on 10/7/22.
//

import WidgetKit
import SwiftUI

@main
struct LockScreenWidget: Widget {
    let kind: String = "LockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Simple Azaan Widget")
        .description("Prayer Time Widget")
        .supportedFamilies([.accessoryInline, .accessoryCircular])
    }
}

struct LockScreenWidget_Previews: PreviewProvider {
    static var previews: some View {
        let pc = PrayerConfig(prayerType: Prayer.Zuhr, timePrayerStarts: Date(), timeToShowPrayerIcon: Date())
        
        LockScreenWidgetEntryView(entry: PrayerEntry(date: pc.timePrayerStarts, prayerConfig: pc))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Inline")
        LockScreenWidgetEntryView(entry: PrayerEntry(date: pc.timePrayerStarts, prayerConfig: pc))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
    }
}
