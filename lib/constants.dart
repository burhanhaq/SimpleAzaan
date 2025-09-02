import 'package:flutter/material.dart';

// App Group and Core Keys
const String kPrayerKey = 'prayerData';
const String kGroup = 'group.com.simpleAzaan';

// Settings Screen
const double kSettingsScreenBumpWidth = 6.0;

// Display Modes
enum PrayerTimeDisplay {
  prayerTime,
  timeToNextPrayer,
}

// Settings Keys
const String kUseCurrentLocationKey = 'use_current_location';
const String kCustomCityKey = 'custom_city';
const String kCustomStateKey = 'custom_state';
const String kCustomCountryKey = 'custom_country';
const String kThemeModeKey = 'theme_mode';
const String kNotificationPrefix = 'notification_';

// Default Values
const String kDefaultCity = 'Bellevue';
const String kDefaultState = 'WA';
const String kDefaultCountry = 'United States';
const String kDefaultMethod = '2'; // ISNA method

// UI Text Constants
const String kLocationPermissionDenied = 'Location permission denied';
const String kLocationPermissionPermanentlyDenied = 'Location permission permanently denied';
const String kLocationServicesDisabled = 'Location services are disabled';
const String kLocationDetectionFailed = 'Failed to detect location';
const String kLocationDetectionTimeout = 'Location detection timed out';
const String kNoInternetConnection = 'No internet connection';
const String kServerError = 'Server error. Please try again later';
const String kLocationNotFound = 'Location not found';
const String kLoadingLocation = 'Loading location...';
const String kUnknownLocation = 'Unknown Location';

// API Constants
const String kAladhanApiBaseUrl = 'https://api.aladhan.com/v1';
const String kTimingsByCityEndpoint = '/timingsByCity';

// Light Theme Colors
const Color kLightAppBackgroundColor = Color(0xfff6f7f9);
const Color kLightPrimaryColor = Color(0xFF4A90E2);
const Color kLightLoadingBackgroundColor = Color(0xFFE8E8E8);
const Color kLightErrorColor = Color(0xFFE57373);
const Color kLightSuccessColor = Color(0xFF81C784);
const Color kLightPrimaryTextColor = Color(0xFF000000);
const Color kLightSecondaryTextColor = Color(0xFF757575);
const Color kLightCardBackgroundColor = Color(0xFFFFFFFF);
const Color kLightDividerColor = Color(0xFF000000);

// Dark Theme Colors
const Color kDarkAppBackgroundColor = Color(0xFF1a1a1a);
const Color kDarkPrimaryColor = Color(0xFF4A90E2);
const Color kDarkLoadingBackgroundColor = Color(0xFF333333);
const Color kDarkErrorColor = Color(0xFFff6b6b);
const Color kDarkSuccessColor = Color(0xFF4CAF50);
const Color kDarkPrimaryTextColor = Color(0xFFFFFFFF);
const Color kDarkSecondaryTextColor = Color(0xFFb3b3b3);
const Color kDarkCardBackgroundColor = Color(0xFF2d2d2d);
const Color kDarkDividerColor = Color(0xFFFFFFFF);

// Prayer-Specific Light Background Colors
const Color kFajrLightBackgroundColor = Color(0xFFF0F4F8);    // Soft blue-gray
const Color kSunriseLightBackgroundColor = Color(0xFFFFF8E1); // Warm cream
const Color kZuhrLightBackgroundColor = Color(0xFFF9F9F9);    // Pure light gray
const Color kAsrLightBackgroundColor = Color(0xFFFFF3E0);     // Warm light orange

// Prayer-Specific Dark Background Colors  
const Color kMaghribDarkBackgroundColor = Color(0xFF2C1810);  // Deep brown
const Color kIshaDarkBackgroundColor = Color(0xFF0D1421);     // Deep blue-black

// Prayer-Specific Text Colors for Light Backgrounds
const Color kFajrLightTextColor = Color(0xFF2C3E50);         // Dark blue-gray
const Color kSunriseLightTextColor = Color(0xFF5D4037);      // Warm brown
const Color kZuhrLightTextColor = Color(0xFF333333);         // Standard dark
const Color kAsrLightTextColor = Color(0xFF4A2C17);          // Dark orange-brown

// Prayer-Specific Text Colors for Dark Backgrounds
const Color kMaghribDarkTextColor = Color(0xFFF5E6D3);       // Warm cream
const Color kIshaDarkTextColor = Color(0xFFE3F2FD);          // Light blue

// Legacy Colors (for backward compatibility during migration)
const Color kAppBackgroundColor = kLightAppBackgroundColor;
const Color kPrimaryColor = kLightPrimaryColor;
const Color kLoadingBackgroundColor = kLightLoadingBackgroundColor;
const Color kErrorColor = kLightErrorColor;
const Color kSuccessColor = kLightSuccessColor;
