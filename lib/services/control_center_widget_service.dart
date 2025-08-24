import 'package:flutter/services.dart';
import 'dart:async';

class ControlCenterWidgetService {
  static const platform = MethodChannel('com.assetworks.controlcenter');
  static final ControlCenterWidgetService _instance = ControlCenterWidgetService._internal();
  
  factory ControlCenterWidgetService() => _instance;
  ControlCenterWidgetService._internal();
  
  final _widgetController = StreamController<ControlCenterEvent>.broadcast();
  Stream<ControlCenterEvent> get widgetStream => _widgetController.stream;
  
  // Initialize Control Center widgets
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeControlCenterWidgets');
      _listenToWidgetEvents();
      await _registerDefaultWidgets();
    } catch (e) {
      print('Failed to initialize Control Center widgets: $e');
    }
  }
  
  // Register Control Center widgets
  Future<void> registerWidgets({
    required List<ControlCenterWidget> widgets,
  }) async {
    try {
      await platform.invokeMethod('registerControlCenterWidgets', {
        'widgets': widgets.map((w) => w.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to register Control Center widgets: $e');
    }
  }
  
  // Register default widgets
  Future<void> _registerDefaultWidgets() async {
    final widgets = [
      ControlCenterWidget(
        id: 'portfolio_quick_view',
        title: 'Portfolio',
        icon: 'chart.line.uptrend.xyaxis',
        type: ControlCenterWidgetType.toggle,
        action: ControlCenterAction.viewPortfolio,
        configuration: {
          'showValue': true,
          'showChange': true,
          'updateInterval': 60, // seconds
        },
      ),
      ControlCenterWidget(
        id: 'quick_trade',
        title: 'Quick Trade',
        icon: 'arrow.left.arrow.right',
        type: ControlCenterWidgetType.button,
        action: ControlCenterAction.openTrade,
        configuration: {
          'defaultSymbol': 'AAPL',
          'defaultAction': 'buy',
        },
      ),
      ControlCenterWidget(
        id: 'market_status',
        title: 'Market Status',
        icon: 'clock',
        type: ControlCenterWidgetType.display,
        action: ControlCenterAction.viewMarketStatus,
        configuration: {
          'showCountdown': true,
          'showIndices': true,
        },
      ),
      ControlCenterWidget(
        id: 'price_alerts',
        title: 'Price Alerts',
        icon: 'bell',
        type: ControlCenterWidgetType.toggle,
        action: ControlCenterAction.toggleAlerts,
        configuration: {
          'enabled': true,
          'soundEnabled': true,
        },
      ),
      ControlCenterWidget(
        id: 'watchlist_sync',
        title: 'Sync Watchlist',
        icon: 'arrow.clockwise',
        type: ControlCenterWidgetType.button,
        action: ControlCenterAction.syncData,
        configuration: {
          'autoSync': true,
          'syncInterval': 300, // seconds
        },
      ),
      ControlCenterWidget(
        id: 'dark_mode',
        title: 'Dark Mode',
        icon: 'moon',
        type: ControlCenterWidgetType.toggle,
        action: ControlCenterAction.toggleDarkMode,
        configuration: {
          'followSystem': true,
        },
      ),
    ];
    
    await registerWidgets(widgets: widgets);
  }
  
  // Update widget data
  Future<void> updateWidgetData({
    required String widgetId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await platform.invokeMethod('updateControlCenterWidget', {
        'widgetId': widgetId,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to update Control Center widget: $e');
    }
  }
  
  // Update portfolio widget
  Future<void> updatePortfolioWidget({
    required double portfolioValue,
    required double dayChange,
    required double dayChangePercent,
  }) async {
    await updateWidgetData(
      widgetId: 'portfolio_quick_view',
      data: {
        'value': portfolioValue,
        'change': dayChange,
        'changePercent': dayChangePercent,
        'isPositive': dayChange >= 0,
      },
    );
  }
  
  // Update market status widget
  Future<void> updateMarketStatusWidget({
    required bool isOpen,
    required String status,
    required DateTime? nextOpen,
    required DateTime? nextClose,
  }) async {
    await updateWidgetData(
      widgetId: 'market_status',
      data: {
        'isOpen': isOpen,
        'status': status,
        'nextOpen': nextOpen?.toIso8601String(),
        'nextClose': nextClose?.toIso8601String(),
      },
    );
  }
  
  // Toggle widget state
  Future<void> toggleWidget({
    required String widgetId,
    required bool enabled,
  }) async {
    try {
      await platform.invokeMethod('toggleControlCenterWidget', {
        'widgetId': widgetId,
        'enabled': enabled,
      });
    } catch (e) {
      print('Failed to toggle Control Center widget: $e');
    }
  }
  
  // Handle widget interaction
  Future<void> handleWidgetInteraction({
    required String widgetId,
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await platform.invokeMethod('handleWidgetInteraction', {
        'widgetId': widgetId,
        'action': action,
        'parameters': parameters,
      });
    } catch (e) {
      print('Failed to handle widget interaction: $e');
    }
  }
  
  // Listen to widget events
  void _listenToWidgetEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onWidgetTapped':
          final widgetId = call.arguments['widgetId'];
          final action = call.arguments['action'];
          _widgetController.add(ControlCenterEvent(
            type: ControlCenterEventType.tapped,
            widgetId: widgetId,
            action: action,
            timestamp: DateTime.now(),
          ));
          _handleWidgetAction(widgetId, action);
          break;
          
        case 'onWidgetToggled':
          final widgetId = call.arguments['widgetId'];
          final enabled = call.arguments['enabled'];
          _widgetController.add(ControlCenterEvent(
            type: ControlCenterEventType.toggled,
            widgetId: widgetId,
            data: {'enabled': enabled},
            timestamp: DateTime.now(),
          ));
          break;
          
        case 'onWidgetLongPressed':
          final widgetId = call.arguments['widgetId'];
          _widgetController.add(ControlCenterEvent(
            type: ControlCenterEventType.longPressed,
            widgetId: widgetId,
            timestamp: DateTime.now(),
          ));
          break;
          
        case 'onWidgetForcePressed':
          final widgetId = call.arguments['widgetId'];
          _widgetController.add(ControlCenterEvent(
            type: ControlCenterEventType.forcePressed,
            widgetId: widgetId,
            timestamp: DateTime.now(),
          ));
          break;
      }
    });
  }
  
  // Handle widget action
  void _handleWidgetAction(String widgetId, String action) {
    switch (action) {
      case 'viewPortfolio':
        // Navigate to portfolio
        break;
      case 'openTrade':
        // Open trade screen
        break;
      case 'viewMarketStatus':
        // Show market status
        break;
      case 'toggleAlerts':
        // Toggle price alerts
        break;
      case 'syncData':
        // Sync data
        break;
      case 'toggleDarkMode':
        // Toggle dark mode
        break;
    }
  }
  
  // Get widget states
  Future<Map<String, bool>> getWidgetStates() async {
    try {
      final result = await platform.invokeMethod<Map>('getWidgetStates');
      return Map<String, bool>.from(result ?? {});
    } catch (e) {
      print('Failed to get widget states: $e');
      return {};
    }
  }
  
  // Remove widget
  Future<void> removeWidget(String widgetId) async {
    try {
      await platform.invokeMethod('removeControlCenterWidget', {
        'widgetId': widgetId,
      });
    } catch (e) {
      print('Failed to remove Control Center widget: $e');
    }
  }
  
  void dispose() {
    _widgetController.close();
  }
}

class ControlCenterWidget {
  final String id;
  final String title;
  final String icon;
  final ControlCenterWidgetType type;
  final ControlCenterAction action;
  final Map<String, dynamic> configuration;
  
  ControlCenterWidget({
    required this.id,
    required this.title,
    required this.icon,
    required this.type,
    required this.action,
    required this.configuration,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'icon': icon,
    'type': type.toString(),
    'action': action.toString(),
    'configuration': configuration,
  };
}

class ControlCenterEvent {
  final ControlCenterEventType type;
  final String? widgetId;
  final String? action;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  
  ControlCenterEvent({
    required this.type,
    this.widgetId,
    this.action,
    this.data,
    required this.timestamp,
  });
}

enum ControlCenterWidgetType {
  button,
  toggle,
  slider,
  display,
  expandable,
}

enum ControlCenterAction {
  viewPortfolio,
  openTrade,
  viewMarketStatus,
  toggleAlerts,
  syncData,
  toggleDarkMode,
  viewWatchlist,
  openSettings,
  custom,
}

enum ControlCenterEventType {
  tapped,
  toggled,
  longPressed,
  forcePressed,
  expanded,
  sliderChanged,
}