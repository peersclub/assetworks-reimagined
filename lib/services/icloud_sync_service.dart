import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

class iCloudSyncService {
  static const platform = MethodChannel('com.assetworks.icloud');
  static final iCloudSyncService _instance = iCloudSyncService._internal();
  
  factory iCloudSyncService() => _instance;
  iCloudSyncService._internal();
  
  final _syncController = StreamController<SyncEvent>.broadcast();
  Stream<SyncEvent> get syncStream => _syncController.stream;
  
  final _conflictController = StreamController<SyncConflict>.broadcast();
  Stream<SyncConflict> get conflictStream => _conflictController.stream;
  
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Map<String, dynamic> _localCache = {};
  
  // Initialize iCloud sync
  Future<void> initialize() async {
    try {
      final available = await platform.invokeMethod<bool>('checkiCloudAvailability');
      if (available != true) {
        throw Exception('iCloud is not available');
      }
      
      await platform.invokeMethod('initializeiCloudSync');
      _listenToSyncEvents();
      await _performInitialSync();
    } catch (e) {
      print('Failed to initialize iCloud sync: $e');
      _syncController.add(SyncEvent(
        type: SyncEventType.error,
        error: e.toString(),
        timestamp: DateTime.now(),
      ));
    }
  }
  
  // Save data to iCloud
  Future<void> saveToiCloud({
    required String key,
    required Map<String, dynamic> data,
    bool mergeWithExisting = false,
  }) async {
    try {
      _localCache[key] = data;
      
      await platform.invokeMethod('saveToiCloud', {
        'key': key,
        'data': jsonEncode(data),
        'merge': mergeWithExisting,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _syncController.add(SyncEvent(
        type: SyncEventType.uploaded,
        key: key,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      print('Failed to save to iCloud: $e');
      _syncController.add(SyncEvent(
        type: SyncEventType.error,
        key: key,
        error: e.toString(),
        timestamp: DateTime.now(),
      ));
    }
  }
  
  // Load data from iCloud
  Future<Map<String, dynamic>?> loadFromiCloud(String key) async {
    try {
      final result = await platform.invokeMethod<String>('loadFromiCloud', {
        'key': key,
      });
      
      if (result != null) {
        final data = jsonDecode(result) as Map<String, dynamic>;
        _localCache[key] = data;
        return data;
      }
      return null;
    } catch (e) {
      print('Failed to load from iCloud: $e');
      return null;
    }
  }
  
  // Delete data from iCloud
  Future<void> deleteFromiCloud(String key) async {
    try {
      await platform.invokeMethod('deleteFromiCloud', {
        'key': key,
      });
      
      _localCache.remove(key);
      
      _syncController.add(SyncEvent(
        type: SyncEventType.deleted,
        key: key,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      print('Failed to delete from iCloud: $e');
    }
  }
  
  // Sync all data
  Future<void> syncAll({bool force = false}) async {
    if (_isSyncing && !force) return;
    
    _isSyncing = true;
    _syncController.add(SyncEvent(
      type: SyncEventType.started,
      timestamp: DateTime.now(),
    ));
    
    try {
      // Sync portfolio data
      await _syncPortfolioData();
      
      // Sync user preferences
      await _syncUserPreferences();
      
      // Sync watchlists
      await _syncWatchlists();
      
      // Sync alerts
      await _syncAlerts();
      
      // Sync transaction history
      await _syncTransactionHistory();
      
      _lastSyncTime = DateTime.now();
      
      _syncController.add(SyncEvent(
        type: SyncEventType.completed,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _syncController.add(SyncEvent(
        type: SyncEventType.error,
        error: e.toString(),
        timestamp: DateTime.now(),
      ));
    } finally {
      _isSyncing = false;
    }
  }
  
  // Sync portfolio data
  Future<void> _syncPortfolioData() async {
    const key = 'portfolio_data';
    
    // Load local data
    final localData = _localCache[key];
    
    // Load cloud data
    final cloudData = await loadFromiCloud(key);
    
    if (localData != null && cloudData != null) {
      // Check for conflicts
      final localTimestamp = DateTime.parse(localData['timestamp'] ?? '');
      final cloudTimestamp = DateTime.parse(cloudData['timestamp'] ?? '');
      
      if (localTimestamp != cloudTimestamp) {
        // Handle conflict
        _handleConflict(key, localData, cloudData);
        return;
      }
    }
    
    // Save latest data
    if (localData != null) {
      await saveToiCloud(key: key, data: localData);
    }
  }
  
  // Sync user preferences
  Future<void> _syncUserPreferences() async {
    const key = 'user_preferences';
    
    final preferences = {
      'theme': 'system',
      'notifications': true,
      'biometric': true,
      'currency': 'USD',
      'language': 'en',
      'defaultView': 'dashboard',
      'chartType': 'candlestick',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await saveToiCloud(key: key, data: preferences, mergeWithExisting: true);
  }
  
  // Sync watchlists
  Future<void> _syncWatchlists() async {
    const key = 'watchlists';
    
    final watchlists = {
      'lists': [
        {
          'id': 'default',
          'name': 'My Watchlist',
          'symbols': ['AAPL', 'GOOGL', 'MSFT', 'AMZN'],
        },
        {
          'id': 'tech',
          'name': 'Tech Stocks',
          'symbols': ['NVDA', 'AMD', 'INTC', 'TSM'],
        },
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await saveToiCloud(key: key, data: watchlists);
  }
  
  // Sync alerts
  Future<void> _syncAlerts() async {
    const key = 'alerts';
    
    final alerts = {
      'priceAlerts': [],
      'newsAlerts': [],
      'volumeAlerts': [],
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await saveToiCloud(key: key, data: alerts);
  }
  
  // Sync transaction history
  Future<void> _syncTransactionHistory() async {
    const key = 'transaction_history';
    
    final transactions = {
      'transactions': [],
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    
    await saveToiCloud(key: key, data: transactions);
  }
  
  // Handle sync conflicts
  void _handleConflict(
    String key,
    Map<String, dynamic> localData,
    Map<String, dynamic> cloudData,
  ) {
    _conflictController.add(SyncConflict(
      key: key,
      localData: localData,
      cloudData: cloudData,
      timestamp: DateTime.now(),
    ));
  }
  
  // Resolve conflict
  Future<void> resolveConflict({
    required String key,
    required ConflictResolution resolution,
    Map<String, dynamic>? mergedData,
  }) async {
    switch (resolution) {
      case ConflictResolution.useLocal:
        final localData = _localCache[key];
        if (localData != null) {
          await saveToiCloud(key: key, data: localData);
        }
        break;
      case ConflictResolution.useCloud:
        final cloudData = await loadFromiCloud(key);
        if (cloudData != null) {
          _localCache[key] = cloudData;
        }
        break;
      case ConflictResolution.merge:
        if (mergedData != null) {
          _localCache[key] = mergedData;
          await saveToiCloud(key: key, data: mergedData);
        }
        break;
    }
  }
  
  // Perform initial sync
  Future<void> _performInitialSync() async {
    await syncAll();
  }
  
  // Listen to sync events
  void _listenToSyncEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onDataChanged':
          final key = call.arguments['key'];
          _syncController.add(SyncEvent(
            type: SyncEventType.changed,
            key: key,
            timestamp: DateTime.now(),
          ));
          break;
        case 'onSyncError':
          final error = call.arguments['error'];
          _syncController.add(SyncEvent(
            type: SyncEventType.error,
            error: error,
            timestamp: DateTime.now(),
          ));
          break;
        case 'onQuotaExceeded':
          _syncController.add(SyncEvent(
            type: SyncEventType.quotaExceeded,
            timestamp: DateTime.now(),
          ));
          break;
      }
    });
  }
  
  // Enable/disable auto sync
  Future<void> setAutoSync(bool enabled) async {
    await platform.invokeMethod('setAutoSync', {'enabled': enabled});
  }
  
  // Get sync status
  Future<SyncStatus> getSyncStatus() async {
    try {
      final result = await platform.invokeMethod<Map>('getSyncStatus');
      return SyncStatus.fromJson(Map<String, dynamic>.from(result!));
    } catch (e) {
      return SyncStatus(
        isEnabled: false,
        lastSync: _lastSyncTime,
        pendingChanges: 0,
        quotaUsed: 0,
        quotaTotal: 0,
      );
    }
  }
  
  // Clear all iCloud data
  Future<void> clearAlliCloudData() async {
    try {
      await platform.invokeMethod('clearAlliCloudData');
      _localCache.clear();
      _lastSyncTime = null;
    } catch (e) {
      print('Failed to clear iCloud data: $e');
    }
  }
  
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  
  void dispose() {
    _syncController.close();
    _conflictController.close();
  }
}

class SyncEvent {
  final SyncEventType type;
  final String? key;
  final String? error;
  final DateTime timestamp;
  
  SyncEvent({
    required this.type,
    this.key,
    this.error,
    required this.timestamp,
  });
}

class SyncConflict {
  final String key;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> cloudData;
  final DateTime timestamp;
  
  SyncConflict({
    required this.key,
    required this.localData,
    required this.cloudData,
    required this.timestamp,
  });
}

class SyncStatus {
  final bool isEnabled;
  final DateTime? lastSync;
  final int pendingChanges;
  final double quotaUsed;
  final double quotaTotal;
  
  SyncStatus({
    required this.isEnabled,
    this.lastSync,
    required this.pendingChanges,
    required this.quotaUsed,
    required this.quotaTotal,
  });
  
  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      isEnabled: json['isEnabled'] ?? false,
      lastSync: json['lastSync'] != null 
        ? DateTime.parse(json['lastSync']) 
        : null,
      pendingChanges: json['pendingChanges'] ?? 0,
      quotaUsed: json['quotaUsed']?.toDouble() ?? 0.0,
      quotaTotal: json['quotaTotal']?.toDouble() ?? 0.0,
    );
  }
  
  double get quotaPercentage => 
    quotaTotal > 0 ? (quotaUsed / quotaTotal) * 100 : 0;
}

enum SyncEventType {
  started,
  completed,
  error,
  uploaded,
  downloaded,
  deleted,
  changed,
  quotaExceeded,
}

enum ConflictResolution {
  useLocal,
  useCloud,
  merge,
}