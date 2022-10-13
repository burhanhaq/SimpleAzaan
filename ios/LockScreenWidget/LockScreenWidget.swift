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
        let pc = PrayerConfig(prayerType: Prayer.ZUHR, timePrayerStarts: Date(), timeToShowPrayerIcon: Date())
        return PrayerEntry(date: pc.timePrayerStarts, prayerConfig: pc)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        let pc = PrayerConfig(prayerType: Prayer.ZUHR, timePrayerStarts: Date(), timeToShowPrayerIcon: Date())
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
//        isoDateFormatter.date(from: <#T##String#>)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSxxxxx"
        let times = [
            isoDateFormatter.date(from: prayerData!.time6),
            isoDateFormatter.date(from: prayerData!.time1),
            isoDateFormatter.date(from: prayerData!.time2),
            isoDateFormatter.date(from: prayerData!.time3),
            isoDateFormatter.date(from: prayerData!.time4),
            isoDateFormatter.date(from: prayerData!.time5),
        ]
        
        let prayers = [
            PrayerConfig(
                prayerType: Prayer.FAJR,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time1)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time6)!
            ),
            PrayerConfig(
                prayerType: Prayer.SUNRISE,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time2)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time1)!
            ),
            PrayerConfig(
                prayerType: Prayer.ZUHR,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time3)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time2)!
            ),
            PrayerConfig(
                prayerType: Prayer.ASR,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time4)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time3)!
            ),
            PrayerConfig(
                prayerType: Prayer.MAGHRIB,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time5)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time4)!
            ),
            PrayerConfig(
                prayerType: Prayer.ISHA,
                timePrayerStarts: isoDateFormatter.date(from: prayerData!.time6)!,
                timeToShowPrayerIcon: isoDateFormatter.date(from: prayerData!.time5)!
            )
        ]
        
//        let data = UserDefaults.init(suiteName:"group.com.simpleAzaan")
//        let m: Int = Int((data?.string(forKey: "id"))!)!

//        let currentDate = Date()
        for pc in prayers {
//            let entryDate = Calendar.current.date(byAdding: .second, value: i * 2, to: currentDate)!
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

struct LockScreenWidgetEntryView : View {
    var entry: PrayerEntry
    @Environment(\.widgetFamily) var widgetFamily
    
//    private var PrayerDataView: some View {
//        Text(entry.date, style: .time)
//    }
//
//    private var NoDataView: some View {
//      Text("No Data found! Go to the Flutter App")
//    }
    
//    var config: PrayerConfig

    var body: some View {
//        if(entry.prayerData == nil) {
//            NoDataView
//        } else {
//        PrayerDataView
//            let _ = print(3)
//        }
        let dateToShow = entry.prayerConfig.timePrayerStarts
        switch (widgetFamily) {
        case .accessoryCircular:
            let hour = Calendar.current.component(.hour, from: dateToShow)
            let minute = Calendar.current.component(.minute, from: dateToShow)
            let timeString: String = String(format: "%02d:%02d", hour, minute)

            ZStack{
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .blur(radius: 20)
                    .opacity(0.7)
    // .foregroundColor(Color.init(.sRGB, red: 0.89, green: 0.89, blue: 0.89, opacity: 0.75))
                VStack(spacing: 2){
                    PrayerView(entry: entry)
                        .frame(width: 15, height: 15)
    //                Rectangle()
    //                    .frame(width: 25, height: 1)
                    Text(timeString)
                        .font(.system(size: 14))
                }
            }
        default:
            Text(entry.date, style: .time)
        }
    }
}

struct PrayerView: View {
    var entry: PrayerEntry
    var body: some View {
        switch (entry.prayerConfig.prayerType) {
        case Prayer.FAJR:
            FajrView()
        case Prayer.SUNRISE:
            SunriseView()
        case Prayer.ZUHR:
            ZuhrView()
        case Prayer.ASR:
            AsrView()
        case Prayer.MAGHRIB:
            MaghribView()
        case Prayer.ISHA:
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
        let pc = PrayerConfig(prayerType: Prayer.ZUHR, timePrayerStarts: Date(), timeToShowPrayerIcon: Date())
        LockScreenWidgetEntryView(entry: PrayerEntry(date: pc.timePrayerStarts, prayerConfig: pc))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
        LockScreenWidgetEntryView(entry: PrayerEntry(date: pc.timePrayerStarts, prayerConfig: pc))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Inline")
//        LockScreenWidgetEntryView(entry: SimpleEntry(date: Date(), prayer: Prayer.ZUHR))
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//            .previewDisplayName("Rectangular")
        
    }
}
