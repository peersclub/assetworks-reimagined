import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

/// Home Widget Service for iOS 18
/// Manages home screen widgets for AssetWorks
class HomeWidgetService extends GetxService {
  static HomeWidgetService get to => Get.find();

  // Widget identifiers
  static const String appGroupId = 'group.com.assetworks.widgets';
  static const String smallWidgetId = 'AssetWorksSmallWidget';
  static const String mediumWidgetId = 'AssetWorksMediumWidget';
  static const String largeWidgetId = 'AssetWorksLargeWidget';

  // Observable states
  final RxBool isConfigured = false.obs;
  final RxString lastUpdate = ''.obs;
  final RxMap<String, dynamic> widgetData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeHomeWidget();
  }
  
  /// Public initialize method for manual initialization
  Future<void> initialize() async {
    await _initializeHomeWidget();
  }

  Future<void> _initializeHomeWidget() async {
    try {
      // Configure app group for data sharing
      await HomeWidget.setAppGroupId(appGroupId);
      
      // Register background callback
      await HomeWidget.registerBackgroundCallback(backgroundCallback);
      
      isConfigured.value = true;
      print('Home Widget Service Initialized');
      
      // Update widget with initial data
      await updatePortfolioWidget();
    } catch (e) {
      print('Home Widget initialization error: $e');
    }
  }

  /// Update portfolio summary widget
  Future<void> updatePortfolioWidget({
    double? totalValue,
    double? dayChange,
    double? percentChange,
    int? widgetCount,
  }) async {
    try {
      final data = {
        'totalValue': totalValue ?? 125430.50,
        'dayChange': dayChange ?? 1543.25,
        'percentChange': percentChange ?? 12.5,
        'widgetCount': widgetCount ?? 8,
        'lastUpdate': DateTime.now().toIso8601String(),
      };

      // Save data to shared preferences
      await HomeWidget.saveWidgetData<double>('totalValue', data['totalValue'] as double);
      await HomeWidget.saveWidgetData<double>('dayChange', data['dayChange'] as double);
      await HomeWidget.saveWidgetData<double>('percentChange', data['percentChange'] as double);
      await HomeWidget.saveWidgetData<int>('widgetCount', data['widgetCount'] as int);
      await HomeWidget.saveWidgetData<String>('lastUpdate', data['lastUpdate'] as String);

      // Update all widget sizes
      await HomeWidget.updateWidget(
        name: smallWidgetId,
        iOSName: smallWidgetId,
      );
      await HomeWidget.updateWidget(
        name: mediumWidgetId,
        iOSName: mediumWidgetId,
      );
      await HomeWidget.updateWidget(
        name: largeWidgetId,
        iOSName: largeWidgetId,
      );

      widgetData.value = data;
      lastUpdate.value = DateTime.now().toString();
      
      print('Home widgets updated successfully');
    } catch (e) {
      print('Error updating home widgets: $e');
    }
  }

  /// Update quick stats widget
  Future<void> updateQuickStatsWidget({
    required Map<String, dynamic> stats,
  }) async {
    try {
      // Save each stat
      stats.forEach((key, value) async {
        if (value is int) {
          await HomeWidget.saveWidgetData<int>(key, value);
        } else if (value is double) {
          await HomeWidget.saveWidgetData<double>(key, value);
        } else if (value is String) {
          await HomeWidget.saveWidgetData<String>(key, value);
        } else if (value is bool) {
          await HomeWidget.saveWidgetData<bool>(key, value);
        }
      });

      // Update widget
      await HomeWidget.updateWidget(
        name: mediumWidgetId,
        iOSName: mediumWidgetId,
      );

      print('Quick stats widget updated');
    } catch (e) {
      print('Error updating quick stats widget: $e');
    }
  }

  /// Update recent activity widget
  Future<void> updateRecentActivityWidget({
    required List<Map<String, dynamic>> activities,
  }) async {
    try {
      // Convert activities to JSON string
      final activitiesJson = activities.map((a) => {
        'title': a['title'],
        'time': a['time'],
        'icon': a['icon'],
      }).toList();

      // Save activities (max 5 for widget display)
      final recentActivities = activitiesJson.take(5).toList();
      
      for (int i = 0; i < recentActivities.length; i++) {
        await HomeWidget.saveWidgetData<String>(
          'activity_$i', 
          '${recentActivities[i]['title']}|${recentActivities[i]['time']}'
        );
      }

      // Update widget
      await HomeWidget.updateWidget(
        name: largeWidgetId,
        iOSName: largeWidgetId,
      );

      print('Recent activity widget updated');
    } catch (e) {
      print('Error updating recent activity widget: $e');
    }
  }

  /// Handle widget tap
  Future<void> handleWidgetTap(Uri? uri) async {
    if (uri == null) return;

    final path = uri.path;
    final queryParams = uri.queryParameters;

    print('Widget tapped: $path with params: $queryParams');

    // Navigate based on widget action
    switch (path) {
      case '/dashboard':
        Get.toNamed('/main');
        break;
      case '/create':
        Get.toNamed('/create');
        break;
      case '/widget':
        final widgetId = queryParams['id'];
        if (widgetId != null) {
          Get.toNamed('/widget/$widgetId');
        }
        break;
      default:
        Get.toNamed('/main');
    }
  }

  /// Pin widget to home screen (iOS 14+)
  Future<void> requestPinWidget() async {
    try {
      // This shows the widget gallery for the user to add
      await HomeWidget.requestPinWidget(
        name: mediumWidgetId,
      );
    } catch (e) {
      print('Error requesting pin widget: $e');
    }
  }

  /// Get widget installation status
  Future<bool> isWidgetInstalled() async {
    try {
      // Check if any widget is installed
      final installed = await HomeWidget.getInstalledWidgets();
      return installed?.isNotEmpty ?? false;
    } catch (e) {
      print('Error checking widget installation: $e');
      return false;
    }
  }

  /// Background callback for widget updates
  static Future<void> backgroundCallback(Uri? uri) async {
    print('Background callback triggered: $uri');
    
    // Handle background updates
    if (uri?.path == '/refresh') {
      // Refresh widget data in background
      await Get.find<HomeWidgetService>().updatePortfolioWidget();
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}

/// Widget Configuration Models
class WidgetConfiguration {
  final String id;
  final String name;
  final WidgetSize size;
  final Map<String, dynamic> data;

  WidgetConfiguration({
    required this.id,
    required this.name,
    required this.size,
    required this.data,
  });
}

enum WidgetSize {
  small,  // 2x2
  medium, // 4x2
  large,  // 4x4
}

/// Widget Data Models
class PortfolioWidgetData {
  final double totalValue;
  final double dayChange;
  final double percentChange;
  final bool isPositive;
  final DateTime lastUpdate;

  PortfolioWidgetData({
    required this.totalValue,
    required this.dayChange,
    required this.percentChange,
    required this.isPositive,
    required this.lastUpdate,
  });

  Map<String, dynamic> toJson() => {
    'totalValue': totalValue,
    'dayChange': dayChange,
    'percentChange': percentChange,
    'isPositive': isPositive,
    'lastUpdate': lastUpdate.toIso8601String(),
  };
}

class QuickStatsWidgetData {
  final int widgetCount;
  final int viewCount;
  final int likeCount;
  final double growthRate;

  QuickStatsWidgetData({
    required this.widgetCount,
    required this.viewCount,
    required this.likeCount,
    required this.growthRate,
  });

  Map<String, dynamic> toJson() => {
    'widgetCount': widgetCount,
    'viewCount': viewCount,
    'likeCount': likeCount,
    'growthRate': growthRate,
  };
}

class ActivityWidgetData {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String icon;

  ActivityWidgetData({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'timestamp': timestamp.toIso8601String(),
    'icon': icon,
  };
}