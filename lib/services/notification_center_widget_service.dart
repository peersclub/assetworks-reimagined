import 'package:flutter/services.dart';
import 'dart:async';

class NotificationCenterWidgetService {
  static const platform = MethodChannel('com.assetworks.notificationcenter');
  static final NotificationCenterWidgetService _instance = NotificationCenterWidgetService._internal();
  
  factory NotificationCenterWidgetService() => _instance;
  NotificationCenterWidgetService._internal();
  
  final _widgetController = StreamController<NotificationCenterEvent>.broadcast();
  Stream<NotificationCenterEvent> get widgetStream => _widgetController.stream;
  
  // Initialize Notification Center widgets
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeNotificationCenterWidgets');
      _listenToWidgetEvents();
      await _configureDefaultWidgets();
    } catch (e) {
      print('Failed to initialize Notification Center widgets: $e');
    }
  }
  
  // Configure Notification Center widgets
  Future<void> configureWidgets({
    required List<NotificationCenterWidget> widgets,
  }) async {
    try {
      await platform.invokeMethod('configureNotificationCenterWidgets', {
        'widgets': widgets.map((w) => w.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to configure Notification Center widgets: $e');
    }
  }
  
  // Configure default widgets
  Future<void> _configureDefaultWidgets() async {
    final widgets = [
      NotificationCenterWidget(
        id: 'portfolio_overview',
        title: 'Portfolio Overview',
        type: NotificationCenterWidgetType.expanded,
        priority: NotificationCenterPriority.high,
        configuration: {
          'showChart': true,
          'showPositions': true,
          'showPerformance': true,
          'updateInterval': 60,
        },
      ),
      NotificationCenterWidget(
        id: 'market_summary',
        title: 'Market Summary',
        type: NotificationCenterWidgetType.compact,
        priority: NotificationCenterPriority.medium,
        configuration: {
          'showIndices': true,
          'showVolume': true,
          'showTrend': true,
          'updateInterval': 30,
        },
      ),
      NotificationCenterWidget(
        id: 'recent_alerts',
        title: 'Recent Alerts',
        type: NotificationCenterWidgetType.list,
        priority: NotificationCenterPriority.high,
        configuration: {
          'maxItems': 5,
          'showTimestamp': true,
          'groupByType': true,
        },
      ),
      NotificationCenterWidget(
        id: 'quick_actions',
        title: 'Quick Actions',
        type: NotificationCenterWidgetType.actions,
        priority: NotificationCenterPriority.low,
        configuration: {
          'actions': ['trade', 'watchlist', 'portfolio', 'news'],
          'style': 'grid',
        },
      ),
      NotificationCenterWidget(
        id: 'news_feed',
        title: 'Market News',
        type: NotificationCenterWidgetType.feed,
        priority: NotificationCenterPriority.medium,
        configuration: {
          'maxItems': 10,
          'showImages': true,
          'categories': ['market', 'stocks', 'crypto'],
        },
      ),
    ];
    
    await configureWidgets(widgets: widgets);
  }
  
  // Update widget data
  Future<void> updateWidgetData({
    required String widgetId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await platform.invokeMethod('updateNotificationCenterWidget', {
        'widgetId': widgetId,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to update Notification Center widget: $e');
    }
  }
  
  // Update portfolio overview widget
  Future<void> updatePortfolioOverviewWidget({
    required double portfolioValue,
    required double dayChange,
    required double dayChangePercent,
    required List<PortfolioPosition> positions,
    required Map<String, List<double>> chartData,
  }) async {
    await updateWidgetData(
      widgetId: 'portfolio_overview',
      data: {
        'portfolioValue': portfolioValue,
        'dayChange': dayChange,
        'dayChangePercent': dayChangePercent,
        'positions': positions.map((p) => p.toJson()).toList(),
        'chartData': chartData,
        'lastUpdate': DateTime.now().toIso8601String(),
      },
    );
  }
  
  // Update market summary widget
  Future<void> updateMarketSummaryWidget({
    required List<MarketIndex> indices,
    required double totalVolume,
    required String marketTrend,
  }) async {
    await updateWidgetData(
      widgetId: 'market_summary',
      data: {
        'indices': indices.map((i) => i.toJson()).toList(),
        'totalVolume': totalVolume,
        'marketTrend': marketTrend,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  // Update recent alerts widget
  Future<void> updateRecentAlertsWidget({
    required List<Alert> alerts,
  }) async {
    await updateWidgetData(
      widgetId: 'recent_alerts',
      data: {
        'alerts': alerts.map((a) => a.toJson()).toList(),
        'unreadCount': alerts.where((a) => !a.isRead).length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  // Update news feed widget
  Future<void> updateNewsFeedWidget({
    required List<NewsItem> newsItems,
  }) async {
    await updateWidgetData(
      widgetId: 'news_feed',
      data: {
        'items': newsItems.map((n) => n.toJson()).toList(),
        'lastUpdate': DateTime.now().toIso8601String(),
      },
    );
  }
  
  // Handle widget action
  Future<void> handleWidgetAction({
    required String widgetId,
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await platform.invokeMethod('handleNotificationCenterAction', {
        'widgetId': widgetId,
        'action': action,
        'parameters': parameters,
      });
    } catch (e) {
      print('Failed to handle widget action: $e');
    }
  }
  
  // Set widget expanded state
  Future<void> setWidgetExpanded({
    required String widgetId,
    required bool expanded,
  }) async {
    try {
      await platform.invokeMethod('setNotificationCenterWidgetExpanded', {
        'widgetId': widgetId,
        'expanded': expanded,
      });
    } catch (e) {
      print('Failed to set widget expanded state: $e');
    }
  }
  
  // Listen to widget events
  void _listenToWidgetEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onWidgetTapped':
          final widgetId = call.arguments['widgetId'];
          _widgetController.add(NotificationCenterEvent(
            type: NotificationCenterEventType.tapped,
            widgetId: widgetId,
            timestamp: DateTime.now(),
          ));
          _handleWidgetTap(widgetId);
          break;
          
        case 'onWidgetExpanded':
          final widgetId = call.arguments['widgetId'];
          final expanded = call.arguments['expanded'];
          _widgetController.add(NotificationCenterEvent(
            type: NotificationCenterEventType.expanded,
            widgetId: widgetId,
            data: {'expanded': expanded},
            timestamp: DateTime.now(),
          ));
          break;
          
        case 'onActionTriggered':
          final widgetId = call.arguments['widgetId'];
          final action = call.arguments['action'];
          _widgetController.add(NotificationCenterEvent(
            type: NotificationCenterEventType.actionTriggered,
            widgetId: widgetId,
            action: action,
            timestamp: DateTime.now(),
          ));
          _handleAction(widgetId, action);
          break;
          
        case 'onRefreshRequested':
          final widgetId = call.arguments['widgetId'];
          _widgetController.add(NotificationCenterEvent(
            type: NotificationCenterEventType.refreshRequested,
            widgetId: widgetId,
            timestamp: DateTime.now(),
          ));
          _refreshWidget(widgetId);
          break;
      }
    });
  }
  
  // Handle widget tap
  void _handleWidgetTap(String widgetId) {
    switch (widgetId) {
      case 'portfolio_overview':
        // Navigate to portfolio
        break;
      case 'market_summary':
        // Navigate to market overview
        break;
      case 'recent_alerts':
        // Navigate to alerts
        break;
      case 'news_feed':
        // Navigate to news
        break;
    }
  }
  
  // Handle action
  void _handleAction(String widgetId, String action) {
    switch (action) {
      case 'trade':
        // Open trade screen
        break;
      case 'watchlist':
        // Open watchlist
        break;
      case 'portfolio':
        // Open portfolio
        break;
      case 'news':
        // Open news
        break;
    }
  }
  
  // Refresh widget
  Future<void> _refreshWidget(String widgetId) async {
    // Refresh widget data based on widgetId
    switch (widgetId) {
      case 'portfolio_overview':
        // Refresh portfolio data
        break;
      case 'market_summary':
        // Refresh market data
        break;
      case 'recent_alerts':
        // Refresh alerts
        break;
      case 'news_feed':
        // Refresh news
        break;
    }
  }
  
  // Get widget visibility
  Future<Map<String, bool>> getWidgetVisibility() async {
    try {
      final result = await platform.invokeMethod<Map>('getNotificationCenterWidgetVisibility');
      return Map<String, bool>.from(result ?? {});
    } catch (e) {
      print('Failed to get widget visibility: $e');
      return {};
    }
  }
  
  // Remove widget
  Future<void> removeWidget(String widgetId) async {
    try {
      await platform.invokeMethod('removeNotificationCenterWidget', {
        'widgetId': widgetId,
      });
    } catch (e) {
      print('Failed to remove Notification Center widget: $e');
    }
  }
  
  void dispose() {
    _widgetController.close();
  }
}

class NotificationCenterWidget {
  final String id;
  final String title;
  final NotificationCenterWidgetType type;
  final NotificationCenterPriority priority;
  final Map<String, dynamic> configuration;
  
  NotificationCenterWidget({
    required this.id,
    required this.title,
    required this.type,
    required this.priority,
    required this.configuration,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.toString(),
    'priority': priority.toString(),
    'configuration': configuration,
  };
}

class NotificationCenterEvent {
  final NotificationCenterEventType type;
  final String? widgetId;
  final String? action;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  
  NotificationCenterEvent({
    required this.type,
    this.widgetId,
    this.action,
    this.data,
    required this.timestamp,
  });
}

class PortfolioPosition {
  final String symbol;
  final double value;
  final double changePercent;
  
  PortfolioPosition({
    required this.symbol,
    required this.value,
    required this.changePercent,
  });
  
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'value': value,
    'changePercent': changePercent,
  };
}

class MarketIndex {
  final String name;
  final double value;
  final double change;
  final double changePercent;
  
  MarketIndex({
    required this.name,
    required this.value,
    required this.change,
    required this.changePercent,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'change': change,
    'changePercent': changePercent,
  };
}

class Alert {
  final String id;
  final String type;
  final String message;
  final bool isRead;
  final DateTime timestamp;
  
  Alert({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'message': message,
    'isRead': isRead,
    'timestamp': timestamp.toIso8601String(),
  };
}

class NewsItem {
  final String id;
  final String title;
  final String summary;
  final String? imageUrl;
  final String source;
  final DateTime publishedAt;
  
  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'imageUrl': imageUrl,
    'source': source,
    'publishedAt': publishedAt.toIso8601String(),
  };
}

enum NotificationCenterWidgetType {
  compact,
  expanded,
  list,
  actions,
  feed,
  chart,
}

enum NotificationCenterPriority {
  low,
  medium,
  high,
}

enum NotificationCenterEventType {
  tapped,
  expanded,
  actionTriggered,
  refreshRequested,
}