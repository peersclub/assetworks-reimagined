import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

class DynamicIslandSyncService {
  static const platform = MethodChannel('com.assetworks.dynamicisland/sync');
  static final DynamicIslandSyncService _instance = DynamicIslandSyncService._internal();
  
  factory DynamicIslandSyncService() => _instance;
  DynamicIslandSyncService._internal();
  
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _syncedItems = 0;
  int _totalItems = 0;
  double _syncProgress = 0.0;
  
  // Initialize sync service
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeSync');
      _startPeriodicSync();
      _listenToNativeUpdates();
    } catch (e) {
      print('Failed to initialize Dynamic Island sync: $e');
    }
  }
  
  // Start periodic sync
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncData();
    });
  }
  
  // Listen to native sync updates
  void _listenToNativeUpdates() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onSyncProgress':
          final data = call.arguments as Map<dynamic, dynamic>;
          _updateSyncProgress(
            progress: data['progress'] ?? 0.0,
            syncedItems: data['syncedItems'] ?? 0,
            totalItems: data['totalItems'] ?? 0,
          );
          break;
        case 'onSyncComplete':
          _onSyncComplete();
          break;
        case 'onSyncError':
          final error = call.arguments as String;
          _onSyncError(error);
          break;
      }
    });
  }
  
  // Sync data with Dynamic Island
  Future<void> syncData({bool force = false}) async {
    if (_isSyncing && !force) return;
    
    _isSyncing = true;
    _syncProgress = 0.0;
    _syncedItems = 0;
    _totalItems = 0;
    
    _updateStatus(SyncStatus(
      isSyncing: true,
      progress: 0.0,
      message: 'Starting sync...',
    ));
    
    try {
      // Prepare data for sync
      final syncData = await _prepareSyncData();
      _totalItems = syncData['items'].length;
      
      // Send data to Dynamic Island
      await platform.invokeMethod('syncData', syncData);
      
      // Simulate progress for demo
      await _simulateSyncProgress();
      
    } catch (e) {
      _onSyncError(e.toString());
    }
  }
  
  // Prepare data for syncing
  Future<Map<String, dynamic>> _prepareSyncData() async {
    // Collect all data that needs to be synced
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'items': [
        {
          'id': 'portfolio_value',
          'type': 'metric',
          'value': 125432.50,
          'change': 2.34,
          'changeType': 'percentage',
        },
        {
          'id': 'daily_gain',
          'type': 'metric',
          'value': 1234.56,
          'change': 0.98,
          'changeType': 'percentage',
        },
        {
          'id': 'watchlist',
          'type': 'list',
          'items': [
            {'symbol': 'AAPL', 'price': 189.45, 'change': 1.23},
            {'symbol': 'GOOGL', 'price': 142.67, 'change': -0.45},
            {'symbol': 'MSFT', 'price': 378.91, 'change': 2.11},
          ],
        },
        {
          'id': 'alerts',
          'type': 'notifications',
          'count': 3,
          'items': [
            {'title': 'AAPL reached target', 'time': '2 min ago'},
            {'title': 'Market closing soon', 'time': '28 min'},
            {'title': 'Earnings report available', 'time': '1 hour ago'},
          ],
        },
        {
          'id': 'market_status',
          'type': 'status',
          'isOpen': true,
          'nextEvent': 'Market closes in 2h 15m',
        },
      ],
      'settings': {
        'refreshInterval': 30,
        'showNotifications': true,
        'compactMode': false,
      },
    };
  }
  
  // Simulate sync progress for demo
  Future<void> _simulateSyncProgress() async {
    for (int i = 1; i <= _totalItems; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      _updateSyncProgress(
        progress: i / _totalItems,
        syncedItems: i,
        totalItems: _totalItems,
      );
    }
    _onSyncComplete();
  }
  
  // Update sync progress
  void _updateSyncProgress({
    required double progress,
    required int syncedItems,
    required int totalItems,
  }) {
    _syncProgress = progress;
    _syncedItems = syncedItems;
    _totalItems = totalItems;
    
    _updateStatus(SyncStatus(
      isSyncing: true,
      progress: progress,
      syncedItems: syncedItems,
      totalItems: totalItems,
      message: 'Syncing... ($syncedItems/$totalItems)',
    ));
    
    // Update Dynamic Island progress
    platform.invokeMethod('updateSyncProgress', {
      'progress': progress,
      'syncedItems': syncedItems,
      'totalItems': totalItems,
    });
  }
  
  // Handle sync completion
  void _onSyncComplete() {
    _isSyncing = false;
    _lastSyncTime = DateTime.now();
    _syncProgress = 1.0;
    
    _updateStatus(SyncStatus(
      isSyncing: false,
      progress: 1.0,
      syncedItems: _syncedItems,
      totalItems: _totalItems,
      lastSyncTime: _lastSyncTime,
      message: 'Sync completed successfully',
      isSuccess: true,
    ));
    
    // Notify Dynamic Island
    platform.invokeMethod('onSyncComplete', {
      'timestamp': _lastSyncTime!.toIso8601String(),
      'itemsSynced': _syncedItems,
    });
    
    HapticFeedback.notificationOccurred(HapticNotificationFeedback.success);
  }
  
  // Handle sync error
  void _onSyncError(String error) {
    _isSyncing = false;
    _syncProgress = 0.0;
    
    _updateStatus(SyncStatus(
      isSyncing: false,
      progress: _syncProgress,
      syncedItems: _syncedItems,
      totalItems: _totalItems,
      lastSyncTime: _lastSyncTime,
      message: 'Sync failed: $error',
      isError: true,
    ));
    
    // Notify Dynamic Island
    platform.invokeMethod('onSyncError', {'error': error});
    
    HapticFeedback.notificationOccurred(HapticNotificationFeedback.error);
  }
  
  // Update sync status
  void _updateStatus(SyncStatus status) {
    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(status);
    }
  }
  
  // Cancel sync
  Future<void> cancelSync() async {
    if (!_isSyncing) return;
    
    try {
      await platform.invokeMethod('cancelSync');
      _isSyncing = false;
      _syncProgress = 0.0;
      
      _updateStatus(SyncStatus(
        isSyncing: false,
        progress: 0.0,
        message: 'Sync cancelled',
      ));
    } catch (e) {
      print('Failed to cancel sync: $e');
    }
  }
  
  // Get last sync time
  DateTime? get lastSyncTime => _lastSyncTime;
  
  // Check if currently syncing
  bool get isSyncing => _isSyncing;
  
  // Get sync progress
  double get syncProgress => _syncProgress;
  
  // Force refresh Dynamic Island
  Future<void> forceRefresh() async {
    try {
      await platform.invokeMethod('forceRefresh');
      await syncData(force: true);
    } catch (e) {
      print('Failed to force refresh: $e');
    }
  }
  
  // Update specific data in Dynamic Island
  Future<void> updateSpecificData(String dataType, dynamic value) async {
    try {
      await platform.invokeMethod('updateData', {
        'type': dataType,
        'value': value,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to update specific data: $e');
    }
  }
  
  // Dispose service
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}

class SyncStatus {
  final bool isSyncing;
  final double progress;
  final int syncedItems;
  final int totalItems;
  final DateTime? lastSyncTime;
  final String message;
  final bool isSuccess;
  final bool isError;
  
  SyncStatus({
    required this.isSyncing,
    required this.progress,
    this.syncedItems = 0,
    this.totalItems = 0,
    this.lastSyncTime,
    required this.message,
    this.isSuccess = false,
    this.isError = false,
  });
}

// Sync configuration
class SyncConfiguration {
  final int syncIntervalMinutes;
  final bool autoSync;
  final bool syncOnAppLaunch;
  final bool syncOnBackground;
  final List<String> dataTypesToSync;
  final bool useWiFiOnly;
  
  const SyncConfiguration({
    this.syncIntervalMinutes = 5,
    this.autoSync = true,
    this.syncOnAppLaunch = true,
    this.syncOnBackground = true,
    this.dataTypesToSync = const ['portfolio', 'watchlist', 'alerts', 'market'],
    this.useWiFiOnly = false,
  });
  
  Map<String, dynamic> toJson() => {
    'syncIntervalMinutes': syncIntervalMinutes,
    'autoSync': autoSync,
    'syncOnAppLaunch': syncOnAppLaunch,
    'syncOnBackground': syncOnBackground,
    'dataTypesToSync': dataTypesToSync,
    'useWiFiOnly': useWiFiOnly,
  };
  
  factory SyncConfiguration.fromJson(Map<String, dynamic> json) {
    return SyncConfiguration(
      syncIntervalMinutes: json['syncIntervalMinutes'] ?? 5,
      autoSync: json['autoSync'] ?? true,
      syncOnAppLaunch: json['syncOnAppLaunch'] ?? true,
      syncOnBackground: json['syncOnBackground'] ?? true,
      dataTypesToSync: List<String>.from(json['dataTypesToSync'] ?? []),
      useWiFiOnly: json['useWiFiOnly'] ?? false,
    );
  }
}