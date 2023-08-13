//
//  TimelineProvider.swift
//  LockScreenWidgetExtension
//  A timeline provider generates a timeline that consists of timeline entries,
//  each specifying the date and time to update the widget’s content.
//
//  Created by Burhan Ul Haq on 3/11/23.
//

import WidgetKit
import UserNotifications

struct Provider: TimelineProvider {
    // A placeholder view is a generic visual representation with no specific content.
    // When WidgetKit renders your widget, it may need to render your content as a placeholder;
    // for example, while you load data in the background. 
    func placeholder(in context: Context) -> PrayerEntry {
        let pc = PrayerConfig(prayerType: Prayer.Mosque, prayerTime: Date(), timeWhenIconVisible: Date())
        return PrayerEntry(date: pc.prayerTime, prayerConfig: pc)
    }

    // To show your widget in the widget gallery, WidgetKit asks the provider for a preview snapshot.
    // This is just a snapshot of the data and does not necessarily need to be real data.
    // This is used in the Widget gallery to give an idea to the user of how the widget will look.
    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        let pc = PrayerConfig(prayerType: Prayer.Zuhr, prayerTime: Date(), timeWhenIconVisible: Date())
        let entry = PrayerEntry(date: pc.prayerTime, prayerConfig: pc)
        completion(entry)
    }

    // Called after getSnapshot(), to fetch real data
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> ()) {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [
            .withFullDate,
            .withTime,
            .withColonSeparatorInTime]
        isoDateFormatter.timeZone = TimeZone.current

        let url = "https://api.aladhan.com/v1/"
        let timingsByCity = "timingsByCity?"
        let city = "Bellevue"
        let state = "WA"
        let country = "US"
        let method = "2"
        let params = "city=" + city + "&state=" + state + "&country=" + country + "&method=" + method + "&iso8601=true"
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
                    let newData = newJsonData!["data"] as? [String: Any]
                    let timings = newData!["timings"] as? [String: Any]
                    let fajr = timings?["Fajr"] as! String
                    let sunrise = timings?["Sunrise"] as! String
                    let zuhr = timings!["Dhuhr"] as! String
                    let asr = timings!["Asr"] as! String
                    let maghrib = timings!["Maghrib"] as! String
                    let isha = timings!["Isha"] as! String
                    
                    let fajrTime = isoDateFormatter.date(from: fajr)!
                    let sunriseTime = isoDateFormatter.date(from: sunrise)!
                    let zuhrTime = isoDateFormatter.date(from: zuhr)!
                    let asrTime = isoDateFormatter.date(from: asr)!
                    let maghribTime = isoDateFormatter.date(from: maghrib)!
                    let ishaTime = isoDateFormatter.date(from: isha)!

                    let dateTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                    let dateTomorrowMidnight = Calendar.current.date(bySettingHour: 0, minute: 5, second: 0, of: dateTomorrow)!
                    let dateTodayMidnight = Calendar.current.date(byAdding: .day, value: -1, to: dateTomorrowMidnight)!

                    let prayers = [
                        PrayerConfig(
                            prayerType: Prayer.Fajr,
                            prayerTime: fajrTime,
                            timeWhenIconVisible: dateTodayMidnight
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Sunrise,
                            prayerTime: sunriseTime,
                            timeWhenIconVisible: fajrTime
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Zuhr,
                            prayerTime: zuhrTime,
                            timeWhenIconVisible: sunriseTime
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Asr,
                            prayerTime: asrTime,
                            timeWhenIconVisible: zuhrTime
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Maghrib,
                            prayerTime: maghribTime,
                            timeWhenIconVisible: asrTime
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Isha,
                            prayerTime: ishaTime,
                            timeWhenIconVisible: maghribTime
                        ),
                        PrayerConfig(
                            prayerType: Prayer.Fajr,
                            prayerTime: fajrTime,
                            timeWhenIconVisible: ishaTime
                        )
                    ]
                    var entries: [PrayerEntry] = []
                    for pc in prayers {
                        let entry = PrayerEntry(
                            date: pc.timeWhenIconVisible,
                            prayerConfig: pc
                        )
                        entries.append(entry)
                    }
                    setPrayerNotifications(prayerConfigList: prayers)
                    // Create the timeline with the entry and a reload policy with the date for the next update.
                    let timeline = Timeline(entries: entries, policy: .after(dateTomorrowMidnight))
                    // Call the completion to pass the timeline to WidgetKit.
                    completion(timeline)
                } catch {
                    print("Error parsing response data")
                }
            }
        }
        task.resume()
    }

    func setPrayerNotifications(prayerConfigList: [PrayerConfig]) {
        // Remove all notifications before creating new ones
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["SimpleAzaanNotificationIdentifier-\(Prayer.Fajr)",
              "SimpleAzaanNotificationIdentifier-\(Prayer.Sunrise)",
              "SimpleAzaanNotificationIdentifier-\(Prayer.Zuhr)",
              "SimpleAzaanNotificationIdentifier-\(Prayer.Asr)",
              "SimpleAzaanNotificationIdentifier-\(Prayer.Maghrib)",
              "SimpleAzaanNotificationIdentifier-\(Prayer.Isha)",])
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Create notification per prayer
        for pc in prayerConfigList {
            let prayerName = "\(pc.prayerType)" as String
            let prayerTime: Date = pc.prayerTime
            let city = "Bellevue"
            
            if (prayerTime < Date()) {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = prayerName
            content.subtitle = "It's \(prayerName) time in \(city) 🙂"
            //        content.body = "Local Notfication Body"
            content.sound = UNNotificationSound.default
            // 2. Create Trigger and Configure the desired behaviour
            let dateComponents = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: prayerTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            // Choose a random identifier, this is important if you want to be able to cancel the Notification
            let notificationIdentifier = "SimpleAzaanNotificationIdentifier-\(prayerName)"
//            let notificationIdentifier = "SimpleAzaanNotificationIdentifier"

            // 3. Create the Request
            let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier,
                                                            content: content,
                                                            trigger: trigger)
            // 4. Add our Notification Request to the que
            UNUserNotificationCenter.current().add(notificationRequest)
        }
    }
}
