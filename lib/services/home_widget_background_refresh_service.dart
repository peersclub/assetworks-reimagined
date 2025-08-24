import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:async';
import 'dart:convert';

// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('Background task started: $task');
    
    try {
      switch (task) {
        case 'widgetRefresh':
          await _performWidgetRefresh(inputData);
          break;
        case 'portfolioUpdate':
          await _updatePortfolioData(inputData);
          break;
        case 'marketDataSync':
          await _syncMarketData(inputData);
          break;
        case 'alertCheck':
          await _checkAlerts(inputData);
          break;
      }
      
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}

// Perform widget refresh
Future<void> _performWidgetRefresh(Map<String, dynamic>? inputData) async {
  // Fetch latest data
  final portfolioData = await _fetchPortfolioData();
  final marketData = await _fetchMarketData();
  
  // Update all widgets
  await HomeWidget.saveWidgetData('portfolio_value', portfolioData['value']);
  await HomeWidget.saveWidgetData('day_change', portfolioData['change']);
  await HomeWidget.saveWidgetData('market_status', marketData['status']);
  await HomeWidget.saveWidgetData('last_refresh', DateTime.now().toIso8601String());
  
  // Request widget update
  await HomeWidget.updateWidget(
    name: 'AssetWorksSmallWidget',
    iOSName: 'AssetWorksSmallWidget',
  );
  await HomeWidget.updateWidget(
    name: 'AssetWorksMediumWidget',
    iOSName: 'AssetWorksMediumWidget',
  );
  await HomeWidget.updateWidget(
    name: 'AssetWorksLargeWidget',
    iOSName: 'AssetWorksLargeWidget',
  );
}

// Update portfolio data
Future<void> _updatePortfolioData(Map<String, dynamic>? inputData) async {
  final portfolioData = await _fetchPortfolioData();
  
  await HomeWidget.saveWidgetData('portfolio_data', jsonEncode(portfolioData));
  await HomeWidget.updateWidget(
    name: 'AssetWorksWidgets',
    iOSName: 'AssetWorksWidgets',
  );
}

// Sync market data
Future<void> _syncMarketData(Map<String, dynamic>? inputData) async {
  final marketData = await _fetchMarketData();
  
  await HomeWidget.saveWidgetData('market_data', jsonEncode(marketData));
  await HomeWidget.updateWidget(
    name: 'AssetWorksWidgets',
    iOSName: 'AssetWorksWidgets',
  );
}

// Check alerts
Future<void> _checkAlerts(Map<String, dynamic>? inputData) async {
  final alerts = await _fetchActiveAlerts();
  
  for (final alert in alerts) {
    if (alert['triggered'] == true) {
      // Show notification
      await _showAlertNotification(alert);
    }
  }
}

// Fetch portfolio data (mock)
Future<Map<String, dynamic>> _fetchPortfolioData() async {
  await Future.delayed(const Duration(seconds: 1));
  return {
    'value': 125432.50,
    'change': 1234.56,
    'changePercent': 0.98,
  };
}

// Fetch market data (mock)
Future<Map<String, dynamic>> _fetchMarketData() async {
  await Future.delayed(const Duration(seconds: 1));
  return {
    'status': 'open',
    'indices': {
      'SP500': 4567.89,
      'NASDAQ': 14234.56,
      'DOW': 35678.90,
    },
  };
}

// Fetch active alerts (mock)
Future<List<Map<String, dynamic>>> _fetchActiveAlerts() async {
  await Future.delayed(const Duration(seconds: 1));
  return [];
}

// Show alert notification
Future<void> _showAlertNotification(Map<String, dynamic> alert) async {
  // Implementation for showing notification
}

class HomeWidgetBackgroundRefreshService {
  static const platform = MethodChannel('com.assetworks.homewidget/background');
  static final HomeWidgetBackgroundRefreshService _instance = 
      HomeWidgetBackgroundRefreshService._internal();
  
  factory HomeWidgetBackgroundRefreshService() => _instance;
  HomeWidgetBackgroundRefreshService._internal();
  
  bool _isInitialized = false;
  Timer? _refreshTimer;
  BackgroundRefreshConfig? _config;
  
