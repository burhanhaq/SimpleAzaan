import 'dart:convert';

import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/models/prayer_data.dart';

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
}
