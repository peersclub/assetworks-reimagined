import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/widget_response_model.dart';
import '../../controllers/profile_controller.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);
  
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late ProfileController _controller;
  late TabController _tabController;
  late UserModel user;
  bool isOwnProfile = false;
  
  @override
  void initState() {
    super.initState();
    _controller = Get.put(ProfileController());
    _tabController = TabController(length: 3, vsync: this);
    
    // Get user from arguments or load current user
    final args = Get.arguments;
    if (args != null && args is UserModel) {
      user = args;
      isOwnProfile = false;
      _controller.loadUserProfile(user.id);
    } else {
      isOwnProfile = true;
      _controller.loadCurrentUserProfile();
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final profileUser = _controller.currentUser.value ?? user;
        
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                actions: [
                  if (isOwnProfile)
                    IconButton(
                      onPressed: () => Get.toNamed('/settings'),
                      icon: const Icon(LucideIcons.settings, size: 22),
                    )
                  else
                    PopupMenuButton<String>(
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(LucideIcons.share2, size: 18),
                              SizedBox(width: 8),
                              Text('Share Profile'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(LucideIcons.flag, size: 18),
                              SizedBox(width: 8),
                              Text('Report User'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Profile Picture
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              image: profileUser.profilePicture != null
                                  ? DecorationImage(
                                      image: NetworkImage(profileUser.profilePicture!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: profileUser.profilePicture == null
                                ? Icon(
                                    LucideIcons.user,
                                    size: 40,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          
                          // Username
                          Text(
                            '@${profileUser.username}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          // Bio
                          if (profileUser.bio != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                profileUser.bio!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const SizedBox(height: 16),
                          
                          // Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStat('Widgets', profileUser.widgetCount),
                              const SizedBox(width: 32),
                              InkWell(
                                onTap: () => _showFollowers(),
                                child: _buildStat('Followers', profileUser.followersCount),
                              ),
                              const SizedBox(width: 32),
                              InkWell(
                                onTap: () => _showFollowing(),
                                child: _buildStat('Following', profileUser.followingCount),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Follow/Edit Button
                          if (!isOwnProfile)
                            Obx(() => AppButton(
                              text: _controller.isFollowing.value ? 'Following' : 'Follow',
                              icon: _controller.isFollowing.value 
                                  ? LucideIcons.userCheck 
                                  : LucideIcons.userPlus,
                              type: _controller.isFollowing.value 
                                  ? AppButtonType.outline 
                                  : AppButtonType.primary,
                              onPressed: _toggleFollow,
                              size: AppButtonSize.small,
                            )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Widgets'),
                      Tab(text: 'Liked'),
                      Tab(text: 'Activity'),
                    ],
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                    indicatorColor: AppColors.primary,
                  ),
                  isDark: isDark,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // User's Widgets
              _buildWidgetsTab(),
              
              // Liked Widgets
              _buildLikedTab(),
              
              // Activity
              _buildActivityTab(),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWidgetsTab() {
    return Obx(() {
      final widgets = _controller.userWidgets;
      
      if (widgets.isEmpty) {
        return _buildEmptyState(
          icon: LucideIcons.layout,
          title: 'No Widgets Yet',
          subtitle: isOwnProfile 
              ? 'Your created widgets will appear here'
              : 'This user hasn\'t created any widgets yet',
        );
      }
      
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: widgets.length,
        itemBuilder: (context, index) {
          final widget = widgets[index];
          return _buildWidgetCard(widget);
        },
      );
    });
  }
  
  Widget _buildLikedTab() {
    return Obx(() {
      final widgets = _controller.likedWidgets;
      
      if (widgets.isEmpty) {
        return _buildEmptyState(
          icon: LucideIcons.heart,
          title: 'No Liked Widgets',
          subtitle: isOwnProfile 
              ? 'Widgets you like will appear here'
              : 'This user hasn\'t liked any widgets yet',
        );
      }
      
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: widgets.length,
        itemBuilder: (context, index) {
          final widget = widgets[index];
          return _buildWidgetCard(widget);
        },
      );
    });
  }
  
  Widget _buildActivityTab() {
    return Obx(() {
      final activities = _controller.activities;
      
      if (activities.isEmpty) {
        return _buildEmptyState(
          icon: LucideIcons.activity,
          title: 'No Recent Activity',
          subtitle: 'Recent activity will appear here',
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityItem(activity);
        },
      );
    });
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark ? AppColors.neutral600 : AppColors.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildWidgetCard(WidgetResponseModel widget) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      onTap: () => Get.toNamed('/widget-view', arguments: widget),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? AppColors.neutral900 : AppColors.neutral100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                LucideIcons.layout,
                size: 32,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // Stats
          Row(
            children: [
              Icon(
                LucideIcons.heart,
                size: 14,
                color: isDark ? AppColors.neutral600 : AppColors.neutral400,
              ),
              const SizedBox(width: 4),
              Text(
                widget.likes.toString(),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 12),
              Icon(
                LucideIcons.eye,
                size: 14,
                color: isDark ? AppColors.neutral600 : AppColors.neutral400,
              ),
              const SizedBox(width: 4),
              Text(
                widget.shares.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getActivityIcon(activity['type']),
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity['time'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'created':
        return LucideIcons.plus;
      case 'liked':
        return LucideIcons.heart;
      case 'followed':
        return LucideIcons.userPlus;
      case 'remixed':
        return LucideIcons.shuffle;
      default:
        return LucideIcons.activity;
    }
  }
  
  void _toggleFollow() {
    if (_controller.isFollowing.value) {
      _controller.unfollowUser(user.id);
    } else {
      _controller.followUser(user.id);
    }
  }
  
  void _showFollowers() {
    Get.toNamed('/followers', arguments: user);
  }
  
  void _showFollowing() {
    Get.toNamed('/following', arguments: user);
  }
  
  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareProfile();
        break;
      case 'report':
        _reportUser();
        break;
    }
  }
  
  void _shareProfile() {
    Get.snackbar(
      'Share Profile',
      'Sharing profile link...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void _reportUser() {
    Get.dialog(
      AlertDialog(
        title: const Text('Report User'),
        content: const Text('Why are you reporting this user?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Reported',
                'User has been reported',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}

// Custom SliverPersistentHeader delegate for TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;
  
  _SliverAppBarDelegate(this.tabBar, {required this.isDark});
  
  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  double get maxExtent => tabBar.preferredSize.height;
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: tabBar,
    );
  }
  
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}