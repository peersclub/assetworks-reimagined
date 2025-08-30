import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Application Theme Configuration
class AppTheme {
  AppTheme._();
  
  // Colors
  static const Color primaryColor = CupertinoColors.systemIndigo;
  static const Color secondaryColor = CupertinoColors.systemPurple;
  static const Color errorColor = CupertinoColors.systemRed;
  static const Color successColor = CupertinoColors.systemGreen;
  static const Color warningColor = CupertinoColors.systemOrange;
  
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground.color,
    platform: TargetPlatform.iOS,
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.label,
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.label,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CupertinoColors.systemBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: CupertinoColors.label),
      titleTextStyle: TextStyle(
        color: CupertinoColors.label,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: CupertinoColors.systemBackground,
      background: CupertinoColors.systemGroupedBackground,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
  
  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: CupertinoColors.black,
    platform: TargetPlatform.iOS,
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: CupertinoColors.black,
      barBackgroundColor: CupertinoColors.darkBackgroundGray,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.white,
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.white,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.white,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      elevation: 0,
      iconTheme: IconThemeData(color: CupertinoColors.white),
      titleTextStyle: TextStyle(
        color: CupertinoColors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: CupertinoColors.darkBackgroundGray,
      background: CupertinoColors.black,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: CupertinoColors.white),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: CupertinoColors.white),
      displaySmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: CupertinoColors.white),
      headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: CupertinoColors.white),
      headlineMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.white),
      headlineSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: CupertinoColors.white),
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.normal, color: CupertinoColors.white),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: CupertinoColors.white),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: CupertinoColors.systemGrey),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: CupertinoColors.white),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CupertinoColors.white),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CupertinoColors.systemGrey),
    ),
  );
}