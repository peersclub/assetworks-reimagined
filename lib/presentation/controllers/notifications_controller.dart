import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/services/haptic_service.dart';

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
  final ApiClient _apiClient = ApiClient();
  
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool showUnreadOnly = false.obs;
  final RxInt unreadCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }
  
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      
      // Fetch real notifications from API
      final response = await _apiClient.getNotifications();
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        
        if (data.isNotEmpty) {
          final newNotifications = data.map((n) => NotificationModel.fromJson(n)).toList();
          
          // Check if there are new unread notifications
          final newUnreadCount = newNotifications.where((n) => !n.isRead).length;
          if (newUnreadCount > unreadCount.value && unreadCount.value > 0) {
            // Vibrate for new notifications
            HapticService.notification();
          }
          
          notifications.value = newNotifications;
        } else {
          // If no notifications, show empty state
          notifications.value = [];
        }
        
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      } else {
        notifications.value = [];
      }
      
    } catch (e) {
      print('Error fetching notifications: $e');
      notifications.value = [];
    } finally {
      isLoading.value = false;
    }
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