//
//  TimelineProvider.swift
//  LockScreenWidgetExtension
//  A timeline provider generates a timeline that consists of timeline entries,
//  each specifying the date and time to update the widget’s content.
//
//  Created by Burhan Ul Haq on 3/11/23.
//

import WidgetKit

struct Provider: TimelineProvider {
    // A placeholder view is a generic visual representation with no specific content.
    // When WidgetKit renders your widget, it may need to render your content as a placeholder;
    // for example, while you load data in the background. 
    func placeholder(in context: Context) -> PrayerEntry {
        let pc = PrayerConfig(prayerType: Prayer.Mosque, timePrayerStarts: Date(), timeToShowPrayerIcon: Date())
        return PrayerEntry(date: pc.timePrayerStarts, prayerConfig: pc)
    }

    // To show your widget in the widget gallery, WidgetKit asks the provider for a preview snapshot.
    // This is just a snapshot of the data and does not necessarily need to be real data.
    // This is used in the Widget gallery to give an idea to the user of how the widget will look.
    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        let pc = PrayerConfig(prayerType: Prayer.Zuhr, timePrayerStarts: Date(), timeToShowPrayerIcon: Date())
        let entry = PrayerEntry(date: pc.timePrayerStarts, prayerConfig: pc)
        completion(entry)
    }

    // Called after getSnapshot(), to fetch real data
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> ()) {
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
                    let newJsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any]
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
                        )
                    ]
                    for pc in prayers {
                        let entry = PrayerEntry(
                            date: pc.timeToShowPrayerIcon,
                            prayerConfig: pc
                        )
                        entries.append(entry)
                    }
                    // Create the timeline with the entry and a reload policy with the date for the next update.
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    // Call the completion to pass the timeline to WidgetKit.
                    completion(timeline)
                } catch {
                    print("Error parsing response data")
                }
            }
        }
        task.resume()
    }
}
