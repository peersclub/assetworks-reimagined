import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class HomeWidgetSmall {
  static const String widgetName = 'AssetWorksSmallWidget';
  static const String widgetId = 'com.assetworks.widget.small';
  static const platform = MethodChannel('com.assetworks.homewidget/small');
  
  // Widget data keys
  static const String keyPortfolioValue = 'portfolio_value';
  static const String keyDayChange = 'day_change';
  static const String keyDayChangePercent = 'day_change_percent';
  static const String keyLastUpdate = 'last_update';
  static const String keyTheme = 'theme';
  static const String keyAccentColor = 'accent_color';
  
  // Initialize small widget
  static Future<void> initialize() async {
    try {
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId('group.com.assetworks.widgets');
      }
      
      await _registerWidget();
      await _setupDefaultData();
      print('Small home widget initialized');
    } catch (e) {
      print('Failed to initialize small widget: $e');
    }
  }
  
  // Register widget with system
  static Future<void> _registerWidget() async {
    try {
      await platform.invokeMethod('registerWidget', {
        'widgetId': widgetId,
        'widgetName': widgetName,
        'size': 'small',
      });
    } catch (e) {
      print('Failed to register widget: $e');
    }
  }
  
  // Setup default widget data
  static Future<void> _setupDefaultData() async {
    await updatePortfolioData(
      portfolioValue: 0.0,
      dayChange: 0.0,
      dayChangePercent: 0.0,
    );
  }
  
  // Update portfolio data
  static Future<void> updatePortfolioData({
    required double portfolioValue,
    required double dayChange,
    required double dayChangePercent,
  }) async {
    try {
      await HomeWidget.saveWidgetData<double>(keyPortfolioValue, portfolioValue);
      await HomeWidget.saveWidgetData<double>(keyDayChange, dayChange);
      await HomeWidget.saveWidgetData<double>(keyDayChangePercent, dayChangePercent);
      await HomeWidget.saveWidgetData<String>(
        keyLastUpdate,
        DateTime.now().toIso8601String(),
      );
      
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
      );
      
      // Send update to native
      await platform.invokeMethod('updateData', {
        'portfolioValue': portfolioValue,
        'dayChange': dayChange,
        'dayChangePercent': dayChangePercent,
        'lastUpdate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to update portfolio data: $e');
    }
  }
  
  // Update theme
  static Future<void> updateTheme({
    required bool isDarkMode,
    String? accentColor,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        keyTheme,
        isDarkMode ? 'dark' : 'light',
      );
      
      if (accentColor != null) {
        await HomeWidget.saveWidgetData<String>(keyAccentColor, accentColor);
      }
      
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
      );
    } catch (e) {
      print('Failed to update theme: $e');
    }
  }
  
  // Configure widget tap action
  static Future<void> configureTapAction({
    required String targetRoute,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final uri = Uri(
        scheme: 'assetworks',
        host: 'app',
        path: targetRoute,
        queryParameters: parameters?.map((key, value) => 
          MapEntry(key, value.toString())),
      );
      
      await HomeWidget.registerInteractivityCallback(
        _handleWidgetTap,
      );
      
      await platform.invokeMethod('configureTapAction', {
        'uri': uri.toString(),
      });
    } catch (e) {
      print('Failed to configure tap action: $e');
    }
  }
  
  // Handle widget tap
  static Future<void> _handleWidgetTap(Uri? uri) async {
    if (uri == null) return;
    
    print('Widget tapped with URI: $uri');
    
    // Parse URI and navigate
    final path = uri.path;
    final params = uri.queryParameters;
    
    // Handle navigation based on path
    switch (path) {
      case '/dashboard':
        // Navigate to dashboard
        break;
      case '/portfolio':
        // Navigate to portfolio
        break;
      case '/stock':
        final symbol = params['symbol'];
        // Navigate to stock details
        break;
      default:
        // Default navigation
        break;
    }
  }
  
  // Request widget update
  static Future<void> requestUpdate() async {
    try {
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
      );
    } catch (e) {
      print('Failed to request widget update: $e');
    }
  }
  
  // Get widget installation status
  static Future<bool> isWidgetInstalled() async {
    try {
      final result = await platform.invokeMethod<bool>('isWidgetInstalled');
      return result ?? false;
    } catch (e) {
      print('Failed to check widget installation: $e');
      return false;
    }
  }
  
  // Pin widget to home screen
  static Future<void> pinToHomeScreen() async {
    try {
      await platform.invokeMethod('pinWidget');
    } catch (e) {
      print('Failed to pin widget: $e');
    }
  }
}

