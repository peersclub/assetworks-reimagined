import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../controllers/notifications_controller.dart';

class iOSNotificationsScreen extends StatefulWidget {
  const iOSNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<iOSNotificationsScreen> createState() => _iOSNotificationsScreenState();
}

class _iOSNotificationsScreenState extends State<iOSNotificationsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationsController _controller = Get.find<NotificationsController>();
  final ScrollController _scrollController = ScrollController();
  
  // Tab controller
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Unread', 'Mentions'];
  
  // Filter state
  String _selectedFilter = 'all';
  bool _showOnlyUnread = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await _controller.loadNotifications();
  }

  Future<void> _handleRefresh() async {
    iOS18Theme.mediumImpact();
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.systemBackground.resolveFrom(context).withOpacity(0.94),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.arrow_left,
            color: iOS18Theme.label.resolveFrom(context),
          ),
        ),
        middle: const Text('Notifications'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                iOS18Theme.lightImpact();
                _showFilterOptions();
              },
              child: Icon(
                CupertinoIcons.line_horizontal_3_decrease,
                size: 22,
                color: iOS18Theme.label.resolveFrom(context),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                iOS18Theme.lightImpact();
                Get.toNamed('/settings/notifications');
              },
              child: Icon(
                CupertinoIcons.gear,
                size: 22,
                color: iOS18Theme.label.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Unread counter
            Obx(() {
              final unreadCount = _controller.unreadCount.value;
              if (unreadCount > 0) {
                return Container(
                  margin: const EdgeInsets.all(iOS18Theme.spacing16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: iOS18Theme.spacing16,
                    vertical: iOS18Theme.spacing12,
                  ),
                  decoration: BoxDecoration(
                    color: iOS18Theme.systemBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.bell_fill,
                        size: 20,
                        color: iOS18Theme.systemBlue,
                      ),
                      const SizedBox(width: iOS18Theme.spacing12),
                      Expanded(
                        child: Text(
                          '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                          style: iOS18Theme.body.copyWith(
                            color: iOS18Theme.systemBlue,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          iOS18Theme.lightImpact();
                          _controller.markAllAsRead();
                        },
                        child: Text(
                          'Mark all read',
                          style: iOS18Theme.footnote.copyWith(
                            color: iOS18Theme.systemBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            // Tabs
            Container(
              decoration: BoxDecoration(
                color: iOS18Theme.systemBackground.resolveFrom(context),
                border: Border(
                  bottom: BorderSide(
                    color: iOS18Theme.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: iOS18Theme.label.resolveFrom(context),
                unselectedLabelColor: iOS18Theme.secondaryLabel.resolveFrom(context),
                indicatorColor: iOS18Theme.systemBlue,
                indicatorWeight: 3,
                labelStyle: iOS18Theme.body,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllNotifications(),
                  _buildUnreadNotifications(),
                  _buildMentions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllNotifications() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CupertinoActivityIndicator(radius: 20),
        );
      }
      
      if (_controller.notifications.isEmpty) {
        return _buildEmptyState(
          icon: CupertinoIcons.bell,
          title: 'No Notifications',
          message: 'You\'re all caught up! Check back later for updates.',
        );
      }
      
      return CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: _handleRefresh,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final notification = _controller.notifications[index];
                return _buildNotificationItem(notification);
              },
              childCount: _controller.notifications.length,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildUnreadNotifications() {
    return Obx(() {
      final unreadNotifications = _controller.notifications
          .where((n) => !n.isRead)
          .toList();
      
      if (unreadNotifications.isEmpty) {
        return _buildEmptyState(
          icon: CupertinoIcons.bell_slash,
          title: 'No Unread Notifications',
          message: 'You\'ve read all your notifications.',
        );
      }
      
      return ListView.builder(
        itemCount: unreadNotifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationItem(unreadNotifications[index]);
        },
      );
    });
  }

  Widget _buildMentions() {
    return Obx(() {
      final mentions = _controller.notifications
          .where((n) => n.type == 'mention')
          .toList();
      
      if (mentions.isEmpty) {
        return _buildEmptyState(
          icon: CupertinoIcons.at,
          title: 'No Mentions',
          message: 'You haven\'t been mentioned in any widgets or comments.',
        );
      }
      
      return ListView.builder(
        itemCount: mentions.length,
        itemBuilder: (context, index) {
          return _buildNotificationItem(mentions[index]);
        },
      );
    });
  }

  Widget _buildNotificationItem(dynamic notification) {
    final isUnread = !notification.isRead;
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: iOS18Theme.spacing20),
        color: iOS18Theme.systemRed,
        child: const Icon(
          CupertinoIcons.trash,
          color: CupertinoColors.white,
        ),
      ),
      onDismissed: (direction) {
        _controller.deleteNotification(notification.id);
        iOS18Theme.lightImpact();
      },
      child: GestureDetector(
        onTap: () {
          iOS18Theme.lightImpact();
          if (isUnread) {
            _controller.markAsRead(notification.id);
          }
          _handleNotificationTap(notification);
        },
        onLongPress: () {
          iOS18Theme.mediumImpact();
          _showNotificationOptions(notification);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: iOS18Theme.spacing16,
            vertical: iOS18Theme.spacing4,
          ),
          padding: const EdgeInsets.all(iOS18Theme.spacing12),
          decoration: BoxDecoration(
            color: isUnread
                ? iOS18Theme.systemBlue.withOpacity(0.05)
                : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
            border: isUnread
                ? Border.all(
                    color: iOS18Theme.systemBlue.withOpacity(0.2),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  size: 20,
                  color: _getNotificationColor(notification.type),
                ),
              ),
              
              const SizedBox(width: iOS18Theme.spacing12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? 'Notification',
                            style: iOS18Theme.body.copyWith(
                              color: iOS18Theme.label.resolveFrom(context),
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(notification.timestamp),
                          style: iOS18Theme.caption2.copyWith(
                            color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: iOS18Theme.spacing4),
                    Text(
                      notification.message ?? '',
                      style: iOS18Theme.footnote.copyWith(
                        color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Action buttons for certain notification types
                    if (notification.type == 'follow_request')
                      _buildFollowRequestActions(notification),
                    
                    if (notification.type == 'widget_shared')
                      _buildWidgetSharedAction(notification),
                  ],
                ),
              ),
              
              // Unread indicator
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(
                    left: iOS18Theme.spacing8,
                    top: iOS18Theme.spacing16,
                  ),
                  decoration: BoxDecoration(
                    color: iOS18Theme.systemBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowRequestActions(dynamic notification) {
    return Padding(
      padding: const EdgeInsets.only(top: iOS18Theme.spacing12),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () {
              iOS18Theme.lightImpact();
              _controller.acceptFollowRequest(notification.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: iOS18Theme.spacing16,
                vertical: iOS18Theme.spacing6,
              ),
              decoration: BoxDecoration(
                color: iOS18Theme.systemBlue,
                borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
              ),
              child: Text(
                'Accept',
                style: iOS18Theme.caption1.copyWith(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: iOS18Theme.spacing8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () {
              iOS18Theme.lightImpact();
              _controller.declineFollowRequest(notification.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: iOS18Theme.spacing16,
                vertical: iOS18Theme.spacing6,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: iOS18Theme.separator.resolveFrom(context),
                ),
                borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
              ),
              child: Text(
                'Decline',
                style: iOS18Theme.caption1.copyWith(
                  color: iOS18Theme.secondaryLabel.resolveFrom(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetSharedAction(dynamic notification) {
    return Padding(
      padding: const EdgeInsets.only(top: iOS18Theme.spacing12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 0,
        onPressed: () {
          iOS18Theme.lightImpact();
          Get.toNamed('/widget/${notification.widgetId}');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: iOS18Theme.spacing16,
            vertical: iOS18Theme.spacing6,
          ),
          decoration: BoxDecoration(
            color: iOS18Theme.systemBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.eye,
                size: 14,
                color: iOS18Theme.systemBlue,
              ),
              const SizedBox(width: iOS18Theme.spacing4),
              Text(
                'View Widget',
                style: iOS18Theme.caption1.copyWith(
                  color: iOS18Theme.systemBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return CupertinoIcons.heart_fill;
      case 'comment':
        return CupertinoIcons.chat_bubble_fill;
      case 'follow':
      case 'follow_request':
        return CupertinoIcons.person_add_solid;
      case 'mention':
        return CupertinoIcons.at;
      case 'widget_shared':
        return CupertinoIcons.share_solid;
      case 'system':
        return CupertinoIcons.info_circle_fill;
      case 'alert':
        return CupertinoIcons.bell_fill;
      case 'achievement':
        return CupertinoIcons.star_fill;
      default:
        return CupertinoIcons.bell_fill;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'like':
        return iOS18Theme.systemPink;
      case 'comment':
        return iOS18Theme.systemBlue;
      case 'follow':
      case 'follow_request':
        return iOS18Theme.systemGreen;
      case 'mention':
        return iOS18Theme.systemPurple;
      case 'widget_shared':
        return iOS18Theme.systemOrange;
      case 'system':
        return iOS18Theme.systemGray;
      case 'alert':
        return iOS18Theme.systemRed;
      case 'achievement':
        return iOS18Theme.systemYellow;
      default:
        return iOS18Theme.systemBlue;
    }
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }

  void _handleNotificationTap(dynamic notification) {
    switch (notification.type) {
      case 'widget_shared':
      case 'like':
      case 'comment':
        Get.toNamed('/widget/${notification.widgetId}');
        break;
      case 'follow':
      case 'follow_request':
      case 'mention':
        Get.toNamed('/profile/${notification.userId}');
        break;
      case 'achievement':
        Get.toNamed('/achievements');
        break;
      case 'alert':
        Get.toNamed('/alerts');
        break;
      default:
        // Handle other notification types
        break;
    }
  }

  void _showNotificationOptions(dynamic notification) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(notification.title ?? 'Notification'),
        actions: [
          if (!notification.isRead)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _controller.markAsRead(notification.id);
              },
              child: const Text('Mark as Read'),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Copy notification text
            },
            child: const Text('Copy'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Share notification
            },
            child: const Text('Share'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteNotification(notification.id);
            },
            isDestructiveAction: true,
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 400,
        color: iOS18Theme.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(iOS18Theme.spacing16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: iOS18Theme.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Filter Notifications',
                    style: iOS18Theme.headline.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Apply'),
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(iOS18Theme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOTIFICATION TYPE',
                      style: iOS18Theme.caption1.copyWith(
                        color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: iOS18Theme.spacing12),
                    _buildFilterOption('All', 'all'),
                    _buildFilterOption('Likes', 'like'),
                    _buildFilterOption('Comments', 'comment'),
                    _buildFilterOption('Follows', 'follow'),
                    _buildFilterOption('Mentions', 'mention'),
                    _buildFilterOption('System', 'system'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, String value) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = value);
        iOS18Theme.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: iOS18Theme.spacing8),
        padding: const EdgeInsets.all(iOS18Theme.spacing12),
        decoration: BoxDecoration(
          color: isSelected
              ? iOS18Theme.systemBlue.withOpacity(0.1)
              : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
          border: Border.all(
            color: isSelected
                ? iOS18Theme.systemBlue
                : iOS18Theme.separator.resolveFrom(context),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: iOS18Theme.body.copyWith(
                color: isSelected
                    ? iOS18Theme.systemBlue
                    : iOS18Theme.label.resolveFrom(context),
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                size: 20,
                color: iOS18Theme.systemBlue,
              ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    _controller.filterNotifications(_selectedFilter);
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(iOS18Theme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iOS18Theme.systemGray6.resolveFrom(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
            ),
            const SizedBox(height: iOS18Theme.spacing20),
            Text(
              title,
              style: iOS18Theme.title3.copyWith(
                color: iOS18Theme.label.resolveFrom(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: iOS18Theme.spacing8),
            Text(
              message,
              style: iOS18Theme.body.copyWith(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}