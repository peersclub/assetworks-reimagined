import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/widget_controller.dart';
import '../../widgets/compact_widget_card.dart';

class EnhancedProfileScreen extends StatefulWidget {
  const EnhancedProfileScreen({Key? key}) : super(key: key);
  
  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen> 
    with SingleTickerProviderStateMixin {
  late AuthController _authController;
  late ProfileController _profileController;
  late WidgetController _widgetController;
  late TabController _tabController;
  
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  
  // Edit profile controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _twitterController = TextEditingController();
  final _linkedinController = TextEditingController();
  
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _profileController = Get.put(ProfileController());
    _widgetController = Get.find<WidgetController>();
    _tabController = TabController(length: 4, vsync: this);
    
    _loadUserData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _twitterController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }
  
  void _loadUserData() async {
    await _profileController.loadCurrentUserProfile();
    await _widgetController.loadDashboardWidgets();
    
    // Initialize edit controllers with current data
    ever(_profileController.currentUser, (user) {
      if (user != null) {
        _nameController.text = user.username;
        _bioController.text = user.bio ?? '';
        // These fields don't exist in UserModel yet
        _websiteController.text = '';
        _twitterController.text = '';
        _linkedinController.text = '';
      }
    });
  }
  
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      // TODO: Upload image to server
    }
  }
  
  
  void _showPasswordDialog(String email) {
    final passwordController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: Text('Enable ${_authController.biometricType.value}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your password to enable ${_authController.biometricType.value} login'),
            const SizedBox(height: 16),
            AppTextField(
              controller: passwordController,
              hint: 'Password',
              obscureText: true,
              showPasswordToggle: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _authController.enableBiometric(
                email,
                passwordController.text,
              );
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveProfile() async {
    final updateData = {
      'username': _nameController.text,
      'bio': _bioController.text,
      'website': _websiteController.text,
      'twitter': _twitterController.text,
      'linkedin': _linkedinController.text,
    };
    
    await _profileController.updateProfile(updateData);
    setState(() {
      _isEditMode = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 340,
              floating: false,
              pinned: true,
              title: _isEditMode ? const Text('Edit Profile') : const Text('Profile'),
              actions: [
                if (!_isEditMode)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditMode = true;
                      });
                    },
                    icon: const Icon(LucideIcons.edit, size: 22),
                  )
                else
                  TextButton(
                    onPressed: _saveProfile,
                    child: const Text('Save'),
                  ),
                IconButton(
                  onPressed: () => Get.toNamed('/settings'),
                  icon: const Icon(LucideIcons.settings, size: 22),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Profile Avatar
                          Obx(() {
                            final user = _profileController.currentUser.value;
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: _isEditMode ? _pickImage : null,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: _selectedImage != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(47),
                                            child: Image.file(
                                              _selectedImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : user?.profilePicture != null && user!.profilePicture!.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(47),
                                                child: Image.network(
                                                  user.profilePicture!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Center(
                                                      child: Text(
                                                        user.username.isNotEmpty
                                                            ? user.username.substring(0, user.username.length >= 2 ? 2 : 1).toUpperCase()
                                                            : 'U',
                                                        style: TextStyle(
                                                          color: AppColors.primary,
                                                          fontSize: 36,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  user?.username != null && user!.username.isNotEmpty
                                                      ? user.username.substring(0, user.username.length >= 2 ? 2 : 1).toUpperCase()
                                                      : 'U',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                  ),
                                ),
                                if (_isEditMode)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        LucideIcons.camera,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                          const SizedBox(height: 16),
                          
                          // User Info
                          if (_isEditMode)
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: _nameController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Display Name',
                                  hintStyle: TextStyle(color: Colors.white60),
                                  border: InputBorder.none,
                                ),
                              ),
                            )
                          else
                            Obx(() {
                              final user = _profileController.currentUser.value;
                              return Column(
                                children: [
                                  Text(
                                    user?.username ?? user?.email ?? 'User',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          const SizedBox(height: 20),
                          
                          // Stats
                          Obx(() {
                            final user = _profileController.currentUser.value;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildStat('Widgets', user?.widgetCount ?? 0),
                                const SizedBox(width: 30),
                                _buildStat('Followers', user?.followersCount ?? 0),
                                const SizedBox(width: 30),
                                _buildStat('Following', user?.followingCount ?? 0),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Widgets'),
                  Tab(text: 'Activity'),
                  Tab(text: 'About'),
                  Tab(text: 'Security'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Widgets Tab
            _buildWidgetsTab(),
            
            // Activity Tab
            _buildActivityTab(),
            
            // About Tab
            _buildAboutTab(isDark),
            
            // Security Tab
            _buildSecurityTab(isDark),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWidgetsTab() {
    return Obx(() {
      final widgets = _profileController.userWidgets;
      
      if (_profileController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (widgets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.package, size: 64, color: AppColors.neutral500),
              const SizedBox(height: 16),
              const Text('No widgets created yet'),
              const SizedBox(height: 8),
              AppButton(
                text: 'Create First Widget',
                onPressed: () => Get.toNamed('/create-widget'),
              ),
            ],
          ),
        );
      }
      
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,  // Square aspect ratio for compact cards
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: widgets.length,
        itemBuilder: (context, index) {
          final widget = widgets[index];
          // Get the display name from the current user
          final currentUser = _profileController.currentUser.value;
          String displayName = currentUser?.username ?? 'User';
          
          return CompactWidgetCard(
            title: widget.title,
            author: displayName,
            date: DateTime.fromMillisecondsSinceEpoch(widget.createdAt * 1000),
            likes: widget.likes,
            category: widget.category,
            onTap: () => Get.toNamed('/widget-view', arguments: widget),
          );
        },
      );
    });
  }
  
  Widget _buildActivityTab() {
    return Obx(() {
      final activities = _profileController.activities;
      
      if (_profileController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (activities.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.activity, size: 64, color: AppColors.neutral500),
              const SizedBox(height: 16),
              const Text('No recent activity'),
              const SizedBox(height: 8),
              Text(
                'Your activity will appear here',
                style: TextStyle(
                  color: AppColors.neutral600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityItem(
            icon: _getActivityIcon(activity['icon'] ?? 'activity'),
            title: activity['title'] ?? '',
            subtitle: activity['description'] ?? '',
            time: _formatActivityTime(activity['timestamp']),
          );
        },
      );
    });
  }
  
  IconData _getActivityIcon(String iconName) {
    switch (iconName) {
      case 'plus':
        return LucideIcons.plus;
      case 'heart':
        return LucideIcons.heart;
      case 'userPlus':
        return LucideIcons.userPlus;
      case 'gitFork':
        return LucideIcons.gitFork;
      default:
        return LucideIcons.activity;
    }
  }
  
  String _formatActivityTime(dynamic timestamp) {
    if (timestamp == null) return '';
    
    try {
      final DateTime time = timestamp is DateTime 
          ? timestamp 
          : DateTime.parse(timestamp.toString());
      
      final now = DateTime.now();
      final difference = now.difference(time);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${time.day}/${time.month}/${time.year}';
      }
    } catch (e) {
      return '';
    }
  }
  
  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(time, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
  
  Widget _buildAboutTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_isEditMode) ...[
          AppTextField(
            controller: _bioController,
            label: 'Bio',
            hint: 'Tell us about yourself',
            maxLines: 3,
            prefixIcon: const Icon(LucideIcons.user, size: 20),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _websiteController,
            label: 'Website',
            hint: 'https://example.com',
            prefixIcon: const Icon(LucideIcons.globe, size: 20),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _twitterController,
            label: 'Twitter',
            hint: '@username',
            prefixIcon: const Icon(LucideIcons.twitter, size: 20),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _linkedinController,
            label: 'LinkedIn',
            hint: 'linkedin.com/in/username',
            prefixIcon: const Icon(LucideIcons.linkedin, size: 20),
          ),
        ] else ...[
          Obx(() {
            final user = _profileController.currentUser.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                  Text(
                    'Bio',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(user.bio!),
                  const SizedBox(height: 20),
                ],
                
                // Website, Twitter, LinkedIn fields not in UserModel yet
                // Will be added when backend supports these fields
                
                _buildInfoRow(
                  LucideIcons.calendar,
                  'Member Since',
                  _formatDate(user?.joinedAt),
                ),
              ],
            );
          }),
        ],
      ],
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.neutral500),
              ),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSecurityTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Biometric Authentication
        Card(
          child: Obx(() {
            final biometricType = _authController.biometricType.value;
            final isEnabled = _authController.isBiometricEnabled.value;
            
            // Show Face ID by default if no biometric is detected
            final displayType = biometricType.isNotEmpty ? biometricType : 'Face ID';
            
            return SwitchListTile(
              title: Text('$displayType Login'),
              subtitle: Text('Use $displayType for quick access'),
              secondary: Icon(
                displayType == 'Face ID' ? Icons.face : Icons.fingerprint,
                color: AppColors.primary,
              ),
              value: isEnabled,
              onChanged: biometricType.isNotEmpty ? (value) {
                HapticService.lightImpact();
                _toggleBiometric();
              } : null,
            );
          }),
        ),
        
        const SizedBox(height: 12),
        
        // Change Password
        Card(
          child: ListTile(
            leading: const Icon(LucideIcons.lock, color: AppColors.primary),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () {
              // Navigate to change password
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Two-Factor Authentication
        Card(
          child: ListTile(
            leading: const Icon(LucideIcons.shield, color: AppColors.primary),
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Add an extra layer of security'),
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () {
              // Navigate to 2FA settings
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Privacy Settings
        Card(
          child: ListTile(
            leading: const Icon(LucideIcons.eye, color: AppColors.primary),
            title: const Text('Privacy Settings'),
            subtitle: const Text('Control who can see your profile'),
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Active Sessions
        Card(
          child: ListTile(
            leading: const Icon(LucideIcons.smartphone, color: AppColors.primary),
            title: const Text('Active Sessions'),
            subtitle: const Text('Manage your logged in devices'),
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () {
              // Navigate to active sessions
            },
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Logout Button
        AppButton(
          text: 'Sign Out',
          onPressed: () {
            Get.dialog(
              AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      _authController.logout();
                    },
                    child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          type: AppButtonType.danger,
          isFullWidth: true,
        ),
      ],
    );
  }
  
  void _toggleBiometric() async {
    final isEnabled = _authController.isBiometricEnabled.value;
    
    if (isEnabled) {
      // Disable biometric
      await _authController.disableBiometric();
      Get.snackbar(
        'Success',
        'Biometric authentication disabled',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // Enable biometric - need to get credentials
      Get.dialog(
        AlertDialog(
          title: Text('Enable ${_authController.biometricType.value}'),
          content: Text('To enable ${_authController.biometricType.value}, please confirm your credentials.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                // For now, we'll need the user to re-authenticate
                // In a real app, you'd prompt for password or use stored credentials
                final user = _authController.user.value;
                if (user != null && user.email.isNotEmpty) {
                  // You might want to show a password dialog here
                  Get.snackbar(
                    'Info',
                    'Please sign out and sign in again to enable biometric authentication',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
}