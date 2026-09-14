import 'package:flutter_test/flutter_test.dart';

import 'package:simple_azaan/models/prayer.dart';

void main() {
  final prayers = [
    Prayer('Fajr', DateTime(2026, 9, 13, 5)),
    Prayer('Sunrise', DateTime(2026, 9, 13, 6, 30)),
    Prayer('Zuhr', DateTime(2026, 9, 13, 13)),
    Prayer('Asr', DateTime(2026, 9, 13, 16, 30)),
    Prayer('Maghrib', DateTime(2026, 9, 13, 19)),
    Prayer('Isha', DateTime(2026, 9, 13, 20, 30)),
  ];

  test('highlights Fajr before the first prayer', () {
    expect(activePrayerAt(prayers, DateTime(2026, 9, 13, 4))?.name, 'Fajr');
  });

  test('highlights the active prayer window', () {
    expect(activePrayerAt(prayers, DateTime(2026, 9, 13, 17))?.name, 'Asr');
  });

  test('does not highlight a timetable for another date', () {
    expect(activePrayerAt(prayers, DateTime(2026, 9, 14, 17)), isNull);
  });

  test('finds the next prayer without storing mutable status', () {
    expect(nextPrayerAt(prayers, DateTime(2026, 9, 13, 17))?.name, 'Maghrib');
    expect(nextPrayerAt(prayers, DateTime(2026, 9, 13, 21)), isNull);
  });
}
