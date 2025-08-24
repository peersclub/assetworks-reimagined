import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../models/dashboard_widget.dart';

class WidgetCard extends StatelessWidget {
  final DashboardWidget widget;
  final Function(String) onAction;
  
  const WidgetCard({
    Key? key,
    required this.widget,
    required this.onAction,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onAction('preview');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget Preview
            if (widget.preview_version_url != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.systemIndigo.withOpacity(0.3),
                          CupertinoColors.systemPurple.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.play_circle_fill,
                        size: 48,
                        color: CupertinoColors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Widget Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Username
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title ?? 'Untitled Widget',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.verified == true)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            size: 16,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Username
                  if (widget.username != null)
                    Text(
                      '@${widget.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Stats Row
                  Row(
                    children: [
                      _buildStat(
                        CupertinoIcons.eye,
                        widget.views_count?.toString() ?? '0',
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        CupertinoIcons.heart,
                        widget.likes_count?.toString() ?? '0',
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        CupertinoIcons.chat_bubble,
                        widget.comments_count?.toString() ?? '0',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionButton(
                        context,
                        icon: widget.like 
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: widget.like
                            ? CupertinoColors.systemRed
                            : null,
                        onTap: () => onAction('like'),
                      ),
                      _buildActionButton(
                        context,
                        icon: widget.save
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        color: widget.save
                            ? CupertinoColors.systemIndigo
                            : null,
                        onTap: () => onAction('save'),
                      ),
                      _buildActionButton(
                        context,
                        icon: widget.follow
                            ? CupertinoIcons.bell_fill
                            : CupertinoIcons.bell,
                        color: widget.follow
                            ? CupertinoColors.systemPurple
                            : null,
                        onTap: () => onAction('follow'),
                      ),
                      _buildActionButton(
                        context,
                        icon: CupertinoIcons.share,
                        onTap: () => onAction('share'),
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
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 32,
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? 
              CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color ?? CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}