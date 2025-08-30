import 'package:flutter/widgets.dart';

class ResponsiveUtils {
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = (size.width * size.width + size.height * size.height);
    final screenDiagonal = diagonal > 0 ? diagonal : 1;
    return screenDiagonal > 850000; // ~922px diagonal for iPad Mini
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 768;
  }

  static double getAdaptiveWidth(BuildContext context, {
    double phoneWidth = 1.0,
    double tabletWidth = 0.7,
    double maxWidth = 1200,
  }) {
    if (isTablet(context)) {
      final screenWidth = MediaQuery.of(context).size.width;
      final width = screenWidth * tabletWidth;
      return width > maxWidth ? maxWidth : width;
    }
    return MediaQuery.of(context).size.width * phoneWidth;
  }

  static int getGridColumns(BuildContext context, {
    int phoneColumns = 2,
    int tabletPortraitColumns = 3,
    int tabletLandscapeColumns = 4,
  }) {
    if (isTablet(context)) {
      return isLandscape(context) ? tabletLandscapeColumns : tabletPortraitColumns;
    }
    return phoneColumns;
  }

  static double getAdaptivePadding(BuildContext context, {
    double phonePadding = 16,
    double tabletPadding = 24,
  }) {
    return isTablet(context) ? tabletPadding : phonePadding;
  }

  static EdgeInsets getAdaptiveMargins(BuildContext context) {
    if (isTablet(context)) {
      final width = MediaQuery.of(context).size.width;
      if (width > 1024) {
        return EdgeInsets.symmetric(horizontal: width * 0.1);
      } else if (width > 768) {
        return EdgeInsets.symmetric(horizontal: width * 0.05);
      }
    }
    return EdgeInsets.zero;
  }

  static double getAdaptiveFontSize(BuildContext context, double baseSize) {
    if (isTablet(context)) {
      return baseSize * 1.1;
    }
    return baseSize;
  }

  static bool shouldShowSplitView(BuildContext context) {
    return isTablet(context) && isLandscape(context);
  }
}