import 'package:flutter/services.dart';
import 'dart:async';

class LiveActivitiesAPIService {
  static const platform = MethodChannel('com.assetworks.liveactivities/api');
  static final LiveActivitiesAPIService _instance = LiveActivitiesAPIService._internal();
  
  factory LiveActivitiesAPIService() => _instance;
  LiveActivitiesAPIService._internal();
  
  // Initialize Live Activities API
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeLiveActivities');
      _listenToActivityUpdates();
    } catch (e) {
      print('Failed to initialize Live Activities: $e');
    }
  }
  
  // Start a live activity
  Future<String?> startActivity({
    required String activityType,
    required Map<String, dynamic> attributes,
    required Map<String, dynamic> contentState,
    String? pushToken,
  }) async {
    try {
      final activityId = await platform.invokeMethod<String>('startActivity', {
        'activityType': activityType,
        'attributes': attributes,
        'contentState': contentState,
        'pushToken': pushToken,
      });
      return activityId;
    } catch (e) {
      print('Failed to start activity: $e');
      return null;
    }
  }
  
  // Update activity
  Future<void> updateActivity({
    required String activityId,
    required Map<String, dynamic> contentState,
    AlertConfiguration? alert,
  }) async {
    try {
      await platform.invokeMethod('updateActivity', {
        'activityId': activityId,
        'contentState': contentState,
        'alert': alert?.toJson(),
      });
    } catch (e) {
      print('Failed to update activity: $e');
    }
  }
  
  // End activity
  Future<void> endActivity({
    required String activityId,
    Map<String, dynamic>? finalContentState,
    ActivityDismissalPolicy? dismissalPolicy,
  }) async {
    try {
      await platform.invokeMethod('endActivity', {
        'activityId': activityId,
        'finalContentState': finalContentState,
        'dismissalPolicy': dismissalPolicy?.toJson(),
      });
    } catch (e) {
      print('Failed to end activity: $e');
    }
  }
  
  // Get all activities
  Future<List<LiveActivityInfo>> getAllActivities() async {
    try {
      final result = await platform.invokeMethod<List>('getAllActivities');
      return result?.map((item) => LiveActivityInfo.fromJson(Map<String, dynamic>.from(item))).toList() ?? [];
    } catch (e) {
      print('Failed to get activities: $e');
      return [];
    }
  }
  
  // Listen to activity updates
  void _listenToActivityUpdates() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onActivityStarted':
        case 'onActivityUpdated':
        case 'onActivityEnded':
        case 'onActivityStale':
          // Handle activity lifecycle events
          break;
      }
    });
  }
}

class LiveActivityInfo {
  final String id;
  final String activityType;
  final ActivityState state;
  final Map<String, dynamic> attributes;
  final Map<String, dynamic> contentState;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  LiveActivityInfo({
    required this.id,
    required this.activityType,
    required this.state,
    required this.attributes,
    required this.contentState,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory LiveActivityInfo.fromJson(Map<String, dynamic> json) {
    return LiveActivityInfo(
      id: json['id'],
      activityType: json['activityType'],
      state: ActivityState.values.firstWhere((e) => e.toString() == json['state']),
      attributes: json['attributes'],
      contentState: json['contentState'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

enum ActivityState { active, ended, dismissed, stale }

class AlertConfiguration {
  final String title;
  final String body;
  final String? sound;
  
  AlertConfiguration({required this.title, required this.body, this.sound});
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'sound': sound,
  };
}

class ActivityDismissalPolicy {
  final DateTime? dismissAt;
  final bool immediate;
  
  ActivityDismissalPolicy({this.dismissAt, this.immediate = false});
  
  Map<String, dynamic> toJson() => {
    'dismissAt': dismissAt?.toIso8601String(),
    'immediate': immediate,
  };
}