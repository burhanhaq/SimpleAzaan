import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/service/settings_service.dart';
import 'package:simple_azaan/themes/prayer_colors.dart';

class AppTheme {
  final Color backgroundColor;
  final Color primaryColor;
  final Color cardBackgroundColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color dividerColor;
  final Color errorColor;
  final Color successColor;
  final Color loadingBackgroundColor;
  final Brightness brightness;
  final SystemUiOverlayStyle systemUiOverlayStyle;
  final PrayerColorScheme prayerColorScheme;

  const AppTheme({
    required this.backgroundColor,
    required this.primaryColor,
    required this.cardBackgroundColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.dividerColor,
    required this.errorColor,
    required this.successColor,
    required this.loadingBackgroundColor,
    required this.brightness,
    required this.systemUiOverlayStyle,
    required this.prayerColorScheme,
  });

  ThemeData get themeData {
    return ThemeData(
      brightness: brightness,
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardBackgroundColor,
      dividerColor: dividerColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: brightness == Brightness.light ? Colors.white : Colors.black,
        secondary: primaryColor,
        onSecondary: brightness == Brightness.light ? Colors.white : Colors.black,
        error: errorColor,
        onError: Colors.white,
        surface: cardBackgroundColor,
        onSurface: primaryTextColor,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: primaryTextColor),
        displayMedium: TextStyle(color: primaryTextColor),
        displaySmall: TextStyle(color: primaryTextColor),
        headlineLarge: TextStyle(color: primaryTextColor),
        headlineMedium: TextStyle(color: primaryTextColor),
        headlineSmall: TextStyle(color: primaryTextColor),
        titleLarge: TextStyle(color: primaryTextColor),
        titleMedium: TextStyle(color: primaryTextColor),
        titleSmall: TextStyle(color: primaryTextColor),
        bodyLarge: TextStyle(color: primaryTextColor),
        bodyMedium: TextStyle(color: primaryTextColor),
        bodySmall: TextStyle(color: secondaryTextColor),
        labelLarge: TextStyle(color: primaryTextColor),
        labelMedium: TextStyle(color: secondaryTextColor),
        labelSmall: TextStyle(color: secondaryTextColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryTextColor,
        systemOverlayStyle: systemUiOverlayStyle,
      ),
    );
  }
}

class AppThemes {
  static const AppTheme light = AppTheme(
    backgroundColor: kLightAppBackgroundColor,
    primaryColor: kLightPrimaryColor,
    cardBackgroundColor: kLightCardBackgroundColor,
    primaryTextColor: kLightPrimaryTextColor,
    secondaryTextColor: kLightSecondaryTextColor,
    dividerColor: kLightDividerColor,
    errorColor: kLightErrorColor,
    successColor: kLightSuccessColor,
    loadingBackgroundColor: kLightLoadingBackgroundColor,
    brightness: Brightness.light,
    systemUiOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    prayerColorScheme: PrayerColorScheme.light,
  );

  static const AppTheme dark = AppTheme(
    backgroundColor: kDarkAppBackgroundColor,
    primaryColor: kDarkPrimaryColor,
    cardBackgroundColor: kDarkCardBackgroundColor,
    primaryTextColor: kDarkPrimaryTextColor,
    secondaryTextColor: kDarkSecondaryTextColor,
    dividerColor: kDarkDividerColor,
    errorColor: kDarkErrorColor,
    successColor: kDarkSuccessColor,
    loadingBackgroundColor: kDarkLoadingBackgroundColor,
    brightness: Brightness.dark,
    systemUiOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
    prayerColorScheme: PrayerColorScheme.dark,
  );

  static AppTheme getTheme(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return light;
      case AppThemeMode.dark:
        return dark;
      case AppThemeMode.dual:
        // For now, dual mode defaults to light
        // In the future, this could switch based on system preference or time of day
        return light;
    }
  }

  static List<AppThemeMode> get availableThemes => AppThemeMode.values;
  
  static String getThemeDisplayName(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.dual:
        return 'Dual';
    }
  }
}