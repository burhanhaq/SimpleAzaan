import 'package:flutter_test/flutter_test.dart';

import 'package:simple_azaan/models/location.dart';
import 'package:simple_azaan/models/prayer_data.dart';
import 'package:simple_azaan/models/prayer_schedule.dart';

void main() {
  test('prayer schedule survives JSON persistence', () {
    final day = PrayerData(
      DateTime(2026, 9, 13, 5),
      DateTime(2026, 9, 13, 6, 30),
      DateTime(2026, 9, 13, 13),
      DateTime(2026, 9, 13, 16, 30),
      DateTime(2026, 9, 13, 19),
      DateTime(2026, 9, 13, 20, 30),
    );
    final schedule = PrayerSchedule(
      generatedAt: DateTime(2026, 9, 13, 1),
      location: Location(
        city: 'Bellevue',
        state: 'WA',
        country: 'United States',
        latitude: 47.61,
        longitude: -122.20,
      ),
      calculationMethod: '2',
      days: [day],
    );

    final decoded = PrayerSchedule.fromJson(schedule.toJson());

    expect(decoded.location, schedule.location);
    expect(decoded.calculationMethod, '2');
    expect(decoded.days, hasLength(1));
    expect(decoded.days.first.time1.isAtSameMomentAs(day.time1), isTrue);
    expect(
      decoded.generatedAt.isAtSameMomentAs(schedule.generatedAt),
      isTrue,
    );
  });
}
