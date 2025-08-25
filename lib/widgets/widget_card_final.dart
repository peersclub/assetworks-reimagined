import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../models/dashboard_widget.dart';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';
import '../screens/user_profile_screen.dart';
import '../screens/widget_creator_screen.dart';

class WidgetCardFinal extends StatefulWidget {
  final DashboardWidget widget;
  final Function(String) onAction;
  
  const WidgetCardFinal({
    Key? key,
    required this.widget,
    required this.onAction,
  }) : super(key: key);
  
  @override
  State<WidgetCardFinal> createState() => _WidgetCardFinalState();
}

class _WidgetCardFinalState extends State<WidgetCardFinal> {
  final ApiService _apiService = Get.find<ApiService>();
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onAction('preview');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).brightness == Brightness.dark
              ? CupertinoColors.darkBackgroundGray
              : CupertinoColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header Section
              Row(
                children: [
                  // Clickable User Avatar
                  GestureDetector(
                    onTap: () => _navigateToUserProfile(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Text(
                          _getUserInitial(),
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Username and Widget Title
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToUserProfile(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username (More Prominent)
                          Row(
                            children: [
                              Text(
                                '@${widget.widget.username ?? 'anonymous'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: CupertinoTheme.of(context).textTheme.textStyle.color,
                                ),
                              ),
                              if (widget.widget.verified == true) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: 16,
                                  color: Color(0xFF1DA1F2),
                                ),
                              ],
                            ],
                          ),
                          // Widget Title (Smaller)
                          if (widget.widget.title != null)
                            Text(
                              widget.widget.title!,
                              style: TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemGrey,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Follow Button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.widget.follow 
                            ? CupertinoColors.systemGrey5
                            : Color(0xFF1DA1F2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        widget.widget.follow ? 'Following' : 'Follow',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.widget.follow 
                              ? CupertinoColors.label
                              : CupertinoColors.white,
                        ),
                      ),
                    ),
                    onPressed: () => _handleFollowAction(),
                  ),
                ],
              ),
              
              // AI Summary Section
              if (widget.widget.summary != null || widget.widget.description != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFFE0F2FE),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.sparkles,
                            size: 16,
                            color: Color(0xFF0EA5E9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI Summary',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0EA5E9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.widget.summary ?? widget.widget.description ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.black,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              
              // Original Prompt
              if (widget.widget.original_prompt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.quote_bubble,
                      size: 14,
                      color: CupertinoColors.systemGrey3,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '"${widget.widget.original_prompt}"',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: CupertinoColors.systemGrey2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Actions Row (No stats on left, only actions on right)
              Container(
                padding: EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: CupertinoColors.systemGrey5,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      icon: widget.widget.like 
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: widget.widget.like
                          ? CupertinoColors.systemRed
                          : CupertinoColors.systemGrey3,
                      onTap: () => _handleLikeAction(),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: widget.widget.save
                          ? CupertinoIcons.add_circled_solid
                          : CupertinoIcons.add_circled,
                      color: widget.widget.save
                          ? Color(0xFF6366F1)
                          : CupertinoColors.systemGrey3,
                      onTap: () => _handleAddToDashboard(),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: CupertinoIcons.arrow_2_squarepath,
                      color: CupertinoColors.systemGrey3,
                      onTap: () => widget.onAction('remix'),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: CupertinoIcons.share,
                      color: CupertinoColors.systemGrey3,
                      onTap: () => _handleShareAction(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getUserInitials() {
    if (widget.widget.username != null && widget.widget.username!.isNotEmpty) {
      final parts = widget.widget.username!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return widget.widget.username!.substring(0, min(2, widget.widget.username!.length)).toUpperCase();
    }
    return 'AN';
  }
  
  String _getUserInitial() {
    return _getUserInitials();
  }
  
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
  
  Widget _buildCompactStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: CupertinoColors.systemGrey3,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: CupertinoColors.systemGrey2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 28,
      child: Icon(
        icon,
        size: 22,
        color: color,
      ),
      onPressed: onTap,
    );
  }
  
  void _navigateToUserProfile() {
    if (widget.widget.user_id != null) {
      HapticFeedback.lightImpact();
      Get.to(() => UserProfileScreen(
        userId: widget.widget.user_id!,
        username: widget.widget.username,
      ));
    }
  }
  
  Future<void> _handleFollowAction() async {
    HapticFeedback.lightImpact();
    
    if (widget.widget.user_id == null) return;
    
    final success = widget.widget.follow
        ? await _apiService.unfollowUser(widget.widget.user_id!)
        : await _apiService.followUser(widget.widget.user_id!);
        
    if (success) {
      setState(() {
        widget.widget.follow = !widget.widget.follow;
      });
      
      DynamicIslandService().updateStatus(
        widget.widget.follow ? 'Following!' : 'Unfollowed',
        icon: widget.widget.follow 
            ? CupertinoIcons.person_add_solid
            : CupertinoIcons.person_badge_minus,
      );
    }
  }
  
  Future<void> _handleLikeAction() async {
    HapticFeedback.lightImpact();
    
    final success = widget.widget.like
        ? await _apiService.dislikeWidget(widget.widget.id)
        : await _apiService.likeWidget(widget.widget.id);
        
    if (success) {
      setState(() {
        widget.widget.like = !widget.widget.like;
      });
    }
  }
  
  Future<void> _handleAddToDashboard() async {
    HapticFeedback.lightImpact();
    
    final success = widget.widget.save
        ? await _apiService.removeWidgetFromDashboard(widget.widget.id)
        : await _apiService.addWidgetToDashboard(widget.widget.id);
    
    if (success) {
      setState(() {
        widget.widget.save = !widget.widget.save;
      });
      
      DynamicIslandService().updateStatus(
        widget.widget.save ? 'Added to Dashboard!' : 'Removed from Dashboard',
        icon: widget.widget.save 
            ? CupertinoIcons.add_circled_solid
            : CupertinoIcons.minus_circled,
      );
    }
  }
  
  Future<void> _handleShareAction() async {
    HapticFeedback.lightImpact();
    
    final shareUrl = 'https://assetworks.ai/widget/${widget.widget.id}';
    final shareText = '${widget.widget.title ?? "Check out this widget"} by @${widget.widget.username ?? "anonymous"}\n\nCreated with AssetWorks AI\n$shareUrl';
    
    // Show share sheet
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Share Widget'),
        message: Text(widget.widget.title ?? 'Investment Widget'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Copy link to clipboard
              Clipboard.setData(ClipboardData(text: shareUrl));
              DynamicIslandService().updateStatus(
                'Link copied!',
                icon: CupertinoIcons.doc_on_clipboard_fill,
              );
            },
            child: const Text('Copy Link'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Copy full text
              Clipboard.setData(ClipboardData(text: shareText));
              DynamicIslandService().updateStatus(
                'Copied to clipboard!',
                icon: CupertinoIcons.doc_on_clipboard_fill,
              );
            },
            child: const Text('Copy Text'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              widget.onAction('share');
            },
            child: const Text('More Options'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}