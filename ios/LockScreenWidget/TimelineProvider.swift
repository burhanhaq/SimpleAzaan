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
    func placeholder(in context: Context) -> PrayerEntry {
        let pc = PrayerConfig(prayerType: Prayer.Mosque, prayerTime: Date(), timeWhenIconVisible: Date())
        return PrayerEntry(date: pc.prayerTime, prayerConfig: pc)
    }

    // Snapshot for the widget gallery
    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        let pc = PrayerConfig(prayerType: Prayer.Zuhr, prayerTime: Date(), timeWhenIconVisible: Date())
        completion(PrayerEntry(date: pc.prayerTime, prayerConfig: pc))
    }

    // Main timeline: read from App Group cache; if stale or missing, fetch from API.
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
        let isoOut = ISO8601DateFormatter()
        isoOut.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoFS = ISO8601DateFormatter()
        isoFS.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoNoFS = ISO8601DateFormatter()
        isoNoFS.formatOptions = [.withInternetDateTime]

        func parseISO(_ s: String) -> Date? {
            return isoFS.date(from: s) ?? isoNoFS.date(from: s)
        }

        let fallback: PrayerEntry = {
            let pc = PrayerConfig(prayerType: Prayer.Mosque, prayerTime: Date(), timeWhenIconVisible: Date())
            return PrayerEntry(date: pc.prayerTime, prayerConfig: pc)
        }()

        func buildEntries(forDay fajr: Date, sunrise: Date, zuhr: Date, asr: Date, maghrib: Date, isha: Date) -> [PrayerEntry] {
            let dayStart = Calendar.current.date(bySettingHour: 0, minute: 5, second: 0, of: fajr)!
            let configs = [
                PrayerConfig(prayerType: Prayer.Fajr,    prayerTime: fajr,    timeWhenIconVisible: dayStart),
                PrayerConfig(prayerType: Prayer.Sunrise, prayerTime: sunrise, timeWhenIconVisible: fajr),
                PrayerConfig(prayerType: Prayer.Zuhr,    prayerTime: zuhr,    timeWhenIconVisible: sunrise),
                PrayerConfig(prayerType: Prayer.Asr,     prayerTime: asr,     timeWhenIconVisible: zuhr),
                PrayerConfig(prayerType: Prayer.Maghrib, prayerTime: maghrib, timeWhenIconVisible: asr),
                PrayerConfig(prayerType: Prayer.Isha,    prayerTime: isha,    timeWhenIconVisible: maghrib),
            ]
            return configs.map { PrayerEntry(date: $0.timeWhenIconVisible, prayerConfig: $0) }
        }

        func fetchAndBuildTimeline(
            for targetDay: Date,
            now: Date,
            completion handler: @escaping (Timeline<PrayerEntry>) -> Void
        ) {
            fetchTimings(for: targetDay) { result in
                guard let (fajr, sunrise, dhuhr, asr, maghrib, isha) = result else {
                    handler(Timeline(entries: [fallback], policy: .after(Date().addingTimeInterval(30 * 60))))
                    return
                }

                var entries = buildEntries(
                    forDay: fajr,
                    sunrise: sunrise,
                    zuhr: dhuhr,
                    asr: asr,
                    maghrib: maghrib,
                    isha: isha
                )

                // After today's Isha, show tomorrow's Fajr immediately instead of
                // waiting until the first scheduled entry on the next calendar day.
                if !Calendar.current.isDate(now, inSameDayAs: fajr) {
                    let preConfig = PrayerConfig(
                        prayerType: Prayer.Fajr,
                        prayerTime: fajr,
                        timeWhenIconVisible: now
                    )
                    let preEntry = PrayerEntry(date: now, prayerConfig: preConfig)
                    entries.insert(preEntry, at: 0)
                }

                handler(Timeline(entries: entries, policy: .after(isha.addingTimeInterval(60))))
            }
        }

        func targetDay(afterIshaFrom fajr: Date?, isha: Date?, now: Date) -> Date {
            if let fajr, let isha,
               Calendar.current.isDate(now, inSameDayAs: fajr) {
                return now < isha ? now : Calendar.current.date(byAdding: .day, value: 1, to: now)!
            }

            if let fajr, fajr < now {
                return Calendar.current.date(byAdding: .day, value: 1, to: now)!
            }

            return now
        }

        func fetchTimings(for date: Date, completion handler: @escaping ((Date, Date, Date, Date, Date, Date)?) -> Void) {
            let defaults = UserDefaults(suiteName: suiteName)
            let city = defaults?.string(forKey: "custom_city") ?? "Bellevue"
            let state = defaults?.string(forKey: "custom_state") ?? "WA"
            let country = defaults?.string(forKey: "custom_country") ?? "United States"
            let method = "2"

            let base = "https://api.aladhan.com/v1"
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let dateStr = formatter.string(from: date)
            let endpoint = "/timingsByCity/\(dateStr)"
            var components = URLComponents(string: base + endpoint)!
            components.queryItems = [
                URLQueryItem(name: "city", value: city),
                URLQueryItem(name: "state", value: state),
                URLQueryItem(name: "country", value: country),
                URLQueryItem(name: "method", value: method),
                URLQueryItem(name: "iso8601", value: "true"),
            ]
            guard let url = components.url else { handler(nil); return }

            let saver = UserDefaults(suiteName: suiteName)
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil, let data = data else { handler(nil); return }
                do {
                    let obj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    guard let dataDict = obj?["data"] as? [String: Any],
                          let timings = dataDict["timings"] as? [String: Any],
                          let fajrStr = timings["Fajr"] as? String,
                          let sunriseStr = timings["Sunrise"] as? String,
                          let dhuhrStr = timings["Dhuhr"] as? String,
                          let asrStr = timings["Asr"] as? String,
                          let maghribStr = timings["Maghrib"] as? String,
                          let ishaStr = timings["Isha"] as? String else {
                        handler(nil); return
                    }

                    guard let fajr = parseISO(fajrStr),
                          let sunrise = parseISO(sunriseStr),
                          let dhuhr = parseISO(dhuhrStr),
                          let asr = parseISO(asrStr),
                          let maghrib = parseISO(maghribStr),
                          let isha = parseISO(ishaStr) else { handler(nil); return }

                    // Cache minimal JSON for other clients
                    let json: [String: String] = [
                        "time1": isoOut.string(from: fajr),
                        "time2": isoOut.string(from: sunrise),
                        "time3": isoOut.string(from: dhuhr),
                        "time4": isoOut.string(from: asr),
                        "time5": isoOut.string(from: maghrib),
                        "time6": isoOut.string(from: isha),
                    ]
                    if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        saver?.set(jsonString, forKey: key)
                    }

                    handler((fajr, sunrise, dhuhr, asr, maghrib, isha))
                } catch {
                    handler(nil)
                }
            }
            task.resume()
        }

        let defaults = UserDefaults(suiteName: suiteName)
        if let jsonString = defaults?.string(forKey: key), let data = jsonString.data(using: .utf8) {
            do {
                let stored = try JSONDecoder().decode(StoredPrayerData.self, from: data)
                guard let fajr = parseISO(stored.time1),
                      let sunrise = parseISO(stored.time2),
                      let dhuhr = parseISO(stored.time3),
                      let asr = parseISO(stored.time4),
                      let maghrib = parseISO(stored.time5),
                      let isha = parseISO(stored.time6) else {
                    throw NSError(domain: "parse", code: -1)
                }

                let now = Date()
                let sameDay = Calendar.current.isDate(now, inSameDayAs: fajr)
                if sameDay, now < isha {
                    // Use cached today’s data; reload after Isha to fetch next day
                    let entries = buildEntries(forDay: fajr, sunrise: sunrise, zuhr: dhuhr, asr: asr, maghrib: maghrib, isha: isha)
                    completion(Timeline(entries: entries, policy: .after(isha.addingTimeInterval(60))))
                } else {
                    // Cache is from a previous day, or we’ve passed Isha.
                    fetchAndBuildTimeline(
                        for: targetDay(afterIshaFrom: fajr, isha: isha, now: now),
                        now: now,
                        completion: completion
                    )
                }
            } catch {
                let now = Date()
                fetchAndBuildTimeline(
                    for: targetDay(afterIshaFrom: nil, isha: nil, now: now),
                    now: now,
                    completion: completion
                )
            }
        } else {
            let now = Date()
            fetchAndBuildTimeline(
                for: targetDay(afterIshaFrom: nil, isha: nil, now: now),
                now: now,
                completion: completion
            )
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
