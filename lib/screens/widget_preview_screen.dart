import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';
import '../models/dashboard_widget.dart';

class WidgetPreviewScreen extends StatefulWidget {
  const WidgetPreviewScreen({Key? key}) : super(key: key);

  @override
  State<WidgetPreviewScreen> createState() => _WidgetPreviewScreenState();
}

class _WidgetPreviewScreenState extends State<WidgetPreviewScreen> with TickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  late WebViewController _webViewController;
  late DashboardWidget dashboardWidget;
  
  late AnimationController _likeAnimationController;
  late AnimationController _saveAnimationController;
  late AnimationController _shareAnimationController;
  late AnimationController _codeAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _saveScaleAnimation;
  late Animation<double> _shareScaleAnimation;
  late Animation<double> _codeScaleAnimation;
  
  bool _isLoading = true;
  bool _isFullscreen = false;
  double _progress = 0.0;
  
  @override
  void initState() {
    super.initState();
    dashboardWidget = Get.arguments as DashboardWidget;
    _initWebView();
    _trackView();
    _initAnimations();
  }
  
  void _initAnimations() {
    // Like animation
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
    
    // Save animation
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
    
    // Share animation
    _shareAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shareScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _shareAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Code animation
    _codeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _codeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _codeAnimationController,
      curve: Curves.easeInOut,
    ));
  }
  
  Future<void> _trackView() async {
    // Track widget view activity
    final ApiService apiService = Get.find<ApiService>();
    if (dashboardWidget.id != null) {
      await apiService.trackActivity(
        action: 'viewed',
        widgetId: dashboardWidget.id!,
        metadata: {
          'source': 'widget_preview',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }
  
  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(CupertinoColors.systemBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            _showError('Failed to load widget preview');
          },
        ),
      )
      ..loadRequest(Uri.parse(dashboardWidget.full_version_url ?? 
          dashboardWidget.preview_version_url ?? 
          'https://assetworks.ai/widget/${dashboardWidget.id}'));
  }
  
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }
  
  Future<void> _handleAction(String action) async {
    HapticFeedback.mediumImpact();
    
    switch (action) {
      case 'save':
        _saveAnimationController.forward().then((_) {
          _saveAnimationController.reverse();
        });
        final success = await _apiService.saveWidgetToProfile(dashboardWidget.id);
        if (success) {
          setState(() {
            dashboardWidget.save = !dashboardWidget.save;
            // Update count locally for display
            if (dashboardWidget.save) {
              dashboardWidget.saves_count = (dashboardWidget.saves_count ?? 0) + 1;
            } else if (dashboardWidget.saves_count != null && dashboardWidget.saves_count! > 0) {
              dashboardWidget.saves_count = dashboardWidget.saves_count! - 1;
            }
          });
          HapticFeedback.heavyImpact();
          DynamicIslandService().updateStatus(
            dashboardWidget.save ? 'Saved to dashboard!' : 'Removed from dashboard',
            icon: dashboardWidget.save ? Icons.bookmark : Icons.bookmark_border,
          );
        }
        break;
        
      case 'like':
        _likeAnimationController.forward().then((_) {
          _likeAnimationController.reverse();
        });
        final success = dashboardWidget.like
            ? await _apiService.dislikeWidget(dashboardWidget.id)
            : await _apiService.likeWidget(dashboardWidget.id);
        if (success) {
          setState(() {
            dashboardWidget.like = !dashboardWidget.like;
            // Note: likes_count is final, so we can't update it locally
            // The actual count will be updated from the backend on refresh
          });
          HapticFeedback.heavyImpact();
          DynamicIslandService().updateStatus(
            dashboardWidget.like ? 'Liked!' : 'Unliked',
            icon: dashboardWidget.like ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          );
        }
        break;
        
      case 'share':
        _shareAnimationController.forward().then((_) {
          _shareAnimationController.reverse();
        });
        await Share.share(
          'Check out this amazing widget: ${dashboardWidget.title}\n'
          'https://assetworks.ai/widget/${dashboardWidget.id}',
          subject: 'AssetWorks Widget',
        );
        break;
        
      case 'code':
        _codeAnimationController.forward().then((_) {
          _codeAnimationController.reverse();
        });
        Get.toNamed('/widget-code', arguments: dashboardWidget);
        break;
    }
  }
  
  void _showError(String message) {
    HapticFeedback.heavyImpact();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _likeAnimationController.dispose();
    _saveAnimationController.dispose();
    _shareAnimationController.dispose();
    _codeAnimationController.dispose();
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: _isFullscreen
          ? null
          : CupertinoNavigationBar(
              backgroundColor: CupertinoColors.systemBackground.withOpacity(0.9),
              border: null,
              middle: Column(
                children: [
                  Text(
                    dashboardWidget.title ?? 'Widget Preview',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (dashboardWidget.username != null)
                    Text(
                      '@${dashboardWidget.username}',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                ],
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  _isFullscreen
                      ? CupertinoIcons.fullscreen_exit
                      : CupertinoIcons.fullscreen,
                ),
                onPressed: _toggleFullscreen,
              ),
            ),
      child: SafeArea(
        top: !_isFullscreen,
        child: Column(
          children: [
            // Progress indicator
            if (_isLoading)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: CupertinoColors.systemGrey5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  CupertinoColors.systemIndigo,
                ),
              ),
            
            // WebView
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  
                  // Loading overlay
                  if (_isLoading)
                    Container(
                      color: CupertinoColors.systemBackground.withOpacity(0.8),
                      child: const Center(
                        child: CupertinoActivityIndicator(radius: 20),
                      ),
                    ),
                ],
              ),
            ),
            
            // Action Bar
            if (!_isFullscreen)
              Container(
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: CupertinoColors.systemGrey5,
                      width: 0.5,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              CupertinoIcons.eye,
                              '${dashboardWidget.views_count ?? 0} views',
                            ),
                            _buildStat(
                              CupertinoIcons.heart,
                              '${dashboardWidget.likes_count ?? 0} likes',
                            ),
                            _buildStat(
                              CupertinoIcons.chat_bubble,
                              '${dashboardWidget.comments_count ?? 0} comments',
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AnimatedBuilder(
                              animation: _likeScaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _likeScaleAnimation.value,
                                  child: _buildActionButton(
                                    icon: dashboardWidget.like
                                        ? CupertinoIcons.heart_fill
                                        : CupertinoIcons.heart,
                                    label: 'Like',
                                    color: dashboardWidget.like
                                        ? CupertinoColors.systemRed
                                        : null,
                                    onTap: () => _handleAction('like'),
                                  ),
                                );
                              },
                            ),
                            AnimatedBuilder(
                              animation: _saveScaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _saveScaleAnimation.value,
                                  child: _buildActionButton(
                                    icon: dashboardWidget.save
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    label: 'Save',
                                    color: dashboardWidget.save
                                        ? CupertinoColors.systemIndigo
                                        : null,
                                    onTap: () => _handleAction('save'),
                                  ),
                                );
                              },
                            ),
                            AnimatedBuilder(
                              animation: _shareScaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _shareScaleAnimation.value,
                                  child: _buildActionButton(
                                    icon: CupertinoIcons.share,
                                    label: 'Share',
                                    onTap: () => _handleAction('share'),
                                  ),
                                );
                              },
                            ),
                            AnimatedBuilder(
                              animation: _codeScaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _codeScaleAnimation.value,
                                  child: _buildActionButton(
                                    icon: CupertinoIcons.doc_text,
                                    label: 'Code',
                                    onTap: () => _handleAction('code'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color ?? CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color ?? CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}