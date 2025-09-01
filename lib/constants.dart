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
