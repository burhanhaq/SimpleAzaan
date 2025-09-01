import 'dart:convert';

import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/models/prayer_data.dart';

class WidgetSync {
  static Future<void> pushPrayerDataToWidget(PrayerData data) async {
    final jsonString = jsonEncode(data.toJson());
    await WidgetKit.setItem(kPrayerKey, jsonString, kGroup);
    WidgetKit.reloadAllTimelines();
  }
}

