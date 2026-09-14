import 'package:intl/intl.dart';

class Prayer {
  final String name;
  final DateTime prayerTime;

  Prayer(
    this.name,
    this.prayerTime,
  );

  DateTime get getPrayerTime => prayerTime;

  String getTimeString() {
    String formattedDate = DateFormat('kk:mm').format(prayerTime);
    return formattedDate;
  }

  String getDateString() {
    String formattedDate = DateFormat("EEE, MMM d, ''yy").format(prayerTime);
    return formattedDate;
  }
}

Prayer? activePrayerAt(List<Prayer> prayers, DateTime now) {
  if (prayers.isEmpty) return null;

  final first = prayers.first.prayerTime;
  if (first.year != now.year ||
      first.month != now.month ||
      first.day != now.day) {
    return null;
  }

  final currentIndex = prayers.lastIndexWhere(
    (prayer) => !prayer.prayerTime.isAfter(now),
  );

  // Before Fajr, highlight the prayer that is coming up rather than leaving
  // the timetable with no active row.
  return currentIndex >= 0 ? prayers[currentIndex] : prayers.first;
}

Prayer? nextPrayerAt(Iterable<Prayer> prayers, DateTime now) {
  for (final prayer in prayers) {
    if (prayer.prayerTime.isAfter(now)) return prayer;
  }
  return null;
}
