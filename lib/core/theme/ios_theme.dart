import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// iOS 18 Theme System for AssetWorks
class iOS18Theme {
  // Singleton pattern
  static final iOS18Theme _instance = iOS18Theme._internal();
  factory iOS18Theme() => _instance;
  iOS18Theme._internal();

  // Theme colors matching iOS 18
  static const CupertinoThemeData lightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: CupertinoColors.systemBlue,
    primaryContrastingColor: CupertinoColors.white,
    scaffoldBackgroundColor: CupertinoColors.systemBackground,
    barBackgroundColor: _lightBarBackground,
    textTheme: CupertinoTextThemeData(
      primaryColor: CupertinoColors.label,
      textStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 17,
        color: CupertinoColors.label,
      ),
      actionTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 17,
        color: CupertinoColors.systemBlue,
      ),
      tabLabelTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 10,
        color: CupertinoColors.inactiveGray,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.label,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.label,
      ),
      navActionTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        color: CupertinoColors.systemBlue,
      ),
      pickerTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 21,
        color: CupertinoColors.label,
      ),
      dateTimePickerTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 21,
        color: CupertinoColors.label,
      ),
    ),
  );

  static const CupertinoThemeData darkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: CupertinoColors.systemBlue,
    primaryContrastingColor: CupertinoColors.black,
    scaffoldBackgroundColor: CupertinoColors.systemBackground,
    barBackgroundColor: _darkBarBackground,
    textTheme: CupertinoTextThemeData(
      primaryColor: CupertinoColors.label,
      textStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 17,
        color: CupertinoColors.label,
      ),
      actionTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 17,
        color: CupertinoColors.systemBlue,
      ),
      tabLabelTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 10,
        color: CupertinoColors.inactiveGray,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.label,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.label,
      ),
      navActionTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        color: CupertinoColors.systemBlue,
      ),
      pickerTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 21,
        color: CupertinoColors.label,
      ),
      dateTimePickerTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 21,
        color: CupertinoColors.label,
      ),
    ),
  );

  // Custom colors for iOS 18
  static const Color _lightBarBackground = Color(0xF0F9F9F9);
  static const Color _darkBarBackground = Color(0xF01D1D1D);

  // iOS 18 System Colors
  static const systemBlue = CupertinoColors.systemBlue;
  static const systemGreen = CupertinoColors.systemGreen;
  static const systemIndigo = CupertinoColors.systemIndigo;
  static const systemOrange = CupertinoColors.systemOrange;
  static const systemPink = CupertinoColors.systemPink;
  static const systemPurple = CupertinoColors.systemPurple;
  static const systemRed = CupertinoColors.systemRed;
  static const systemTeal = CupertinoColors.systemTeal;
  static const systemYellow = CupertinoColors.systemYellow;
  static const systemGray = CupertinoColors.systemGrey;
  static const systemGray2 = CupertinoColors.systemGrey2;
  static const systemGray3 = CupertinoColors.systemGrey3;
  static const systemGray4 = CupertinoColors.systemGrey4;
  static const systemGray5 = CupertinoColors.systemGrey5;
  static const systemGray6 = CupertinoColors.systemGrey6;

  // Background Colors
  static const systemBackground = CupertinoColors.systemBackground;
  static const secondarySystemBackground = CupertinoColors.secondarySystemBackground;
  static const tertiarySystemBackground = CupertinoColors.tertiarySystemBackground;
  static const systemGroupedBackground = CupertinoColors.systemGroupedBackground;
  static const secondarySystemGroupedBackground = CupertinoColors.secondarySystemGroupedBackground;
  static const tertiarySystemGroupedBackground = CupertinoColors.tertiarySystemGroupedBackground;

  // Fill Colors
  static const systemFill = CupertinoColors.systemFill;
  static const secondarySystemFill = CupertinoColors.secondarySystemFill;
  static const tertiarySystemFill = CupertinoColors.tertiarySystemFill;
  static const quaternarySystemFill = CupertinoColors.quaternarySystemFill;

  // Label Colors
  static const label = CupertinoColors.label;
  static const secondaryLabel = CupertinoColors.secondaryLabel;
  static const tertiaryLabel = CupertinoColors.tertiaryLabel;
  static const quaternaryLabel = CupertinoColors.quaternaryLabel;
  static const placeholderText = CupertinoColors.placeholderText;

  // Separator Colors
  static const separator = CupertinoColors.separator;
  static const opaqueSeparator = CupertinoColors.opaqueSeparator;

  // Link Color
  static const link = CupertinoColors.link;

  // iOS 18 Blur Effects
  static const double regularBlur = 20.0;
  static const double prominentBlur = 30.0;
  static const double thickBlur = 40.0;
  static const double ultraThinBlur = 10.0;

  // iOS 18 Corner Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 20.0;
  static const double continuousRadius = 38.0;

  // iOS 18 Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // iOS 18 Typography
  static const TextStyle largeTitle = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 34,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.41,
  );

  static const TextStyle title1 = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 28,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.36,
  );

  static const TextStyle title2 = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 22,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.35,
  );

  static const TextStyle title3 = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 20,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.38,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  static const TextStyle body = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 17,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.41,
  );

  static const TextStyle callout = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.32,
  );

  static const TextStyle subheadline = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 15,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.24,
  );

  static const TextStyle footnote = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.08,
  );

  static const TextStyle caption1 = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  );

  static const TextStyle caption2 = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.07,
  );

  // Haptic Feedback
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  static void vibrate() {
    HapticFeedback.vibrate();
  }

  // iOS 18 Transitions
  static const Duration quickTransition = Duration(milliseconds: 200);
  static const Duration normalTransition = Duration(milliseconds: 350);
  static const Duration slowTransition = Duration(milliseconds: 500);

  // iOS 18 Curves
  static const Curve springCurve = Curves.easeOutBack;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;
}