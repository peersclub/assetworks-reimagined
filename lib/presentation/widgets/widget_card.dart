import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';

class WidgetCard extends StatelessWidget {
  final String title;
  final String author;
  final String authorId;
  final DateTime date;
  final int likes;
  final int comments;
  final int shares;
  final String? imageUrl;
  final String? description;
  final List<String> tags;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onReport;
  
  const WidgetCard({
    Key? key,
    required this.title,
    required this.author,
    required this.authorId,
    required this.date,
    required this.likes,
    required this.comments,
    required this.shares,
    this.imageUrl,
    this.description,
    this.tags = const [],
    this.isSaved = false,
    this.onTap,
    this.onAuthorTap,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onReport,
  }) : super(key: key);
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info and date
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    author.isNotEmpty ? author[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onAuthorTap,
                      child: Text(
                        author,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  LucideIcons.moreVertical,
                  size: 20,
                  color: isDark ? AppColors.neutral500 : AppColors.neutral600,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'save':
                      onSave?.call();
                      break;
                    case 'share':
                      onShare?.call();
                      break;
                    case 'report':
                      onReport?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'save',
                    child: Row(
                      children: [
                        Icon(
                          isSaved ? LucideIcons.bookmarkMinus : LucideIcons.bookmark,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(isSaved ? 'Unsave' : 'Save'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(LucideIcons.share2, size: 18),
                        SizedBox(width: 12),
                        Text('Share'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(LucideIcons.flag, size: 18),
                        SizedBox(width: 12),
                        Text('Report'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Description
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Tags
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              _ActionButton(
                icon: LucideIcons.heart,
                label: _formatCount(likes),
                isActive: false,
                onTap: onLike,
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: LucideIcons.messageCircle,
                label: _formatCount(comments),
                isActive: false,
                onTap: onComment,
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: LucideIcons.share2,
                label: _formatCount(shares),
                isActive: false,
                onTap: onShare,
              ),
              const Spacer(),
              IconButton(
                onPressed: onSave,
                icon: Icon(
                  isSaved ? LucideIcons.bookmarkMinus : LucideIcons.bookmark,
                  size: 20,
                  color: isSaved 
                      ? AppColors.primary 
                      : (isDark ? AppColors.neutral500 : AppColors.neutral600),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isActive 
        ? AppColors.primary 
        : (isDark ? AppColors.neutral500 : AppColors.neutral600);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}