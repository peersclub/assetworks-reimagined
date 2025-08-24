import 'package:flutter/services.dart';
import 'dart:async';

class SiriShortcutsService {
  static const platform = MethodChannel('com.assetworks.siri');
  static final SiriShortcutsService _instance = SiriShortcutsService._internal();
  
  factory SiriShortcutsService() => _instance;
  SiriShortcutsService._internal();
  
  final _shortcutController = StreamController<ShortcutEvent>.broadcast();
  Stream<ShortcutEvent> get shortcutStream => _shortcutController.stream;
  
  // Initialize Siri Shortcuts
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeSiriShortcuts');
      _listenToShortcutEvents();
      await _donateDefaultShortcuts();
    } catch (e) {
      print('Failed to initialize Siri Shortcuts: $e');
    }
  }
  
  // Donate shortcuts to Siri
  Future<void> donateShortcut({
    required SiriShortcut shortcut,
  }) async {
    try {
      await platform.invokeMethod('donateShortcut', shortcut.toJson());
    } catch (e) {
      print('Failed to donate shortcut: $e');
    }
  }
  
  // Donate default shortcuts
  Future<void> _donateDefaultShortcuts() async {
    final shortcuts = [
      SiriShortcut(
        id: 'check_portfolio',
        title: 'Check Portfolio',
        phrase: 'Show my portfolio',
        description: 'View your current portfolio value and performance',
        intentType: IntentType.viewPortfolio,
        parameters: {},
      ),
      SiriShortcut(
        id: 'buy_stock',
        title: 'Buy Stock',
        phrase: 'Buy stock',
        description: 'Quickly buy stocks',
        intentType: IntentType.trade,
        parameters: {'action': 'buy'},
      ),
      SiriShortcut(
        id: 'check_watchlist',
        title: 'Check Watchlist',
        phrase: 'Show my watchlist',
        description: 'View your stock watchlist',
        intentType: IntentType.viewWatchlist,
        parameters: {},
      ),
      SiriShortcut(
        id: 'market_status',
        title: 'Market Status',
        phrase: 'Is the market open',
        description: 'Check if the market is currently open',
        intentType: IntentType.marketStatus,
        parameters: {},
      ),
    ];
    
    for (final shortcut in shortcuts) {
      await donateShortcut(shortcut: shortcut);
    }
  }
  
  // Create custom shortcut
  Future<void> createCustomShortcut({
    required String title,
    required String phrase,
    required Map<String, dynamic> action,
  }) async {
    try {
      await platform.invokeMethod('createCustomShortcut', {
        'title': title,
        'phrase': phrase,
        'action': action,
      });
    } catch (e) {
      print('Failed to create custom shortcut: $e');
    }
  }
  
  // Delete shortcut
  Future<void> deleteShortcut(String shortcutId) async {
    try {
      await platform.invokeMethod('deleteShortcut', {'id': shortcutId});
    } catch (e) {
      print('Failed to delete shortcut: $e');
    }
  }
  
  // Get all shortcuts
  Future<List<SiriShortcut>> getAllShortcuts() async {
    try {
      final result = await platform.invokeMethod<List>('getAllShortcuts');
      return result?.map((item) => 
        SiriShortcut.fromJson(Map<String, dynamic>.from(item))
      ).toList() ?? [];
    } catch (e) {
      print('Failed to get shortcuts: $e');
      return [];
    }
  }
  
  // Listen to shortcut events
  void _listenToShortcutEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onShortcutInvoked':
          final data = Map<String, dynamic>.from(call.arguments);
          _shortcutController.add(ShortcutEvent(
            shortcutId: data['shortcutId'],
            parameters: data['parameters'] ?? {},
            timestamp: DateTime.now(),
          ));
          _handleShortcutInvocation(data);
          break;
        case 'onShortcutAdded':
          // Handle shortcut addition
          break;
      }
    });
  }
  
  // Handle shortcut invocation
  void _handleShortcutInvocation(Map<String, dynamic> data) {
    final shortcutId = data['shortcutId'];
    final parameters = data['parameters'] ?? {};
    
    switch (shortcutId) {
      case 'check_portfolio':
        // Navigate to portfolio
        break;
      case 'buy_stock':
        final symbol = parameters['symbol'];
        // Open trade screen
        break;
      case 'check_watchlist':
        // Navigate to watchlist
        break;
      case 'market_status':
        // Show market status
        break;
      default:
        // Handle custom shortcuts
        break;
    }
  }
  
  void dispose() {
    _shortcutController.close();
  }
}

class SiriShortcut {
  final String id;
  final String title;
  final String phrase;
  final String description;
  final IntentType intentType;
  final Map<String, dynamic> parameters;
  final String? imageUrl;
  
  SiriShortcut({
    required this.id,
    required this.title,
    required this.phrase,
    required this.description,
    required this.intentType,
    required this.parameters,
    this.imageUrl,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'phrase': phrase,
    'description': description,
    'intentType': intentType.toString(),
    'parameters': parameters,
    'imageUrl': imageUrl,
  };
  
  factory SiriShortcut.fromJson(Map<String, dynamic> json) {
    return SiriShortcut(
      id: json['id'],
      title: json['title'],
      phrase: json['phrase'],
      description: json['description'],
      intentType: IntentType.values.firstWhere(
        (e) => e.toString() == json['intentType'],
      ),
      parameters: json['parameters'] ?? {},
      imageUrl: json['imageUrl'],
    );
  }
}

class ShortcutEvent {
  final String shortcutId;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  
  ShortcutEvent({
    required this.shortcutId,
    required this.parameters,
    required this.timestamp,
  });
}

enum IntentType {
  viewPortfolio,
  viewStock,
  trade,
  viewWatchlist,
  marketStatus,
  setAlert,
  viewNews,
  custom,
}