// Small widget configuration
class SmallWidgetConfiguration {
  final bool showPortfolioValue;
  final bool showDayChange;
  final bool showPercentChange;
  final bool showSparkline;
  final String displayMode; // 'compact', 'detailed'
  final String colorScheme; // 'green_red', 'blue_orange', 'monochrome'
  final bool autoRefresh;
  final int refreshIntervalMinutes;
  
  const SmallWidgetConfiguration({
    this.showPortfolioValue = true,
    this.showDayChange = true,
    this.showPercentChange = true,
    this.showSparkline = false,
    this.displayMode = 'compact',
    this.colorScheme = 'green_red',
    this.autoRefresh = true,
    this.refreshIntervalMinutes = 5,
  });
  
  Map<String, dynamic> toJson() => {
    'showPortfolioValue': showPortfolioValue,
    'showDayChange': showDayChange,
    'showPercentChange': showPercentChange,
    'showSparkline': showSparkline,
    'displayMode': displayMode,
    'colorScheme': colorScheme,
    'autoRefresh': autoRefresh,
    'refreshIntervalMinutes': refreshIntervalMinutes,
  };
  
  factory SmallWidgetConfiguration.fromJson(Map<String, dynamic> json) {
    return SmallWidgetConfiguration(
      showPortfolioValue: json['showPortfolioValue'] ?? true,
      showDayChange: json['showDayChange'] ?? true,
      showPercentChange: json['showPercentChange'] ?? true,
      showSparkline: json['showSparkline'] ?? false,
      displayMode: json['displayMode'] ?? 'compact',
      colorScheme: json['colorScheme'] ?? 'green_red',
      autoRefresh: json['autoRefresh'] ?? true,
      refreshIntervalMinutes: json['refreshIntervalMinutes'] ?? 5,
    );
  }
  
  // Apply configuration to widget
  Future<void> apply() async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'configuration',
        jsonEncode(toJson()),
      );
      await HomeWidget.updateWidget(
        name: HomeWidgetSmall.widgetName,
        iOSName: HomeWidgetSmall.widgetName,
      );
    } catch (e) {
      print('Failed to apply configuration: $e');
    }
  }
}

// Small widget data model
class SmallWidgetData {
  final double portfolioValue;
  final double dayChange;
  final double dayChangePercent;
  final DateTime lastUpdate;
  final List<double>? sparklineData;
  
  SmallWidgetData({
    required this.portfolioValue,
    required this.dayChange,
    required this.dayChangePercent,
    required this.lastUpdate,
    this.sparklineData,
  });
  
  Map<String, dynamic> toJson() => {
    'portfolioValue': portfolioValue,
    'dayChange': dayChange,
    'dayChangePercent': dayChangePercent,
    'lastUpdate': lastUpdate.toIso8601String(),
    'sparklineData': sparklineData,
  };
  
  factory SmallWidgetData.fromJson(Map<String, dynamic> json) {
    return SmallWidgetData(
      portfolioValue: json['portfolioValue'] ?? 0.0,
      dayChange: json['dayChange'] ?? 0.0,
      dayChangePercent: json['dayChangePercent'] ?? 0.0,
      lastUpdate: DateTime.parse(json['lastUpdate'] ?? DateTime.now().toIso8601String()),
      sparklineData: json['sparklineData'] != null
          ? List<double>.from(json['sparklineData'])
          : null,
    );
  }
  
  // Update widget with this data
  Future<void> updateWidget() async {
    await HomeWidgetSmall.updatePortfolioData(
      portfolioValue: portfolioValue,
      dayChange: dayChange,
      dayChangePercent: dayChangePercent,
    );
    
    if (sparklineData != null) {
      await HomeWidget.saveWidgetData<String>(
        'sparklineData',
        jsonEncode(sparklineData),
      );
    }
  }
}