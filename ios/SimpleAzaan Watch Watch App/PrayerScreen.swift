//
//  PrayerScreen.swift
//  SimpleAzaan Watch Watch App
//

import SwiftUI

/// The watch app's only screen: what's next, today's times and tomorrow's
/// Fajr and Sunrise.
struct PrayerScreen: View {
    let store: PrayerScheduleStore

    var body: some View {
        // Prayer times fall on whole minutes, so this flips rows on time.
        TimelineView(.everyMinute) { context in
            if let schedule = store.schedule,
               let status = PrayerStatus(at: context.date, schedule: schedule) {
                PrayerStatusList(status: status, location: schedule.location)
            } else {
                SyncNeededView()
            }
        }
    }
}

private struct PrayerStatusList: View {
    let status: PrayerStatus
    let location: PrayerLocation

    var body: some View {
        List {
            Section {
                NextPrayerHeader(status: status)
            }

            Section("Today") {
                ForEach(status.today, id: \.self) { prayer in
                    PrayerRow(prayer: prayer, state: state(of: prayer))
                }
            }

            let tomorrow = [status.tomorrowFajr, status.tomorrowSunrise].compactMap { $0 }
            if !tomorrow.isEmpty {
                Section("Tomorrow") {
                    ForEach(tomorrow, id: \.self) { prayer in
                        PrayerRow(prayer: prayer, state: .upcoming)
                    }
                }
            }

            if !location.displayName.isEmpty {
                Section {
                    Label(location.displayName, systemImage: "location.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }
            }
        }
    }

    private func state(of prayer: PrayerTime) -> PrayerRow.State {
        if prayer == status.current { return .current }
        return prayer.date < status.next.date ? .past : .upcoming
    }
}

private struct NextPrayerHeader: View {
    let status: PrayerStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let current = status.current {
                Text("Now: \(current.kind.displayName)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 6) {
                PrayerIcon(kind: status.next.kind, size: 18)
                    .foregroundStyle(.tint)
                Text(status.next.kind.displayName)
                    .font(.headline)
            }
            Text(PrayerTimeFormat.string(from: status.next.date))
                .font(.system(.title, design: .rounded, weight: .semibold))
                .monospacedDigit()
            Text("in \(Text(status.next.date, style: .timer))")
                .font(.footnote)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct PrayerRow: View {
    enum State {
        case past, current, upcoming
    }

    let prayer: PrayerTime
    let state: State

    var body: some View {
        HStack(spacing: 8) {
            PrayerIcon(kind: prayer.kind)
            Text(prayer.kind.displayName)
            Spacer()
            Text(PrayerTimeFormat.string(from: prayer.date))
                .monospacedDigit()
        }
        .fontWeight(state == .current ? .semibold : .regular)
        .foregroundStyle(state == .past ? AnyShapeStyle(.secondary) : AnyShapeStyle(.primary))
        .listRowBackground(
            state == .current
                ? RoundedRectangle(cornerRadius: 10).fill(.tint.opacity(0.35))
                : nil
        )
    }
}

private struct SyncNeededView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "iphone")
                .font(.title2)
                .foregroundStyle(.tint)
            Text("Open Simple Azaan on your iPhone to sync prayer times.")
                .font(.footnote)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    PrayerScreen(store: .shared)
}
