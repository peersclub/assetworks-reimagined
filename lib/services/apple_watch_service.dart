import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

class AppleWatchService {
  static const platform = MethodChannel('com.assetworks.watch');
  static final AppleWatchService _instance = AppleWatchService._internal();
  
  factory AppleWatchService() => _instance;
  AppleWatchService._internal();
  
  final _connectivityController = StreamController<WatchConnectivity>.broadcast();
  Stream<WatchConnectivity> get connectivityStream => _connectivityController.stream;
  
  final _messageController = StreamController<WatchMessage>.broadcast();
  Stream<WatchMessage> get messageStream => _messageController.stream;
  
  final _complicationController = StreamController<ComplicationUpdate>.broadcast();
  Stream<ComplicationUpdate> get complicationStream => _complicationController.stream;
  
  bool _isReachable = false;
  bool _isPaired = false;
  bool _isInstalled = false;
  
  // Initialize Watch connectivity
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeWatchConnectivity');
      _listenToWatchEvents();
      await _checkWatchStatus();
    } catch (e) {
      print('Failed to initialize Apple Watch: $e');
    }
  }
  
  // Check watch status
  Future<void> _checkWatchStatus() async {
    try {
      final status = await platform.invokeMethod<Map>('getWatchStatus');
      _isPaired = status?['isPaired'] ?? false;
      _isInstalled = status?['isInstalled'] ?? false;
      _isReachable = status?['isReachable'] ?? false;
      
      _connectivityController.add(WatchConnectivity(
        isPaired: _isPaired,
        isInstalled: _isInstalled,
        isReachable: _isReachable,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      print('Failed to check watch status: $e');
    }
  }
  
  // Send message to watch
  Future<void> sendMessage({
    required String type,
    required Map<String, dynamic> data,
    bool requiresReply = false,
  }) async {
    if (!_isReachable) {
      throw Exception('Watch is not reachable');
    }
    
    try {
      final message = {
        'type': type,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      if (requiresReply) {
        final reply = await platform.invokeMethod<Map>('sendMessageWithReply', message);
        _handleReply(reply);
      } else {
        await platform.invokeMethod('sendMessage', message);
      }
    } catch (e) {
      print('Failed to send message to watch: $e');
    }
  }
  
  // Update watch application context
  Future<void> updateApplicationContext(Map<String, dynamic> context) async {
    try {
      await platform.invokeMethod('updateApplicationContext', {
        'context': jsonEncode(context),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to update application context: $e');
    }
  }
  
  // Transfer user info
  Future<void> transferUserInfo(Map<String, dynamic> userInfo) async {
    try {
      await platform.invokeMethod('transferUserInfo', {
        'userInfo': jsonEncode(userInfo),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to transfer user info: $e');
    }
  }
  
  // Transfer file
  Future<void> transferFile({
    required String filePath,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await platform.invokeMethod('transferFile', {
        'filePath': filePath,
        'metadata': metadata != null ? jsonEncode(metadata) : null,
      });
    } catch (e) {
      print('Failed to transfer file: $e');
    }
  }
  
  // Update complications
  Future<void> updateComplications({
    required List<WatchComplication> complications,
  }) async {
    try {
      await platform.invokeMethod('updateComplications', {
        'complications': complications.map((c) => c.toJson()).toList(),
      });
      
      _complicationController.add(ComplicationUpdate(
        complications: complications,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      print('Failed to update complications: $e');
    }
  }
  
  // Sync portfolio data
  Future<void> syncPortfolioData({
    required double portfolioValue,
    required double dayChange,
    required double dayChangePercent,
    required List<WatchPosition> positions,
  }) async {
    final data = {
      'portfolioValue': portfolioValue,
      'dayChange': dayChange,
      'dayChangePercent': dayChangePercent,
      'positions': positions.map((p) => p.toJson()).toList(),
      'lastUpdate': DateTime.now().toIso8601String(),
    };
    
    // Update application context for background sync
    await updateApplicationContext(data);
    
    // Send immediate message if watch is reachable
    if (_isReachable) {
      await sendMessage(type: 'portfolio_update', data: data);
    }
    
    // Update complications
    await updateComplications(complications: [
      WatchComplication(
        type: ComplicationType.portfolioValue,
        data: {
          'value': portfolioValue,
          'change': dayChange,
          'changePercent': dayChangePercent,
        },
      ),
    ]);
  }
  
  // Sync watchlist
  Future<void> syncWatchlist(List<WatchlistItem> items) async {
    final data = {
      'items': items.map((item) => item.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await updateApplicationContext({'watchlist': data});
    
    if (_isReachable) {
      await sendMessage(type: 'watchlist_update', data: data);
    }
  }
  
  // Handle workout session
  Future<void> startWorkoutSession({
    required WorkoutType type,
    Map<String, dynamic>? configuration,
  }) async {
    try {
      await platform.invokeMethod('startWorkoutSession', {
        'type': type.toString(),
        'configuration': configuration,
      });
    } catch (e) {
      print('Failed to start workout session: $e');
    }
  }
  
  // Handle reply from watch
  void _handleReply(Map? reply) {
    if (reply != null) {
      _messageController.add(WatchMessage(
        type: reply['type'] ?? 'reply',
        data: Map<String, dynamic>.from(reply['data'] ?? {}),
        timestamp: DateTime.now(),
      ));
    }
  }
  
  // Listen to watch events
  void _listenToWatchEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onReachabilityChanged':
          _isReachable = call.arguments['isReachable'] ?? false;
          _connectivityController.add(WatchConnectivity(
            isPaired: _isPaired,
            isInstalled: _isInstalled,
            isReachable: _isReachable,
            timestamp: DateTime.now(),
          ));
          break;
          
        case 'onMessageReceived':
          final data = Map<String, dynamic>.from(call.arguments);
          _messageController.add(WatchMessage(
            type: data['type'] ?? 'unknown',
            data: Map<String, dynamic>.from(data['data'] ?? {}),
            timestamp: DateTime.now(),
          ));
          _handleWatchMessage(data);
          break;
          
        case 'onApplicationContextReceived':
          final context = Map<String, dynamic>.from(call.arguments);
          _handleApplicationContext(context);
          break;
          
        case 'onUserInfoReceived':
          final userInfo = Map<String, dynamic>.from(call.arguments);
          _handleUserInfo(userInfo);
          break;
          
        case 'onFileReceived':
          final fileData = Map<String, dynamic>.from(call.arguments);
          _handleFile(fileData);
          break;
          
        case 'onComplicationRequest':
          await _handleComplicationRequest(call.arguments);
          break;
      }
    });
  }
  
  // Handle message from watch
  void _handleWatchMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final data = message['data'] ?? {};
    
    switch (type) {
      case 'trade_request':
        // Handle trade request from watch
        break;
      case 'refresh_request':
        // Handle refresh request
        break;
      case 'alert_request':
        // Handle alert request
        break;
    }
  }
  
  // Handle application context
  void _handleApplicationContext(Map<String, dynamic> context) {
    // Process context updates from watch
  }
  
  // Handle user info
  void _handleUserInfo(Map<String, dynamic> userInfo) {
    // Process user info from watch
  }
  
  // Handle file transfer
  void _handleFile(Map<String, dynamic> fileData) {
    // Process received file
  }
  
  // Handle complication request
  Future<void> _handleComplicationRequest(dynamic request) async {
    // Provide complication data
    await updateComplications(complications: [
      WatchComplication(
        type: ComplicationType.portfolioValue,
        data: {
          'value': 125000.00,
          'change': 2500.00,
          'changePercent': 2.04,
        },
      ),
    ]);
  }
  
  bool get isReachable => _isReachable;
  bool get isPaired => _isPaired;
  bool get isInstalled => _isInstalled;
  
  void dispose() {
    _connectivityController.close();
    _messageController.close();
    _complicationController.close();
  }
}

class WatchConnectivity {
  final bool isPaired;
  final bool isInstalled;
  final bool isReachable;
  final DateTime timestamp;
  
  WatchConnectivity({
    required this.isPaired,
    required this.isInstalled,
    required this.isReachable,
    required this.timestamp,
  });
}

class WatchMessage {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  WatchMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}

class WatchComplication {
  final ComplicationType type;
  final Map<String, dynamic> data;
  
  WatchComplication({
    required this.type,
    required this.data,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'data': data,
  };
}

class ComplicationUpdate {
  final List<WatchComplication> complications;
  final DateTime timestamp;
  
  ComplicationUpdate({
    required this.complications,
    required this.timestamp,
  });
}

class WatchPosition {
  final String symbol;
  final String name;
  final double quantity;
  final double price;
  final double value;
  final double change;
  final double changePercent;
  
  WatchPosition({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.price,
    required this.value,
    required this.change,
    required this.changePercent,
  });
  
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'quantity': quantity,
    'price': price,
    'value': value,
    'change': change,
    'changePercent': changePercent,
  };
}

class WatchlistItem {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  
  WatchlistItem({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
  });
  
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'price': price,
    'change': change,
    'changePercent': changePercent,
  };
}

enum ComplicationType {
  portfolioValue,
  topMover,
  marketStatus,
  watchlistItem,
  alert,
  news,
}

enum WorkoutType {
  trading,
  research,
  analysis,
}