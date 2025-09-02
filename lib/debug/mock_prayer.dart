import 'package:flutter/foundation.dart';
import 'package:simple_azaan/models/prayer.dart';
import 'package:simple_azaan/service/settings_service.dart';
import 'package:simple_azaan/themes/prayer_colors.dart';

/// Debug-only mock prayer factory for testing prayer-specific colors
class MockPrayer {
  /// Creates a mock prayer for the specified prayer type
  static Prayer? create(PrayerType prayerType) {
    if (!kDebugMode) return null; // Only available in debug mode
    
    final now = DateTime.now();
    final prayerName = PrayerTypeHelper.getPrayerName(prayerType);
    
    // Create a mock prayer with current time
    final mockPrayer = Prayer(prayerName, now);
    
    // Mark as current prayer for visual distinction
    mockPrayer.isCurrentPrayer = true;
    
    return mockPrayer;
  }

  /// Gets display names for all prayer types
  static Map<PrayerType, String> get prayerDisplayNames => {
    PrayerType.fajr: 'Fajr (Dawn)',
    PrayerType.sunrise: 'Sunrise',
    PrayerType.zuhr: 'Zuhr (Noon)',
    PrayerType.asr: 'Asr (Afternoon)',
    PrayerType.maghrib: 'Maghrib (Sunset)',
    PrayerType.isha: 'Isha (Night)',
  };

  /// Gets color description for each prayer type
  static Map<PrayerType, String> get prayerColorDescriptions => {
    PrayerType.fajr: 'Soft Blue-Gray',
    PrayerType.sunrise: 'Warm Cream',
    PrayerType.zuhr: 'Pure Light Gray',
    PrayerType.asr: 'Light Orange',
    PrayerType.maghrib: 'Deep Brown (Dark)',
    PrayerType.isha: 'Deep Blue-Black (Dark)',
  };
}