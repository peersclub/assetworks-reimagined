import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

class AppBottomSheet {
  static Future<T?> show<T>({
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
    bool isScrollControlled = false,
    EdgeInsetsGeometry? padding,
    VoidCallback? onClose,
  }) {
    return Get.bottomSheet<T>(
      _BottomSheetContent(
        title: title,
        onClose: onClose,
        padding: padding,
        child: child,
      ),
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      enterBottomSheetDuration: const Duration(milliseconds: 250),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
    );
  }
  
  static Future<T?> showOptions<T>({
    required String title,
    required List<BottomSheetOption> options,
    String? subtitle,
    bool showCancel = true,
  }) {
    return show<T>(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: Get.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
          ...options.map((option) => _OptionTile(option: option)),
          if (showCancel) ...[
            const SizedBox(height: 8),
            _OptionTile(
              option: BottomSheetOption(
                title: 'Cancel',
                icon: LucideIcons.x,
                onTap: () => Get.back(),
                isDestructive: false,
              ),
            ),
          ],
        ],
      ),
      title: title,
      isScrollControlled: true,
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  final String? title;
  final Widget child;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? padding;
  
  const _BottomSheetContent({
    this.title,
    required this.child,
    this.onClose,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.neutral700 : AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (onClose != null)
                    IconButton(
                      onPressed: () {
                        onClose!();
                        Get.back();
                      },
                      icon: const Icon(LucideIcons.x, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                ],
              ),
            ),
          
          // Content
          Flexible(
            child: Padding(
              padding: padding ?? const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomSheetOption {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isDisabled;
  
  const BottomSheetOption({
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.isDestructive = false,
    this.isDisabled = false,
  });
}

class _OptionTile extends StatelessWidget {
  final BottomSheetOption option;
  
  const _OptionTile({required this.option});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color textColor;
    if (option.isDisabled) {
      textColor = isDark ? AppColors.neutral600 : AppColors.neutral400;
    } else if (option.isDestructive) {
      textColor = AppColors.error;
    } else {
      textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    }
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: option.isDisabled ? null : () {
          Get.back();
          option.onTap?.call();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (option.icon != null) ...[
                Icon(
                  option.icon,
                  size: 22,
                  color: textColor,
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark 
                              ? AppColors.textSecondaryDark 
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}