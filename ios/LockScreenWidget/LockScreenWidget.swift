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
        SimpleEntry(date: Date(), prayer: Prayer.FAJR
//                    , flutterData: FlutterData(
//            time1: "1",
//            time2: "1",
//            time3: "2",
//            time4: "4")
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), prayer: Prayer.ZUHR
//                                , flutterData: FlutterData(
//            time1: "2",
//            time2: "2",
//            time3: "2",
//            time4: "2")
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let sharedDefaults = UserDefaults.init(suiteName: "group.com.simpleAzaan")
        var flutterData: FlutterData? = nil

        if(sharedDefaults != nil) {
            do {
              let shared = sharedDefaults?.string(forKey: "widgetData")
              if(shared != nil){
                let decoder = JSONDecoder()
                flutterData = try decoder.decode(FlutterData.self, from: shared!.data(using: .utf8)!)
//                  flutterData = shared!
              }
            } catch {
              print(error)
            }
        }
        
        let data = UserDefaults.init(suiteName:"group.com.simpleAzaan")
        let m: Int = Int((data?.string(forKey: "id"))!)!

        let currentDate = Date()
//        for 1..<5:
        let entryDate = Calendar.current.date(byAdding: .hour, value: 24, to: currentDate)!
        let entry = SimpleEntry(date: entryDate, prayer: Prayer.ASR)
//                                , flutterData: flutterData!)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let prayer: Prayer
//    let flutterData: FlutterData?
}

struct LockScreenWidgetEntryView : View {
    var entry: SimpleEntry
    
    private var FlutterDataView: some View {
        Text(entry.flutterData!.time1)
    }
    
    private var NoDataView: some View {
      Text("No Data found! Go to the Flutter App")
    }
    
//    var config: PrayerConfig

    var body: some View {
        if(entry.flutterData == nil) {
            NoDataView
        } else {
            FlutterDataView
            let _ = print(3)
        }
        
//        let data = UserDefaults.init(suiteName:"group.com.simpleAzaan")
//        let m: Int = Int((data?.string(forKey: "id"))!)!
////
//        let hour = Calendar.current.component(.hour, from: entry.date)
//        let minute = Calendar.current.component(.minute, from: entry.date)
//        let timeString: String = String(format: "%02d:%02d:%02d", hour, minute, entry.flutterData ?? 99)
//
//        ZStack{
//            Circle()
//                .frame(width: 60, height: 60)
//                .foregroundColor(.gray)
//                .blur(radius: 20)
//                .opacity(0.7)
//// .foregroundColor(Color.init(.sRGB, red: 0.89, green: 0.89, blue: 0.89, opacity: 0.75))
//            VStack(spacing: 2){
//                PrayerView(entry: entry)
//                    .frame(width: 15, height: 15)
////                Rectangle()
////                    .frame(width: 25, height: 1)
//                Text(timeString)
//                    .font(.system(size: 14))
//            }
//        }
        
    }
}

struct PrayerView: View {
    var entry: SimpleEntry
    var body: some View {
        switch (entry.prayer) {
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
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

struct LockScreenWidget_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenWidgetEntryView(entry: SimpleEntry(date: Date(), prayer: Prayer.ZUHR
//                                                    flutterData: FlutterData(
//            time1: "3", time2: "3", time3: "3", time4: "3")
        ))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
//        LockScreenWidgetEntryView(entry: SimpleEntry(date: Date(), prayer: Prayer.SUNRISE))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//            .previewDisplayName("Circular")
//        LockScreenWidgetEntryView(entry: SimpleEntry(date: Date(), prayer: Prayer.ZUHR))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//            .previewDisplayName("Circular")
//        LockScreenWidgetEntryView(entry: SimpleEntry(date: Date(), prayer: Prayer.ASR))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//            .previewDisplayName("Circular")
//        LockScreenWidgetEntryView(entry: SimpleEntry(date: Date(), prayer: Prayer.MAGHRIB))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//            .previewDisplayName("Circular")
//        LockScreenWidgetEntryView(entry: SimpleEntry(date: Date(), prayer: Prayer.ISHA))
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//            .previewDisplayName("Circular")
//        LockScreenWidgetEntryView(entry: SimpleEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//            .previewDisplayName("Rectangular")
        
    }
}

struct FlutterData: Decodable, Hashable {
    let time1: String
    let time2: String
    let time3: String
    let time4: String
}
