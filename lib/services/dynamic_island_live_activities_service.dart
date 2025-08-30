import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

class DynamicIslandLiveActivitiesService {
  static const platform = MethodChannel('com.assetworks.dynamicisland/liveactivities');
  static final DynamicIslandLiveActivitiesService _instance = 
      DynamicIslandLiveActivitiesService._internal();
  
  factory DynamicIslandLiveActivitiesService() => _instance;
  DynamicIslandLiveActivitiesService._internal();
  
  final _activityController = StreamController<LiveActivity>.broadcast();
  Stream<LiveActivity> get activityStream => _activityController.stream;
  
  final Map<String, LiveActivity> _activeActivities = {};
  final Map<String, Timer> _activityTimers = {};
  
  // Initialize live activities service
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeLiveActivities');
      _listenToNativeEvents();
    } catch (e) {
      print('Failed to initialize Dynamic Island live activities: $e');
    }
  }
  
  // Listen to native events
  void _listenToNativeEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onActivityTapped':
          final id = call.arguments['id'] as String;
          _handleActivityTap(id);
          break;
        case 'onActivityExpanded':
          final id = call.arguments['id'] as String;
          _handleActivityExpand(id);
          break;
        case 'onActivityEnded':
          final id = call.arguments['id'] as String;
          _handleActivityEnd(id);
          break;
        case 'onActivityUpdated':
          final data = call.arguments as Map<dynamic, dynamic>;
          _handleActivityUpdate(data);
          break;
      }
    });
  }
  
  // Start market tracking activity
  Future<String> startMarketTracking({
    required String marketName,
    required MarketStatus status,
    Map<String, dynamic>? additionalData,
  }) async {
    final activityId = 'market_${DateTime.now().millisecondsSinceEpoch}';
    
    final activity = LiveActivity(
      id: activityId,
      type: ActivityType.marketTracking,
      title: marketName,
      status: status.toString(),
      startTime: DateTime.now(),
      data: {
        'marketName': marketName,
        'status': status.toString(),
        ...?additionalData,
      },
    );
    
    try {
      await platform.invokeMethod('startActivity', activity.toJson());
      _activeActivities[activityId] = activity;
      _activityController.add(activity);
      
      // Update market data periodically
      _startMarketUpdates(activityId);
      
      return activityId;
    } catch (e) {
      print('Failed to start market tracking: $e');
      throw e;
    }
  }
  
  // Start portfolio monitoring activity
  Future<String> startPortfolioMonitoring({
    required double totalValue,
    required double dayChange,
    required double dayChangePercent,
    List<Map<String, dynamic>>? topMovers,
  }) async {
    final activityId = 'portfolio_${DateTime.now().millisecondsSinceEpoch}';
    
    final activity = LiveActivity(
      id: activityId,
      type: ActivityType.portfolioMonitoring,
      title: 'Portfolio Monitor',
      subtitle: 'Live Updates',
      status: dayChange >= 0 ? 'gaining' : 'losing',
      startTime: DateTime.now(),
      data: {
        'totalValue': totalValue,
        'dayChange': dayChange,
        'dayChangePercent': dayChangePercent,
        'topMovers': topMovers ?? [],
      },
    );
    
    try {
      await platform.invokeMethod('startActivity', activity.toJson());
      _activeActivities[activityId] = activity;
      _activityController.add(activity);
      
      // Update portfolio data periodically
      _startPortfolioUpdates(activityId);
      
      return activityId;
    } catch (e) {
      print('Failed to start portfolio monitoring: $e');
      throw e;
    }
  }
  
  // Start trade execution activity
  Future<String> startTradeExecution({
    required String symbol,
    required TradeType tradeType,
    required double quantity,
    required double price,
    OrderType orderType = OrderType.market,
  }) async {
    final activityId = 'trade_${DateTime.now().millisecondsSinceEpoch}';
    
    final activity = LiveActivity(
      id: activityId,
      type: ActivityType.tradeExecution,
      title: '${tradeType == TradeType.buy ? 'Buying' : 'Selling'} $symbol',
      subtitle: '$quantity shares @ \$$price',
      status: 'pending',
      startTime: DateTime.now(),
      data: {
        'symbol': symbol,
        'tradeType': tradeType.toString(),
        'quantity': quantity,
        'price': price,
        'orderType': orderType.toString(),
        'executionStatus': 'pending',
      },
    );
    
    try {
      await platform.invokeMethod('startActivity', activity.toJson());
      _activeActivities[activityId] = activity;
      _activityController.add(activity);
      
      // Simulate trade execution
      _simulateTradeExecution(activityId);
      
      return activityId;
    } catch (e) {
      print('Failed to start trade execution: $e');
      throw e;
    }
  }
  
  // Start earnings countdown activity
  Future<String> startEarningsCountdown({
    required String symbol,
    required String companyName,
    required DateTime earningsDate,
    Map<String, dynamic>? estimates,
  }) async {
    final activityId = 'earnings_${DateTime.now().millisecondsSinceEpoch}';
    
    final activity = LiveActivity(
      id: activityId,
      type: ActivityType.earningsCountdown,
      title: '$symbol Earnings',
      subtitle: companyName,
      status: 'upcoming',
      startTime: DateTime.now(),
      endTime: earningsDate,
      data: {
        'symbol': symbol,
        'companyName': companyName,
        'earningsDate': earningsDate.toIso8601String(),
        'estimates': estimates ?? {},
      },
    );
    
    try {
      await platform.invokeMethod('startActivity', activity.toJson());
      _activeActivities[activityId] = activity;
      _activityController.add(activity);
      
      // Update countdown periodically
      _startCountdownUpdates(activityId, earningsDate);
      
      return activityId;
    } catch (e) {
      print('Failed to start earnings countdown: $e');
      throw e;
    }
  }
  
  // Start price alert monitoring
  Future<String> startPriceAlertMonitoring({
    required String symbol,
    required double targetPrice,
    required AlertDirection direction,
    required double currentPrice,
  }) async {
    final activityId = 'alert_${DateTime.now().millisecondsSinceEpoch}';
    
    final activity = LiveActivity(
      id: activityId,
      type: ActivityType.priceAlert,
      title: '$symbol Price Alert',
      subtitle: '${direction == AlertDirection.above ? 'Above' : 'Below'} \$$targetPrice',
      status: 'monitoring',
      startTime: DateTime.now(),
      data: {
        'symbol': symbol,
        'targetPrice': targetPrice,
        'direction': direction.toString(),
        'currentPrice': currentPrice,
        'distance': (targetPrice - currentPrice).abs(),
        'distancePercent': ((targetPrice - currentPrice).abs() / currentPrice * 100),
      },
    );
    
    try {
      await platform.invokeMethod('startActivity', activity.toJson());
      _activeActivities[activityId] = activity;
      _activityController.add(activity);
      
      // Monitor price changes
      _startPriceMonitoring(activityId, symbol, targetPrice, direction);
      
      return activityId;
    } catch (e) {
      print('Failed to start price alert monitoring: $e');
      throw e;
    }
  }
  
  // Update activity data
  Future<void> updateActivity(String activityId, Map<String, dynamic> data) async {
    if (!_activeActivities.containsKey(activityId)) return;
    
    try {
      await platform.invokeMethod('updateActivity', {
        'id': activityId,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      final activity = _activeActivities[activityId]!;
      _activeActivities[activityId] = activity.copyWith(
        data: {...activity.data, ...data},
        lastUpdate: DateTime.now(),
      );
      
      _activityController.add(_activeActivities[activityId]!);
    } catch (e) {
      print('Failed to update activity: $e');
    }
  }
  
  // End activity
  Future<void> endActivity(String activityId, {String? finalStatus}) async {
    if (!_activeActivities.containsKey(activityId)) return;
    
    try {
      await platform.invokeMethod('endActivity', {
        'id': activityId,
        'finalStatus': finalStatus,
        'endTime': DateTime.now().toIso8601String(),
      });
      
      _activeActivities.remove(activityId);
      _activityTimers[activityId]?.cancel();
      _activityTimers.remove(activityId);
      
      HapticFeedback.heavyImpact();
    } catch (e) {
      print('Failed to end activity: $e');
    }
  }
  
  // End all activities
  Future<void> endAllActivities() async {
    try {
      await platform.invokeMethod('endAllActivities');
      _activeActivities.clear();
      _activityTimers.forEach((_, timer) => timer.cancel());
      _activityTimers.clear();
    } catch (e) {
      print('Failed to end all activities: $e');
    }
  }
  
  // Start market updates
  void _startMarketUpdates(String activityId) {
    _activityTimers[activityId] = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_activeActivities.containsKey(activityId)) return;
      
      // Update with latest market data
      updateActivity(activityId, {
        'lastUpdate': DateTime.now().toIso8601String(),
        'indices': {
          'SP500': {'value': 4567.89, 'change': 12.34, 'changePercent': 0.27},
          'NASDAQ': {'value': 14234.56, 'change': -45.67, 'changePercent': -0.32},
          'DOW': {'value': 35678.90, 'change': 89.01, 'changePercent': 0.25},
        },
      });
    });
  }
  
  // Start portfolio updates
  void _startPortfolioUpdates(String activityId) {
    _activityTimers[activityId] = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_activeActivities.containsKey(activityId)) return;
      
      final activity = _activeActivities[activityId]!;
      final currentValue = activity.data['totalValue'] as double;
      final change = (DateTime.now().millisecondsSinceEpoch % 100 - 50) / 10;
      
      updateActivity(activityId, {
        'totalValue': currentValue + change,
        'dayChange': (activity.data['dayChange'] as double) + change,
        'lastUpdate': DateTime.now().toIso8601String(),
      });
    });
  }
  
  // Simulate trade execution
  void _simulateTradeExecution(String activityId) {
    // Pending -> Processing
    Timer(const Duration(seconds: 1), () {
      updateActivity(activityId, {
        'executionStatus': 'processing',
        'status': 'processing',
      });
    });
    
    // Processing -> Filled
    Timer(const Duration(seconds: 3), () {
      updateActivity(activityId, {
        'executionStatus': 'filled',
        'status': 'completed',
        'fillPrice': (_activeActivities[activityId]?.data['price'] as double?) ?? 0,
        'fillTime': DateTime.now().toIso8601String(),
      });
      
      // End activity after completion
      Timer(const Duration(seconds: 2), () {
        endActivity(activityId, finalStatus: 'completed');
      });
    });
  }
  
  // Start countdown updates
  void _startCountdownUpdates(String activityId, DateTime targetDate) {
    _activityTimers[activityId] = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_activeActivities.containsKey(activityId)) return;
      
      final remaining = targetDate.difference(DateTime.now());
      
      if (remaining.isNegative) {
        endActivity(activityId, finalStatus: 'expired');
        return;
      }
      
      updateActivity(activityId, {
        'timeRemaining': {
          'days': remaining.inDays,
          'hours': remaining.inHours % 24,
          'minutes': remaining.inMinutes % 60,
          'seconds': remaining.inSeconds % 60,
        },
      });
    });
  }
  
  // Start price monitoring
  void _startPriceMonitoring(
    String activityId,
    String symbol,
    double targetPrice,
    AlertDirection direction,
  ) {
    _activityTimers[activityId] = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_activeActivities.containsKey(activityId)) return;
      
      // Simulate price changes
      final activity = _activeActivities[activityId]!;
      final currentPrice = activity.data['currentPrice'] as double;
      final change = (DateTime.now().millisecondsSinceEpoch % 10 - 5) / 100 * currentPrice;
      final newPrice = currentPrice + change;
      
      updateActivity(activityId, {
        'currentPrice': newPrice,
        'distance': (targetPrice - newPrice).abs(),
        'distancePercent': ((targetPrice - newPrice).abs() / newPrice * 100),
      });
      
      // Check if alert triggered
      if ((direction == AlertDirection.above && newPrice >= targetPrice) ||
          (direction == AlertDirection.below && newPrice <= targetPrice)) {
        updateActivity(activityId, {
          'status': 'triggered',
          'triggeredAt': DateTime.now().toIso8601String(),
          'triggeredPrice': newPrice,
        });
        
        HapticFeedback.heavyImpact();
        
        // End activity after trigger
        Timer(const Duration(seconds: 3), () {
          endActivity(activityId, finalStatus: 'triggered');
        });
      }
    });
  }
  
  // Handle activity tap
  void _handleActivityTap(String id) {
    print('Activity tapped: $id');
    // Navigate to relevant screen
  }
  
  // Handle activity expand
  void _handleActivityExpand(String id) {
    print('Activity expanded: $id');
    // Show expanded view
  }
  
  // Handle activity end
  void _handleActivityEnd(String id) {
    _activeActivities.remove(id);
    _activityTimers[id]?.cancel();
    _activityTimers.remove(id);
  }
  
  // Handle activity update
  void _handleActivityUpdate(Map<dynamic, dynamic> data) {
    final id = data['id'] as String;
    if (_activeActivities.containsKey(id)) {
      final activity = _activeActivities[id]!;
      _activeActivities[id] = activity.copyWith(
        data: {...activity.data, ...data['data']},
        lastUpdate: DateTime.now(),
      );
      _activityController.add(_activeActivities[id]!);
    }
  }
  
  // Get active activities
  List<LiveActivity> get activeActivities => _activeActivities.values.toList();
  
  // Check if activity is active
  bool isActivityActive(String activityId) => _activeActivities.containsKey(activityId);
  
  // Dispose service
  void dispose() {
    _activityTimers.forEach((_, timer) => timer.cancel());
    _activityController.close();
  }
}

// Live activity model
class LiveActivity {
  final String id;
  final ActivityType type;
  final String title;
  final String? subtitle;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final DateTime? lastUpdate;
  final Map<String, dynamic> data;
  
  LiveActivity({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.status,
    required this.startTime,
    this.endTime,
    this.lastUpdate,
    required this.data,
  });
  
  LiveActivity copyWith({
    String? id,
    ActivityType? type,
    String? title,
    String? subtitle,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? lastUpdate,
    Map<String, dynamic>? data,
  }) {
    return LiveActivity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      data: data ?? this.data,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'title': title,
    'subtitle': subtitle,
    'status': status,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'lastUpdate': lastUpdate?.toIso8601String(),
    'data': data,
  };
}

// Enums
enum ActivityType {
  marketTracking,
  portfolioMonitoring,
  tradeExecution,
  earningsCountdown,
  priceAlert,
}

enum MarketStatus { preMarket, open, afterHours, closed }
enum TradeType { buy, sell }
enum OrderType { market, limit, stopLoss, stopLimit }
enum AlertDirection { above, below }