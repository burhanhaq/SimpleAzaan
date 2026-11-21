//
//  PrayerIcon.swift
//  Shared by the watch app and the watch complications.
//

import SwiftUI

/// The lock screen widget's custom prayer icons (ios/LockScreenWidget/Shapes).
/// Those shapes are drawn for a 15 pt frame, so other sizes scale them.
struct PrayerIcon: View {
    private static let designSize: CGFloat = 15

    let kind: PrayerKind
    var size: CGFloat = PrayerIcon.designSize

    var body: some View {
        shape
            .frame(width: Self.designSize, height: Self.designSize)
            .scaleEffect(size / Self.designSize)
            .frame(width: size, height: size)
    }

    @ViewBuilder
    private var shape: some View {
        switch kind {
        case .fajr: FajrView()
        case .sunrise: SunriseView()
        case .dhuhr: ZuhrView()
        case .asr: AsrView()
        case .maghrib: MaghribView()
        case .isha: IshaView()
        }
    }
}
