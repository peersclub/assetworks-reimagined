import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';
import '../models/dashboard_widget.dart';
import '../screens/widget_preview_screen.dart';

class DashboardV2Screen extends StatefulWidget {
  const DashboardV2Screen({Key? key}) : super(key: key);

  @override
  State<DashboardV2Screen> createState() => _DashboardV2ScreenState();
}

class _DashboardV2ScreenState extends State<DashboardV2Screen> {
  final ApiService _apiService = Get.find<ApiService>();
  final ScrollController _scrollController = ScrollController();
  
  List<DashboardWidget> _widgets = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  
  @override
  void initState() {
    super.initState();
    _loadWidgets();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreWidgets();
      }
    }
  }
  
  Future<void> _loadWidgets() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final widgets = await _apiService.fetchDashboardWidgets(
        page: 1,
        limit: 20,
      );
      
      if (mounted) {
        setState(() {
          _widgets = widgets;
          _currentPage = 1;
          _hasMore = widgets.length >= 20;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _loadMoreWidgets() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);
    
    try {
      final widgets = await _apiService.fetchDashboardWidgets(
        page: _currentPage + 1,
        limit: 20,
      );
      
      if (mounted) {
        setState(() {
          _widgets.addAll(widgets);
          _currentPage++;
          _hasMore = widgets.length >= 20;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Twitter-style header
          CupertinoSliverNavigationBar(
            backgroundColor: CupertinoColors.black.withOpacity(0.9),
            border: null,
            largeTitle: Text(
              'For You',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemIndigo,
                      CupertinoColors.systemPurple,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  CupertinoIcons.sparkles,
                  color: CupertinoColors.white,
                  size: 18,
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Toggle between For You and Following
              },
            ),
          ),
          
          // Widget Feed
          if (_widgets.isEmpty && !_isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.rectangle_stack,
                      size: 64,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No widgets yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first widget or follow creators',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == _widgets.length) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: _hasMore
                          ? CupertinoActivityIndicator()
                          : Text(
                              'No more widgets',
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                    );
                  }
                  
                  final widget = _widgets[index];
                  return TwitterStyleWidgetCard(
                    widget: widget,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.to(() => const WidgetPreviewScreen(), 
                        arguments: widget,
                        transition: Transition.cupertino,
                      );
                    },
                  );
                },
                childCount: _widgets.length + 1,
              ),
            ),
        ],
      ),
    );
  }
}

// Twitter-style Widget Card
class TwitterStyleWidgetCard extends StatefulWidget {
  final DashboardWidget widget;
  final VoidCallback onTap;
  
  const TwitterStyleWidgetCard({
    Key? key,
    required this.widget,
    required this.onTap,
  }) : super(key: key);
  
  @override
  State<TwitterStyleWidgetCard> createState() => _TwitterStyleWidgetCardState();
}

class _TwitterStyleWidgetCardState extends State<TwitterStyleWidgetCard> {
  late WebViewController _webViewController;
  bool _isWebViewLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initWebView();
  }
  
  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(CupertinoColors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isWebViewLoading = false);
          },
        ),
      );
    
    if (widget.widget.preview_version_url != null) {
      _webViewController.loadRequest(Uri.parse(widget.widget.preview_version_url!));
    }
  }
  
  String _getTimeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.systemIndigo,
                          CupertinoColors.systemPurple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        (widget.widget.username != null && widget.widget.username!.isNotEmpty) 
                            ? widget.widget.username!.substring(0, 1).toUpperCase() 
                            : 'A',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Username and metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.widget.username ?? 'Anonymous',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.widget.verified == true) ...[
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                size: 16,
                                color: CupertinoColors.activeBlue,
                              ),
                            ],
                            const SizedBox(width: 8),
                            Text(
                              '• ${_getTimeAgo(widget.widget.created_at)}',
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (widget.widget.title != null)
                          Text(
                            widget.widget.title!,
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  
                  // More button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      CupertinoIcons.ellipsis,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Show options
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Widget Description (Claude Response)
              if (widget.widget.description != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    widget.widget.description!,
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              // HTML Preview
              if (widget.widget.preview_version_url != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Container(
                          color: CupertinoColors.systemGrey6.darkColor,
                          child: _isWebViewLoading
                              ? Center(child: CupertinoActivityIndicator())
                              : AbsorbPointer(
                                  absorbing: true,
                                  child: WebViewWidget(
                                    controller: _webViewController,
                                  ),
                                ),
                        ),
                        // Play overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  CupertinoIcons.play_fill,
                                  color: CupertinoColors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Engagement Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildEngagementButton(
                    icon: widget.widget.like 
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    count: widget.widget.likes_count ?? 0,
                    color: widget.widget.like 
                        ? CupertinoColors.systemRed
                        : CupertinoColors.systemGrey,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final success = widget.widget.like
                          ? await _apiService.dislikeWidget(widget.widget.id)
                          : await _apiService.likeWidget(widget.widget.id);
                      if (success) {
                        setState(() {
                          widget.widget.like = !widget.widget.like;
                          // likes_count is read-only, will be updated from server
                        });
                      }
                    },
                  ),
                  _buildEngagementButton(
                    icon: CupertinoIcons.chat_bubble,
                    count: widget.widget.comments_count ?? 0,
                    color: CupertinoColors.systemGrey,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Open comments
                    },
                  ),
                  _buildEngagementButton(
                    icon: widget.widget.save
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    count: widget.widget.shares_count ?? 0,
                    color: widget.widget.save
                        ? CupertinoColors.systemIndigo
                        : CupertinoColors.systemGrey,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final success = await _apiService.saveWidgetToProfile(widget.widget.id);
                      if (success) {
                        setState(() {
                          widget.widget.save = !widget.widget.save;
                        });
                      }
                    },
                  ),
                  _buildEngagementButton(
                    icon: CupertinoIcons.share,
                    color: CupertinoColors.systemGrey,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Share widget
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
  
  Widget _buildEngagementButton({
    required IconData icon,
    int? count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          if (count != null && count > 0) ...[
            const SizedBox(width: 4),
            Text(
              count > 999 ? '${(count / 1000).toStringAsFixed(1)}k' : count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  final ApiService _apiService = Get.find<ApiService>();
}