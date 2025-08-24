import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final notifications = await _apiService.fetchNotifications();
      
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
      
      // Mark all as read
      await _apiService.markNotificationsAsRead();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _clearAllNotifications() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear All'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear'),
            onPressed: () => Navigator.pop(context, true),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _apiService.clearNotifications();
      setState(() => _notifications.clear());
      
      DynamicIslandService().updateStatus(
        'Notifications cleared',
        icon: CupertinoIcons.checkmark_circle_fill,
      );
    }
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.0),
        border: null,
        middle: const Text('Notifications'),
        trailing: _notifications.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Clear'),
                onPressed: _clearAllNotifications,
              )
            : null,
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.bell,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationsList() {
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Dismissible(
          key: Key(notification.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: CupertinoColors.systemRed,
            child: const Icon(
              CupertinoIcons.delete,
              color: CupertinoColors.white,
            ),
          ),
          onDismissed: (direction) async {
            await _apiService.deleteNotification(notification.id);
            setState(() {
              _notifications.removeAt(index);
            });
            
            HapticFeedback.mediumImpact();
          },
          child: _buildNotificationTile(notification),
        );
      },
    );
  }
  
  Widget _buildNotificationTile(NotificationModel notification) {
    IconData icon;
    Color iconColor;
    
    switch (notification.type) {
      case 'like':
        icon = CupertinoIcons.heart_fill;
        iconColor = CupertinoColors.systemRed;
        break;
      case 'follow':
        icon = CupertinoIcons.person_badge_plus_fill;
        iconColor = CupertinoColors.systemIndigo;
        break;
      case 'comment':
        icon = CupertinoIcons.chat_bubble_fill;
        iconColor = CupertinoColors.systemBlue;
        break;
      case 'widget':
        icon = CupertinoIcons.cube_box_fill;
        iconColor = CupertinoColors.systemPurple;
        break;
      case 'mention':
        icon = CupertinoIcons.at;
        iconColor = CupertinoColors.systemGreen;
        break;
      default:
        icon = CupertinoIcons.bell_fill;
        iconColor = CupertinoColors.systemGrey;
    }
    
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        
        // Navigate based on notification type
        if (notification.widget_id != null) {
          Get.toNamed('/widget-preview', arguments: {
            'id': notification.widget_id,
          });
        } else if (notification.user_id != null) {
          Get.toNamed('/user-profile', arguments: {
            'id': notification.user_id,
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.is_read
              ? Colors.transparent
              : CupertinoColors.systemIndigo.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey5,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        color: CupertinoTheme.of(context).textTheme.textStyle.color,
                      ),
                      children: [
                        if (notification.user_name != null)
                          TextSpan(
                            text: notification.user_name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        TextSpan(text: ' ${notification.message}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimeAgo(notification.created_at),
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Unread indicator
            if (!notification.is_read)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