  // Initialize background refresh
  Future<void> initialize({
    BackgroundRefreshConfig? config,
  }) async {
    if (_isInitialized) return;
    
    try {
      _config = config ?? BackgroundRefreshConfig.defaultConfig();
      
      // Initialize Workmanager
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
      
      // Setup platform channel
      await platform.invokeMethod('initializeBackgroundRefresh', {
        'config': _config!.toJson(),
      });
      
      // Register periodic tasks
      await _registerPeriodicTasks();
      
      // Start foreground refresh timer
      _startForegroundRefresh();
      
      _isInitialized = true;
      print('Background refresh service initialized');
    } catch (e) {
      print('Failed to initialize background refresh: $e');
    }
  }
  
  // Register periodic background tasks
  Future<void> _registerPeriodicTasks() async {
    if (_config == null) return;
    
    // Widget refresh task
    if (_config!.enableWidgetRefresh) {
      await Workmanager().registerPeriodicTask(
        'widget-refresh',
        'widgetRefresh',
        frequency: Duration(minutes: _config!.widgetRefreshInterval),
        constraints: Constraints(
          networkType: _config!.requireWifi ? NetworkType.unmetered : NetworkType.connected,
          requiresBatteryNotLow: _config!.requireBatteryNotLow,
        ),
        inputData: {
          'widgetIds': _config!.widgetIds,
        },
      );
    }
    
    // Portfolio update task
    if (_config!.enablePortfolioUpdate) {
      await Workmanager().registerPeriodicTask(
        'portfolio-update',
        'portfolioUpdate',
        frequency: Duration(minutes: _config!.portfolioUpdateInterval),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    }
    
    // Market data sync task
    if (_config!.enableMarketDataSync) {
      await Workmanager().registerPeriodicTask(
        'market-data-sync',
        'marketDataSync',
        frequency: Duration(minutes: _config!.marketDataSyncInterval),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    }
    
    // Alert check task
    if (_config!.enableAlertCheck) {
      await Workmanager().registerPeriodicTask(
        'alert-check',
        'alertCheck',
        frequency: Duration(minutes: _config!.alertCheckInterval),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    }
  }
  
  // Start foreground refresh
  void _startForegroundRefresh() {
    if (_config == null || !_config!.enableForegroundRefresh) return;
    
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(seconds: _config!.foregroundRefreshInterval),
      (_) => refreshWidgets(),
    );
  }
  
  // Refresh widgets immediately
  Future<void> refreshWidgets({
    List<String>? widgetIds,
    bool force = false,
  }) async {
    try {
      final ids = widgetIds ?? _config?.widgetIds ?? [];
      
      await platform.invokeMethod('refreshWidgets', {
        'widgetIds': ids,
        'force': force,
      });
      
      // Update widget data
      await _updateWidgetData();
      
      // Request widget updates
      for (final id in ids) {
        await HomeWidget.updateWidget(
          name: id,
          iOSName: id,
        );
      }
    } catch (e) {
      print('Failed to refresh widgets: $e');
    }
  }
  
  // Update widget data
  Future<void> _updateWidgetData() async {
    // Fetch latest data
    final data = await _fetchLatestData();
    
    // Save to widget storage
    for (final entry in data.entries) {
      await HomeWidget.saveWidgetData(entry.key, entry.value);
    }
  }
  
  // Fetch latest data
  Future<Map<String, dynamic>> _fetchLatestData() async {
    // Implementation to fetch data from API or local storage
    return {
      'portfolio_value': 125432.50,
      'day_change': 1234.56,
      'day_change_percent': 0.98,
      'last_update': DateTime.now().toIso8601String(),
    };
  }
  
  // Configure refresh settings
  Future<void> configureRefresh(BackgroundRefreshConfig config) async {
    _config = config;
    
    try {
      // Update native configuration
      await platform.invokeMethod('configureRefresh', config.toJson());
      
      // Cancel existing tasks
      await Workmanager().cancelAll();
      
      // Re-register with new configuration
      await _registerPeriodicTasks();
      
      // Restart foreground refresh
      _startForegroundRefresh();
    } catch (e) {
      print('Failed to configure refresh: $e');
    }
  }
  
  // Pause background refresh
  Future<void> pauseBackgroundRefresh() async {
    try {
      await Workmanager().cancelAll();
      await platform.invokeMethod('pauseBackgroundRefresh');
    } catch (e) {
      print('Failed to pause background refresh: $e');
    }
  }
  
  // Resume background refresh
  Future<void> resumeBackgroundRefresh() async {
    try {
      await _registerPeriodicTasks();
      await platform.invokeMethod('resumeBackgroundRefresh');
    } catch (e) {
      print('Failed to resume background refresh: $e');
    }
  }
  
  // Get refresh status
  Future<RefreshStatus> getRefreshStatus() async {
    try {
      final result = await platform.invokeMethod<Map>('getRefreshStatus');
      return RefreshStatus.fromJson(Map<String, dynamic>.from(result ?? {}));
    } catch (e) {
      print('Failed to get refresh status: $e');
      return RefreshStatus.unknown();
    }
  }
  
  // Dispose service
  void dispose() {
    _refreshTimer?.cancel();
    Workmanager().cancelAll();
  }
}

// Background refresh configuration
class BackgroundRefreshConfig {
  final bool enableWidgetRefresh;
  final bool enablePortfolioUpdate;
  final bool enableMarketDataSync;
  final bool enableAlertCheck;
  final bool enableForegroundRefresh;
  final int widgetRefreshInterval; // minutes
  final int portfolioUpdateInterval; // minutes
  final int marketDataSyncInterval; // minutes
  final int alertCheckInterval; // minutes
  final int foregroundRefreshInterval; // seconds
  final bool requireWifi;
  final bool requireBatteryNotLow;
  final List<String> widgetIds;
  
  BackgroundRefreshConfig({
    this.enableWidgetRefresh = true,
    this.enablePortfolioUpdate = true,
    this.enableMarketDataSync = true,
    this.enableAlertCheck = true,
    this.enableForegroundRefresh = true,
    this.widgetRefreshInterval = 15,
    this.portfolioUpdateInterval = 5,
    this.marketDataSyncInterval = 10,
    this.alertCheckInterval = 30,
    this.foregroundRefreshInterval = 30,
    this.requireWifi = false,
    this.requireBatteryNotLow = true,
    this.widgetIds = const [],
  });
  
  factory BackgroundRefreshConfig.defaultConfig() {
    return BackgroundRefreshConfig(
      widgetIds: [
        'AssetWorksSmallWidget',
        'AssetWorksMediumWidget',
        'AssetWorksLargeWidget',
      ],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'enableWidgetRefresh': enableWidgetRefresh,
    'enablePortfolioUpdate': enablePortfolioUpdate,
    'enableMarketDataSync': enableMarketDataSync,
    'enableAlertCheck': enableAlertCheck,
    'enableForegroundRefresh': enableForegroundRefresh,
    'widgetRefreshInterval': widgetRefreshInterval,
    'portfolioUpdateInterval': portfolioUpdateInterval,
    'marketDataSyncInterval': marketDataSyncInterval,
    'alertCheckInterval': alertCheckInterval,
    'foregroundRefreshInterval': foregroundRefreshInterval,
    'requireWifi': requireWifi,
    'requireBatteryNotLow': requireBatteryNotLow,
    'widgetIds': widgetIds,
  };
}

// Refresh status
class RefreshStatus {
  final bool isActive;
  final DateTime? lastRefresh;
  final DateTime? nextScheduledRefresh;
  final int successCount;
  final int failureCount;
  final String? lastError;
  
  RefreshStatus({
    required this.isActive,
    this.lastRefresh,
    this.nextScheduledRefresh,
    required this.successCount,
    required this.failureCount,
    this.lastError,
  });
  
  factory RefreshStatus.unknown() {
    return RefreshStatus(
      isActive: false,
      successCount: 0,
      failureCount: 0,
    );
  }
  
  factory RefreshStatus.fromJson(Map<String, dynamic> json) {
    return RefreshStatus(
      isActive: json['isActive'] ?? false,
      lastRefresh: json['lastRefresh'] != null 
          ? DateTime.parse(json['lastRefresh']) 
          : null,
      nextScheduledRefresh: json['nextScheduledRefresh'] != null
          ? DateTime.parse(json['nextScheduledRefresh'])
          : null,
      successCount: json['successCount'] ?? 0,
      failureCount: json['failureCount'] ?? 0,
      lastError: json['lastError'],
    );
  }
}