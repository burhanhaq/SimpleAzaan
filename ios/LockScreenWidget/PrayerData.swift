//
//  PrayerData.swift
//  Runner
//
//  Created by Burhan Ul Haq on 10/13/22.
//

import Foundation

struct PrayerConfig {
    let prayerType: Prayer
    let timePrayerStarts: Date
    let timeToShowPrayerIcon: Date
}

enum Prayer: Int {
    case Fajr = 1
    case Sunrise = 2
    case Zuhr = 3
    case Asr = 4
    case Maghrib = 5
    case Isha = 6
    case Mosque = 7
}

struct PrayerData: Decodable, Hashable {
    let time1: String
    let time2: String
    let time3: String
    let time4: String
    let time5: String
    let time6: String
}
