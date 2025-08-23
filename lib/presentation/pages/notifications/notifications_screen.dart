import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../controllers/notifications_controller.dart';

enum NotificationType {
  like,
  comment,
  follow,
  mention,
  system,
  achievement,
  analysis,
  widget
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? avatarUrl;
  final String? actionUrl;
  
  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.avatarUrl,
    this.actionUrl,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NotificationsController _notificationsController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _notificationsController = Get.put(NotificationsController());
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'like':
        return LucideIcons.heart;
      case 'comment':
        return LucideIcons.messageCircle;
      case 'follow':
        return LucideIcons.userPlus;
      case 'mention':
        return LucideIcons.atSign;
      case 'system':
        return LucideIcons.info;
      case 'achievement':
        return LucideIcons.trophy;
      case 'analysis':
        return LucideIcons.barChart3;
      case 'widget':
        return LucideIcons.layout;
      case 'report':
        return LucideIcons.fileText;
      default:
        return LucideIcons.bell;
    }
  }
  
  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'like':
        return AppColors.error;
      case 'comment':
        return AppColors.info;
      case 'follow':
        return AppColors.primary;
      case 'mention':
        return AppColors.warning;
      case 'system':
        return AppColors.neutral500;
      case 'achievement':
        return AppColors.warning;
      case 'analysis':
        return AppColors.success;
      case 'widget':
        return AppColors.accent;
      case 'report':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
  
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() => IconButton(
            onPressed: () {
              _notificationsController.showUnreadOnly.value = 
                  !_notificationsController.showUnreadOnly.value;
            },
            icon: Icon(
              _notificationsController.showUnreadOnly.value 
                  ? LucideIcons.mailOpen 
                  : LucideIcons.mail,
              size: 22,
            ),
            tooltip: _notificationsController.showUnreadOnly.value 
                ? 'Show all' 
                : 'Show unread only',
          )),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical, size: 22),
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _notificationsController.markAllAsRead();
                  break;
                case 'clear_all':
                  _notificationsController.clearAll();
                  break;
                case 'settings':
                  Get.toNamed('/notification-settings');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(LucideIcons.checkCheck, size: 18),
                    SizedBox(width: 12),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 18),
                    SizedBox(width: 12),
                    Text('Clear all'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(LucideIcons.settings, size: 18),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Activity'),
            Tab(text: 'System'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(null),
          _buildNotificationList([
            'like',
            'comment',
            'follow',
            'mention',
          ]),
          _buildNotificationList([
            'system',
            'achievement',
            'analysis',
            'widget',
            'report',
          ]),
        ],
      ),
    );
  }
  
  Widget _buildNotificationList(List<String>? types) {
    return Obx(() {
      final notifications = types == null 
          ? _notificationsController.filteredNotifications
          : _notificationsController.getNotificationsByType(types);
      
      if (_notificationsController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (notifications.isEmpty) {
        return _buildEmptyState();
      }
      
      return RefreshIndicator(
        onRefresh: () => _notificationsController.fetchNotifications(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationItem(notification);
          },
        ),
      );
    });
  }
  
  Widget _buildNotificationItem(NotificationModel notification) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(
          LucideIcons.trash2,
          color: Colors.white,
          size: 20,
        ),
      ),
      onDismissed: (direction) {
        _notificationsController.deleteNotification(notification.id);
        Get.snackbar(
          'Notification removed',
          'Tap to undo',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () {
              // Undo action
              Get.back();
            },
            child: const Text('UNDO'),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          _notificationsController.markAsRead(notification.id);
          if (notification.actionUrl != null) {
            // Navigate to action URL
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Colors.transparent 
                : (isDark ? AppColors.primary.withOpacity(0.05) : AppColors.primaryLight.withOpacity(0.1)),
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  size: 20,
                  color: _getNotificationColor(notification.type),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bellOff,
            size: 64,
            color: isDark ? AppColors.neutral600 : AppColors.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            _notificationsController.showUnreadOnly.value 
                ? 'You have no unread notifications'
                : 'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          )),
        ],
      ),
    );
  }
}