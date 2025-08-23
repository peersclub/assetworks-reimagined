import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../services/haptic_service.dart';
import 'app_button.dart';

enum ErrorType {
  network,
  server,
  authentication,
  validation,
  notFound,
  permission,
  unknown,
}

class ErrorStateWidget extends StatelessWidget {
  final ErrorType errorType;
  final String? customTitle;
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionText;
  final bool showDetails;
  final String? errorDetails;
  
  const ErrorStateWidget({
    Key? key,
    this.errorType = ErrorType.unknown,
    this.customTitle,
    this.customMessage,
    this.onRetry,
    this.onSecondaryAction,
    this.secondaryActionText,
    this.showDetails = false,
    this.errorDetails,
  }) : super(key: key);
  
  IconData get _icon {
    switch (errorType) {
      case ErrorType.network:
        return LucideIcons.wifiOff;
      case ErrorType.server:
        return LucideIcons.serverCrash;
      case ErrorType.authentication:
        return LucideIcons.userX;
      case ErrorType.validation:
        return LucideIcons.alertCircle;
      case ErrorType.notFound:
        return LucideIcons.searchX;
      case ErrorType.permission:
        return LucideIcons.lock;
      case ErrorType.unknown:
      default:
        return LucideIcons.xCircle;
    }
  }
  
  Color get _iconColor {
    switch (errorType) {
      case ErrorType.network:
        return AppColors.warning;
      case ErrorType.authentication:
      case ErrorType.permission:
        return AppColors.error;
      default:
        return AppColors.error;
    }
  }
  
  String get _title {
    if (customTitle != null) return customTitle!;
    
    switch (errorType) {
      case ErrorType.network:
        return 'Connection Problem';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.authentication:
        return 'Authentication Failed';
      case ErrorType.validation:
        return 'Invalid Data';
      case ErrorType.notFound:
        return 'Not Found';
      case ErrorType.permission:
        return 'Access Denied';
      case ErrorType.unknown:
      default:
        return 'Something Went Wrong';
    }
  }
  
  String get _message {
    if (customMessage != null) return customMessage!;
    
    switch (errorType) {
      case ErrorType.network:
        return 'Please check your internet connection and try again.';
      case ErrorType.server:
        return 'Our servers are having issues. Please try again later.';
      case ErrorType.authentication:
        return 'Please sign in again to continue.';
      case ErrorType.validation:
        return 'Please check your input and try again.';
      case ErrorType.notFound:
        return 'The requested content could not be found.';
      case ErrorType.permission:
        return 'You don\'t have permission to access this content.';
      case ErrorType.unknown:
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
  
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 48,
                color: _iconColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (showDetails && errorDetails != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.neutral800 : AppColors.neutral100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorDetails!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (onRetry != null)
              AppButton(
                text: 'Try Again',
                onPressed: () {
                  HapticService.mediumImpact();
                  onRetry!();
                },
                type: AppButtonType.primary,
                icon: LucideIcons.refreshCw,
                isFullWidth: true,
              ),
            if (onSecondaryAction != null) ...[
              const SizedBox(height: 12),
              AppButton(
                text: secondaryActionText ?? 'Go Back',
                onPressed: () {
                  HapticService.lightImpact();
                  onSecondaryAction!();
                },
                type: AppButtonType.outline,
                isFullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Factory constructors for common error scenarios
  static Widget networkError({VoidCallback? onRetry}) {
    return ErrorStateWidget(
      errorType: ErrorType.network,
      onRetry: onRetry,
    );
  }
  
  static Widget serverError({VoidCallback? onRetry}) {
    return ErrorStateWidget(
      errorType: ErrorType.server,
      onRetry: onRetry,
    );
  }
  
  static Widget authenticationError({
    VoidCallback? onSignIn,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      errorType: ErrorType.authentication,
      onRetry: onRetry,
      onSecondaryAction: onSignIn,
      secondaryActionText: 'Sign In',
    );
  }
  
  static Widget notFoundError({VoidCallback? onGoBack}) {
    return ErrorStateWidget(
      errorType: ErrorType.notFound,
      onSecondaryAction: onGoBack,
      secondaryActionText: 'Go Back',
    );
  }
  
  static Widget permissionError({VoidCallback? onRequestAccess}) {
    return ErrorStateWidget(
      errorType: ErrorType.permission,
      onSecondaryAction: onRequestAccess,
      secondaryActionText: 'Request Access',
    );
  }
  
  static Widget customError({
    required String title,
    required String message,
    VoidCallback? onRetry,
    String? details,
  }) {
    return ErrorStateWidget(
      errorType: ErrorType.unknown,
      customTitle: title,
      customMessage: message,
      onRetry: onRetry,
      errorDetails: details,
      showDetails: details != null,
    );
  }
}