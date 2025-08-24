import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';
import '../models/dashboard_widget.dart';
import '../models/user_profile.dart';
import '../widgets/widget_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  late TabController _tabController;
  
  UserProfile? _userProfile;
  List<DashboardWidget> _userWidgets = [];
  List<DashboardWidget> _savedWidgets = [];
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];
  
  bool _isLoading = true;
  int _selectedTab = 0;
  File? _selectedImage;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    _loadProfile();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final profile = await _apiService.getUserProfile();
      final widgets = await _apiService.getUserWidgets();
      final saved = await _apiService.getSavedWidgets();
      final followers = await _apiService.getFollowers();
      final following = await _apiService.getFollowing();
      
      setState(() {
        _userProfile = profile;
        _userWidgets = widgets;
        _savedWidgets = saved;
        _followers = followers;
        _following = following;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      
      // Upload profile picture
      final success = await _apiService.updateProfilePicture(_selectedImage!);
      if (success) {
        DynamicIslandService().updateStatus(
          'Profile updated!',
          icon: CupertinoIcons.checkmark_circle_fill,
        );
        _loadProfile();
      }
    }
  }
  
  void _showEditProfile() {
    final nameController = TextEditingController(
      text: _userProfile?.name ?? '',
    );
    final bioController = TextEditingController(
      text: _userProfile?.bio ?? '',
    );
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Save'),
                    onPressed: () async {
                      Navigator.pop(context);
                      
                      final success = await _apiService.updateUserProfile({
                        'name': nameController.text,
                        'bio': bioController.text,
                      });
                      
                      if (success) {
                        DynamicIslandService().updateStatus(
                          'Profile updated!',
                          icon: CupertinoIcons.checkmark_circle_fill,
                        );
                        _loadProfile();
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    CupertinoColors.systemIndigo,
                                    CupertinoColors.systemPurple,
                                  ],
                                ),
                              ),
                              child: _selectedImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      CupertinoIcons.person_fill,
                                      size: 50,
                                      color: CupertinoColors.white,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemIndigo,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  CupertinoIcons.camera_fill,
                                  size: 16,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Name
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: nameController,
                      placeholder: 'Enter your name',
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Bio
                    const Text(
                      'Bio',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: bioController,
                      placeholder: 'Tell us about yourself',
                      maxLines: 4,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.0),
        border: null,
        middle: const Text('Profile'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.settings),
          onPressed: () => Get.toNamed('/settings'),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                CupertinoColors.systemIndigo,
                                CupertinoColors.systemPurple,
                              ],
                            ),
                          ),
                          child: _userProfile?.avatar != null
                              ? ClipOval(
                                  child: Image.network(
                                    _userProfile!.avatar!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  CupertinoIcons.person_fill,
                                  size: 40,
                                  color: CupertinoColors.white,
                                ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Name
                        Text(
                          _userProfile?.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        // Username
                        Text(
                          '@${_userProfile?.username ?? 'username'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Bio
                        if (_userProfile?.bio != null)
                          Text(
                            _userProfile!.bio!,
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(
                              '${_userWidgets.length}',
                              'Widgets',
                            ),
                            _buildStatColumn(
                              '${_followers.length}',
                              'Followers',
                            ),
                            _buildStatColumn(
                              '${_following.length}',
                              'Following',
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Edit Profile Button
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 8,
                          ),
                          color: CupertinoColors.systemIndigo,
                          borderRadius: BorderRadius.circular(20),
                          onPressed: _showEditProfile,
                          child: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab Bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.systemGrey5,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTab(
                          icon: CupertinoIcons.square_grid_2x2,
                          index: 0,
                        ),
                        _buildTab(
                          icon: CupertinoIcons.bookmark,
                          index: 1,
                        ),
                        _buildTab(
                          icon: CupertinoIcons.person_2,
                          index: 2,
                        ),
                        _buildTab(
                          icon: CupertinoIcons.person_badge_plus,
                          index: 3,
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildWidgetGrid(_userWidgets),
                        _buildWidgetGrid(_savedWidgets),
                        _buildFollowersList(_followers),
                        _buildFollowingList(_following),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTab({required IconData icon, required int index}) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _tabController.animateTo(index),
        child: Icon(
          icon,
          color: isSelected
              ? CupertinoColors.systemIndigo
              : CupertinoColors.systemGrey,
        ),
      ),
    );
  }
  
  Widget _buildWidgetGrid(List<DashboardWidget> widgets) {
    if (widgets.isEmpty) {
      return Center(
        child: Text(
          'No widgets yet',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        return WidgetCard(
          widget: widgets[index],
          onAction: (action) {
            // Handle widget actions
          },
        );
      },
    );
  }
  
  Widget _buildFollowersList(List<Map<String, dynamic>> followers) {
    if (followers.isEmpty) {
      return Center(
        child: Text(
          'No followers yet',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: followers.length,
      itemBuilder: (context, index) {
        final follower = followers[index];
        return _UserListTile(user: follower);
      },
    );
  }
  
  Widget _buildFollowingList(List<Map<String, dynamic>> following) {
    if (following.isEmpty) {
      return Center(
        child: Text(
          'Not following anyone',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: following.length,
      itemBuilder: (context, index) {
        final user = following[index];
        return _UserListTile(user: user);
      },
    );
  }
}

class _UserListTile extends StatelessWidget {
  final Map<String, dynamic> user;
  
  const _UserListTile({Key? key, required this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        Get.toNamed('/user-profile', arguments: user);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey5,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemIndigo,
                    CupertinoColors.systemPurple,
                  ],
                ),
              ),
              child: user['avatar'] != null
                  ? ClipOval(
                      child: Image.network(
                        user['avatar'],
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      CupertinoIcons.person_fill,
                      size: 24,
                      color: CupertinoColors.white,
                    ),
            ),
            
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '@${user['username'] ?? 'username'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Follow button
            CupertinoButton(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              color: user['following'] == true
                  ? CupertinoColors.systemGrey5
                  : CupertinoColors.systemIndigo,
              borderRadius: BorderRadius.circular(16),
              onPressed: () {
                // Toggle follow
              },
              child: Text(
                user['following'] == true ? 'Following' : 'Follow',
                style: TextStyle(
                  fontSize: 14,
                  color: user['following'] == true
                      ? CupertinoColors.label
                      : CupertinoColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}