import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';
import '../models/dashboard_widget.dart';

class WidgetRemixScreen extends StatefulWidget {
  const WidgetRemixScreen({Key? key}) : super(key: key);

  @override
  State<WidgetRemixScreen> createState() => _WidgetRemixScreenState();
}

class _WidgetRemixScreenState extends State<WidgetRemixScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  final TextEditingController _promptController = TextEditingController();
  
  DashboardWidget? originalWidget;
  bool _isGenerating = false;
  
  // Widget Templates
  final List<WidgetTemplate> _templates = [
    WidgetTemplate(
      icon: CupertinoIcons.chart_bar_alt_fill,
      title: 'Stock Portfolio',
      description: 'Track stocks & equity investments',
      prompt: 'Create a stock portfolio tracker showing real-time prices, gains/losses, and portfolio allocation for ',
      color: CupertinoColors.systemIndigo,
    ),
    WidgetTemplate(
      icon: CupertinoIcons.bitcoin,
      title: 'Crypto Dashboard',
      description: 'Monitor cryptocurrency holdings',
      prompt: 'Build a crypto dashboard with live prices, 24h changes, and portfolio value for ',
      color: CupertinoColors.systemOrange,
    ),
    WidgetTemplate(
      icon: CupertinoIcons.building_2_fill,
      title: 'Real Estate',
      description: 'Track property investments',
      prompt: 'Design a real estate investment tracker showing property values, rental income, and ROI for ',
      color: CupertinoColors.systemBrown,
    ),
    WidgetTemplate(
      icon: CupertinoIcons.graph_circle_fill,
      title: 'Mutual Funds',
      description: 'Monitor mutual fund performance',
      prompt: 'Create a mutual fund tracker displaying NAV, returns, and fund allocation for ',
      color: CupertinoColors.systemGreen,
    ),
    WidgetTemplate(
      icon: CupertinoIcons.money_dollar_circle_fill,
      title: 'Fixed Income',
      description: 'Track bonds & fixed deposits',
      prompt: 'Build a fixed income dashboard showing yields, maturity dates, and interest payments for ',
      color: CupertinoColors.systemBlue,
    ),
    WidgetTemplate(
      icon: CupertinoIcons.chart_pie_fill,
      title: 'Asset Allocation',
      description: 'Visualize portfolio distribution',
      prompt: 'Design an asset allocation widget showing portfolio distribution across asset classes for ',
      color: CupertinoColors.systemPurple,
    ),
    WidgetTemplate(
      icon: CupertinoIcons.arrow_up_arrow_down_circle_fill,
      title: 'Commodities',
      description: 'Track gold, silver, oil prices',
      prompt: 'Create a commodities tracker for gold, silver, oil with live prices and trends for ',
      color: CupertinoColors.systemYellow,
    ),
    WidgetTemplate(
      icon: CupertinoIcons.shield_fill,
      title: 'Insurance Portfolio',
      description: 'Manage insurance policies',
      prompt: 'Build an insurance portfolio tracker showing policies, premiums, and coverage for ',
      color: CupertinoColors.systemTeal,
    ),
    WidgetTemplate(
      icon: CupertinoIcons.graph_square_fill,
      title: 'Market Indices',
      description: 'Track major market indices',
      prompt: 'Design a market indices widget showing S&P 500, NASDAQ, DOW performance for ',
      color: CupertinoColors.systemRed,
    ),
    WidgetTemplate(
      icon: CupertinoIcons.creditcard_fill,
      title: 'Expense Tracker',
      description: 'Monitor spending & budgets',
      prompt: 'Create an expense tracker with categories, budgets, and spending trends for ',
      color: CupertinoColors.systemPink,
    ),
    WidgetTemplate(
      icon: CupertinoIcons.briefcase_fill,
      title: 'Retirement Planning',
      description: 'Track retirement savings',
      prompt: 'Build a retirement planning widget showing 401k, IRA, and savings progress for ',
      color: CupertinoColors.systemIndigo,
    ),
    WidgetTemplate(
      icon: CupertinoIcons.percent,
      title: 'Tax Calculator',
      description: 'Calculate tax obligations',
      prompt: 'Design a tax calculator widget for income tax, capital gains, and deductions for ',
      color: CupertinoColors.systemGrey,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    originalWidget = Get.arguments as DashboardWidget?;
    if (originalWidget != null && originalWidget!.original_prompt != null) {
      _promptController.text = originalWidget!.original_prompt!;
    }
  }
  
  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
  
  Future<void> _remixWidget({String? templatePrompt}) async {
    final prompt = templatePrompt ?? _promptController.text.trim();
    
    if (prompt.isEmpty) {
      _showError('Please enter a prompt or select a template');
      return;
    }
    
    setState(() => _isGenerating = true);
    
    DynamicIslandService().startLiveActivity(
      'widget_remix',
      {
        'title': 'Remixing Widget',
        'status': 'Generating new version...',
        'progress': 0.3,
      },
    );
    
    try {
      final result = await _apiService.createWidgetFromPrompt(prompt);
      
      if (result['success'] == true && result['widget'] != null) {
        DynamicIslandService().endLiveActivity('widget_remix');
        DynamicIslandService().updateStatus(
          'Widget remixed!',
          icon: CupertinoIcons.checkmark_circle_fill,
        );
        
        // Navigate to preview
        Get.back(result: result['widget']);
      } else {
        setState(() => _isGenerating = false);
        _showError(result['message'] ?? 'Failed to remix widget');
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      _showError('An error occurred. Please try again.');
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
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Remix Widget'),
        trailing: _isGenerating
            ? CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Create'),
                onPressed: () => _remixWidget(),
              ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Original Widget Info
            if (originalWidget != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.arrow_2_squarepath,
                            size: 16,
                            color: CupertinoColors.systemIndigo,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Remixing from',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.systemIndigo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        originalWidget!.title ?? 'Untitled Widget',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (originalWidget!.username != null)
                        Text(
                          'by @${originalWidget!.username}',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            
            // Prompt Input
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Describe your remix',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _promptController,
                      placeholder: 'Enter your widget idea or modification...',
                      maxLines: 4,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      style: TextStyle(fontSize: 16),
                      enabled: !_isGenerating,
                    ),
                  ],
                ),
              ),
            ),
            
            // Templates Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Quick Templates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final template = _templates[index];
                    return GestureDetector(
                      onTap: _isGenerating
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              _promptController.text = template.prompt;
                              setState(() {});
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              template.color.withOpacity(0.2),
                              template.color.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: template.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              template.icon,
                              size: 32,
                              color: template.color,
                            ),
                            const Spacer(),
                            Text(
                              template.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              template.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: CupertinoColors.systemGrey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _templates.length,
                ),
              ),
            ),
            
            // Recent Remixes Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Popular Remix Ideas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildRemixIdeas(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildRemixIdeas() {
    final ideas = [
      'Add dark mode support to this widget',
      'Make it responsive for different screen sizes',
      'Add real-time data updates',
      'Include animation effects',
      'Add user customization options',
    ];
    
    return ideas.map((idea) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _isGenerating
            ? null
            : () {
                _promptController.text = idea;
                setState(() {});
              },
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.lightbulb,
                size: 16,
                color: CupertinoColors.systemOrange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  idea,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )).toList();
  }
}

class WidgetTemplate {
  final IconData icon;
  final String title;
  final String description;
  final String prompt;
  final Color color;
  
  WidgetTemplate({
    required this.icon,
    required this.title,
    required this.description,
    required this.prompt,
    required this.color,
  });
}