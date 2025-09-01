//
//  TimelineProvider.swift
//  LockScreenWidgetExtension
//  A timeline provider generates a timeline that consists of timeline entries,
//  each specifying the date and time to update the widget’s content.
//
//  Created by Burhan Ul Haq on 3/11/23.
//

import WidgetKit
import Foundation
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

    // Called after getSnapshot(), to fetch real data from shared App Group cache
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> ()) {
        struct StoredPrayerData: Decodable {
            let time1: String
            let time2: String
            let time3: String
            let time4: String
            let time5: String
            let time6: String
        }

        let suiteName = "group.com.simpleAzaan"
        let key = "prayerData"

        // Default: show placeholder-like entry and try again soon
        let fallbackEntry: PrayerEntry = {
            let pc = PrayerConfig(prayerType: Prayer.Mosque, prayerTime: Date(), timeWhenIconVisible: Date())
            return PrayerEntry(date: pc.prayerTime, prayerConfig: pc)
        }()

        guard let defaults = UserDefaults(suiteName: suiteName),
              let jsonString = defaults.string(forKey: key),
              let data = jsonString.data(using: .utf8) else {
            let timeline = Timeline(entries: [fallbackEntry], policy: .after(Date().addingTimeInterval(30 * 60)))
            completion(timeline)
            return
        }

        do {
            let decoder = JSONDecoder()
            let stored = try decoder.decode(StoredPrayerData.self, from: data)
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            guard let fajrTime = iso.date(from: stored.time1),
                  let sunriseTime = iso.date(from: stored.time2),
                  let zuhrTime = iso.date(from: stored.time3),
                  let asrTime = iso.date(from: stored.time4),
                  let maghribTime = iso.date(from: stored.time5),
                  let ishaTime = iso.date(from: stored.time6) else {
                let timeline = Timeline(entries: [fallbackEntry], policy: .after(Date().addingTimeInterval(30 * 60)))
                completion(timeline)
                return
            }

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
                    // Notifications are now scheduled by the Flutter app.
                    // setPrayerNotifications(prayerConfigList: prayers)
            let timeline = Timeline(entries: entries, policy: .after(dateTomorrowMidnight))
            completion(timeline)
        } catch {
            let timeline = Timeline(entries: [fallbackEntry], policy: .after(Date().addingTimeInterval(30 * 60)))
            completion(timeline)
        }
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
