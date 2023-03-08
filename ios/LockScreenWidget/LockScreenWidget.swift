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
        
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [
            .withFullDate,
            .withTime,
            .withColonSeparatorInTime]
        isoDateFormatter.timeZone = TimeZone.current

        let url = "https://api.aladhan.com/v1/"
        let timingsByCity = "timingsByCity?"
        let params = "city=Bellevue&country=US&method=2&iso8601=true"
        let apiUrl = url+timingsByCity+params
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.allHTTPHeaderFields = [
            "content-Type": "application/x-www-form-urlencoded",
            "accept": "application/json"]
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil && data != nil {
                do {
                    var newJsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any]
                    print(newJsonData!)
                    let newData = newJsonData!["data"] as? [String: Any]
                    let timings = newData!["timings"] as? [String: Any]
                    let fajr = timings?["Fajr"] as! String
                    let sunrise = timings?["Sunrise"] as! String
                    let zuhr = timings!["Dhuhr"] as! String
                    let asr = timings!["Asr"] as! String
                    let maghrib = timings!["Maghrib"] as! String
                    let isha = timings!["Isha"] as! String


                    let prayers = [
                        PrayerConfig(
                            prayerType: Prayer.Sunrise,
                            timePrayerStarts: isoDateFormatter.date(from: sunrise)!,
                            timeToShowPrayerIcon: isoDateFormatter.date(from: fajr)!
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Zuhr,
                            timePrayerStarts: isoDateFormatter.date(from: zuhr)!,
                            timeToShowPrayerIcon: isoDateFormatter.date(from: sunrise)!
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Asr,
                            timePrayerStarts: isoDateFormatter.date(from: asr)!,
                            timeToShowPrayerIcon: isoDateFormatter.date(from: zuhr)!
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Maghrib,
                            timePrayerStarts: isoDateFormatter.date(from: maghrib)!,
                            timeToShowPrayerIcon: isoDateFormatter.date(from: asr)!
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Isha,
                            timePrayerStarts: isoDateFormatter.date(from: isha)!,
                            timeToShowPrayerIcon: isoDateFormatter.date(from: maghrib)!
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Fajr,
                            timePrayerStarts: isoDateFormatter.date(from: fajr)!,
                            timeToShowPrayerIcon: isoDateFormatter.date(from: isha)!
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Fajr,
                            timePrayerStarts: isoDateFormatter.date(from: fajr)!,
                            timeToShowPrayerIcon: isoDateFormatter.date(from: fajr)!
                        )
                    ]
                    for pc in prayers {
                        let entry = PrayerEntry(
                            date: pc.timeToShowPrayerIcon,
                            prayerConfig: pc
                        )
                        entries.append(entry)
                    }
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                } catch {
                    print("Error parsing response data")
                }
            }
        }
        task.resume()
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
//        default:
//            MosqueShape()
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
