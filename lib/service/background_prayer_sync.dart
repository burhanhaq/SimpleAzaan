import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          initialDelay: await _getInitialDelay(),
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
          initialDelay: await _getInitialDelay(),
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

  /// Get current prayer data from cache asynchronously
  static Future<PrayerData?> _getCurrentPrayerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(kPrayerKey);
      if (jsonString != null) {
        final jsonData = jsonDecode(jsonString);
        return PrayerData.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundPrayerSync: Error reading cached prayer data: $e');
      }
      return null;
    }
  }

  /// Calculate initial delay to sync 1 minute after Isha prayer
  static Future<Duration> _getInitialDelay() async {
    final now = DateTime.now();
    
    try {
      // Try to get current prayer data for Isha time
      final prayerData = await _getCurrentPrayerData();
      if (prayerData != null) {
        final ishaTime = prayerData.time6;
        final syncTime = ishaTime.add(const Duration(minutes: 1));
        
        // If today's Isha + 1min already passed, schedule for tomorrow
        if (syncTime.isAfter(now)) {
          if (kDebugMode) {
            print('BackgroundPrayerSync: Next sync scheduled for ${syncTime.toString()} (1min after today\'s Isha)');
          }
          return syncTime.difference(now);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundPrayerSync: Could not get current prayer data: $e');
      }
    }
    
    // Fallback: Use 2:05 AM next day if prayer data unavailable or Isha passed
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 2, 5);
    final delay = tomorrow.difference(now);
    
    if (kDebugMode) {
      print('BackgroundPrayerSync: Next sync scheduled for ${tomorrow.toString()} (fallback time)');
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
        initialDelay: await _getInitialDelay(), // Dynamic delay based on prayer times
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