import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:simple_azaan/api/aladhan_api.dart';
import 'package:simple_azaan/models/prayer_data.dart';
import 'package:simple_azaan/service/widget_sync.dart';
import 'package:simple_azaan/constants.dart';

class BackgroundPrayerSync {
  static const String _dailySyncTaskName = 'dailyPrayerSync';
  static const String _taskTag = 'prayer-sync';

  /// Initialize WorkManager and register the daily prayer sync task
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
      
      // Cancel any existing tasks first (Android only - iOS doesn't support cancelByTag)
      if (Platform.isAndroid) {
        await Workmanager().cancelByTag(_taskTag);
      }
      
      // Schedule daily task - platform specific implementation
      if (Platform.isAndroid) {
        // Android: Use periodic WorkManager task
        await Workmanager().registerPeriodicTask(
          _dailySyncTaskName,
          _dailySyncTaskName,
          frequency: const Duration(days: 1),
          initialDelay: _getInitialDelay(),
          tag: _taskTag,
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
        );
      } else if (Platform.isIOS) {
        // iOS: Use one-off task + iOS background fetch system will reschedule
        await Workmanager().registerOneOffTask(
          _dailySyncTaskName,
          _dailySyncTaskName,
          initialDelay: _getInitialDelay(),
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
        );
      }
      
      if (kDebugMode) {
        print('BackgroundPrayerSync: Daily task registered successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundPrayerSync: Failed to initialize: $e');
      }
    }
  }

  /// Calculate initial delay to sync at 2:05 AM
  static Duration _getInitialDelay() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 2, 5); // 2:05 AM tomorrow
    final delay = tomorrow.difference(now);
    
    if (kDebugMode) {
      print('BackgroundPrayerSync: Next sync scheduled for ${tomorrow.toString()}');
    }
    
    return delay;
  }

  /// Manual sync trigger for testing
  static Future<void> syncNow() async {
    try {
      await _performPrayerSync();
      if (kDebugMode) {
        print('BackgroundPrayerSync: Manual sync completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundPrayerSync: Manual sync failed: $e');
      }
      rethrow;
    }
  }

  /// Reschedule iOS task for next day (since one-off tasks don't repeat)
  static Future<void> _rescheduleIOSTask() async {
    try {
      await Workmanager().registerOneOffTask(
        _dailySyncTaskName,
        _dailySyncTaskName,
        initialDelay: const Duration(days: 1), // Next day at the same time
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
      
      if (kDebugMode) {
        print('BackgroundPrayerSync: iOS task rescheduled for next day');
      }
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundPrayerSync: Failed to reschedule iOS task: $e');
      }
    }
  }

  /// Perform the actual prayer data sync
  static Future<void> _performPrayerSync() async {
    try {
      final api = AlAdhanApi(
        city: kDefaultCity,
        state: kDefaultState,
        country: kDefaultCountry,
        method: kDefaultMethod,
      );
      final response = await api.getPrayerTimeToday();
      final prayerData = PrayerData.fromAlAdhanApi(response);
      
      // Update widget with fresh data
      await WidgetSync.pushPrayerDataToWidget(prayerData);
      
      if (kDebugMode) {
        print('BackgroundPrayerSync: Prayer data updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundPrayerSync: Sync failed: $e');
      }
      rethrow;
    }
  }
}

/// Background task callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (kDebugMode) {
        print('BackgroundPrayerSync: Executing background task: $task');
      }
      
      switch (task) {
        case 'dailyPrayerSync':
          await BackgroundPrayerSync._performPrayerSync();
          
          // iOS: Reschedule next day's task since one-off tasks don't repeat
          if (Platform.isIOS) {
            await BackgroundPrayerSync._rescheduleIOSTask();
          }
          
          return Future.value(true);
        default:
          if (kDebugMode) {
            print('BackgroundPrayerSync: Unknown task: $task');
          }
          return Future.value(false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundPrayerSync: Background task failed: $e');
      }
      return Future.value(false);
    }
  });
}