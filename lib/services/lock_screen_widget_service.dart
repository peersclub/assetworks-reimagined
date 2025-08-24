import 'package:flutter/services.dart';
import 'dart:async';

class LockScreenWidgetService {
  static const platform = MethodChannel('com.assetworks.lockscreen');
  static final LockScreenWidgetService _instance = LockScreenWidgetService._internal();
  
  factory LockScreenWidgetService() => _instance;
  LockScreenWidgetService._internal();
  
  final _widgetController = StreamController<LockScreenEvent>.broadcast();
  Stream<LockScreenEvent> get widgetStream => _widgetController.stream;
  
  // Initialize Lock Screen widgets
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeLockScreenWidgets');
      _listenToWidgetEvents();
      await _configureDefaultWidgets();
    } catch (e) {
      print('Failed to initialize Lock Screen widgets: $e');
    }
  }
  
  // Configure Lock Screen widgets
  Future<void> configureWidgets({
    required List<LockScreenWidget> widgets,
  }) async {
    try {
      await platform.invokeMethod('configureLockScreenWidgets', {
        'widgets': widgets.map((w) => w.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to configure Lock Screen widgets: $e');
    }
  }
  
  // Configure default widgets
  Future<void> _configureDefaultWidgets() async {
    final widgets = [
      LockScreenWidget(
        id: 'portfolio_summary',
        type: LockScreenWidgetType.circular,
        position: LockScreenPosition.topLeft,
        configuration: LockScreenConfiguration(
          title: 'Portfolio',
          updateInterval: const Duration(minutes: 1),
          showProgressRing: true,
          showIcon: true,
          icon: 'chart.line.uptrend.xyaxis',
          primaryColor: '#007AFF',
          accentColor: '#34C759',
        ),
      ),
      LockScreenWidget(
        id: 'market_countdown',
        type: LockScreenWidgetType.rectangular,
        position: LockScreenPosition.topRight,
        configuration: LockScreenConfiguration(
          title: 'Market Opens',
          updateInterval: const Duration(seconds: 30),
          showCountdown: true,
          showIcon: true,
          icon: 'clock',
          primaryColor: '#FF9500',
        ),
      ),
      LockScreenWidget(
        id: 'top_movers',
        type: LockScreenWidgetType.inline,
        position: LockScreenPosition.belowTime,
        configuration: LockScreenConfiguration(
          title: 'Top Movers',
          updateInterval: const Duration(minutes: 5),
          maxItems: 3,
          showIcon: false,
          scrollable: true,
        ),
      ),
      LockScreenWidget(
        id: 'watchlist_mini',
        type: LockScreenWidgetType.rectangular,
        position: LockScreenPosition.aboveNotifications,
        configuration: LockScreenConfiguration(
          title: 'Watchlist',
          updateInterval: const Duration(minutes: 2),
          maxItems: 5,
          showIcon: true,
          icon: 'star',
          primaryColor: '#5856D6',
        ),
      ),
    ];
    
    await configureWidgets(widgets: widgets);
  }
  
  // Update widget data
  Future<void> updateWidgetData({
    required String widgetId,
    required LockScreenWidgetData data,
  }) async {
    try {
      await platform.invokeMethod('updateLockScreenWidget', {
        'widgetId': widgetId,
        'data': data.toJson(),
      });
    } catch (e) {
      print('Failed to update Lock Screen widget: $e');
    }
  }
  
  // Update portfolio widget
  Future<void> updatePortfolioWidget({
    required double portfolioValue,
    required double dayChange,
    required double dayChangePercent,
    required double progress,
  }) async {
    await updateWidgetData(
      widgetId: 'portfolio_summary',
      data: LockScreenWidgetData(
        primaryText: '\$${portfolioValue.toStringAsFixed(2)}',
        secondaryText: '${dayChange >= 0 ? '+' : ''}${dayChangePercent.toStringAsFixed(2)}%',
        progress: progress,
        isPositive: dayChange >= 0,
        timestamp: DateTime.now(),
      ),
    );
  }
  
  // Update market countdown widget
  Future<void> updateMarketCountdownWidget({
    required bool isOpen,
    required Duration? timeUntilOpen,
    required Duration? timeUntilClose,
  }) async {
    String primaryText;
    String secondaryText;
    
    if (isOpen) {
      primaryText = 'Market Open';
      if (timeUntilClose != null) {
        final hours = timeUntilClose.inHours;
        final minutes = timeUntilClose.inMinutes % 60;
        secondaryText = 'Closes in ${hours}h ${minutes}m';
      } else {
        secondaryText = '';
      }
    } else {
      primaryText = 'Market Closed';
      if (timeUntilOpen != null) {
        final hours = timeUntilOpen.inHours;
        final minutes = timeUntilOpen.inMinutes % 60;
        secondaryText = 'Opens in ${hours}h ${minutes}m';
      } else {
        secondaryText = '';
      }
    }
    
    await updateWidgetData(
      widgetId: 'market_countdown',
      data: LockScreenWidgetData(
        primaryText: primaryText,
        secondaryText: secondaryText,
        isActive: isOpen,
        timestamp: DateTime.now(),
      ),
    );
  }
  
  // Update top movers widget
  Future<void> updateTopMoversWidget({
    required List<TopMover> movers,
  }) async {
    await updateWidgetData(
      widgetId: 'top_movers',
      data: LockScreenWidgetData(
        items: movers.map((m) => {
          'symbol': m.symbol,
          'change': m.changePercent,
          'isPositive': m.changePercent >= 0,
        }).toList(),
        timestamp: DateTime.now(),
      ),
    );
  }
  
  // Update watchlist widget
  Future<void> updateWatchlistWidget({
    required List<WatchlistItem> items,
  }) async {
    await updateWidgetData(
      widgetId: 'watchlist_mini',
      data: LockScreenWidgetData(
        items: items.map((item) => {
          'symbol': item.symbol,
          'price': item.price,
          'change': item.changePercent,
          'isPositive': item.changePercent >= 0,
        }).toList(),
        timestamp: DateTime.now(),
      ),
    );
  }
  
  // Set widget visibility
  Future<void> setWidgetVisibility({
    required String widgetId,
    required bool visible,
  }) async {
    try {
      await platform.invokeMethod('setLockScreenWidgetVisibility', {
        'widgetId': widgetId,
        'visible': visible,
      });
    } catch (e) {
      print('Failed to set widget visibility: $e');
    }
  }
  
  // Listen to widget events
  void _listenToWidgetEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onWidgetTapped':
          final widgetId = call.arguments['widgetId'];
          _widgetController.add(LockScreenEvent(
            type: LockScreenEventType.tapped,
            widgetId: widgetId,
            timestamp: DateTime.now(),
          ));
          _handleWidgetTap(widgetId);
          break;
          
        case 'onWidgetSwiped':
          final widgetId = call.arguments['widgetId'];
          final direction = call.arguments['direction'];
          _widgetController.add(LockScreenEvent(
            type: LockScreenEventType.swiped,
            widgetId: widgetId,
            data: {'direction': direction},
            timestamp: DateTime.now(),
          ));
          break;
          
        case 'onScreenUnlocked':
          _widgetController.add(LockScreenEvent(
            type: LockScreenEventType.unlocked,
            timestamp: DateTime.now(),
          ));
          break;
          
        case 'onScreenLocked':
          _widgetController.add(LockScreenEvent(
            type: LockScreenEventType.locked,
            timestamp: DateTime.now(),
          ));
          break;
      }
    });
  }
  
  // Handle widget tap
  void _handleWidgetTap(String widgetId) {
    switch (widgetId) {
      case 'portfolio_summary':
        // Deep link to portfolio
        break;
      case 'market_countdown':
        // Show market hours
        break;
      case 'top_movers':
        // Show top movers list
        break;
      case 'watchlist_mini':
        // Show watchlist
        break;
    }
  }
  
  // Get widget settings
  Future<Map<String, dynamic>> getWidgetSettings() async {
    try {
      final result = await platform.invokeMethod<Map>('getLockScreenWidgetSettings');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      print('Failed to get widget settings: $e');
      return {};
    }
  }
  
  // Remove widget
  Future<void> removeWidget(String widgetId) async {
    try {
      await platform.invokeMethod('removeLockScreenWidget', {
        'widgetId': widgetId,
      });
    } catch (e) {
      print('Failed to remove Lock Screen widget: $e');
    }
  }
  
  void dispose() {
    _widgetController.close();
  }
}

