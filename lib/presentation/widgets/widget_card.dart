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
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'finance':
      case 'banking':
        return LucideIcons.dollarSign;
      case 'technology':
      case 'tech':
        return LucideIcons.cpu;
      case 'health':
      case 'medical':
        return LucideIcons.heart;
      case 'education':
        return LucideIcons.graduationCap;
      case 'sports':
        return LucideIcons.trophy;
      case 'travel':
        return LucideIcons.plane;
      case 'food':
        return LucideIcons.utensils;
      case 'music':
        return LucideIcons.music;
      case 'gaming':
        return LucideIcons.gamepad2;
      case 'shopping':
        return LucideIcons.shoppingCart;
      case 'news':
        return LucideIcons.newspaper;
      case 'weather':
        return LucideIcons.cloud;
      case 'crypto':
      case 'bitcoin':
        return LucideIcons.bitcoin;
      default:
        return LucideIcons.layoutGrid;
    }
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    author.isNotEmpty && author != '-' && !author.startsWith('-') 
                        ? author.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  LucideIcons.moreVertical,
                  size: 16,
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
          
          const SizedBox(height: 8),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Description
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Tags with icon
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getCategoryIcon(tags.first),
                  size: 12,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tags.first,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          
          const Spacer(),
          
          // Action buttons
          Row(
            children: [
              _ActionButton(
                icon: LucideIcons.heart,
                label: _formatCount(likes),
                isActive: false,
                onTap: onLike,
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: LucideIcons.messageCircle,
                label: _formatCount(comments),
                isActive: false,
                onTap: onComment,
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: LucideIcons.share2,
                label: _formatCount(shares),
                isActive: false,
                onTap: onShare,
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSave,
                child: Icon(
                  isSaved ? LucideIcons.bookmarkMinus : LucideIcons.bookmark,
                  size: 16,
                  color: isSaved 
                      ? AppColors.primary 
                      : (isDark ? AppColors.neutral500 : AppColors.neutral600),
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
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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