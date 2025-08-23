import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/widget_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthController _authController;
  late WidgetController _widgetController;
  
  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _widgetController = Get.find<WidgetController>();
    _loadUserStats();
  }
  
  void _loadUserStats() {
    // Load user widgets and stats
    _widgetController.loadDashboardWidgets();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => _showSettingsMenu(),
            icon: const Icon(LucideIcons.settings, size: 22),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Obx(() {
                    final user = _authController.user.value;
                    final email = user?.email ?? '';
                    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'U';
                    
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.checkCircle,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  
                  // Email and Member Info
                  Obx(() {
                    final user = _authController.user.value;
                    return Column(
                      children: [
                        Text(
                          user?.email ?? 'User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Member since ${_formatDate(user?.joinedAt)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Active User | Widget Creator',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                  
                  // Stats
                  Obx(() {
                    final widgetCount = _widgetController.dashboardWidgets.length;
                    final likeCount = _widgetController.dashboardWidgets.fold<int>(
                      0, (sum, widget) => sum + widget.likes
                    );
                    final shareCount = _widgetController.dashboardWidgets.fold<int>(
                      0, (sum, widget) => sum + widget.shares
                    );
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Widgets', widgetCount.toString()),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                        ),
                        _buildStatItem('Likes', _formatCount(likeCount)),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                        ),
                        _buildStatItem('Shares', _formatCount(shareCount)),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Edit Profile',
                          icon: LucideIcons.edit3,
                          onPressed: () {},
                          size: AppButtonSize.medium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Share',
                          icon: LucideIcons.share2,
                          type: AppButtonType.outline,
                          onPressed: () {},
                          size: AppButtonSize.medium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Menu Items
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: LucideIcons.user,
                    title: 'Personal Information',
                    subtitle: 'Update your personal details',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: LucideIcons.bell,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: LucideIcons.shield,
                    title: 'Privacy & Security',
                    subtitle: 'Control your privacy settings',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: LucideIcons.creditCard,
                    title: 'Subscription',
                    subtitle: 'Premium member',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.crown,
                            size: 12,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {},
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Support',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: LucideIcons.helpCircle,
                    title: 'Help Center',
                    subtitle: 'Get help and support',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: LucideIcons.messageSquare,
                    title: 'Contact Us',
                    subtitle: 'Send us a message',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: LucideIcons.fileText,
                    title: 'Terms & Conditions',
                    subtitle: 'Read our terms',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: LucideIcons.lock,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () {},
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: LucideIcons.logOut,
                    title: 'Sign Out',
                    subtitle: 'Sign out of your account',
                    isDestructive: true,
                    onTap: () => _handleSignOut(),
                  ),
                  
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'AssetWorks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
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
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
  
  Widget _buildStatItem(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isDestructive ? AppColors.error : AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDestructive ? AppColors.error : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDestructive 
                        ? AppColors.error 
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) 
            trailing
          else
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark ? AppColors.neutral600 : AppColors.neutral400,
            ),
        ],
      ),
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
  
  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.neutral700
                      : AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(LucideIcons.palette),
                title: const Text('Appearance'),
                onTap: () {
                  Get.back();
                  // Handle appearance settings
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.globe),
                title: const Text('Language'),
                onTap: () {
                  Get.back();
                  // Handle language settings
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.download),
                title: const Text('Data & Storage'),
                onTap: () {
                  Get.back();
                  // Handle data settings
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.info),
                title: const Text('About'),
                onTap: () {
                  Get.back();
                  // Handle about
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              // Handle sign out
              Get.offAllNamed('/login');
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}