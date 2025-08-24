import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

class DynamicIslandNotificationService {
  static const platform = MethodChannel('com.assetworks.dynamicisland/notifications');
  static final DynamicIslandNotificationService _instance = 
      DynamicIslandNotificationService._internal();
  
  factory DynamicIslandNotificationService() => _instance;
  DynamicIslandNotificationService._internal();
  
  final _notificationController = StreamController<DynamicIslandNotification>.broadcast();
  Stream<DynamicIslandNotification> get notificationStream => _notificationController.stream;
  
  final List<DynamicIslandNotification> _activeNotifications = [];
  Timer? _dismissTimer;
  
  // Initialize notification service
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeNotifications');
      _listenToNativeNotifications();
    } catch (e) {
      print('Failed to initialize Dynamic Island notifications: $e');
    }
  }
  
  // Listen to native notification events
  void _listenToNativeNotifications() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onNotificationTapped':
          final id = call.arguments as String;
          _handleNotificationTap(id);
          break;
        case 'onNotificationDismissed':
          final id = call.arguments as String;
          _handleNotificationDismiss(id);
          break;
        case 'onNotificationExpanded':
          final id = call.arguments as String;
          _handleNotificationExpand(id);
          break;
      }
    });
  }
  
  // Show notification in Dynamic Island
  Future<void> showNotification({
    required String id,
    required String title,
    String? subtitle,
    String? body,
    NotificationType type = NotificationType.info,
    NotificationPriority priority = NotificationPriority.normal,
    Duration? duration,
    Map<String, dynamic>? data,
    List<NotificationAction>? actions,
    bool expandable = true,
    bool dismissible = true,
  }) async {
    final notification = DynamicIslandNotification(
      id: id,
      title: title,
      subtitle: subtitle,
      body: body,
      type: type,
      priority: priority,
      timestamp: DateTime.now(),
      data: data,
      actions: actions,
      expandable: expandable,
      dismissible: dismissible,
    );
    
    try {
      await platform.invokeMethod('showNotification', notification.toJson());
      
      _activeNotifications.add(notification);
      _notificationController.add(notification);
      
      // Auto-dismiss after duration
      if (duration != null) {
        Timer(duration, () => dismissNotification(id));
      }
      
      // Haptic feedback based on priority
      _provideHapticFeedback(priority);
      
    } catch (e) {
      print('Failed to show Dynamic Island notification: $e');
    }
  }
  
  // Update existing notification
  Future<void> updateNotification({
    required String id,
    String? title,
    String? subtitle,
    String? body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await platform.invokeMethod('updateNotification', {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'body': body,
        'data': data,
      });
      
      final index = _activeNotifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final notification = _activeNotifications[index];
        _activeNotifications[index] = notification.copyWith(
          title: title ?? notification.title,
          subtitle: subtitle ?? notification.subtitle,
          body: body ?? notification.body,
          data: data ?? notification.data,
        );
      }
    } catch (e) {
      print('Failed to update notification: $e');
    }
  }
  
  // Dismiss notification
  Future<void> dismissNotification(String id) async {
    try {
      await platform.invokeMethod('dismissNotification', {'id': id});
      _activeNotifications.removeWhere((n) => n.id == id);
    } catch (e) {
      print('Failed to dismiss notification: $e');
    }
  }
  
  // Dismiss all notifications
  Future<void> dismissAllNotifications() async {
    try {
      await platform.invokeMethod('dismissAllNotifications');
      _activeNotifications.clear();
    } catch (e) {
      print('Failed to dismiss all notifications: $e');
    }
  }
  
  // Show alert notification
  Future<void> showAlert({
    required String title,
    required String message,
    AlertType alertType = AlertType.warning,
    List<NotificationAction>? actions,
  }) async {
    await showNotification(
      id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: message,
      type: _getNotificationType(alertType),
      priority: NotificationPriority.high,
      actions: actions ?? [
        NotificationAction(
          id: 'dismiss',
          title: 'Dismiss',
          style: ActionStyle.cancel,
        ),
      ],
      expandable: true,
      dismissible: true,
    );
  }
  
  // Show progress notification
  Future<void> showProgress({
    required String id,
    required String title,
    required double progress,
    String? subtitle,
    bool indeterminate = false,
  }) async {
    try {
      await platform.invokeMethod('showProgressNotification', {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'progress': progress,
        'indeterminate': indeterminate,
      });
      
      if (progress >= 1.0) {
        // Auto-dismiss completed progress after delay
        Timer(const Duration(seconds: 2), () => dismissNotification(id));
      }
    } catch (e) {
      print('Failed to show progress notification: $e');
    }
  }
  
  // Show live activity notification
  Future<void> showLiveActivity({
    required String id,
    required String title,
    required Map<String, dynamic> data,
    LiveActivityType activityType = LiveActivityType.tracking,
    Duration? duration,
  }) async {
    try {
      await platform.invokeMethod('showLiveActivity', {
        'id': id,
        'title': title,
        'data': data,
        'activityType': activityType.toString(),
        'duration': duration?.inSeconds,
      });
    } catch (e) {
      print('Failed to show live activity: $e');
    }
  }
  
  // Update live activity
  Future<void> updateLiveActivity({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await platform.invokeMethod('updateLiveActivity', {
        'id': id,
        'data': data,
      });
    } catch (e) {
      print('Failed to update live activity: $e');
    }
  }
  
  // End live activity
  Future<void> endLiveActivity(String id) async {
    try {
      await platform.invokeMethod('endLiveActivity', {'id': id});
    } catch (e) {
      print('Failed to end live activity: $e');
    }
  }
  
  // Handle notification tap
  void _handleNotificationTap(String id) {
    final notification = _activeNotifications.firstWhere(
      (n) => n.id == id,
      orElse: () => DynamicIslandNotification.empty(),
    );
    
    if (notification.id.isNotEmpty) {
      // Handle tap action
      print('Notification tapped: $id');
      // Navigate or perform action based on notification data
    }
  }
  
  // Handle notification dismiss
  void _handleNotificationDismiss(String id) {
    _activeNotifications.removeWhere((n) => n.id == id);
  }
  
  // Handle notification expand
  void _handleNotificationExpand(String id) {
    print('Notification expanded: $id');
  }
  
  // Provide haptic feedback based on priority
  void _provideHapticFeedback(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        HapticFeedback.lightImpact();
        break;
      case NotificationPriority.normal:
        HapticFeedback.mediumImpact();
        break;
      case NotificationPriority.high:
        HapticFeedback.heavyImpact();
        break;
      case NotificationPriority.urgent:
        HapticFeedback.notificationOccurred(HapticNotificationFeedback.error);
        break;
    }
  }
  
  // Get notification type from alert type
  NotificationType _getNotificationType(AlertType alertType) {
    switch (alertType) {
      case AlertType.success:
        return NotificationType.success;
      case AlertType.warning:
        return NotificationType.warning;
      case AlertType.error:
        return NotificationType.error;
      case AlertType.info:
        return NotificationType.info;
    }
  }
  
  // Get active notifications
  List<DynamicIslandNotification> get activeNotifications => 
      List.unmodifiable(_activeNotifications);
  
  // Dispose service
  void dispose() {
    _dismissTimer?.cancel();
    _notificationController.close();
  }
}

