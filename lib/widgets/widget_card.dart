import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/dashboard_widget.dart';

class WidgetCard extends StatefulWidget {
  final DashboardWidget widget;
  final Function(String) onAction;
  
  const WidgetCard({
    Key? key,
    required this.widget,
    required this.onAction,
  }) : super(key: key);
  
  @override
  State<WidgetCard> createState() => _WidgetCardState();
}

class _WidgetCardState extends State<WidgetCard> {
  late WebViewController _webViewController;
  
  @override
  void initState() {
    super.initState();
    _initWebView();
  }
  
  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(CupertinoColors.systemBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            // Silent fail for thumbnail
          },
        ),
      );
    
    // Load the preview HTML if available
    if (widget.widget.preview_version_url != null) {
      _webViewController.loadRequest(Uri.parse(widget.widget.preview_version_url!));
    }
  }
  
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget Preview - Shows minified HTML as thumbnail
            if (widget.widget.preview_version_url != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      // WebView showing the minified HTML
                      AbsorbPointer(
                        absorbing: true, // Prevent interaction with WebView
                        child: WebViewWidget(
                          controller: _webViewController,
                        ),
                      ),
                      // Overlay to indicate it's clickable
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                CupertinoIcons.eye_fill,
                                color: CupertinoColors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Preview',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (widget.widget.picture != null)
              // Fallback to picture if no preview URL
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    widget.widget.picture!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
                            CupertinoIcons.photo,
                            size: 48,
                            color: CupertinoColors.white.withOpacity(0.9),
                          ),
                        ),
                      );
                    },
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
                          widget.widget.title ?? 'Untitled Widget',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.widget.verified == true)
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
                  if (widget.widget.username != null)
                    Text(
                      '@${widget.widget.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  // Claude Response Summary
                  if (widget.widget.summary != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.widget.summary!,
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoTheme.of(context).textTheme.textStyle.color,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  // Stats Row
                  Row(
                    children: [
                      _buildStat(
                        CupertinoIcons.eye,
                        widget.widget.views_count?.toString() ?? '0',
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        CupertinoIcons.heart,
                        widget.widget.likes_count?.toString() ?? '0',
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        CupertinoIcons.chat_bubble,
                        widget.widget.comments_count?.toString() ?? '0',
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
                        icon: widget.widget.like 
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: widget.widget.like
                            ? CupertinoColors.systemRed
                            : null,
                        onTap: () => widget.onAction('like'),
                      ),
                      _buildActionButton(
                        context,
                        icon: widget.widget.save
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        color: widget.widget.save
                            ? CupertinoColors.systemIndigo
                            : null,
                        onTap: () => widget.onAction('save'),
                      ),
                      _buildActionButton(
                        context,
                        icon: widget.widget.follow
                            ? CupertinoIcons.bell_fill
                            : CupertinoIcons.bell,
                        color: widget.widget.follow
                            ? CupertinoColors.systemPurple
                            : null,
                        onTap: () => widget.onAction('follow'),
                      ),
                      _buildActionButton(
                        context,
                        icon: CupertinoIcons.share,
                        onTap: () => widget.onAction('share'),
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