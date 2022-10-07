//
//  LockScreenWidget.swift
//  LockScreenWidget
//
//  Created by Burhan Ul Haq on 10/7/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct LockScreenWidgetEntryView : View {
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
                ZuhrView()
                    .frame(width: 15, height: 15)
                Rectangle()
                    .frame(width: 25, height: 1)
                Text(timeString)
                    .font(.system(size: 14))
            }
        }
        
    }
}

@main
struct LockScreenWidget: Widget {
    let kind: String = "LockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

struct LockScreenWidget_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
        LockScreenWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangular")
        
    }
}
