import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class DynamicIslandService {
  static final DynamicIslandService _instance = DynamicIslandService._internal();
  factory DynamicIslandService() => _instance;
  DynamicIslandService._internal();

  // Platform channel for native communication
  static const MethodChannel _channel = MethodChannel('ai.assetworks.dynamicisland');
  
  // Current status
  String _currentStatus = '';
  IconData _currentIcon = CupertinoIcons.app;
  double _currentProgress = 0.0;
  bool _isActive = false;
  
  // Stream controllers
  final _statusController = StreamController<DynamicIslandStatus>.broadcast();
  final _progressController = StreamController<double>.broadcast();
  
  // Getters
  Stream<DynamicIslandStatus> get statusStream => _statusController.stream;
  Stream<double> get progressStream => _progressController.stream;
  bool get isActive => _isActive;
  
  // Initialize service
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
      _isActive = true;
      print('Dynamic Island Service initialized');
    } catch (e) {
      print('Failed to initialize Dynamic Island: $e');
      _isActive = false;
    }
  }
  
  // Update status with icon
  Future<void> updateStatus(String status, {IconData? icon}) async {
    _currentStatus = status;
    if (icon != null) _currentIcon = icon;
    
    final update = DynamicIslandStatus(
      message: status,
      icon: icon ?? _currentIcon,
      timestamp: DateTime.now(),
    );
    
    _statusController.add(update);
    
    try {
      await _channel.invokeMethod('updateStatus', {
        'status': status,
        'icon': icon?.codePoint,
      });
    } catch (e) {
      print('Failed to update Dynamic Island status: $e');
    }
  }
  
  // Show progress
  Future<void> showProgress(String task, {required double progress}) async {
    _currentProgress = progress.clamp(0.0, 1.0);
    _progressController.add(_currentProgress);
    
    try {
      await _channel.invokeMethod('showProgress', {
        'task': task,
        'progress': _currentProgress,
      });
    } catch (e) {
      print('Failed to show Dynamic Island progress: $e');
    }
  }
  
  // Show notification
  Future<void> showNotification(String title, String body, {IconData? icon}) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'title': title,
        'body': body,
        'icon': icon?.codePoint,
      });
      
      // Haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      print('Failed to show Dynamic Island notification: $e');
    }
  }
  
  // Start live activity
  Future<void> startLiveActivity(String activityType, Map<String, dynamic> data) async {
    try {
      await _channel.invokeMethod('startLiveActivity', {
        'type': activityType,
        'data': data,
      });
    } catch (e) {
      print('Failed to start live activity: $e');
    }
  }
  
  // Update live activity
  Future<void> updateLiveActivity(String activityId, Map<String, dynamic> data) async {
    try {
      await _channel.invokeMethod('updateLiveActivity', {
        'id': activityId,
        'data': data,
      });
    } catch (e) {
      print('Failed to update live activity: $e');
    }
  }
  
  // End live activity
  Future<void> endLiveActivity([String? activityId]) async {
    try {
      await _channel.invokeMethod('endLiveActivity', {
        'id': activityId ?? 'current',
      });
    } catch (e) {
      print('Failed to end live activity: $e');
    }
  }
  
  // Widget Creation Live Activity Methods
  Future<void> startWidgetCreation({
    required String prompt,
    String? widgetType,
  }) async {
    try {
      await _channel.invokeMethod('startWidgetCreation', {
        'prompt': prompt,
        'widgetType': widgetType ?? 'custom',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      _isActive = true;
      
      // Update status
      updateStatus(
        'Creating widget...',
        icon: CupertinoIcons.sparkles,
      );
    } catch (e) {
      print('Failed to start widget creation live activity: $e');
    }
  }
  
  Future<void> updateWidgetCreationProgress({
    required String stage,
    required double progress,
    String? detail,
  }) async {
    try {
      await _channel.invokeMethod('updateWidgetCreation', {
        'stage': stage,
        'progress': progress,
        'detail': detail,
      });
      
      // Update local progress
      _currentProgress = progress;
      _progressController.add(progress);
      
      // Update status with stage
      String statusMessage;
      IconData statusIcon;
      
      switch (stage) {
        case 'analyzing':
          statusMessage = 'Analyzing your request...';
          statusIcon = CupertinoIcons.waveform;
          break;
        case 'generating':
          statusMessage = 'Generating widget...';
          statusIcon = CupertinoIcons.sparkles;
          break;
        case 'optimizing':
          statusMessage = 'Optimizing design...';
          statusIcon = CupertinoIcons.paintbrush_fill;
          break;
        case 'finalizing':
          statusMessage = 'Finalizing widget...';
          statusIcon = CupertinoIcons.checkmark_circle;
          break;
        case 'complete':
          statusMessage = 'Widget created!';
          statusIcon = CupertinoIcons.checkmark_circle_fill;
          break;
        default:
          statusMessage = detail ?? 'Processing...';
          statusIcon = CupertinoIcons.gear;
      }
      
      updateStatus(statusMessage, icon: statusIcon);
    } catch (e) {
      print('Failed to update widget creation progress: $e');
    }
  }
  
  Future<void> completeWidgetCreation({
    required String widgetTitle,
    required bool success,
    String? errorMessage,
  }) async {
    try {
      await _channel.invokeMethod('completeWidgetCreation', {
        'widgetTitle': widgetTitle,
        'success': success,
        'errorMessage': errorMessage,
      });
      
      // Show completion notification
      if (success) {
        showNotification(
          'Widget Created!',
          widgetTitle,
          icon: CupertinoIcons.checkmark_circle_fill,
        );
        
        updateStatus(
          'Widget "$widgetTitle" created successfully',
          icon: CupertinoIcons.checkmark_circle_fill,
        );
      } else {
        showNotification(
          'Creation Failed',
          errorMessage ?? 'Unable to create widget',
          icon: CupertinoIcons.xmark_circle_fill,
        );
        
        updateStatus(
          'Widget creation failed',
          icon: CupertinoIcons.xmark_circle_fill,
        );
      }
      
      // Clear progress after delay
      Future.delayed(Duration(seconds: 3), () {
        endLiveActivity();
      });
    } catch (e) {
      print('Failed to complete widget creation: $e');
    }
  }
  
  Future<void> startWidgetRemix({
    required String originalTitle,
    required String modifications,
  }) async {
    try {
      await _channel.invokeMethod('startWidgetRemix', {
        'originalTitle': originalTitle,
        'modifications': modifications,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      updateStatus(
        'Remixing "$originalTitle"...',
        icon: CupertinoIcons.arrow_2_circlepath,
      );
    } catch (e) {
      print('Failed to start widget remix live activity: $e');
    }
  }
  
  // Clear Dynamic Island
  Future<void> clear() async {
    _currentStatus = '';
    _currentProgress = 0.0;
    
    try {
      await _channel.invokeMethod('clear');
    } catch (e) {
      print('Failed to clear Dynamic Island: $e');
    }
  }
  
  // Dispose
  void dispose() {
    _statusController.close();
    _progressController.close();
  }
}

// Dynamic Island Status Model
class DynamicIslandStatus {
  final String message;
  final IconData icon;
  final DateTime timestamp;
  
  DynamicIslandStatus({
    required this.message,
    required this.icon,
    required this.timestamp,
  });
}