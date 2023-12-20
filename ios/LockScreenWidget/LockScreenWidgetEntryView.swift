//
//  LockScreenWidgetEntryView.swift
//  LockScreenWidgetExtension
//
//  Created by Burhan Ul Haq on 3/11/23.
//

import SwiftUI

struct LockScreenWidgetEntryView : View {
    var entry: PrayerEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch (widgetFamily) {
        case .accessoryCircular:
            if #available(iOSApplicationExtension 17.0, *) {
                IconAndTimeCircularWidget(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
            } else {
                IconAndTimeCircularWidget(entry: entry)
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
        let timeString: String = getTimeString(entry: entry)
        HStack {
            Text("\(entry.prayerConfig.prayerType) \(timeString)" as String)
        }
    }
}

struct IconAndTimeCircularWidget: View {
    let entry: PrayerEntry
    var body: some View {
        let timeString: String = getTimeString(entry: entry)
        ZStack{
            Circle()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
                .blur(radius: 8)
                .opacity(0.7)
            // .foregroundColor(Color.init(.sRGB, red: 0.89, green: 0.89, blue: 0.89, opacity: 0.75))
            
            VStack(spacing: 2){
                PrayerView(entry: entry)
                    .frame(width: 15, height: 15)
                Text(timeString)
                    .font(.system(size: 14))
            }
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
        default:
            MosqueView()
        }
    }
}

func getTimeString(entry: PrayerEntry) -> String{
    let dateToShow = entry.prayerConfig.prayerTime
    let hour = Calendar.current.component(.hour, from: dateToShow)
    let minute = Calendar.current.component(.minute, from: dateToShow)
    let timeString: String = String(format: "%02d:%02d", hour, minute)
    
    return timeString
}
