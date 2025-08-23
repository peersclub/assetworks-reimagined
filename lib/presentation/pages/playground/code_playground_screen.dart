import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../controllers/playground_controller.dart';

class CodePlaygroundScreen extends StatefulWidget {
  const CodePlaygroundScreen({Key? key}) : super(key: key);
  
  @override
  State<CodePlaygroundScreen> createState() => _CodePlaygroundScreenState();
}

class _CodePlaygroundScreenState extends State<CodePlaygroundScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PlaygroundController _controller;
  late WebViewController _webViewController;
  
  final _htmlController = TextEditingController();
  final _cssController = TextEditingController();
  final _jsController = TextEditingController();
  
  bool _showPreview = true;
  bool _isFullScreen = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = Get.put(PlaygroundController());
    _initWebView();
    _loadDefaultTemplate();
  }
  
  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white);
  }
  
  void _loadDefaultTemplate() {
    _htmlController.text = '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Financial Dashboard</title>
</head>
<body>
  <div class="container">
    <h1>Portfolio Performance</h1>
    <div class="stats-grid">
      <div class="stat-card">
        <h3>Total Value</h3>
        <p class="value">\$125,430</p>
        <span class="change positive">+12.5%</span>
      </div>
      <div class="stat-card">
        <h3>Daily P&L</h3>
        <p class="value">\$2,340</p>
        <span class="change positive">+1.8%</span>
      </div>
      <div class="stat-card">
        <h3>YTD Return</h3>
        <p class="value">18.7%</p>
        <span class="change positive">+5.2%</span>
      </div>
    </div>
    <canvas id="chart"></canvas>
  </div>
</body>
</html>''';
    
    _cssController.text = '''body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  margin: 0;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  background: white;
  border-radius: 20px;
  padding: 30px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.3);
}

h1 {
  color: #2d3748;
  margin-bottom: 30px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: #f7fafc;
  padding: 20px;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
}

.stat-card h3 {
  color: #718096;
  font-size: 14px;
  margin: 0 0 10px 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.value {
  font-size: 28px;
  font-weight: bold;
  color: #2d3748;
  margin: 0;
}

.change {
  font-size: 14px;
  font-weight: 600;
}

.change.positive {
  color: #48bb78;
}

.change.negative {
  color: #f56565;
}

#chart {
  width: 100%;
  height: 300px;
  margin-top: 20px;
}''';
    
    _jsController.text = '''// Sample chart data
const canvas = document.getElementById('chart');
const ctx = canvas.getContext('2d');

// Set canvas size
canvas.width = canvas.offsetWidth;
canvas.height = 300;

// Draw a simple line chart
const data = [30, 45, 35, 50, 40, 60, 55, 70, 65, 80, 75, 90];
const maxValue = Math.max(...data);
const padding = 40;
const chartWidth = canvas.width - padding * 2;
const chartHeight = canvas.height - padding * 2;

// Draw axes
ctx.strokeStyle = '#e2e8f0';
ctx.lineWidth = 1;
ctx.beginPath();
ctx.moveTo(padding, padding);
ctx.lineTo(padding, canvas.height - padding);
ctx.lineTo(canvas.width - padding, canvas.height - padding);
ctx.stroke();

// Draw line chart
ctx.strokeStyle = '#667eea';
ctx.lineWidth = 3;
ctx.beginPath();

data.forEach((value, index) => {
  const x = padding + (index / (data.length - 1)) * chartWidth;
  const y = canvas.height - padding - (value / maxValue) * chartHeight;
  
  if (index === 0) {
    ctx.moveTo(x, y);
  } else {
    ctx.lineTo(x, y);
  }
});

ctx.stroke();

// Draw data points
ctx.fillStyle = '#667eea';
data.forEach((value, index) => {
  const x = padding + (index / (data.length - 1)) * chartWidth;
  const y = canvas.height - padding - (value / maxValue) * chartHeight;
  
  ctx.beginPath();
  ctx.arc(x, y, 4, 0, Math.PI * 2);
  ctx.fill();
});

