import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../controllers/profile_controller.dart';
import '../../../widgets/ios/ios_widget_card.dart';

class iOSProfileScreen extends StatefulWidget {
  const iOSProfileScreen({Key? key}) : super(key: key);

  @override
  State<iOSProfileScreen> createState() => _iOSProfileScreenState();
}

class _iOSProfileScreenState extends State<iOSProfileScreen>
    with SingleTickerProviderStateMixin {
  final ProfileController _controller = Get.find<ProfileController>();
  final ScrollController _scrollController = ScrollController();
  
  // Tab controller
  late TabController _tabController;
  final List<String> _tabs = ['Widgets', 'Liked', 'Following'];
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Profile stats
  final int _widgetsCount = 12;
  final int _followersCount = 1234;
  final int _followingCount = 89;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _setupAnimations();
    _loadProfileData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
  }

  Future<void> _loadProfileData() async {
    await _controller.loadUserProfile();
    await _controller.loadUserWidgets();
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
        middle: const Text('Profile'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            iOS18Theme.lightImpact();
            Get.toNamed('/settings');
          },
          child: Icon(
            CupertinoIcons.gear,
            size: 22,
            color: iOS18Theme.label.resolveFrom(context),
          ),
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Profile header
              SliverToBoxAdapter(
                child: _buildProfileHeader(),
              ),
              
              // Stats
              SliverToBoxAdapter(
                child: _buildStats(),
              ),
              
              // Action buttons
              SliverToBoxAdapter(
                child: _buildActionButtons(),
              ),
              
              // Tab bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: iOS18Theme.label.resolveFrom(context),
                    unselectedLabelColor: iOS18Theme.secondaryLabel.resolveFrom(context),
                    indicatorColor: iOS18Theme.systemBlue,
                    indicatorWeight: 3,
                    labelStyle: iOS18Theme.body,
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  ),
                  iOS18Theme.systemBackground.resolveFrom(context),
                ),
              ),
              
              // Tab content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWidgetsTab(),
                    _buildLikedTab(),
                    _buildFollowingTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iOS18Theme.systemBlue,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    color: iOS18Theme.systemGray5.resolveFrom(context),
                    child: Icon(
                      CupertinoIcons.person_fill,
                      size: 50,
                      color: iOS18Theme.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  iOS18Theme.lightImpact();
                  _showPhotoOptions();
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iOS18Theme.systemBlue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iOS18Theme.systemBackground.resolveFrom(context),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.camera_fill,
                    size: 16,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: iOS18Theme.spacing16),
          
          // Name and username
          Obx(() => Text(
            _controller.user.value?.name ?? 'John Doe',
            style: iOS18Theme.title2.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
              fontWeight: FontWeight.bold,
            ),
          )),
          
          const SizedBox(height: iOS18Theme.spacing4),
          
          Obx(() => Text(
            '@${_controller.user.value?.username ?? 'johndoe'}',
            style: iOS18Theme.body.copyWith(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
          )),
          
          const SizedBox(height: iOS18Theme.spacing12),
          
          // Bio
          Obx(() => Text(
            _controller.user.value?.bio ?? 'Investment enthusiast | Widget creator | Always learning',
            style: iOS18Theme.footnote.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
            textAlign: TextAlign.center,
          )),
          
          const SizedBox(height: iOS18Theme.spacing8),
          
          // Location and join date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.location,
                size: 14,
                color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              ),
              const SizedBox(width: 4),
              Text(
                'San Francisco, CA',
                style: iOS18Theme.caption1.copyWith(
                  color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                ),
              ),
              const SizedBox(width: iOS18Theme.spacing16),
              Icon(
                CupertinoIcons.calendar,
                size: 14,
                color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              ),
              const SizedBox(width: 4),
              Text(
                'Joined Jan 2024',
                style: iOS18Theme.caption1.copyWith(
                  color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Widgets', _widgetsCount.toString()),
          _buildStatDivider(),
          _buildStatItem('Followers', _formatCount(_followersCount)),
          _buildStatDivider(),
          _buildStatItem('Following', _followingCount.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return GestureDetector(
      onTap: () {
        iOS18Theme.lightImpact();
        // Navigate to respective list
      },
      child: Column(
        children: [
          Text(
            value,
            style: iOS18Theme.title2.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: iOS18Theme.caption1.copyWith(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: iOS18Theme.separator.resolveFrom(context),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              color: iOS18Theme.systemBlue,
              borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
              padding: const EdgeInsets.symmetric(vertical: iOS18Theme.spacing12),
              onPressed: () {
                iOS18Theme.lightImpact();
                Get.toNamed('/profile/edit');
              },
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: iOS18Theme.spacing12),
          CupertinoButton(
            padding: const EdgeInsets.all(iOS18Theme.spacing12),
            onPressed: () {
              iOS18Theme.lightImpact();
              _shareProfile();
            },
            child: Container(
              padding: const EdgeInsets.all(iOS18Theme.spacing8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: iOS18Theme.separator.resolveFrom(context),
                ),
                borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
              ),
              child: Icon(
                CupertinoIcons.share,
                size: 20,
                color: iOS18Theme.label.resolveFrom(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetsTab() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CupertinoActivityIndicator(radius: 20),
        );
      }
      
      if (_controller.userWidgets.isEmpty) {
        return _buildEmptyState(
          icon: CupertinoIcons.square_grid_2x2,
          title: 'No Widgets Yet',
          message: 'Create your first widget to get started',
          actionTitle: 'Create Widget',
          onAction: () => Get.toNamed('/create'),
        );
      }
      
      return GridView.builder(
        padding: const EdgeInsets.all(iOS18Theme.spacing16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: iOS18Theme.spacing12,
          mainAxisSpacing: iOS18Theme.spacing12,
        ),
        itemCount: _controller.userWidgets.length,
        itemBuilder: (context, index) {
          final widget = _controller.userWidgets[index];
          return _buildWidgetGridItem(widget);
        },
      );
    });
  }

  Widget _buildLikedTab() {
    return Obx(() {
      if (_controller.likedWidgets.isEmpty) {
        return _buildEmptyState(
          icon: CupertinoIcons.heart,
          title: 'No Liked Widgets',
          message: 'Widgets you like will appear here',
          actionTitle: 'Discover Widgets',
          onAction: () => Get.toNamed('/discovery'),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(iOS18Theme.spacing16),
        itemCount: _controller.likedWidgets.length,
        itemBuilder: (context, index) {
          final widget = _controller.likedWidgets[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: iOS18Theme.spacing12),
            child: iOSWidgetCard(
              widget: widget,
              onTap: () {
                iOS18Theme.lightImpact();
                Get.toNamed('/widget/${widget.id}');
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildFollowingTab() {
    return Obx(() {
      if (_controller.following.isEmpty) {
        return _buildEmptyState(
          icon: CupertinoIcons.person_2,
          title: 'Not Following Anyone',
          message: 'Follow creators to see their widgets here',
          actionTitle: 'Find Creators',
          onAction: () => Get.toNamed('/discovery'),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(iOS18Theme.spacing16),
        itemCount: _controller.following.length,
        itemBuilder: (context, index) {
          final creator = _controller.following[index];
          return _buildCreatorListItem(creator);
        },
      );
    });
  }

  Widget _buildWidgetGridItem(dynamic widget) {
    return GestureDetector(
      onTap: () {
        iOS18Theme.lightImpact();
        Get.toNamed('/widget/${widget.id}');
      },
      onLongPress: () {
        iOS18Theme.mediumImpact();
        _showWidgetOptions(widget);
      },
      child: Container(
        decoration: BoxDecoration(
          color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
        ),
        child: Stack(
          children: [
            // Widget preview
            Center(
              child: Icon(
                CupertinoIcons.chart_line,
                size: 50,
                color: iOS18Theme.systemBlue.withOpacity(0.5),
              ),
            ),
            
            // Widget info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(iOS18Theme.spacing12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      CupertinoColors.black.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(iOS18Theme.largeRadius),
                    bottomRight: Radius.circular(iOS18Theme.largeRadius),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title ?? 'Widget',
                      style: iOS18Theme.footnote.copyWith(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.eye,
                          size: 12,
                          color: CupertinoColors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '234',
                          style: iOS18Theme.caption2.copyWith(
                            color: CupertinoColors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(width: iOS18Theme.spacing8),
                        Icon(
                          CupertinoIcons.heart,
                          size: 12,
                          color: CupertinoColors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '45',
                          style: iOS18Theme.caption2.copyWith(
                            color: CupertinoColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Privacy indicator
            if (!(widget.isPublic ?? true))
              Positioned(
                top: iOS18Theme.spacing8,
                right: iOS18Theme.spacing8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.lock_fill,
                    size: 12,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorListItem(dynamic creator) {
    return Container(
      margin: const EdgeInsets.only(bottom: iOS18Theme.spacing12),
      padding: const EdgeInsets.all(iOS18Theme.spacing12),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iOS18Theme.systemGray5.resolveFrom(context),
            ),
            child: Icon(
              CupertinoIcons.person_fill,
              size: 25,
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
          ),
          
          const SizedBox(width: iOS18Theme.spacing12),
          
          // Creator info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creator.name ?? 'Creator',
                  style: iOS18Theme.body.copyWith(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${creator.widgetsCount ?? 0} widgets • ${creator.followersCount ?? 0} followers',
                  style: iOS18Theme.caption1.copyWith(
                    color: iOS18Theme.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          
          // Unfollow button
          CupertinoButton(
            padding: const EdgeInsets.symmetric(
              horizontal: iOS18Theme.spacing12,
              vertical: iOS18Theme.spacing6,
            ),
            onPressed: () {
              iOS18Theme.lightImpact();
              _controller.toggleFollow(creator.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: iOS18Theme.spacing12,
                vertical: iOS18Theme.spacing6,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: iOS18Theme.systemBlue,
                ),
                borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
              ),
              child: Text(
                'Following',
                style: iOS18Theme.caption1.copyWith(
                  color: iOS18Theme.systemBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionTitle,
    required VoidCallback onAction,
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
            const SizedBox(height: iOS18Theme.spacing24),
            CupertinoButton.filled(
              onPressed: onAction,
              child: Text(actionTitle),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Change Profile Photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Handle camera
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Handle gallery
            },
            child: const Text('Choose from Library'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Remove photo
            },
            isDestructiveAction: true,
            child: const Text('Remove Photo'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showWidgetOptions(dynamic widget) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(widget.title ?? 'Widget Options'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed('/widget/${widget.id}/edit');
            },
            child: const Text('Edit'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Share widget
            },
            child: const Text('Share'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Duplicate widget
            },
            child: const Text('Duplicate'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _deleteWidget(widget);
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

  void _deleteWidget(dynamic widget) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Widget?'),
        content: Text('Are you sure you want to delete "${widget.title}"?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteWidget(widget.id);
            },
          ),
        ],
      ),
    );
  }

  void _shareProfile() {
    // Implement share functionality
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

// Custom sliver delegate for pinned tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}