import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/widget_response_model.dart';

class RemixInfoCard extends StatelessWidget {
  final WidgetResponseModel widget;
  final VoidCallback? onViewOriginal;
  final VoidCallback? onRemoveRemix;
  final bool showInPromptArea;
  
  const RemixInfoCard({
    Key? key,
    required this.widget,
    this.onViewOriginal,
    this.onRemoveRemix,
    this.showInPromptArea = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (!widget.isRemix || widget.remixedFromId == null) {
      return const SizedBox.shrink();
    }
    
    final createdDate = widget.remixedFromCreatedAt != null
        ? DateTime.fromMillisecondsSinceEpoch(widget.remixedFromCreatedAt!)
        : null;
    
    return Container(
      margin: EdgeInsets.only(bottom: showInPromptArea ? 16 : 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with remix icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.gitBranch,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remixed From',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.remixedFromTitle ?? 'Original Widget',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (showInPromptArea && onRemoveRemix != null)
                IconButton(
                  onPressed: onRemoveRemix,
                  icon: Icon(
                    LucideIcons.x,
                    size: 18,
                    color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Original creator info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark 
                ? AppColors.surfaceDark.withOpacity(0.5)
                : AppColors.surfaceLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Creator info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        (widget.remixedFromUsername ?? 'U')[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'by ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark 
                                    ? AppColors.textSecondaryDark 
                                    : AppColors.textSecondaryLight,
                                ),
                              ),
                              Text(
                                '@${widget.remixedFromUsername ?? 'unknown'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (createdDate != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              timeago.format(createdDate),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark 
                                  ? AppColors.textSecondaryDark 
                                  : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onViewOriginal != null)
                      AppButton(
                        text: 'View Original',
                        icon: LucideIcons.externalLink,
                        size: AppButtonSize.small,
                        type: AppButtonType.outline,
                        onPressed: onViewOriginal,
                      ),
                  ],
                ),
                
                // Original prompt (if available and in prompt area)
                if (showInPromptArea && widget.remixedFromPrompt != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? AppColors.neutral900.withOpacity(0.5)
                        : AppColors.neutral100.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark 
                          ? AppColors.neutral800 
                          : AppColors.neutral200,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.messageSquare,
                              size: 12,
                              color: isDark 
                                ? AppColors.textSecondaryDark 
                                : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Original Prompt',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark 
                                  ? AppColors.textSecondaryDark 
                                  : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.remixedFromPrompt!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark 
                              ? AppColors.textPrimaryDark 
                              : AppColors.textPrimaryLight,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Attribution notice
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.info,
                  size: 14,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    showInPromptArea 
                      ? 'This widget will be marked as a remix with attribution to the original creator'
                      : 'This is a remixed widget. Original creator has been attributed.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.info,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RemixBadge extends StatelessWidget {
  final bool small;
  
  const RemixBadge({
    Key? key,
    this.small = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(small ? 4 : 6),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.gitBranch,
            size: small ? 10 : 12,
            color: Colors.white,
          ),
          SizedBox(width: small ? 3 : 4),
          Text(
            'REMIXED',
            style: TextStyle(
              fontSize: small ? 9 : 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}