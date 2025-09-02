import 'package:flutter/material.dart';
import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/service/settings_service.dart';

/// Represents colors for a specific prayer time
class PrayerColors {
  final Color backgroundColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color cardBackgroundColor;
  final Color dividerColor;
  final Color accentColor;
  final Brightness brightness;

  const PrayerColors({
    required this.backgroundColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.cardBackgroundColor,
    required this.dividerColor,
    required this.accentColor,
    required this.brightness,
  });
}

/// Manages color schemes for all prayer types
class PrayerColorScheme {
  final Map<PrayerType, PrayerColors> _prayerColors;

  const PrayerColorScheme(this._prayerColors);

  PrayerColors getColorsForPrayer(PrayerType prayerType) {
    return _prayerColors[prayerType] ?? _prayerColors[PrayerType.zuhr]!;
  }

  Map<PrayerType, PrayerColors> get allColors => Map.unmodifiable(_prayerColors);

  /// Light prayer color scheme (Fajr, Sunrise, Zuhr, Asr use light themes)
  static const light = PrayerColorScheme({
    PrayerType.fajr: PrayerColors(
      backgroundColor: kFajrLightBackgroundColor,
      primaryTextColor: kFajrLightTextColor,
      secondaryTextColor: Color(0xFF607D8B),
      cardBackgroundColor: Color(0xFFFFFFFF),
      dividerColor: kFajrLightTextColor,
      accentColor: Color(0xFF3F51B5),
      brightness: Brightness.light,
    ),
    PrayerType.sunrise: PrayerColors(
      backgroundColor: kSunriseLightBackgroundColor,
      primaryTextColor: kSunriseLightTextColor,
      secondaryTextColor: Color(0xFF8D6E63),
      cardBackgroundColor: Color(0xFFFFFFFF),
      dividerColor: kSunriseLightTextColor,
      accentColor: Color(0xFFFF9800),
      brightness: Brightness.light,
    ),
    PrayerType.zuhr: PrayerColors(
      backgroundColor: kZuhrLightBackgroundColor,
      primaryTextColor: kZuhrLightTextColor,
      secondaryTextColor: Color(0xFF757575),
      cardBackgroundColor: Color(0xFFFFFFFF),
      dividerColor: kZuhrLightTextColor,
      accentColor: Color(0xFF2196F3),
      brightness: Brightness.light,
    ),
    PrayerType.asr: PrayerColors(
      backgroundColor: kAsrLightBackgroundColor,
      primaryTextColor: kAsrLightTextColor,
      secondaryTextColor: Color(0xFF8D6E63),
      cardBackgroundColor: Color(0xFFFFFFFF),
      dividerColor: kAsrLightTextColor,
      accentColor: Color(0xFFFF5722),
      brightness: Brightness.light,
    ),
    PrayerType.maghrib: PrayerColors(
      backgroundColor: kMaghribDarkBackgroundColor,
      primaryTextColor: kMaghribDarkTextColor,
      secondaryTextColor: Color(0xFFD7CCC8),
      cardBackgroundColor: Color(0xFF3E2723),
      dividerColor: kMaghribDarkTextColor,
      accentColor: Color(0xFFFF7043),
      brightness: Brightness.dark,
    ),
    PrayerType.isha: PrayerColors(
      backgroundColor: kIshaDarkBackgroundColor,
      primaryTextColor: kIshaDarkTextColor,
      secondaryTextColor: Color(0xFFB0BEC5),
      cardBackgroundColor: Color(0xFF1A237E),
      dividerColor: kIshaDarkTextColor,
      accentColor: Color(0xFF3F51B5),
      brightness: Brightness.dark,
    ),
  });

  /// Dark prayer color scheme (all prayers use dark theme variants)
  static const dark = PrayerColorScheme({
    PrayerType.fajr: PrayerColors(
      backgroundColor: Color(0xFF1A1A2E),
      primaryTextColor: Color(0xFFE8E8E8),
      secondaryTextColor: Color(0xFFB0BEC5),
      cardBackgroundColor: Color(0xFF16213E),
      dividerColor: Color(0xFFE8E8E8),
      accentColor: Color(0xFF3F51B5),
      brightness: Brightness.dark,
    ),
    PrayerType.sunrise: PrayerColors(
      backgroundColor: Color(0xFF2C1810),
      primaryTextColor: Color(0xFFF5E6D3),
      secondaryTextColor: Color(0xFFD7CCC8),
      cardBackgroundColor: Color(0xFF3E2723),
      dividerColor: Color(0xFFF5E6D3),
      accentColor: Color(0xFFFF9800),
      brightness: Brightness.dark,
    ),
    PrayerType.zuhr: PrayerColors(
      backgroundColor: Color(0xFF1A1A1A),
      primaryTextColor: Color(0xFFFFFFFF),
      secondaryTextColor: Color(0xFFB3B3B3),
      cardBackgroundColor: Color(0xFF2D2D2D),
      dividerColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF2196F3),
      brightness: Brightness.dark,
    ),
    PrayerType.asr: PrayerColors(
      backgroundColor: Color(0xFF2C1810),
      primaryTextColor: Color(0xFFF5E6D3),
      secondaryTextColor: Color(0xFFD7CCC8),
      cardBackgroundColor: Color(0xFF3E2723),
      dividerColor: Color(0xFFF5E6D3),
      accentColor: Color(0xFFFF5722),
      brightness: Brightness.dark,
    ),
    PrayerType.maghrib: PrayerColors(
      backgroundColor: kMaghribDarkBackgroundColor,
      primaryTextColor: kMaghribDarkTextColor,
      secondaryTextColor: Color(0xFFD7CCC8),
      cardBackgroundColor: Color(0xFF3E2723),
      dividerColor: kMaghribDarkTextColor,
      accentColor: Color(0xFFFF7043),
      brightness: Brightness.dark,
    ),
    PrayerType.isha: PrayerColors(
      backgroundColor: kIshaDarkBackgroundColor,
      primaryTextColor: kIshaDarkTextColor,
      secondaryTextColor: Color(0xFFB0BEC5),
      cardBackgroundColor: Color(0xFF1A237E),
      dividerColor: kIshaDarkTextColor,
      accentColor: Color(0xFF3F51B5),
      brightness: Brightness.dark,
    ),
  });
}

/// Helper class to map prayer names to PrayerType enum
class PrayerTypeHelper {
  static const Map<String, PrayerType> _nameToType = {
    'Fajr': PrayerType.fajr,
    'Sunrise': PrayerType.sunrise,
    'Zuhr': PrayerType.zuhr,
    'Asr': PrayerType.asr,
    'Maghrib': PrayerType.maghrib,
    'Isha': PrayerType.isha,
  };

  static PrayerType? getPrayerType(String prayerName) {
    return _nameToType[prayerName];
  }

  static String getPrayerName(PrayerType prayerType) {
    return _nameToType.entries
        .firstWhere((entry) => entry.value == prayerType)
        .key;
  }
}
