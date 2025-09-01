import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:simple_azaan/models/prayer_data.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  tz.Location? _localLocation;

  Future<void> init() async {
    if (_initialized) return;

    // Timezone setup
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      _localLocation = tz.getLocation(timeZoneName);
      tz.setLocalLocation(_localLocation!);
    } catch (e) {
      // Fallback to local if timezone name resolution fails
      _localLocation ??= tz.local;
    }

    // iOS initialization
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // On iOS 10+, explicit permission request via plugin API
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    _initialized = true;
  }

  Future<void> cancelTodaySchedules() async {
    // Use fixed IDs for each prayer to allow rescheduling
    const ids = [100, 101, 102, 103, 104, 105];
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }

  Future<void> scheduleForPrayerData(PrayerData pd,
      {String cityLabel = 'Your city'}) async {
    if (!_initialized) await init();

    // Cancel existing for the day to avoid duplicates
    await cancelTodaySchedules();

    final now = DateTime.now();

    final entries = <_PrayerEntry>[
      _PrayerEntry(id: 100, name: 'Fajr', time: pd.time1),
      _PrayerEntry(id: 101, name: 'Sunrise', time: pd.time2),
      _PrayerEntry(id: 102, name: 'Zuhr', time: pd.time3),
      _PrayerEntry(id: 103, name: 'Asr', time: pd.time4),
      _PrayerEntry(id: 104, name: 'Maghrib', time: pd.time5),
      _PrayerEntry(id: 105, name: 'Isha', time: pd.time6),
    ];

    final details = const NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    for (final e in entries) {
      if (e.time.isAfter(now)) {
        final tzTime = tz.TZDateTime.from(e.time, _localLocation ?? tz.local);
        final title = e.name;
        final body = "It's ${e.name} time in ${cityLabel} 🙂";
        try {
          await _plugin.zonedSchedule(
            e.id,
            title,
            body,
            tzTime,
            details,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (err) {
          if (kDebugMode) {
            print('Failed to schedule ${e.name}: $err');
          }
        }
      }
    }
  }
}

class _PrayerEntry {
  final int id;
  final String name;
  final DateTime time;
  _PrayerEntry({required this.id, required this.name, required this.time});
}
