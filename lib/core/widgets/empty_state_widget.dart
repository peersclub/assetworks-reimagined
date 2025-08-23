import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../services/haptic_service.dart';
import 'app_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customAction;
  final double iconSize;
  final Color? iconColor;
  
  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.customAction,
    this.iconSize = 64,
    this.iconColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (customAction != null)
              customAction!
            else if (buttonText != null && onButtonPressed != null)
              AppButton(
                text: buttonText!,
                onPressed: () {
                  HapticService.mediumImpact();
                  onButtonPressed!();
                },
                type: AppButtonType.primary,
                icon: LucideIcons.plus,
              ),
          ],
        ),
      ),
    );
  }
  
  // Predefined empty states for common scenarios
  static Widget noWidgets({VoidCallback? onCreateWidget}) {
    return EmptyStateWidget(
      icon: LucideIcons.package,
      title: 'No Widgets Yet',
      message: 'Create your first widget to start building your investment dashboard',
      buttonText: 'Create Widget',
      onButtonPressed: onCreateWidget,
      iconColor: AppColors.primary,
    );
  }
  
  static Widget noNotifications() {
    return const EmptyStateWidget(
      icon: LucideIcons.bellOff,
      title: 'All Caught Up!',
      message: 'You have no new notifications. We\'ll let you know when something important happens.',
      iconColor: AppColors.info,
    );
  }
  
  static Widget noSearchResults({VoidCallback? onClearSearch}) {
    return EmptyStateWidget(
      icon: LucideIcons.searchX,
      title: 'No Results Found',
      message: 'Try adjusting your search or filters to find what you\'re looking for',
      buttonText: 'Clear Search',
      onButtonPressed: onClearSearch,
      iconColor: AppColors.warning,
    );
  }
  
  static Widget noHistory() {
    return const EmptyStateWidget(
      icon: LucideIcons.history,
      title: 'No History Yet',
      message: 'Your prompt history will appear here as you create widgets and analyses',
      iconColor: AppColors.neutral500,
    );
  }
  
  static Widget noFollowers() {
    return const EmptyStateWidget(
      icon: LucideIcons.userPlus,
      title: 'No Followers Yet',
      message: 'Share your widgets and analyses to build your following',
      iconColor: AppColors.primary,
    );
  }
  
  static Widget noFollowing({VoidCallback? onDiscover}) {
    return EmptyStateWidget(
      icon: LucideIcons.users,
      title: 'Not Following Anyone',
      message: 'Discover and follow other users to see their widgets in your feed',
      buttonText: 'Discover Users',
      onButtonPressed: onDiscover,
      iconColor: AppColors.primary,
    );
  }
  
  static Widget noInternet({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: LucideIcons.wifiOff,
      title: 'No Internet Connection',
      message: 'Please check your connection and try again',
      buttonText: 'Retry',
      onButtonPressed: onRetry,
      iconColor: AppColors.error,
    );
  }
  
  static Widget emptyAnalysis({VoidCallback? onAnalyze}) {
    return EmptyStateWidget(
      icon: LucideIcons.barChart3,
      title: 'No Analysis Available',
      message: 'Start analyzing market data to get insights',
      buttonText: 'Start Analysis',
      onButtonPressed: onAnalyze,
      iconColor: AppColors.success,
    );
  }
}