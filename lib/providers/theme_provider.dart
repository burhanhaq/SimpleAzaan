import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_azaan/themes/app_theme.dart';
import 'package:simple_azaan/themes/prayer_colors.dart';
import 'package:simple_azaan/service/settings_service.dart';
import 'package:simple_azaan/models/prayer.dart';

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _currentThemeMode = AppThemeMode.light;
  AppTheme _currentTheme = AppThemes.light;
  final SettingsService _settingsService = SettingsService.instance;
  Prayer? _currentPrayer;
  
  // Debug prayer override - only available in debug mode
  PrayerType? _debugOverridePrayer;

  AppThemeMode get currentThemeMode => _currentThemeMode;
  AppTheme get currentTheme => _currentTheme;
  ThemeData get themeData => _currentTheme.themeData;
  Prayer? get currentPrayer => _currentPrayer;
  
  // Debug getters
  PrayerType? get debugOverridePrayer => _debugOverridePrayer;
  bool get hasDebugOverride => kDebugMode && _debugOverridePrayer != null;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final settings = await _settingsService.loadSettings();
      _currentThemeMode = settings.themeMode;
      _currentTheme = AppThemes.getTheme(_currentThemeMode);
      _updateSystemUiOverlay();
      notifyListeners();
    } catch (e) {
      // If loading fails, stick with default light theme
      _currentThemeMode = AppThemeMode.light;
      _currentTheme = AppThemes.light;
      _updateSystemUiOverlay();
    }
  }

  Future<void> setTheme(AppThemeMode themeMode) async {
    if (_currentThemeMode == themeMode) return;
    
    _currentThemeMode = themeMode;
    _currentTheme = AppThemes.getTheme(themeMode);
    _updateSystemUiOverlay();
    
    await _settingsService.updateThemeMode(themeMode);
    notifyListeners();
  }

  /// Updates the current prayer which affects the background color
  void setCurrentPrayer(Prayer? prayer) {
    if (_currentPrayer == prayer) return;
    _currentPrayer = prayer;
    _updateSystemUiOverlay();
    notifyListeners();
  }

  /// Debug-only method to override current prayer for testing colors
  void setDebugPrayer(PrayerType? prayerType) {
    if (!kDebugMode) return; // Only works in debug mode
    if (_debugOverridePrayer == prayerType) return;
    _debugOverridePrayer = prayerType;
    _updateSystemUiOverlay();
    notifyListeners();
  }

  /// Clears debug prayer override
  void clearDebugOverride() {
    if (!kDebugMode) return; // Only works in debug mode
    if (_debugOverridePrayer == null) return;
    _debugOverridePrayer = null;
    _updateSystemUiOverlay();
    notifyListeners();
  }

  /// Gets the effective prayer type considering debug override
  PrayerType? _getEffectivePrayerType() {
    if (kDebugMode && _debugOverridePrayer != null) {
      return _debugOverridePrayer;
    }
    return _currentPrayer?.prayerType;
  }

  void _updateSystemUiOverlay() {
    // Use prayer-specific brightness if prayer type is available
    SystemUiOverlayStyle overlayStyle = _currentTheme.systemUiOverlayStyle;
    
    final effectivePrayerType = _getEffectivePrayerType();
    if (effectivePrayerType != null) {
      final prayerColors = _currentTheme.prayerColorScheme
          .getColorsForPrayer(effectivePrayerType);
      
      overlayStyle = overlayStyle.copyWith(
        statusBarIconBrightness: prayerColors.brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        statusBarBrightness: prayerColors.brightness,
        systemNavigationBarIconBrightness: prayerColors.brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
      );
    }
    
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }

  // Convenience getters for commonly used colors
  /// Gets prayer-specific background color if current prayer is set, otherwise default
  Color get backgroundColor {
    final effectivePrayerType = _getEffectivePrayerType();
    if (effectivePrayerType != null) {
      return _currentTheme.prayerColorScheme
          .getColorsForPrayer(effectivePrayerType)
          .backgroundColor;
    }
    return _currentTheme.backgroundColor;
  }

  Color get primaryColor => _currentTheme.primaryColor;
  
  /// Gets prayer-specific card background color if current prayer is set
  Color get cardBackgroundColor {
    final effectivePrayerType = _getEffectivePrayerType();
    if (effectivePrayerType != null) {
      return _currentTheme.prayerColorScheme
          .getColorsForPrayer(effectivePrayerType)
          .cardBackgroundColor;
    }
    return _currentTheme.cardBackgroundColor;
  }

  /// Gets prayer-specific primary text color if current prayer is set
  Color get primaryTextColor {
    final effectivePrayerType = _getEffectivePrayerType();
    if (effectivePrayerType != null) {
      return _currentTheme.prayerColorScheme
          .getColorsForPrayer(effectivePrayerType)
          .primaryTextColor;
    }
    return _currentTheme.primaryTextColor;
  }

  /// Gets prayer-specific secondary text color if current prayer is set
  Color get secondaryTextColor {
    final effectivePrayerType = _getEffectivePrayerType();
    if (effectivePrayerType != null) {
      return _currentTheme.prayerColorScheme
          .getColorsForPrayer(effectivePrayerType)
          .secondaryTextColor;
    }
    return _currentTheme.secondaryTextColor;
  }

  /// Gets prayer-specific divider color if current prayer is set
  Color get dividerColor {
    final effectivePrayerType = _getEffectivePrayerType();
    if (effectivePrayerType != null) {
      return _currentTheme.prayerColorScheme
          .getColorsForPrayer(effectivePrayerType)
          .dividerColor;
    }
    return _currentTheme.dividerColor;
  }

  Color get errorColor => _currentTheme.errorColor;
  Color get successColor => _currentTheme.successColor;
  Color get loadingBackgroundColor => _currentTheme.loadingBackgroundColor;
  
  // Helper methods to get theme-aware colors for specific use cases
  Color getCurrentPrayerTextColor() => primaryTextColor;
  Color getInactivePrayerTextColor() => secondaryTextColor;

  /// Gets colors for a specific prayer type
  PrayerColors getColorsForPrayer(PrayerType prayerType) {
    return _currentTheme.prayerColorScheme.getColorsForPrayer(prayerType);
  }

  /// Gets colors for a specific prayer
  PrayerColors? getColorsForPrayerModel(Prayer prayer) {
    if (prayer.prayerType != null) {
      return getColorsForPrayer(prayer.prayerType!);
    }
    return null;
  }
}