import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:simple_azaan/models/prayer_data.dart';
import 'package:simple_azaan/models/prayer_schedule.dart';
import 'package:simple_azaan/service/settings_service.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  static const String _payloadPrefix = 'simple_azaan_prayer:';
  static const List<int> _legacyIds = [100, 101, 102, 103, 104, 105];

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Future<void>? _initializing;
  tz.Location? _localLocation;

  Future<void> init() {
    if (_initialized) return Future.value();
    return _initializing ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      tz.initializeTimeZones();
      final timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      _localLocation = tz.getLocation(timeZoneName);
      tz.setLocalLocation(_localLocation!);
    } catch (_) {
      _localLocation = tz.local;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );
    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await init();
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: false, sound: true);
    } else if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleForPrayerSchedule(PrayerSchedule schedule) async {
    await init();
    final settings = await SettingsService.instance.loadSettings();
    final now = DateTime.now();
    final desired = <int, _PrayerEntry>{};

    for (final day in schedule.days) {
      final entries = _entriesForDay(day);
      for (var index = 0; index < entries.length; index++) {
        final entry = entries[index];
        if (entry.time.isAfter(now) &&
            settings.notificationSettings[entry.type] == true) {
          desired[_notificationId(entry.time, index)] = entry;
        }
      }
    }

    // Remove legacy IDs and only stale requests owned by this app feature.
    for (final id in _legacyIds) {
      await _plugin.cancel(id);
    }
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      final isPrayerRequest =
          request.payload?.startsWith(_payloadPrefix) ?? false;
      if (isPrayerRequest && !desired.containsKey(request.id)) {
        await _plugin.cancel(request.id);
      }
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_times',
        'Prayer times',
        channelDescription: 'Prayer time reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    for (final item in desired.entries) {
      final prayer = item.value;
      final scheduledTime =
          tz.TZDateTime.from(prayer.time, _localLocation ?? tz.local);
      try {
        await _plugin.zonedSchedule(
          item.key,
          prayer.name,
          "It's ${prayer.name} time in ${schedule.location.displayName} 🙂",
          scheduledTime,
          details,
          payload: '$_payloadPrefix${prayer.name}',
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (error) {
        if (kDebugMode) {
          debugPrint('Failed to schedule ${prayer.name}: $error');
        }
      }
    }
  }

  List<_PrayerEntry> _entriesForDay(PrayerData data) => [
        _PrayerEntry('Fajr', data.time1, PrayerType.fajr),
        _PrayerEntry('Sunrise', data.time2, PrayerType.sunrise),
        _PrayerEntry('Zuhr', data.time3, PrayerType.zuhr),
        _PrayerEntry('Asr', data.time4, PrayerType.asr),
        _PrayerEntry('Maghrib', data.time5, PrayerType.maghrib),
        _PrayerEntry('Isha', data.time6, PrayerType.isha),
      ];

  int _notificationId(DateTime time, int prayerIndex) {
    final dateId = time.year * 10000 + time.month * 100 + time.day;
    return dateId * 10 + prayerIndex;
  }
}

class _PrayerEntry {
  const _PrayerEntry(this.name, this.time, this.type);

  final String name;
  final DateTime time;
  final PrayerType type;
}
