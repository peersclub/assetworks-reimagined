import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';
import '../models/dashboard_widget.dart';
import '../screens/widget_preview_screen.dart';

class WidgetCreationScreen extends StatefulWidget {
  const WidgetCreationScreen({Key? key}) : super(key: key);

  @override
  State<WidgetCreationScreen> createState() => _WidgetCreationScreenState();
}

class _WidgetCreationScreenState extends State<WidgetCreationScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  
  bool _isGenerating = false;
  String _selectedCategory = 'investment';
  
  // Investment & Asset Templates
  final Map<String, List<WidgetTemplate>> _templatesByCategory = {
    'investment': [
      WidgetTemplate(
        icon: CupertinoIcons.chart_bar_alt_fill,
        title: 'Stock Portfolio',
        description: 'Track stocks & equity investments',
        prompt: 'Create a stock portfolio tracker showing real-time prices, gains/losses, and portfolio allocation',
        color: CupertinoColors.systemIndigo,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.bitcoin,
        title: 'Crypto Dashboard',
        description: 'Monitor cryptocurrency holdings',
        prompt: 'Build a crypto dashboard with live prices, 24h changes, and portfolio value',
        color: CupertinoColors.systemOrange,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.building_2_fill,
        title: 'Real Estate',
        description: 'Track property investments',
        prompt: 'Design a real estate investment tracker showing property values, rental income, and ROI',
        color: CupertinoColors.systemBrown,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.graph_circle_fill,
        title: 'Mutual Funds',
        description: 'Monitor mutual fund performance',
        prompt: 'Create a mutual fund tracker displaying NAV, returns, and fund allocation',
        color: CupertinoColors.systemGreen,
      ),
    ],
    'finance': [
      WidgetTemplate(
        icon: CupertinoIcons.money_dollar_circle_fill,
        title: 'Budget Tracker',
        description: 'Monitor spending & budgets',
        prompt: 'Create a budget tracker with categories, spending limits, and savings goals',
        color: CupertinoColors.systemGreen,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.creditcard_fill,
        title: 'Expense Monitor',
        description: 'Track daily expenses',
        prompt: 'Build an expense monitor with transaction history and spending analysis',
        color: CupertinoColors.systemRed,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.chart_pie_fill,
        title: 'Savings Goal',
        description: 'Track savings progress',
        prompt: 'Design a savings goal tracker with progress visualization',
        color: CupertinoColors.systemBlue,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.percent,
        title: 'Tax Calculator',
        description: 'Calculate tax obligations',
        prompt: 'Create a tax calculator for income tax and deductions',
        color: CupertinoColors.systemGrey,
      ),
    ],
    'productivity': [
      WidgetTemplate(
        icon: CupertinoIcons.calendar,
        title: 'Event Calendar',
        description: 'Manage events and deadlines',
        prompt: 'Create an event calendar with reminders and schedule management',
        color: CupertinoColors.systemOrange,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.list_bullet,
        title: 'Task Manager',
        description: 'Organize tasks and todos',
        prompt: 'Build a task management widget with priorities and deadlines',
        color: CupertinoColors.systemGreen,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.timer,
        title: 'Time Tracker',
        description: 'Track time spent on activities',
        prompt: 'Design a time tracking widget for productivity monitoring',
        color: CupertinoColors.systemPurple,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.doc_text_fill,
        title: 'Notes Widget',
        description: 'Quick notes and reminders',
        prompt: 'Create a notes widget with categories and search',
        color: CupertinoColors.systemYellow,
      ),
    ],
    'lifestyle': [
      WidgetTemplate(
        icon: CupertinoIcons.heart_fill,
        title: 'Health Tracker',
        description: 'Monitor health metrics',
        prompt: 'Create a health tracker for steps, calories, and vitals',
        color: CupertinoColors.systemRed,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.cloud_sun_fill,
        title: 'Weather Widget',
        description: 'Display weather information',
        prompt: 'Build a weather widget with forecasts and alerts',
        color: CupertinoColors.systemBlue,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.music_note_2,
        title: 'Music Player',
        description: 'Control and display music',
        prompt: 'Design a music player widget with playlists',
        color: CupertinoColors.systemPink,
      ),
      WidgetTemplate(
        icon: CupertinoIcons.news,
        title: 'News Feed',
        description: 'Latest news and updates',
        prompt: 'Create a news feed widget with personalized content',
        color: CupertinoColors.systemIndigo,
      ),
    ],
  };
  
  @override
  void dispose() {
    _promptController.dispose();
    _titleController.dispose();
    super.dispose();
  }
  
  Future<void> _createWidget({String? templatePrompt}) async {
    final prompt = templatePrompt ?? _promptController.text.trim();
    final title = _titleController.text.trim();
    
    if (prompt.isEmpty) {
      _showError('Please enter a prompt or select a template');
      return;
    }
    
    setState(() => _isGenerating = true);
    
    DynamicIslandService().startLiveActivity(
      'widget_creation',
      {
        'title': 'Creating Widget',
        'status': 'Generating with AI...',
        'progress': 0.3,
      },
    );
    
    try {
      final result = await _apiService.createWidgetFromPrompt(prompt);
      
      if (result['success'] == true && result['widget'] != null) {
        DynamicIslandService().endLiveActivity('widget_creation');
        DynamicIslandService().updateStatus(
          'Widget created!',
          icon: CupertinoIcons.checkmark_circle_fill,
        );
        
        // Navigate to preview
        Get.to(() => const WidgetPreviewScreen(), 
          arguments: result['widget'],
          transition: Transition.cupertino,
        );
      } else {
        setState(() => _isGenerating = false);
        _showError(result['message'] ?? 'Failed to create widget');
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
        middle: const Text('Create Widget'),
        trailing: _isGenerating
            ? CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Create'),
                onPressed: () => _createWidget(),
              ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Input Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What would you like to create?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title Input
                    CupertinoTextField(
                      controller: _titleController,
                      placeholder: 'Widget title (optional)',
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      style: TextStyle(fontSize: 16),
                      enabled: !_isGenerating,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Prompt Input
                    CupertinoTextField(
                      controller: _promptController,
                      placeholder: 'Describe your widget idea...',
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
            
            // Category Selector
            SliverToBoxAdapter(
              child: Container(
                height: 44,
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _templatesByCategory.keys.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        color: isSelected 
                            ? CupertinoColors.systemIndigo
                            : CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(22),
                        onPressed: () {
                          setState(() => _selectedCategory = category);
                        },
                        child: Text(
                          category.capitalize!,
                          style: TextStyle(
                            color: isSelected 
                                ? CupertinoColors.white
                                : CupertinoColors.label,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
            
            // Templates Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final templates = _templatesByCategory[_selectedCategory]!;
                    if (index >= templates.length) return null;
                    
                    final template = templates[index];
                    return GestureDetector(
                      onTap: _isGenerating
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              _promptController.text = template.prompt;
                              _titleController.text = template.title;
                              setState(() {});
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              template.color.withOpacity(0.15),
                              template.color.withOpacity(0.05),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              template.icon,
                              size: 36,
                              color: template.color,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  template.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  template.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _templatesByCategory[_selectedCategory]!.length,
                ),
              ),
            ),
            
            // Quick Tips
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemIndigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.systemIndigo.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.lightbulb_fill,
                          size: 20,
                          color: CupertinoColors.systemIndigo,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pro Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.systemIndigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('• Be specific about the data you want to display'),
                    _buildTip('• Mention if you want real-time updates'),
                    _buildTip('• Specify colors or theme preferences'),
                    _buildTip('• Include any special features or interactions'),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: CupertinoColors.systemGrey,
          height: 1.4,
        ),
      ),
    );
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