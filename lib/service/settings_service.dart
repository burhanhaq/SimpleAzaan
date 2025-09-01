import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_azaan/constants.dart';

enum AppThemeMode {
  light,
  dark,
  dual,
}

enum PrayerType {
  fajr,
  sunrise,
  zuhr,
  asr,
  maghrib,
  isha,
}

class AppSettings {
  bool useCurrentLocation;
  String customCity;
  String customState;
  String customCountry;
  Map<PrayerType, bool> notificationSettings;
  AppThemeMode themeMode;

  AppSettings({
    this.useCurrentLocation = true,
    this.customCity = kDefaultCity,
    this.customState = kDefaultState,
    this.customCountry = kDefaultCountry,
    Map<PrayerType, bool>? notificationSettings,
    this.themeMode = AppThemeMode.light,
  }) : notificationSettings = notificationSettings ??
            {
              PrayerType.fajr: true,
              PrayerType.sunrise: false,
              PrayerType.zuhr: true,
              PrayerType.asr: true,
              PrayerType.maghrib: true,
              PrayerType.isha: true,
            };
}

class SettingsService {
  static const String _useCurrentLocationKey = kUseCurrentLocationKey;
  static const String _customCityKey = kCustomCityKey;
  static const String _customStateKey = kCustomStateKey;
  static const String _customCountryKey = kCustomCountryKey;
  static const String _themeModeKey = kThemeModeKey;
  static const String _notificationPrefix = kNotificationPrefix;

  static SettingsService? _instance;
  static SettingsService get instance {
    _instance ??= SettingsService._internal();
    return _instance!;
  }

  SettingsService._internal();

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final useCurrentLocation = prefs.getBool(_useCurrentLocationKey) ?? true;
    final customCity = prefs.getString(_customCityKey) ?? kDefaultCity;
    final customState = prefs.getString(_customStateKey) ?? kDefaultState;
    final customCountry = prefs.getString(_customCountryKey) ?? kDefaultCountry;
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
    final themeMode = AppThemeMode.values[themeModeIndex];

    final notificationSettings = <PrayerType, bool>{};
    for (final prayerType in PrayerType.values) {
      final key = '$_notificationPrefix${prayerType.name}';
      final defaultValue = prayerType == PrayerType.sunrise ? false : true;
      notificationSettings[prayerType] = prefs.getBool(key) ?? defaultValue;
    }

    return AppSettings(
      useCurrentLocation: useCurrentLocation,
      customCity: customCity,
      customState: customState,
      customCountry: customCountry,
      notificationSettings: notificationSettings,
      themeMode: themeMode,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_useCurrentLocationKey, settings.useCurrentLocation);
    await prefs.setString(_customCityKey, settings.customCity);
    await prefs.setString(_customStateKey, settings.customState);
    await prefs.setString(_customCountryKey, settings.customCountry);
    await prefs.setInt(_themeModeKey, settings.themeMode.index);

    for (final entry in settings.notificationSettings.entries) {
      final key = '$_notificationPrefix${entry.key.name}';
      await prefs.setBool(key, entry.value);
    }
  }

  Future<void> updateNotificationSetting(PrayerType prayerType, bool enabled) async {
    final settings = await loadSettings();
    settings.notificationSettings[prayerType] = enabled;
    await saveSettings(settings);
  }

  Future<void> updateLocationSettings({
    bool? useCurrentLocation,
    String? customCity,
    String? customState,
    String? customCountry,
  }) async {
    final settings = await loadSettings();
    if (useCurrentLocation != null) settings.useCurrentLocation = useCurrentLocation;
    if (customCity != null) settings.customCity = customCity;
    if (customState != null) settings.customState = customState;
    if (customCountry != null) settings.customCountry = customCountry;
    await saveSettings(settings);
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final settings = await loadSettings();
    settings.themeMode = themeMode;
    await saveSettings(settings);
  }
}