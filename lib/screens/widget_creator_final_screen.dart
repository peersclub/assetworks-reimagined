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
import '../core/services/storage_service.dart';
import 'widget_preview_screen.dart';

class WidgetCreatorFinalScreen extends StatefulWidget {
  final DashboardWidget? remixWidget;
  final bool isRemixMode;
  
  const WidgetCreatorFinalScreen({
    Key? key,
    this.remixWidget,
    this.isRemixMode = false,
  }) : super(key: key);

  @override
  State<WidgetCreatorFinalScreen> createState() => _WidgetCreatorFinalScreenState();
}

class _WidgetCreatorFinalScreenState extends State<WidgetCreatorFinalScreen> 
    with TickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ThemeController _themeController = Get.find<ThemeController>();
  
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State variables
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  String _currentStage = '';
  String? _errorMessage;
  Map<String, dynamic>? _generatedWidget;
  String? _selectedTemplate;
  
  // User info
  String? _currentUsername;
  String? _currentUserId;
  
  // Example prompts for different templates
  final Map<String, List<String>> _templatePrompts = {
    'dashboard': [
      'Create a sales analytics dashboard with revenue charts and KPI metrics',
      'Build a project management dashboard with task progress and team activity',
      'Design a social media dashboard showing follower growth and engagement',
      'Make a fitness dashboard with workout stats and health metrics',
    ],
    'chart': [
      'Create a real-time stock price chart with candlestick patterns',
      'Build a weather forecast chart with temperature and precipitation',
      'Design a budget tracker chart showing expenses by category',
      'Make a crypto portfolio chart with profit/loss indicators',
    ],
    'social': [
      'Create a Twitter-style feed widget with real-time updates',
      'Build an Instagram stories widget with swipe navigation',
      'Design a chat widget with typing indicators and read receipts',
      'Make a social profile card with follower stats and recent posts',
    ],
    'calendar': [
      'Create a monthly calendar with event reminders and color coding',
      'Build a weekly schedule widget with drag-and-drop functionality',
      'Design a countdown widget for upcoming events',
      'Make a habit tracker calendar with streak visualization',
    ],
    'media': [
      'Create a music player widget with album art and visualizer',
      'Build a video player widget with custom controls',
      'Design a photo gallery widget with zoom and swipe features',
      'Make a podcast player widget with playback speed control',
    ],
    'custom': [
      'Create a modern portfolio tracker with real-time stock prices',
      'Build a weather widget with animated backgrounds',
      'Design a todo list with drag and drop functionality',
      'Make a news feed widget with category filters',
    ],
  };
  
  // Widget templates
  final List<WidgetTemplate> _templates = [
    WidgetTemplate(
      id: 'dashboard',
      title: 'Dashboard',
      icon: CupertinoIcons.square_grid_2x2_fill,
      description: 'Analytics & metrics',
      color: CupertinoColors.systemIndigo,
    ),
    WidgetTemplate(
      id: 'chart',
      title: 'Chart',
      icon: CupertinoIcons.chart_bar_alt_fill,
      description: 'Data visualization',
      color: CupertinoColors.systemGreen,
    ),
    WidgetTemplate(
      id: 'social',
      title: 'Social',
      icon: CupertinoIcons.person_2_fill,
      description: 'Social media',
      color: CupertinoColors.systemPurple,
    ),
    WidgetTemplate(
      id: 'calendar',
      title: 'Calendar',
      icon: CupertinoIcons.calendar,
      description: 'Events & scheduling',
      color: CupertinoColors.systemRed,
    ),
    WidgetTemplate(
      id: 'media',
      title: 'Media',
      icon: CupertinoIcons.play_rectangle_fill,
      description: 'Music & video',
      color: CupertinoColors.systemOrange,
    ),
    WidgetTemplate(
      id: 'custom',
      title: 'Custom',
      icon: CupertinoIcons.sparkles,
      description: 'Your imagination',
      color: CupertinoColors.systemPink,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    
    // Load user info
    _loadUserInfo();
    
    // Initialize remix mode
    if (widget.isRemixMode && widget.remixWidget != null) {
      _initializeRemix();
    } else {
      _selectedTemplate = 'custom';
    }
  }
  
  void _loadUserInfo() {
    final user = _storageService.getUser();
    if (user != null) {
      setState(() {
        _currentUsername = user['username'] ?? user['name'] ?? 'Anonymous';
        _currentUserId = user['id']?.toString() ?? user['user_id']?.toString();
      });
    }
  }
  
  @override
  void dispose() {
    _promptController.dispose();
    _titleController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  void _initializeRemix() {
    _titleController.text = 'Remix of ${widget.remixWidget!.title ?? "Widget"}';
    _promptController.text = 'Create a variation of "${widget.remixWidget!.title}" with ';
    _selectedTemplate = widget.remixWidget!.metadata?['template'] ?? 'custom';
  }
  
  void _selectTemplate(String templateId) {
    setState(() {
      _selectedTemplate = templateId;
      _errorMessage = null;
    });
    
    HapticFeedback.lightImpact();
    
    // Show example prompts for selected template
    if (!widget.isRemixMode) {
      _showExamplePrompts(templateId);
    }
  }
  
  void _showExamplePrompts(String templateId) {
    final prompts = _templatePrompts[templateId] ?? _templatePrompts['custom']!;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              'Example Prompts',
              style: iOS18Theme.headline.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: prompts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(16),
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () {
                        _promptController.text = prompts[index];
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                      },
                      child: Text(
                        prompts[index],
                        style: iOS18Theme.body.copyWith(
                          color: CupertinoColors.label,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _generateWidget() async {
    // Validate input
    if (_promptController.text.trim().isEmpty) {
      _showError('Please enter a description for your widget');
      return;
    }
    
    // Use prompt as title if title is empty
    if (_titleController.text.trim().isEmpty) {
      _titleController.text = _promptController.text.trim().length > 50
          ? _promptController.text.trim().substring(0, 50) + '...'
          : _promptController.text.trim();
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
      widgetType: _selectedTemplate,
    );
    
    try {
      // Stage 1: Analyzing
      await _updateProgress('Analyzing your request...', 0.15);
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Stage 2: Generating
      await _updateProgress('Generating widget code...', 0.35);
      
      // Call the actual API
      final response = await _apiService.createWidgetFromPrompt(
        _promptController.text.trim(),
      );
      
      if (response['success'] != true || response['widget'] == null) {
        throw Exception(response['message'] ?? 'Failed to generate widget');
      }
      
      // Stage 3: Optimizing
      await _updateProgress('Optimizing design...', 0.65);
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Stage 4: Applying styles
      await _updateProgress('Applying styles...', 0.85);
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stage 5: Finalizing
      await _updateProgress('Finalizing...', 0.95);
      
      // Process the response
      final widgetData = response['widget'];
      
      // Add current user info to the widget data
      widgetData['username'] = _currentUsername ?? 'Anonymous';
      widgetData['user_id'] = _currentUserId;
      widgetData['title'] = _titleController.text.trim();
      widgetData['original_prompt'] = _promptController.text.trim();
      widgetData['template'] = _selectedTemplate;
      
      setState(() {
        _generatedWidget = widgetData;
        _generationProgress = 1.0;
        _currentStage = 'Complete!';
      });
      
      // Complete Dynamic Island activity
      DynamicIslandService().completeWidgetCreation(
        widgetTitle: widgetData['title'] ?? 'Custom Widget',
        success: true,
      );
      
      // Navigate to preview after a short delay
      await Future.delayed(const Duration(milliseconds: 800));
      _navigateToPreview();
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isGenerating = false;
      });
      
      DynamicIslandService().completeWidgetCreation(
        widgetTitle: 'Widget',
        success: false,
        errorMessage: _errorMessage,
      );
      
      _showError(_errorMessage ?? 'Failed to generate widget');
    }
  }
  
  Future<void> _updateProgress(String stage, double progress) async {
    if (mounted) {
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
  }
  
  void _navigateToPreview() {
    if (_generatedWidget == null) return;
    
    // Create DashboardWidget from generated data
    final widget = DashboardWidget(
      id: _generatedWidget!['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _generatedWidget!['title'] ?? _titleController.text.trim(),
      description: _generatedWidget!['description'] ?? _generatedWidget!['summary'] ?? '',
      summary: _generatedWidget!['summary'] ?? _generatedWidget!['claude_response'] ?? '',
      original_prompt: _promptController.text.trim(),
      username: _currentUsername ?? 'Anonymous',
      user_id: _currentUserId,
      preview_version_url: _generatedWidget!['preview_version_url'] ?? _generatedWidget!['preview_url'],
      full_version_url: _generatedWidget!['full_version_url'] ?? _generatedWidget!['full_url'],
      code_url: _generatedWidget!['code_url'],
      created_at: DateTime.now(),
      metadata: {
        'template': _selectedTemplate,
        'theme': _themeController.isDarkMode ? 'dark' : 'light',
        ..._generatedWidget!,
      },
    );
    
    Get.off(() => const WidgetPreviewScreen(), 
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
        trailing: _isGenerating 
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.xmark_circle_fill),
                onPressed: () => Get.back(),
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
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Title Input
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Widget Title',
                      style: iOS18Theme.headline.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? CupertinoColors.white : CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CupertinoTextField(
                      controller: _titleController,
                      placeholder: 'Give your widget a name...',
                      placeholderStyle: TextStyle(
                        color: CupertinoColors.placeholderText,
                      ),
                      style: iOS18Theme.body.copyWith(
                        color: isDark ? CupertinoColors.white : CupertinoColors.black,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? CupertinoColors.darkBackgroundGray 
                            : CupertinoColors.white,
                        borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
                        border: Border.all(
                          color: CupertinoColors.systemGrey5,
                        ),
                      ),
                      cursorColor: CupertinoColors.systemBlue,
                    ),
                  ],
                ),
              ),
            ),
            
            // Template Selection
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Template',
                      style: iOS18Theme.headline.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? CupertinoColors.white : CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    final isSelected = _selectedTemplate == template.id;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _selectTemplate(template.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 100,
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
                            borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
                            border: Border.all(
                              color: isSelected 
                                  ? template.color 
                                  : CupertinoColors.systemGrey5,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: template.color.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ] : null,
                          ),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Prompt Input
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.isRemixMode ? 'Remix Instructions' : 'Describe Your Widget',
                          style: iOS18Theme.headline.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? CupertinoColors.white : CupertinoColors.black,
                          ),
                        ),
                        if (!widget.isRemixMode && _selectedTemplate != null)
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.lightbulb_fill,
                                  size: 16,
                                  color: CupertinoColors.systemYellow,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Examples',
                                  style: iOS18Theme.footnote.copyWith(
                                    color: CupertinoColors.systemBlue,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () => _showExamplePrompts(_selectedTemplate!),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: isDark 
                            ? CupertinoColors.darkBackgroundGray 
                            : CupertinoColors.white,
                        borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
                        border: Border.all(
                          color: CupertinoColors.systemGrey5,
                        ),
                      ),
                      child: Column(
                        children: [
                          CupertinoTextField(
                            controller: _promptController,
                            placeholder: widget.isRemixMode 
                                ? 'How would you like to modify this widget?'
                                : 'Describe what you want to create in detail...',
                            placeholderStyle: TextStyle(
                              color: CupertinoColors.placeholderText,
                            ),
                            style: iOS18Theme.body.copyWith(
                              color: isDark ? CupertinoColors.white : CupertinoColors.black,
                            ),
                            maxLines: 6,
                            minLines: 4,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            cursorColor: CupertinoColors.systemBlue,
                          ),
                          
                          // Character count
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6.withOpacity(0.5),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(iOS18Theme.largeRadius),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Be specific for better results',
                                  style: iOS18Theme.caption1.copyWith(
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                                Text(
                                  '${_promptController.text.length} characters',
                                  style: iOS18Theme.caption1.copyWith(
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Error Message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
                          border: Border.all(
                            color: CupertinoColors.systemRed.withOpacity(0.3),
                          ),
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
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.isRemixMode ? 'Remix Widget' : 'Generate Widget',
                              style: iOS18Theme.headline.copyWith(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // User Info
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Creating as @${_currentUsername ?? "Anonymous"}',
                        style: iOS18Theme.caption1.copyWith(
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                width: 140,
                height: 140,
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
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.sparkles,
                  color: CupertinoColors.white,
                  size: 60,
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Progress Text
            Text(
              'Creating Your Widget',
              style: iOS18Theme.title1.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              _currentStage,
              style: iOS18Theme.body.copyWith(
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Progress Bar
            SizedBox(
              width: 280,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _generationProgress,
                      minHeight: 12,
                      backgroundColor: CupertinoColors.systemGrey5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CupertinoColors.systemBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
            
            const SizedBox(height: 60),
            
            // Creating as user
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Creating as @${_currentUsername ?? "Anonymous"}',
                style: iOS18Theme.footnote.copyWith(
                  color: CupertinoColors.secondaryLabel,
                ),
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
  final Color color;
  
  WidgetTemplate({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
  });
}