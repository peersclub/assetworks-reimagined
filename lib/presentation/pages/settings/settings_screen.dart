import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/theme/theme_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/otp_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeController = ThemeController.to;
    final authController = Get.find<AuthController>();
    final otpController = Get.find<OtpController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Obx(() {
              final user = authController.user.value;
              
              return Container(
                padding: const EdgeInsets.all(16),
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user?.username?.substring(0, 2).toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.toNamed('/profile'),
                      icon: const Icon(LucideIcons.user, size: 20),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 20),
            
            // Appearance Section (Working - Local Storage)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppCard(
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: LucideIcons.moon,
                      title: 'Dark Mode',
                      subtitle: 'Theme preference (stored locally)',
                      trailing: Obx(() => Switch(
                        value: themeController.isDarkMode,
                        onChanged: (value) => themeController.toggleTheme(),
                        activeColor: AppColors.primary,
                      )),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Account Section (Only Working Features)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppCard(
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: LucideIcons.user,
                      title: 'My Profile',
                      subtitle: 'View your profile and widgets',
                      onTap: () => Get.toNamed('/profile'),
                    ),
                    _buildDivider(isDark),
                    _buildSettingItem(
                      icon: LucideIcons.logOut,
                      title: 'Sign Out',
                      subtitle: 'Sign out from your account',
                      onTap: () => _showLogoutDialog(context, authController),
                      textColor: AppColors.error,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // About Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'About',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppCard(
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: LucideIcons.info,
                      title: 'Version',
                      subtitle: '1.0.0',
                      trailing: null,
                    ),
                    _buildDivider(isDark),
                    _buildSettingItem(
                      icon: LucideIcons.globe,
                      title: 'API Status',
                      subtitle: 'https://staging-api.assetworks.ai',
                      trailing: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: textColor ?? Get.theme.iconTheme.color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor?.withOpacity(0.7) ?? 
                               (Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: Get.isDarkMode ? AppColors.neutral600 : AppColors.neutral400,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 54,
      color: isDark ? AppColors.neutral800 : AppColors.neutral200,
    );
  }
  
  void _showLogoutDialog(BuildContext context, AuthController authController) {
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
              authController.logout();
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