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
    case FAJR = 1
    case SUNRISE = 2
    case ZUHR = 3
    case ASR = 4
    case MAGHRIB = 5
    case ISHA = 6
}

struct PrayerData: Decodable, Hashable {
    let time1: String
    let time2: String
    let time3: String
    let time4: String
    let time5: String
    let time6: String
}
