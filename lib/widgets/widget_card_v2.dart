import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/dashboard_widget.dart';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';

class WidgetCardV2 extends StatefulWidget {
  final DashboardWidget widget;
  final Function(String) onAction;
  
  const WidgetCardV2({
    Key? key,
    required this.widget,
    required this.onAction,
  }) : super(key: key);
  
  @override
  State<WidgetCardV2> createState() => _WidgetCardV2State();
}

class _WidgetCardV2State extends State<WidgetCardV2> {
  final ApiService _apiService = Get.find<ApiService>();
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onAction('preview');
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).brightness == Brightness.dark
              ? CupertinoColors.systemGrey6.darkColor
              : CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header with Follow Button
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.systemIndigo,
                          CupertinoColors.systemPurple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        (widget.widget.username != null && widget.widget.username!.isNotEmpty)
                            ? widget.widget.username!.substring(0, 1).toUpperCase()
                            : 'A',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Username and Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '@${widget.widget.username ?? 'anonymous'}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: CupertinoTheme.of(context).textTheme.textStyle.color,
                              ),
                            ),
                            if (widget.widget.verified == true) ...[
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                size: 14,
                                color: CupertinoColors.activeBlue,
                              ),
                            ],
                          ],
                        ),
                        if (widget.widget.title != null)
                          Text(
                            widget.widget.title!,
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  
                  // Follow Button
                  CupertinoButton(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    minSize: 0,
                    borderRadius: BorderRadius.circular(14),
                    color: widget.widget.follow 
                        ? CupertinoColors.systemGrey5
                        : CupertinoColors.activeBlue,
                    child: Text(
                      widget.widget.follow ? 'Following' : 'Follow',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.widget.follow 
                            ? CupertinoColors.label
                            : CupertinoColors.white,
                      ),
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final success = widget.widget.follow
                          ? await _apiService.unfollowUser(widget.widget.user_id ?? '')
                          : await _apiService.followUser(widget.widget.user_id ?? '');
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
                    },
                  ),
                ],
              ),
              
              // Claude Response Summary
              if (widget.widget.summary != null || widget.widget.description != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.systemGrey5,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.sparkles,
                            size: 14,
                            color: CupertinoColors.systemIndigo,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI Summary',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.systemIndigo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.widget.summary ?? widget.widget.description ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoTheme.of(context).textTheme.textStyle.color,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              
              // Original Prompt (if available)
              if (widget.widget.original_prompt != null) ...[
                const SizedBox(height: 8),
                Text(
                  '"${widget.widget.original_prompt}"',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: CupertinoColors.systemGrey2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Stats Row
              Row(
                children: [
                  _buildStat(
                    CupertinoIcons.eye,
                    widget.widget.views_count?.toString() ?? '0',
                  ),
                  const SizedBox(width: 20),
                  _buildStat(
                    CupertinoIcons.heart,
                    widget.widget.likes_count?.toString() ?? '0',
                  ),
                  const SizedBox(width: 20),
                  _buildStat(
                    CupertinoIcons.chat_bubble,
                    widget.widget.comments_count?.toString() ?? '0',
                  ),
                  const Spacer(),
                  _buildTimeAgo(),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    context,
                    icon: widget.widget.like 
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color: widget.widget.like
                        ? CupertinoColors.systemRed
                        : null,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final success = widget.widget.like
                          ? await _apiService.dislikeWidget(widget.widget.id)
                          : await _apiService.likeWidget(widget.widget.id);
                      if (success) {
                        setState(() {
                          widget.widget.like = !widget.widget.like;
                        });
                      }
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: widget.widget.save
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    color: widget.widget.save
                        ? CupertinoColors.systemIndigo
                        : null,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final success = await _apiService.saveWidgetToProfile(widget.widget.id);
                      if (success) {
                        setState(() {
                          widget.widget.save = !widget.widget.save;
                        });
                        DynamicIslandService().updateStatus(
                          widget.widget.save ? 'Saved!' : 'Removed',
                          icon: widget.widget.save 
                              ? CupertinoIcons.bookmark_fill
                              : CupertinoIcons.bookmark,
                        );
                      }
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: CupertinoIcons.arrow_2_squarepath,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onAction('remix');
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: CupertinoIcons.share,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onAction('share');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeAgo() {
    if (widget.widget.created_at == null) return SizedBox.shrink();
    
    final now = DateTime.now();
    final difference = now.difference(widget.widget.created_at!);
    
    String timeAgo;
    if (difference.inDays > 30) {
      timeAgo = '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}m';
    } else {
      timeAgo = 'now';
    }
    
    return Text(
      timeAgo,
      style: TextStyle(
        fontSize: 12,
        color: CupertinoColors.systemGrey2,
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 32,
      child: Icon(
        icon,
        size: 20,
        color: color ?? CupertinoColors.systemGrey,
      ),
      onPressed: onTap,
    );
  }
}