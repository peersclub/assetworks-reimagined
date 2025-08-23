import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../presentation/controllers/create_widget_controller.dart';

class WidgetPreview extends StatefulWidget {
  final String prompt;
  final String? title;
  final String? description;
  final WidgetType type;
  
  const WidgetPreview({
    Key? key,
    required this.prompt,
    this.title,
    this.description,
    required this.type,
  }) : super(key: key);
  
  @override
  State<WidgetPreview> createState() => _WidgetPreviewState();
}

class _WidgetPreviewState extends State<WidgetPreview> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initWebView();
  }
  
  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
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
        ),
      )
      ..loadHtmlString(_generatePreviewHtml());
  }
  
  String _generatePreviewHtml() {
    // Generate preview HTML based on widget type
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? '#1a1a1a' : '#ffffff';
    final textColor = isDark ? '#ffffff' : '#000000';
    
    String content = '';
    
    switch (widget.type) {
      case WidgetType.chart:
        content = _generateChartPreview();
        break;
      case WidgetType.table:
        content = _generateTablePreview();
        break;
      case WidgetType.dashboard:
        content = _generateDashboardPreview();
        break;
      case WidgetType.form:
        content = _generateFormPreview();
        break;
      case WidgetType.custom:
        content = _generateCustomPreview();
        break;
    }
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body {
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
          margin: 0;
          padding: 20px;
          background-color: $bgColor;
          color: $textColor;
        }
        .container {
          max-width: 100%;
          margin: 0 auto;
        }
        h1 {
          font-size: 24px;
          margin-bottom: 10px;
        }
        p {
          font-size: 14px;
          opacity: 0.7;
          margin-bottom: 20px;
        }
        .widget-content {
          padding: 20px;
          background: ${isDark ? '#2a2a2a' : '#f5f5f5'};
          border-radius: 12px;
          min-height: 300px;
          display: flex;
          align-items: center;
          justify-content: center;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>${widget.title ?? 'Widget Preview'}</h1>
        <p>${widget.description ?? widget.prompt}</p>
        <div class="widget-content">
          $content
        </div>
      </div>
    </body>
    </html>
    ''';
  }
  
  String _generateChartPreview() {
    return '''
      <svg width="300" height="200" xmlns="http://www.w3.org/2000/svg">
        <rect x="50" y="150" width="40" height="50" fill="#4CAF50"/>
        <rect x="100" y="100" width="40" height="100" fill="#2196F3"/>
        <rect x="150" y="120" width="40" height="80" fill="#FF9800"/>
        <rect x="200" y="80" width="40" height="120" fill="#9C27B0"/>
        <text x="145" y="30" text-anchor="middle" font-size="16" fill="currentColor">Chart Preview</text>
      </svg>
    ''';
  }
  
  String _generateTablePreview() {
    return '''
      <table style="width: 100%; border-collapse: collapse;">
        <thead>
          <tr style="border-bottom: 2px solid #ddd;">
            <th style="padding: 12px; text-align: left;">Column 1</th>
            <th style="padding: 12px; text-align: left;">Column 2</th>
            <th style="padding: 12px; text-align: left;">Column 3</th>
          </tr>
        </thead>
        <tbody>
          <tr style="border-bottom: 1px solid #eee;">
            <td style="padding: 12px;">Data 1</td>
            <td style="padding: 12px;">Data 2</td>
            <td style="padding: 12px;">Data 3</td>
          </tr>
          <tr style="border-bottom: 1px solid #eee;">
            <td style="padding: 12px;">Data 4</td>
            <td style="padding: 12px;">Data 5</td>
            <td style="padding: 12px;">Data 6</td>
          </tr>
        </tbody>
      </table>
    ''';
  }
  
  String _generateDashboardPreview() {
    return '''
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; width: 100%;">
        <div style="padding: 20px; background: rgba(76, 175, 80, 0.1); border-radius: 8px;">
          <h3 style="margin: 0 0 10px 0; font-size: 14px;">Metric 1</h3>
          <p style="margin: 0; font-size: 24px; font-weight: bold;">1,234</p>
        </div>
        <div style="padding: 20px; background: rgba(33, 150, 243, 0.1); border-radius: 8px;">
          <h3 style="margin: 0 0 10px 0; font-size: 14px;">Metric 2</h3>
          <p style="margin: 0; font-size: 24px; font-weight: bold;">56.7%</p>
        </div>
        <div style="padding: 20px; background: rgba(255, 152, 0, 0.1); border-radius: 8px;">
          <h3 style="margin: 0 0 10px 0; font-size: 14px;">Metric 3</h3>
          <p style="margin: 0; font-size: 24px; font-weight: bold;">\$89.5K</p>
        </div>
        <div style="padding: 20px; background: rgba(156, 39, 176, 0.1); border-radius: 8px;">
          <h3 style="margin: 0 0 10px 0; font-size: 14px;">Metric 4</h3>
          <p style="margin: 0; font-size: 24px; font-weight: bold;">432</p>
        </div>
      </div>
    ''';
  }
  
  String _generateFormPreview() {
    return '''
      <form style="width: 100%; max-width: 400px;">
        <div style="margin-bottom: 20px;">
          <label style="display: block; margin-bottom: 8px; font-size: 14px;">Input Field 1</label>
          <input type="text" placeholder="Enter value" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; background: transparent; color: currentColor;">
        </div>
        <div style="margin-bottom: 20px;">
          <label style="display: block; margin-bottom: 8px; font-size: 14px;">Input Field 2</label>
          <select style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; background: transparent; color: currentColor;">
            <option>Option 1</option>
            <option>Option 2</option>
            <option>Option 3</option>
          </select>
        </div>
        <button type="submit" style="padding: 10px 20px; background: #2196F3; color: white; border: none; border-radius: 6px; font-size: 14px;">Submit</button>
      </form>
    ''';
  }
  
  String _generateCustomPreview() {
    return '''
      <div style="text-align: center;">
        <svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
          <circle cx="50" cy="50" r="40" fill="none" stroke="#2196F3" stroke-width="3"/>
          <path d="M30 50 L45 65 L70 35" fill="none" stroke="#4CAF50" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
        <p style="margin-top: 20px;">Custom Widget Preview</p>
        <p style="opacity: 0.6; font-size: 12px;">Your custom widget will appear here</p>
      </div>
    ''';
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Preview'),
        actions: [
          IconButton(
            onPressed: _shareWidget,
            icon: const Icon(LucideIcons.share2, size: 22),
          ),
          IconButton(
            onPressed: _editWidget,
            icon: const Icon(LucideIcons.edit3, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          // Loading indicator
          if (_isLoading)
            LinearProgressIndicator(
              backgroundColor: isDark ? AppColors.neutral800 : AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          
          // WebView
          Expanded(
            child: WebViewWidget(controller: _webViewController),
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
                Expanded(
                  child: AppButton(
                    text: 'Remix',
                    icon: LucideIcons.wand2,
                    type: AppButtonType.outline,
                    onPressed: _remixWidget,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Use This Widget',
                    icon: LucideIcons.check,
                    onPressed: _useWidget,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _shareWidget() {
    Get.snackbar(
      'Share Widget',
      'Widget sharing will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void _editWidget() {
    Get.back();
  }
  
  void _remixWidget() {
    Get.toNamed('/widget-remix', arguments: {
      'prompt': widget.prompt,
      'title': widget.title,
      'type': widget.type,
    });
  }
  
  void _useWidget() {
    // Return to create screen and proceed with creation
    Get.back(result: true);
  }
}