class LockScreenWidget {
  final String id;
  final LockScreenWidgetType type;
  final LockScreenPosition position;
  final LockScreenConfiguration configuration;
  
  LockScreenWidget({
    required this.id,
    required this.type,
    required this.position,
    required this.configuration,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'position': position.toString(),
    'configuration': configuration.toJson(),
  };
}

class LockScreenConfiguration {
  final String title;
  final Duration updateInterval;
  final bool showProgressRing;
  final bool showCountdown;
  final bool showIcon;
  final String? icon;
  final String? primaryColor;
  final String? accentColor;
  final int? maxItems;
  final bool scrollable;
  
  LockScreenConfiguration({
    required this.title,
    required this.updateInterval,
    this.showProgressRing = false,
    this.showCountdown = false,
    this.showIcon = true,
    this.icon,
    this.primaryColor,
    this.accentColor,
    this.maxItems,
    this.scrollable = false,
  });
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'updateInterval': updateInterval.inSeconds,
    'showProgressRing': showProgressRing,
    'showCountdown': showCountdown,
    'showIcon': showIcon,
    'icon': icon,
    'primaryColor': primaryColor,
    'accentColor': accentColor,
    'maxItems': maxItems,
    'scrollable': scrollable,
  };
}

class LockScreenWidgetData {
  final String? primaryText;
  final String? secondaryText;
  final double? progress;
  final bool? isPositive;
  final bool? isActive;
  final List<Map<String, dynamic>>? items;
  final DateTime timestamp;
  
  LockScreenWidgetData({
    this.primaryText,
    this.secondaryText,
    this.progress,
    this.isPositive,
    this.isActive,
    this.items,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'primaryText': primaryText,
    'secondaryText': secondaryText,
    'progress': progress,
    'isPositive': isPositive,
    'isActive': isActive,
    'items': items,
    'timestamp': timestamp.toIso8601String(),
  };
}

class LockScreenEvent {
  final LockScreenEventType type;
  final String? widgetId;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  
  LockScreenEvent({
    required this.type,
    this.widgetId,
    this.data,
    required this.timestamp,
  });
}

class TopMover {
  final String symbol;
  final double changePercent;
  
  TopMover({
    required this.symbol,
    required this.changePercent,
  });
}

class WatchlistItem {
  final String symbol;
  final double price;
  final double changePercent;
  
  WatchlistItem({
    required this.symbol,
    required this.price,
    required this.changePercent,
  });
}

enum LockScreenWidgetType {
  circular,
  rectangular,
  inline,
  accessory,
}

enum LockScreenPosition {
  topLeft,
  topRight,
  belowTime,
  aboveNotifications,
  bottom,
}

enum LockScreenEventType {
  tapped,
  swiped,
  locked,
  unlocked,
}