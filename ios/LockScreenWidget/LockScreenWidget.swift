//
//  LockScreenWidget.swift
//  LockScreenWidget
//
//  Created by Burhan Ul Haq on 10/7/22.
//

import WidgetKit
import SwiftUI
import os

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        let pc = PrayerConfig(prayerType: Prayer.Zuhr, timePrayerStarts: Date(), timeToShowPrayerIcon: Date())
        return PrayerEntry(date: pc.timePrayerStarts, prayerConfig: pc)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        let pc = PrayerConfig(prayerType: Prayer.Zuhr, timePrayerStarts: Date(), timeToShowPrayerIcon: Date())
        let entry = PrayerEntry(date: pc.timePrayerStarts, prayerConfig: pc)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [PrayerEntry] = []

        let sharedDefaults = UserDefaults.init(suiteName: "group.com.simpleAzaan")
        var prayerData: PrayerData? = nil

        if(sharedDefaults != nil) {
            do {
              let shared = sharedDefaults?.string(forKey: "prayerData")
              if(shared != nil){
                let decoder = JSONDecoder()
                prayerData = try decoder.decode(PrayerData.self, from: shared!.data(using: .utf8)!)
              }
            } catch {
              print(error)
            }
        }
        
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [
            .withFullDate,
            .withTime,
            .withColonSeparatorInTime]
        isoDateFormatter.timeZone = TimeZone.current
        
        let prayers = [
            PrayerConfig(
                prayerType: Prayer.Fajr,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time1)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time6)!
            ),
            PrayerConfig(
                prayerType: Prayer.Sunrise,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time2)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time1)!
            ),
            PrayerConfig(
                prayerType: Prayer.Zuhr,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time3)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time2)!
            ),
            PrayerConfig(
                prayerType: Prayer.Asr,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time4)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time3)!
            ),
            PrayerConfig(
                prayerType: Prayer.Maghrib,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time5)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time4)!
            ),
            PrayerConfig(
                prayerType: Prayer.Isha,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time6)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time5)!
            )
        ]
        
//        let data = UserDefaults.init(suiteName:"group.com.simpleAzaan")
//        let m: Int = Int((data?.string(forKey: "id"))!)!

        for pc in prayers {
            let entry = PrayerEntry(
                date: pc.timeToShowPrayerIcon,
                prayerConfig: pc
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct PrayerEntry: TimelineEntry {
    let date: Date
    let prayerConfig: PrayerConfig
}

func getTimeString(entry: PrayerEntry) -> String{
    let dateToShow = entry.prayerConfig.timePrayerStarts
    let hour = Calendar.current.component(.hour, from: dateToShow)
    let minute = Calendar.current.component(.minute, from: dateToShow)
    let timeString: String = String(format: "%02d:%02d", hour, minute)
    
    return timeString
}

struct LockScreenWidgetEntryView : View {
    var entry: PrayerEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
//        let dateToShow = entry.prayerConfig.timePrayerStarts
//        let hour = Calendar.current.component(.hour, from: dateToShow)
//        let minute = Calendar.current.component(.minute, from: dateToShow)
//        let timeString: String = String(format: "%02d:%02d", hour, minute)
        
        switch (widgetFamily) {
        case .accessoryCircular:
            CircularWidget(entry: entry)
        case .accessoryInline:
            InlineWidget(entry: entry)
        default:
            Text(entry.date, style: .time)
        }
    }
}

struct InlineWidget: View {
    let entry: PrayerEntry
    var body: some View {
        let timeString: String = getTimeString(entry: entry)
        HStack {
//            CircularWidget(entry: entry)
            
//            PrayerView(entry: entry)
//            MoonShape(filled: true)
//                .frame(width: 5, height: 5)
            Text("\(entry.prayerConfig.prayerType) \(timeString)" as String)
        }
    }
}

struct CircularWidget: View {
    let entry: PrayerEntry
    var body: some View {
        let timeString: String = getTimeString(entry: entry)
        ZStack{
            Circle()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
                .blur(radius: 20)
                .opacity(0.7)
            // .foregroundColor(Color.init(.sRGB, red: 0.89, green: 0.89, blue: 0.89, opacity: 0.75))
            
//            if (entry.prayerConfig.prayerType == Prayer.MOSQUE) {
//                MosqueShape()
//            } else {
                VStack(spacing: 2){
                    PrayerView(entry: entry)
                        .frame(width: 15, height: 15)
//                    Text("\(entry.prayerConfig.prayerType.rawValue)")
                    Text(timeString)
                        .font(.system(size: 14))
                }
//            }
        }
    }
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
        //default:
        //    SunShape(filled: false)
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
        .configurationDisplayName("Small Widget")
        .description("Prayer Time Widget.")
        .supportedFamilies([.accessoryCircular, .accessoryInline])
    }
}

struct LockScreenWidget_Previews: PreviewProvider {
    static var previews: some View {
        let pc = PrayerConfig(prayerType: Prayer.Zuhr, timePrayerStarts: Date(), timeToShowPrayerIcon: Date())
        
        LockScreenWidgetEntryView(entry: PrayerEntry(date: pc.timePrayerStarts, prayerConfig: pc))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
        LockScreenWidgetEntryView(entry: PrayerEntry(date: pc.timePrayerStarts, prayerConfig: pc))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Inline")
        
    }
}
