import 'dart:convert';

import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/models/prayer_data.dart';
import 'package:simple_azaan/models/prayer_schedule.dart';

class WidgetSync {
  static Future<void> pushPrayerDataToWidget(PrayerData data) async {
    final jsonString = jsonEncode(data.toJson());
    // Persist to SharedPreferences so background scheduler can read Isha time
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kPrayerKey, jsonString);
    } catch (_) {
      // If persisting fails, continue to update widget
    }
    await WidgetKit.setItem(kPrayerKey, jsonString, kGroup);
    WidgetKit.reloadAllTimelines();
  }

  static Future<void> pushPrayerScheduleToWidget(
    PrayerSchedule schedule,
  ) async {
    final jsonString = jsonEncode(schedule.toJson());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrayerScheduleKey, jsonString);

    await WidgetKit.setItem(kPrayerScheduleKey, jsonString, kGroup);

    // Keep the old single-day key during migration for installed widgets that
    // may still be rendering a previously compiled timeline provider.
    if (schedule.days.isNotEmpty) {
      final legacyJson = jsonEncode(schedule.days.first.toJson());
      await prefs.setString(kPrayerKey, legacyJson);
      await WidgetKit.setItem(kPrayerKey, legacyJson, kGroup);
    }
    WidgetKit.reloadAllTimelines();
  }
}