// Notification model
class DynamicIslandNotification {
  final String id;
  final String title;
  final String? subtitle;
  final String? body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final List<NotificationAction>? actions;
  final bool expandable;
  final bool dismissible;
  
  DynamicIslandNotification({
    required this.id,
    required this.title,
    this.subtitle,
    this.body,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.data,
    this.actions,
    this.expandable = true,
    this.dismissible = true,
  });
  
  factory DynamicIslandNotification.empty() {
    return DynamicIslandNotification(
      id: '',
      title: '',
      type: NotificationType.info,
      priority: NotificationPriority.normal,
      timestamp: DateTime.now(),
    );
  }
  
  DynamicIslandNotification copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    List<NotificationAction>? actions,
    bool? expandable,
    bool? dismissible,
  }) {
    return DynamicIslandNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      actions: actions ?? this.actions,
      expandable: expandable ?? this.expandable,
      dismissible: dismissible ?? this.dismissible,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'body': body,
    'type': type.toString(),
    'priority': priority.toString(),
    'timestamp': timestamp.toIso8601String(),
    'data': data,
    'actions': actions?.map((a) => a.toJson()).toList(),
    'expandable': expandable,
    'dismissible': dismissible,
  };
}

// Notification action
class NotificationAction {
  final String id;
  final String title;
  final ActionStyle style;
  final Map<String, dynamic>? data;
  
  NotificationAction({
    required this.id,
    required this.title,
    this.style = ActionStyle.default_,
    this.data,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'style': style.toString(),
    'data': data,
  };
}

// Enums
enum NotificationType { success, warning, error, info, progress, live }
enum NotificationPriority { low, normal, high, urgent }
enum AlertType { success, warning, error, info }
enum LiveActivityType { tracking, timer, workout, navigation, delivery }
enum ActionStyle { default_, cancel, destructive }