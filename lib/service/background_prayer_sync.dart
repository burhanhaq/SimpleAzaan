import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/models/location.dart';
import 'package:simple_azaan/models/prayer_schedule.dart';
import 'package:simple_azaan/repositories/prayer_times_repository.dart';
import 'package:simple_azaan/service/notification_service.dart';
import 'package:simple_azaan/service/settings_service.dart';
import 'package:simple_azaan/service/widget_sync.dart';

class BackgroundPrayerSync {
  static const String taskIdentifier = 'com.simpleAzaan.dailyPrayerSync';
  static const String _taskTag = 'prayer-sync';

  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      if (Platform.isAndroid) {
        await Workmanager().cancelByTag(_taskTag);
        await Workmanager().registerPeriodicTask(
          taskIdentifier,
          taskIdentifier,
          frequency: const Duration(days: 1),
          initialDelay: _nextRefreshDelay(),
          tag: _taskTag,
          constraints: _networkConstraints,
        );
      } else if (Platform.isIOS) {
        await _registerIOSTask();
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('BackgroundPrayerSync initialization failed: $error');
      }
    }
  }

  static Constraints get _networkConstraints => Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      );

  static Duration _nextRefreshDelay() {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, 2, 5);
    if (!next.isAfter(now)) {
      next = DateTime(now.year, now.month, now.day + 1, 2, 5);
    }
    return next.difference(now);
  }

  static Future<void> _registerIOSTask() async {
    await Workmanager().registerOneOffTask(
      taskIdentifier,
      taskIdentifier,
      initialDelay: _nextRefreshDelay(),
      constraints: _networkConstraints,
    );
  }

  static Future<void> syncNow() => _performPrayerSync();

  static Future<void> _performPrayerSync() async {
    final settings = await SettingsService.instance.loadSettings();
    final location = Location(
      city: settings.customCity.isNotEmpty ? settings.customCity : kDefaultCity,
      state: settings.customState.isNotEmpty
          ? settings.customState
          : kDefaultState,
      country: settings.customCountry.isNotEmpty
          ? settings.customCountry
          : kDefaultCountry,
      latitude: settings.latitude,
      longitude: settings.longitude,
    );

    final days = await PrayerTimesRepository.instance.getPrayerTimesRange(
      location: location,
      startDate: DateTime.now(),
      dayCount: kScheduleHorizonDays,
      forceRefresh: true,
    );
    final schedule = PrayerSchedule(
      generatedAt: DateTime.now(),
      location: location,
      calculationMethod: kDefaultMethod,
      days: days,
    );

    await WidgetSync.pushPrayerScheduleToWidget(schedule);
    await NotificationService().scheduleForPrayerSchedule(schedule);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    DartPluginRegistrant.ensureInitialized();
    if (task != BackgroundPrayerSync.taskIdentifier) return false;

    try {
      await BackgroundPrayerSync._performPrayerSync();
      if (Platform.isIOS) {
        await BackgroundPrayerSync._registerIOSTask();
      }
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('BackgroundPrayerSync task failed: $error');
      }
      return false;
    }
  });
}
