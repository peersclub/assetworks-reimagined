import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/widget_response_model.dart';
import '../../controllers/widget_controller.dart';
import '../../widgets/remix_info_card.dart';

class WidgetViewScreen extends StatefulWidget {
  const WidgetViewScreen({Key? key}) : super(key: key);
  
  @override
  State<WidgetViewScreen> createState() => _WidgetViewScreenState();
}

class _WidgetViewScreenState extends State<WidgetViewScreen> {
  late WebViewController _webViewController;
  late WidgetResponseModel widgetData;
  late WidgetController _controller;
  bool _isLoading = true;
  bool _showingFullVersion = true;
  
  @override
  void initState() {
    super.initState();
    _controller = Get.find<WidgetController>();
    
    // Get widget from arguments
    final args = Get.arguments;
    if (args is WidgetResponseModel) {
      widgetData = args;
    } else if (args is Map<String, dynamic>) {
      widgetData = WidgetResponseModel.fromJson(args);
    } else {
      // Fallback to generated widget from controller
      widgetData = _controller.generatedWidget.value!;
    }
    
    _initWebView();
  }
  
  void _initWebView() {
    final url = _showingFullVersion 
        ? widgetData.fullVersionUrl 
        : widgetData.previewVersionUrl;
    
    print('Loading widget URL: $url');
    print('Widget title: ${widgetData.title}');
    print('Widget ID: ${widgetData.id}');
    
    // Check if URL is empty or invalid
    if (url.isEmpty) {
      _showError('Widget URL is empty. The widget may not have been generated properly.');
      
      // Show widget details instead
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // Ensure URL has proper protocol
    final finalUrl = url.startsWith('http') ? url : 'https:$url';
    
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('WebView loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print('WebView finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            print('WebView error: ${error.description}');
            setState(() {
              _isLoading = false;
            });
            _showError(error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(finalUrl));
  }
  
  void _toggleVersion() {
    setState(() {
      _showingFullVersion = !_showingFullVersion;
    });
    _webViewController.loadRequest(Uri.parse(
      _showingFullVersion ? widgetData.fullVersionUrl : widgetData.previewVersionUrl,
    ));
  }
  
  void _showError(String error) {
    Get.snackbar(
      'Error Loading Widget',
      error,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return WillPopScope(
      onWillPop: () async {
        // Navigate to home screen when back is pressed
        Get.offAllNamed('/');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  widgetData.title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widgetData.isRemix) ...[
                const SizedBox(width: 8),
                const RemixBadge(small: true),
              ],
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate to home screen
              Get.offAllNamed('/');
            },
          ),
          actions: [
          IconButton(
            onPressed: _shareWidget,
            icon: const Icon(LucideIcons.share2, size: 22),
          ),
          IconButton(
            onPressed: _toggleVersion,
            icon: Icon(
              _showingFullVersion ? LucideIcons.eye : LucideIcons.eyeOff,
              size: 22,
            ),
            tooltip: _showingFullVersion ? 'Show Preview' : 'Show Full Version',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(LucideIcons.bookmark, size: 18),
                    SizedBox(width: 8),
                    Text('Save to Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remix',
                child: Row(
                  children: [
                    Icon(LucideIcons.wand2, size: 18),
                    SizedBox(width: 8),
                    Text('Remix Widget'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(LucideIcons.flag, size: 18),
                    SizedBox(width: 8),
                    Text('Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Remix info (if applicable)
          if (widgetData.isRemix)
            Padding(
              padding: const EdgeInsets.all(12),
              child: RemixInfoCard(
                widget: widgetData,
                onViewOriginal: widgetData.remixedFromId != null 
                  ? () {
                      // Navigate to original widget
                      _controller.getWidgetById(widgetData.remixedFromId!).then((original) {
                        if (original != null) {
                          Get.toNamed('/widget-view', arguments: original);
                        }
                      });
                    }
                  : null,
              ),
            ),
          
          // Widget info bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widgetData.tagline.isNotEmpty)
                  Text(
                    widgetData.tagline,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Creator info
                    GestureDetector(
                      onTap: () {
                        // Navigate to user profile
                        Get.toNamed('/user-profile', arguments: {
                          'userId': widgetData.userId,
                          'username': widgetData.username,
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.user,
                            size: 16,
                            color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widgetData.username,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Likes
                    Icon(
                      widgetData.like ? LucideIcons.heart : LucideIcons.heart,
                      size: 16,
                      color: widgetData.like ? AppColors.error : (isDark ? AppColors.neutral600 : AppColors.neutral400),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widgetData.likes.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widgetData.category,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    
                    // Version indicator
                    Text(
                      _showingFullVersion ? 'Full Version' : 'Preview',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            LinearProgressIndicator(
              backgroundColor: isDark ? AppColors.neutral800 : AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          
          // WebView or Fallback
          Expanded(
            child: widgetData.fullVersionUrl.isEmpty && widgetData.previewVersionUrl.isEmpty
                ? _buildFallbackUI()
                : Stack(
                    children: [
                      WebViewWidget(controller: _webViewController),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
          ),
          
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                ),
              ),
            ),
            child: Row(
              children: [
                // Like/Dislike buttons
                IconButton(
                  onPressed: () => _likeWidget(),
                  icon: Icon(
                    widgetData.like ? LucideIcons.heart : LucideIcons.heart,
                    color: widgetData.like ? AppColors.error : null,
                  ),
                ),
                IconButton(
                  onPressed: () => _dislikeWidget(),
                  icon: Icon(
                    widgetData.dislike ? LucideIcons.thumbsDown : LucideIcons.thumbsDown,
                    color: widgetData.dislike ? AppColors.primary : null,
                  ),
                ),
                const Spacer(),
                
                // Continue conversation button (if has session)
                if (widgetData.userSessionId != null)
                  Expanded(
                    child: AppButton(
                      text: 'Continue',
                      icon: LucideIcons.messageCircle,
                      type: AppButtonType.outline,
                      onPressed: _continueConversation,
                    ),
                  ),
                const SizedBox(width: 12),
                
                // Save button
                Expanded(
                  child: AppButton(
                    text: widgetData.save ? 'Saved' : 'Save',
                    icon: widgetData.save ? LucideIcons.bookmarkMinus : LucideIcons.bookmark,
                    onPressed: widgetData.save ? null : _saveWidget,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
  
  void _shareWidget() {
    Get.toNamed('/widget-share', arguments: widgetData);
  }
  
  void _handleMenuAction(String action) {
    switch (action) {
      case 'save':
        _saveWidget();
        break;
      case 'remix':
        _remixWidget();
        break;
      case 'report':
        _reportWidget();
        break;
    }
  }
  
  void _saveWidget() {
    _controller.saveWidget(widgetData.id);
    setState(() {
      widgetData = widgetData.copyWith(save: true);
    });
  }
  
  void _likeWidget() {
    _controller.likeWidget(widgetData.id);
    setState(() {
      widgetData = widgetData.copyWith(
        like: !widgetData.like,
        dislike: false,
        likes: widgetData.like ? widgetData.likes - 1 : widgetData.likes + 1,
      );
    });
  }
  
  void _dislikeWidget() {
    _controller.dislikeWidget(widgetData.id);
    setState(() {
      widgetData = widgetData.copyWith(
        like: false,
        dislike: !widgetData.dislike,
        dislikes: widgetData.dislike ? widgetData.dislikes - 1 : widgetData.dislikes + 1,
      );
    });
  }
  
  void _remixWidget() {
    // Navigate to remix approach screen with widget data
    Get.toNamed('/remix-approach', arguments: widgetData);
  }
  
  void _reportWidget() {
    Get.dialog(
      AlertDialog(
        title: const Text('Report Widget'),
        content: const Text('Why are you reporting this widget?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.reportWidget(widgetData.id, 'spam');
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFallbackUI() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: AppColors.warning,
            ),
            const SizedBox(height: 16),
            const Text(
              'Widget Preview Not Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The widget was generated but the preview URLs are not available yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            
            // Show widget details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Title:', widgetData.title),
                  const SizedBox(height: 8),
                  _buildDetailRow('Category:', widgetData.category),
                  const SizedBox(height: 8),
                  _buildDetailRow('Created:', 'Just now'),
                  if (widgetData.summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow('Summary:', widgetData.summary),
                  ],
                  if (widgetData.originalPrompt.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Original Prompt:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widgetData.originalPrompt,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            AppButton(
              text: 'Try Again',
              icon: LucideIcons.refreshCw,
              onPressed: () {
                Get.back();
                Get.toNamed('/create-widget');
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
  
  void _continueConversation() {
    // Navigate back to create screen with session ID
    Get.offNamed('/create-widget', arguments: {
      'sessionId': widgetData.userSessionId,
      'initialQuery': '',
    });
  }
}