// Add month labels
ctx.fillStyle = '#718096';
ctx.font = '12px sans-serif';
const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
months.forEach((month, index) => {
  const x = padding + (index / (months.length - 1)) * chartWidth;
  ctx.fillText(month, x - 15, canvas.height - padding + 20);
});''';
    
    _updatePreview();
  }
  
  void _updatePreview() {
    final html = _htmlController.text;
    final css = _cssController.text;
    final js = _jsController.text;
    
    final fullHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    $css
  </style>
</head>
<body>
  ${html.contains('<body>') ? html.substring(html.indexOf('<body>') + 6, html.contains('</body>') ? html.indexOf('</body>') : html.length) : html}
  <script>
    $js
  </script>
</body>
</html>
''';
    
    _webViewController.loadHtmlString(fullHtml);
  }
  
  void _saveAsTemplate() {
    _controller.saveTemplate(
      title: 'Custom Template',
      html: _htmlController.text,
      css: _cssController.text,
      js: _jsController.text,
    );
    
    Get.snackbar(
      'Success',
      'Template saved successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _htmlController.dispose();
    _cssController.dispose();
    _jsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Playground'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showPreview = !_showPreview;
              });
            },
            icon: Icon(_showPreview ? LucideIcons.code2 : LucideIcons.eye),
            tooltip: _showPreview ? 'Show Code Only' : 'Show Preview',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isFullScreen = !_isFullScreen;
              });
            },
            icon: Icon(_isFullScreen ? LucideIcons.minimize2 : LucideIcons.maximize2),
            tooltip: _isFullScreen ? 'Exit Fullscreen' : 'Fullscreen',
          ),
          IconButton(
            onPressed: _saveAsTemplate,
            icon: const Icon(LucideIcons.save),
            tooltip: 'Save as Template',
          ),
        ],
      ),
      body: _isFullScreen 
          ? _buildFullScreenPreview(isDark)
          : _buildSplitView(isDark),
    );
  }
  
  Widget _buildSplitView(bool isDark) {
    return Row(
      children: [
        // Code Editor Panel
        Expanded(
          flex: _showPreview ? 1 : 2,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                ),
              ),
            ),
            child: Column(
              children: [
                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'HTML'),
                      Tab(text: 'CSS'),
                      Tab(text: 'JavaScript'),
                    ],
                  ),
                ),
                
                // Code Editor
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCodeEditor(_htmlController, 'html', isDark),
                      _buildCodeEditor(_cssController, 'css', isDark),
                      _buildCodeEditor(_jsController, 'javascript', isDark),
                    ],
                  ),
                ),
                
                // Action Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      AppButton(
                        text: 'Run',
                        icon: LucideIcons.play,
                        onPressed: _updatePreview,
                        type: AppButtonType.primary,
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Clear',
                        icon: LucideIcons.trash2,
                        onPressed: () {
                          _htmlController.clear();
                          _cssController.clear();
                          _jsController.clear();
                          _updatePreview();
                        },
                        type: AppButtonType.outline,
                      ),
                      const Spacer(),
                      Text(
                        'Auto-run enabled',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Preview Panel
        if (_showPreview)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Preview Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.globe,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Live Preview',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _updatePreview,
                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ),
                  
                  // WebView
                  Expanded(
                    child: WebViewWidget(controller: _webViewController),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildFullScreenPreview(bool isDark) {
    return Column(
      children: [
        // Preview Controls
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
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isFullScreen = false;
                  });
                },
                icon: const Icon(LucideIcons.minimize2),
              ),
              const SizedBox(width: 12),
              Text(
                'Preview Mode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Refresh',
                icon: LucideIcons.refreshCw,
                onPressed: _updatePreview,
                type: AppButtonType.outline,
              ),
            ],
          ),
        ),
        
        // Full Screen WebView
        Expanded(
          child: WebViewWidget(controller: _webViewController),
        ),
      ],
    );
  }
  
  Widget _buildCodeEditor(TextEditingController controller, String language, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Start typing your $language code here...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.neutral600 : AppColors.neutral400,
          ),
        ),
        onChanged: (value) {
          // Auto-run if enabled
          Future.delayed(const Duration(milliseconds: 500), () {
            _updatePreview();
          });
        },
      ),
    );
  }
}