//
//  lock_screen_widget.swift
//  lock-screen-widget
//
//  Created by Burhan Ul Haq on 9/30/22.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), configuration: ConfigurationIntent())
}

func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date(), configuration: configuration)
    completion(entry)
}

func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    var entries: [SimpleEntry] = []

    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    for hourOffset in 0 ..< 5 {
        let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
        let entry = SimpleEntry(date: entryDate, configuration: configuration)
        entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
}
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct lock_screen_widgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: SimpleEntry
    
//    var config: PrayerConfig

    var body: some View {
        let hour = Calendar.current.component(.hour, from: entry.date)
        let minute = Calendar.current.component(.minute, from: entry.date)
        let timeString: String = String(format: "%02d:%02d", hour, minute)
        
        
        ZStack{
            Circle()
                .frame(width: 60, height: 60)
//                .foregroundColor(.gray)
//                .blur(radius: 20)
//                .opacity(0.7)
                .foregroundColor(Color.init(.sRGB, red: 0.89, green: 0.89, blue: 0.89, opacity: 0.75))
            VStack(spacing: 2){
                ZuhrView().frame(width: 15, height: 15)
                Rectangle()
                    .frame(width: 25, height: 1)
                Text(timeString)
                    .font(.system(size: 14))
            }
        }
        
    }
}

@main
struct lock_screen_widget: Widget {
    let kind: String = "lock_screen_widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            lock_screen_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

struct lock_screen_widget_Previews: PreviewProvider {
    static var previews: some View {
        lock_screen_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
        lock_screen_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangular")
    }
}
