import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/haptic_service.dart';
import '../../data/models/widget_model.dart';
import '../../services/api_service.dart';

class InteractiveCompactWidgetCard extends StatefulWidget {
  final WidgetModel widget;
  final VoidCallback? onTap;
  
  const InteractiveCompactWidgetCard({
    Key? key,
    required this.widget,
    this.onTap,
  }) : super(key: key);
  
  @override
  State<InteractiveCompactWidgetCard> createState() => _InteractiveCompactWidgetCardState();
}

class _InteractiveCompactWidgetCardState extends State<InteractiveCompactWidgetCard> 
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late AnimationController _saveAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _saveScaleAnimation;
  
  // Local state since model fields are immutable
  late bool _isLiked;
  late bool _isSaved;
  late int _likesCount;
  
  final ApiService _apiService = Get.find<ApiService>();
  
  @override
  void initState() {
    super.initState();
    _initAnimations();
    // Initialize local state from model
    _isLiked = widget.widget.isLiked;
    _isSaved = widget.widget.isSaved;
    _likesCount = widget.widget.likes;
  }
  
  void _initAnimations() {
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _saveScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.elasticOut,
    ));
  }
  
  Future<void> _handleLike() async {
    HapticService.mediumImpact();
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likesCount++;
      } else {
        _likesCount = (_likesCount > 0) ? _likesCount - 1 : 0;
      }
    });
    
    if (_isLiked) {
      await _apiService.likeWidget(widget.widget.id);
    } else {
      await _apiService.dislikeWidget(widget.widget.id);
    }
  }
  
  Future<void> _handleSave() async {
    HapticService.mediumImpact();
    _saveAnimationController.forward().then((_) {
      _saveAnimationController.reverse();
    });
    
    setState(() {
      _isSaved = !_isSaved;
    });
    
    await _apiService.saveWidgetToProfile(widget.widget.id);
  }
  
  Future<void> _handleShare() async {
    HapticService.lightImpact();
    await Share.share(
      'Check out this widget: ${widget.widget.title}\n'
      'https://assetworks.ai/widget/${widget.widget.id}',
      subject: 'AssetWorks Widget',
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}';
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'finance':
      case 'general':
        return LucideIcons.trendingUp;
      case 'technology':
        return LucideIcons.cpu;
      case 'crypto':
        return LucideIcons.bitcoin;
      default:
        return LucideIcons.layoutGrid;
    }
  }
  
  @override
  void dispose() {
    _likeAnimationController.dispose();
    _saveAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.neutral800 : AppColors.neutral200,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with author and time
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.neutral900 : AppColors.neutral50).withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.widget.authorName?.isNotEmpty == true
                            ? widget.widget.authorName!.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.widget.authorName ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(widget.widget.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.widget.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Category
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(widget.widget.category ?? 'Investment'),
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.widget.category ?? 'Investment',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Engagement buttons
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                    width: 0.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Like button
                  AnimatedBuilder(
                    animation: _likeScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _likeScaleAnimation.value,
                        child: IconButton(
                          icon: Icon(
                            _isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: _isLiked
                                ? Colors.red
                                : (isDark ? AppColors.neutral600 : AppColors.neutral400),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: _handleLike,
                        ),
                      );
                    },
                  ),
                  
                  // Save button
                  AnimatedBuilder(
                    animation: _saveScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _saveScaleAnimation.value,
                        child: IconButton(
                          icon: Icon(
                            _isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 18,
                            color: _isSaved
                                ? AppColors.primary
                                : (isDark ? AppColors.neutral600 : AppColors.neutral400),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: _handleSave,
                        ),
                      );
                    },
                  ),
                  
                  // Share button
                  IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _handleShare,
                  ),
                  
                  // Likes count
                  Row(
                    children: [
                      Text(
                        '$_likesCount',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'likes',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}