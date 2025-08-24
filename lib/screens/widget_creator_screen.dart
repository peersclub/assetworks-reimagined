import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';
import '../models/dashboard_widget.dart';
import '../core/theme/ios_theme.dart';
import '../controllers/theme_controller.dart';
import 'widget_preview_screen.dart';

class WidgetCreatorScreen extends StatefulWidget {
  final DashboardWidget? templateWidget;
  final bool isRemixMode;
  
  const WidgetCreatorScreen({
    Key? key,
    this.templateWidget,
    this.isRemixMode = false,
  }) : super(key: key);

  @override
  State<WidgetCreatorScreen> createState() => _WidgetCreatorScreenState();
}

class _WidgetCreatorScreenState extends State<WidgetCreatorScreen> 
    with TickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final ThemeController _themeController = Get.find<ThemeController>();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  // State variables
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  String _currentStage = '';
  String? _errorMessage;
  Map<String, dynamic>? _generatedWidget;
  
  // Widget templates
  final List<WidgetTemplate> _templates = [
    WidgetTemplate(
      id: 'dashboard',
      title: 'Dashboard Widget',
      icon: CupertinoIcons.square_grid_2x2_fill,
      description: 'Analytics and metrics display',
      prompt: 'Create a dashboard widget that shows ',
      color: CupertinoColors.systemIndigo,
    ),
    WidgetTemplate(
      id: 'chart',
      title: 'Chart Widget',
      icon: CupertinoIcons.chart_bar_alt_fill,
      description: 'Data visualization charts',
      prompt: 'Design a chart widget displaying ',
      color: CupertinoColors.systemGreen,
    ),
    WidgetTemplate(
      id: 'calendar',
      title: 'Calendar Widget',
      icon: CupertinoIcons.calendar,
      description: 'Events and scheduling',
      prompt: 'Build a calendar widget for ',
      color: CupertinoColors.systemRed,
    ),
    WidgetTemplate(
      id: 'weather',
      title: 'Weather Widget',
      icon: CupertinoIcons.cloud_sun_fill,
      description: 'Weather information display',
      prompt: 'Create a weather widget showing ',
      color: CupertinoColors.systemBlue,
    ),
    WidgetTemplate(
      id: 'social',
      title: 'Social Widget',
      icon: CupertinoIcons.person_2_fill,
      description: 'Social media integration',
      prompt: 'Design a social widget that displays ',
      color: CupertinoColors.systemPurple,
    ),
    WidgetTemplate(
      id: 'custom',
      title: 'Custom Widget',
      icon: CupertinoIcons.sparkles,
      description: 'Create anything you imagine',
      prompt: '',
      color: CupertinoColors.systemOrange,
    ),
  ];
  
  WidgetTemplate? _selectedTemplate;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _fadeController.forward();
    
    // Initialize remix mode
    if (widget.isRemixMode && widget.templateWidget != null) {
      _initializeRemix();
    }
  }
  
  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  void _initializeRemix() {
    _promptController.text = 'Remix of "${widget.templateWidget!.title}": ';
    _selectedTemplate = _templates.firstWhere(
      (t) => t.id == 'custom',
      orElse: () => _templates.last,
    );
  }
  
  Future<void> _generateWidget() async {
    if (_promptController.text.trim().isEmpty) {
      _showError('Please enter a description for your widget');
      return;
    }
    
    setState(() {
      _isGenerating = true;
      _generationProgress = 0.0;
      _currentStage = 'Initializing...';
      _errorMessage = null;
    });
    
    // Start Dynamic Island activity
    DynamicIslandService().startWidgetCreation(
      prompt: _promptController.text.trim(),
      widgetType: _selectedTemplate?.id,
    );
    
    try {
      // Simulate progress stages
      await _updateProgress('Analyzing requirements...', 0.2);
      await Future.delayed(const Duration(seconds: 1));
      
      await _updateProgress('Generating widget code...', 0.4);
      
      // Call API to generate widget
      final response = await _apiService.generateWidget({
        'prompt': _promptController.text.trim(),
        'template': _selectedTemplate?.id ?? 'custom',
        'remix_id': widget.templateWidget?.id,
        'user_preferences': await _getUserPreferences(),
      });
      
      await _updateProgress('Optimizing design...', 0.6);
      await Future.delayed(const Duration(milliseconds: 500));
      
      await _updateProgress('Applying styles...', 0.8);
      await Future.delayed(const Duration(milliseconds: 500));
      
      await _updateProgress('Finalizing...', 0.95);
      
      setState(() {
        _generatedWidget = response;
        _generationProgress = 1.0;
        _currentStage = 'Complete!';
      });
      
      // Complete Dynamic Island activity
      DynamicIslandService().completeWidgetCreation(
        widgetTitle: response['title'] ?? 'Custom Widget',
        success: true,
      );
      
      // Navigate to preview
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToPreview();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate widget: ${e.toString()}';
        _isGenerating = false;
      });
      
      DynamicIslandService().completeWidgetCreation(
        widgetTitle: 'Widget',
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  Future<void> _updateProgress(String stage, double progress) async {
    setState(() {
      _currentStage = stage;
      _generationProgress = progress;
    });
    
    DynamicIslandService().updateWidgetCreationProgress(
      stage: stage.toLowerCase().replaceAll(' ', '_').replaceAll('...', ''),
      progress: progress,
      detail: stage,
    );
  }
  
  Future<Map<String, dynamic>> _getUserPreferences() async {
    return {
      'theme': _themeController.isDarkMode ? 'dark' : 'light',
      'style': 'modern',
      'complexity': 'balanced',
    };
  }
  
  void _navigateToPreview() {
    if (_generatedWidget == null) return;
    
    final widget = DashboardWidget(
      id: _generatedWidget!['id'] ?? '0',
      title: _generatedWidget!['title'] ?? 'Custom Widget',
      description: _generatedWidget!['description'] ?? '',
      summary: _generatedWidget!['summary'] ?? '',
      original_prompt: _promptController.text.trim(),
      preview_version_url: _generatedWidget!['preview_url'],
      full_version_url: _generatedWidget!['full_url'],
      code_url: _generatedWidget!['code_url'],
      created_at: DateTime.now(),
      metadata: _generatedWidget!['metadata'] ?? {},
    );
    
    Get.to(() => const WidgetPreviewScreen(), 
      arguments: widget,
      transition: Transition.cupertino,
    );
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
    final isDark = _themeController.isDarkMode;
    
    return CupertinoPageScaffold(
      backgroundColor: isDark 
          ? CupertinoColors.black 
          : CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? CupertinoColors.darkBackgroundGray.withOpacity(0.94)
            : CupertinoColors.systemBackground.withOpacity(0.94),
        border: null,
        middle: Text(
          widget.isRemixMode ? 'Remix Widget' : 'Create Widget',
          style: iOS18Theme.headline,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            _isGenerating ? 'Cancel' : 'Close',
            style: TextStyle(
              color: CupertinoColors.systemBlue,
              fontSize: 17,
            ),
          ),
          onPressed: () {
            if (_isGenerating) {
              setState(() => _isGenerating = false);
              DynamicIslandService().endLiveActivity();
            } else {
              Get.back();
            }
          },
        ),
      ),
      child: SafeArea(
        child: _isGenerating ? _buildGeneratingView() : _buildCreationView(),
      ),
    );
  }
  
  Widget _buildCreationView() {
    final isDark = _themeController.isDarkMode;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Template Selection
          if (!widget.isRemixMode) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a Template',
                      style: iOS18Theme.title2.copyWith(
                        color: isDark ? CupertinoColors.white : CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start with a template or create from scratch',
                      style: iOS18Theme.subheadline.copyWith(
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final template = _templates[index];
                    final isSelected = _selectedTemplate?.id == template.id;
                    
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedTemplate = template;
                          if (template.prompt.isNotEmpty) {
                            _promptController.text = template.prompt;
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(
                            colors: [
                              template.color.withOpacity(0.8),
                              template.color,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ) : null,
                          color: isSelected ? null : (isDark 
                              ? CupertinoColors.darkBackgroundGray 
                              : CupertinoColors.white),
                          borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
                          border: Border.all(
                            color: isSelected 
                                ? template.color 
                                : CupertinoColors.systemGrey5,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: template.color.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ] : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                template.icon,
                                size: 32,
                                color: isSelected 
                                    ? CupertinoColors.white 
                                    : template.color,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                template.title,
                                style: iOS18Theme.footnote.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? CupertinoColors.white 
                                      : (isDark ? CupertinoColors.white : CupertinoColors.black),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                template.description,
                                style: iOS18Theme.caption2.copyWith(
                                  color: isSelected 
                                      ? CupertinoColors.white.withOpacity(0.8)
                                      : CupertinoColors.secondaryLabel,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _templates.length,
                ),
              ),
            ),
          ],
          
          // Prompt Input
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isRemixMode ? 'Remix Instructions' : 'Describe Your Widget',
                    style: iOS18Theme.title2.copyWith(
                      color: isDark ? CupertinoColors.white : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isRemixMode 
                        ? 'Tell me how you want to modify this widget'
                        : 'Be specific about what you want to create',
                    style: iOS18Theme.subheadline.copyWith(
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Text Field
                  Container(
                    decoration: BoxDecoration(
                      color: isDark 
                          ? CupertinoColors.darkBackgroundGray 
                          : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
                      border: Border.all(
                        color: CupertinoColors.systemGrey5,
                      ),
                    ),
                    child: CupertinoTextField(
                      controller: _promptController,
                      placeholder: widget.isRemixMode 
                          ? 'Change the color scheme to dark purple and add animations...'
                          : 'A modern dashboard showing sales metrics with charts...',
                      placeholderStyle: TextStyle(
                        color: CupertinoColors.placeholderText,
                      ),
                      style: iOS18Theme.body.copyWith(
                        color: isDark ? CupertinoColors.white : CupertinoColors.black,
                      ),
                      maxLines: 5,
                      minLines: 3,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? CupertinoColors.darkBackgroundGray 
                            : CupertinoColors.white,
                        borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
                      ),
                      cursorColor: CupertinoColors.systemBlue,
                    ),
                  ),
                  
                  // Error Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_circle_fill,
                            color: CupertinoColors.systemRed,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: iOS18Theme.footnote.copyWith(
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: CupertinoButton(
                      borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
                      color: CupertinoColors.systemBlue,
                      onPressed: _generateWidget,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.sparkles,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isRemixMode ? 'Remix Widget' : 'Generate Widget',
                            style: iOS18Theme.headline.copyWith(
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGeneratingView() {
    final isDark = _themeController.isDarkMode;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemIndigo,
                      CupertinoColors.systemPurple,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemIndigo.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.sparkles,
                  color: CupertinoColors.white,
                  size: 50,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Progress Text
            Text(
              'Creating Your Widget',
              style: iOS18Theme.title2.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              _currentStage,
              style: iOS18Theme.subheadline.copyWith(
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Progress Bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: MediaQuery.of(context).size.width * _generationProgress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.systemIndigo,
                        CupertinoColors.systemPurple,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress Percentage
            Text(
              '${(_generationProgress * 100).toInt()}%',
              style: iOS18Theme.headline.copyWith(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemIndigo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Template Model
class WidgetTemplate {
  final String id;
  final String title;
  final IconData icon;
  final String description;
  final String prompt;
  final Color color;
  
  WidgetTemplate({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.prompt,
    required this.color,
  });
}