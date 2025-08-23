import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

enum AppButtonType { primary, secondary, outline, text, danger }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? margin;
  
  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.margin,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final buttonStyle = _getButtonStyle(context, isDark);
    final textStyle = _getTextStyle(context);
    final padding = _getPadding();
    final height = _getHeight();
    
    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(right: 8),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.primary || type == AppButtonType.danger
                    ? Colors.white
                    : AppColors.primary,
              ),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: size == AppButtonSize.small ? 16 : 18),
          const SizedBox(width: 8),
        ],
        Text(text, style: textStyle),
      ],
    );
    
    Widget button;
    
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
      case AppButtonType.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            minimumSize: WidgetStateProperty.all(
              Size(isFullWidth ? double.infinity : 0, height),
            ),
            padding: WidgetStateProperty.all(padding),
          ),
          child: buttonContent,
        );
        break;
        
      case AppButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            minimumSize: WidgetStateProperty.all(
              Size(isFullWidth ? double.infinity : 0, height),
            ),
            padding: WidgetStateProperty.all(padding),
          ),
          child: buttonContent,
        );
        break;
        
      case AppButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            minimumSize: WidgetStateProperty.all(
              Size(isFullWidth ? double.infinity : 0, height),
            ),
            padding: WidgetStateProperty.all(padding),
          ),
          child: buttonContent,
        );
        break;
    }
    
    if (margin != null) {
      return Padding(padding: margin!, child: button);
    }
    
    return button;
  }
  
  ButtonStyle _getButtonStyle(BuildContext context, bool isDark) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutral300,
          disabledForegroundColor: AppColors.neutral500,
        );
        
      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.neutral800 : AppColors.neutral100,
          foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          disabledBackgroundColor: AppColors.neutral300,
          disabledForegroundColor: AppColors.neutral500,
        );
        
      case AppButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutral300,
          disabledForegroundColor: AppColors.neutral500,
        );
        
      case AppButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: isDark ? AppColors.neutral700 : AppColors.neutral300,
          ),
          disabledForegroundColor: AppColors.neutral500,
        );
        
      case AppButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.neutral500,
        );
    }
  }
  
  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.labelLarge!;
    
    switch (size) {
      case AppButtonSize.small:
        return baseStyle.copyWith(fontSize: 12);
      case AppButtonSize.medium:
        return baseStyle.copyWith(fontSize: 14);
      case AppButtonSize.large:
        return baseStyle.copyWith(fontSize: 16);
    }
  }
  
  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }
  
  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 32;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.large:
        return 52;
    }
  }
}