import 'package:flutter/services.dart';
import 'dart:async';

class HandoffService {
  static const platform = MethodChannel('com.assetworks.handoff');
  static final HandoffService _instance = HandoffService._internal();
  
  factory HandoffService() => _instance;
  HandoffService._internal();
  
  final _handoffController = StreamController<HandoffActivity>.broadcast();
  Stream<HandoffActivity> get handoffStream => _handoffController.stream;
  
  HandoffActivity? _currentActivity;
  
  // Initialize Handoff
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeHandoff');
      _listenToHandoffEvents();
    } catch (e) {
      print('Failed to initialize Handoff: $e');
    }
  }
  
  // Start Handoff activity
  Future<void> startActivity({
    required String activityType,
    required String title,
    required Map<String, dynamic> userInfo,
    String? webpageURL,
  }) async {
    try {
      final activity = HandoffActivity(
        activityType: activityType,
        title: title,
        userInfo: userInfo,
        webpageURL: webpageURL,
        isEligibleForHandoff: true,
        isEligibleForSearch: true,
        isEligibleForPublicIndexing: false,
      );
      
      await platform.invokeMethod('startHandoffActivity', activity.toJson());
      _currentActivity = activity;
    } catch (e) {
      print('Failed to start Handoff activity: $e');
    }
  }
  
  // Update current activity
  Future<void> updateActivity(Map<String, dynamic> userInfo) async {
    if (_currentActivity == null) return;
    
    try {
      await platform.invokeMethod('updateHandoffActivity', userInfo);
      _currentActivity = _currentActivity!.copyWith(userInfo: userInfo);
    } catch (e) {
      print('Failed to update Handoff activity: $e');
    }
  }
  
  // Invalidate activity
  Future<void> invalidateActivity() async {
    try {
      await platform.invokeMethod('invalidateHandoffActivity');
      _currentActivity = null;
    } catch (e) {
      print('Failed to invalidate Handoff activity: $e');
    }
  }
  
  // Resume activity from another device
  Future<bool> resumeActivity(HandoffActivity activity) async {
    try {
      final result = await platform.invokeMethod<bool>(
        'resumeHandoffActivity',
        activity.toJson(),
      );
      return result ?? false;
    } catch (e) {
      print('Failed to resume Handoff activity: $e');
      return false;
    }
  }
  
  // Listen to Handoff events
  void _listenToHandoffEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onContinueUserActivity':
          final data = Map<String, dynamic>.from(call.arguments);
          final activity = HandoffActivity.fromJson(data);
          _handoffController.add(activity);
          _handleContinuation(activity);
          break;
        case 'onActivityWillSave':
          // Save activity state
          break;
        case 'onActivityFailed':
          // Handle failure
          break;
      }
    });
  }
  
  // Handle activity continuation
  void _handleContinuation(HandoffActivity activity) {
    switch (activity.activityType) {
      case 'com.assetworks.viewPortfolio':
        // Navigate to portfolio
        break;
      case 'com.assetworks.viewStock':
        final symbol = activity.userInfo['symbol'];
        // Navigate to stock details
        break;
      case 'com.assetworks.trade':
        // Open trade screen
        break;
      case 'com.assetworks.viewChart':
        // Navigate to chart
        break;
      default:
        // Handle custom activity types
        break;
    }
  }
  
  // Register activity types
  Future<void> registerActivityTypes(List<String> types) async {
    try {
      await platform.invokeMethod('registerActivityTypes', {'types': types});
    } catch (e) {
      print('Failed to register activity types: $e');
    }
  }
  
  HandoffActivity? get currentActivity => _currentActivity;
  
  void dispose() {
    _handoffController.close();
  }
}

class HandoffActivity {
  final String activityType;
  final String title;
  final Map<String, dynamic> userInfo;
  final String? webpageURL;
  final bool isEligibleForHandoff;
  final bool isEligibleForSearch;
  final bool isEligibleForPublicIndexing;
  final DateTime? timestamp;
  
  HandoffActivity({
    required this.activityType,
    required this.title,
    required this.userInfo,
    this.webpageURL,
    this.isEligibleForHandoff = true,
    this.isEligibleForSearch = true,
    this.isEligibleForPublicIndexing = false,
    this.timestamp,
  });
  
  HandoffActivity copyWith({
    String? activityType,
    String? title,
    Map<String, dynamic>? userInfo,
    String? webpageURL,
    bool? isEligibleForHandoff,
    bool? isEligibleForSearch,
    bool? isEligibleForPublicIndexing,
    DateTime? timestamp,
  }) {
    return HandoffActivity(
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      userInfo: userInfo ?? this.userInfo,
      webpageURL: webpageURL ?? this.webpageURL,
      isEligibleForHandoff: isEligibleForHandoff ?? this.isEligibleForHandoff,
      isEligibleForSearch: isEligibleForSearch ?? this.isEligibleForSearch,
      isEligibleForPublicIndexing: isEligibleForPublicIndexing ?? this.isEligibleForPublicIndexing,
      timestamp: timestamp ?? this.timestamp,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'activityType': activityType,
    'title': title,
    'userInfo': userInfo,
    'webpageURL': webpageURL,
    'isEligibleForHandoff': isEligibleForHandoff,
    'isEligibleForSearch': isEligibleForSearch,
    'isEligibleForPublicIndexing': isEligibleForPublicIndexing,
    'timestamp': timestamp?.toIso8601String(),
  };
  
  factory HandoffActivity.fromJson(Map<String, dynamic> json) {
    return HandoffActivity(
      activityType: json['activityType'],
      title: json['title'],
      userInfo: Map<String, dynamic>.from(json['userInfo'] ?? {}),
      webpageURL: json['webpageURL'],
      isEligibleForHandoff: json['isEligibleForHandoff'] ?? true,
      isEligibleForSearch: json['isEligibleForSearch'] ?? true,
      isEligibleForPublicIndexing: json['isEligibleForPublicIndexing'] ?? false,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }
}

// Common Handoff activity types
class HandoffActivityTypes {
  static const String viewPortfolio = 'com.assetworks.viewPortfolio';
  static const String viewStock = 'com.assetworks.viewStock';
  static const String trade = 'com.assetworks.trade';
  static const String viewChart = 'com.assetworks.viewChart';
  static const String viewWatchlist = 'com.assetworks.viewWatchlist';
  static const String viewNews = 'com.assetworks.viewNews';
  static const String viewAlerts = 'com.assetworks.viewAlerts';
  static const String viewSettings = 'com.assetworks.viewSettings';
}