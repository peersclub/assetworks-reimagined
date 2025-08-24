import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';
import '../models/dashboard_widget.dart';
import '../widgets/widget_card_final.dart';
import '../screens/widget_preview_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? username;
  
  const UserProfileScreen({
    Key? key,
    required this.userId,
    this.username,
  }) : super(key: key);
  
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  
  UserProfile? _userProfile;
  List<DashboardWidget> _userWidgets = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  int _selectedTab = 0;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    try {
      // Load user profile
      final profile = await _apiService.fetchUserProfile();
      
      // Load user's widgets
      final widgets = await _apiService.fetchUserWidgets(
        userId: widget.userId,
        page: 1,
        limit: 50,
      );
      
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _userWidgets = widgets;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _toggleFollow() async {
    HapticFeedback.lightImpact();
    
    final success = _isFollowing
        ? await _apiService.unfollowUser(widget.userId)
        : await _apiService.followUser(widget.userId);
        
    if (success) {
      setState(() {
        _isFollowing = !_isFollowing;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground.withOpacity(0.94),
        border: null,
        middle: Text('@${widget.username ?? 'User'}'),
        trailing: _isLoading
            ? CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.ellipsis),
                onPressed: () => _showOptionsMenu(),
              ),
      ),
      child: _isLoading
          ? Center(child: CupertinoActivityIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Profile Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    color: CupertinoColors.systemBackground,
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: Text(
                              widget.username?.substring(0, 1).toUpperCase() ?? 'U',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Username and Verified Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '@${widget.username ?? 'anonymous'}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_userProfile?.verified == true) ...[
                              const SizedBox(width: 8),
                              Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                size: 24,
                                color: Color(0xFF1DA1F2),
                              ),
                            ],
                          ],
                        ),
                        
                        // Bio
                        if (_userProfile?.bio != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _userProfile!.bio!,
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        
                        const SizedBox(height: 20),
                        
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn('Widgets', _userWidgets.length),
                            _buildStatColumn('Followers', _userProfile?.followers_count ?? 0),
                            _buildStatColumn('Following', _userProfile?.following_count ?? 0),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Follow Button
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isFollowing 
                                  ? CupertinoColors.systemGrey5
                                  : Color(0xFF1DA1F2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              _isFollowing ? 'Following' : 'Follow',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _isFollowing 
                                    ? CupertinoColors.label
                                    : CupertinoColors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onPressed: _toggleFollow,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Tab Selector
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(top: 8),
                    color: CupertinoColors.systemBackground,
                    child: CupertinoSegmentedControl<int>(
                      padding: EdgeInsets.all(16),
                      groupValue: _selectedTab,
                      children: {
                        0: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Widgets'),
                        ),
                        1: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('About'),
                        ),
                      },
                      onValueChanged: (value) {
                        setState(() => _selectedTab = value);
                      },
                    ),
                  ),
                ),
                
                // Content based on selected tab
                if (_selectedTab == 0)
                  // User's Widgets
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return WidgetCardFinal(
                            widget: _userWidgets[index],
                            onAction: (action) => _handleWidgetAction(
                              _userWidgets[index],
                              action,
                            ),
                          );
                        },
                        childCount: _userWidgets.length,
                      ),
                    ),
                  )
                else
                  // About Section
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            CupertinoIcons.calendar,
                            'Joined',
                            _formatDate(_userProfile?.created_at),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            CupertinoIcons.location,
                            'Location',
                            _userProfile?.location ?? 'Not specified',
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            CupertinoIcons.link,
                            'Website',
                            _userProfile?.website ?? 'Not specified',
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
  
  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          _formatCount(count),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
  
  void _showOptionsMenu() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Share Profile'),
            onPressed: () {
              Navigator.pop(context);
              // Implement share
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Report User'),
            onPressed: () {
              Navigator.pop(context);
              // Implement report
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
  
  void _handleWidgetAction(DashboardWidget widget, String action) {
    switch (action) {
      case 'preview':
        Get.to(() => const WidgetPreviewScreen(), 
          arguments: widget,
          transition: Transition.cupertino,
        );
        break;
      case 'remix':
        // Navigate to remix
        break;
      case 'share':
        // Implement share
        break;
    }
  }
}