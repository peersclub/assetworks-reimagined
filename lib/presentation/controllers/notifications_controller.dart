import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../data/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final String? avatarUrl;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.avatarUrl,
    this.actionUrl,
    this.metadata,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? json['content'] ?? '',
      type: json['type'] ?? 'system',
      timestamp: json['created_at'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
          : DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? json['read'] ?? false,
      avatarUrl: json['avatar_url'] ?? json['sender_avatar'],
      actionUrl: json['action_url'] ?? json['link'],
      metadata: json['metadata'],
    );
  }
}

class NotificationsController extends GetxController {
  final Dio _dio = Dio();
  
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool showUnreadOnly = false.obs;
  final RxInt unreadCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    fetchNotifications();
  }
  
  void _initializeDio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      
      // For now, just load default notifications since we don't have a real notifications endpoint
      _loadDefaultNotifications();
      
    } catch (e) {
      print('Error fetching notifications: $e');
      _loadDefaultNotifications();
    } finally {
      isLoading.value = false;
    }
  }
  
  void _loadDefaultNotifications() {
    notifications.value = [
      NotificationModel(
        id: '1',
        title: 'Analysis Complete',
        message: 'Your portfolio analysis is ready to view',
        type: 'analysis',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'New Widget Shared',
        message: 'Check out the latest market trends widget',
        type: 'widget',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Weekly Report',
        message: 'Your weekly performance report is available',
        type: 'report',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          type: notifications[index].type,
          timestamp: notifications[index].timestamp,
          isRead: true,
          avatarUrl: notifications[index].avatarUrl,
          actionUrl: notifications[index].actionUrl,
          metadata: notifications[index].metadata,
        );
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      for (int i = 0; i < notifications.length; i++) {
        notifications[i] = NotificationModel(
          id: notifications[i].id,
          title: notifications[i].title,
          message: notifications[i].message,
          type: notifications[i].type,
          timestamp: notifications[i].timestamp,
          isRead: true,
          avatarUrl: notifications[i].avatarUrl,
          actionUrl: notifications[i].actionUrl,
          metadata: notifications[i].metadata,
        );
      }
      unreadCount.value = 0;
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    try {
      notifications.removeWhere((n) => n.id == notificationId);
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
  
  Future<void> clearAll() async {
    try {
      notifications.clear();
      unreadCount.value = 0;
    } catch (e) {
      print('Error clearing all notifications: $e');
    }
  }
  
  List<NotificationModel> get filteredNotifications {
    if (showUnreadOnly.value) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }
  
  List<NotificationModel> getNotificationsByType(List<String> types) {
    return filteredNotifications.where((n) => types.contains(n.type)).toList();
  }
}