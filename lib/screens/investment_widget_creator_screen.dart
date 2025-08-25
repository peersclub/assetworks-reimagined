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

/// Investment Widget Creator Screen
/// Supports 4 creation flows:
/// 1. Standard widget creation (from scratch)
/// 2. Template-based creation (using investment templates)
/// 3. Remix existing widget
/// 4. Remix with template (modify existing widget with template guidance)
class InvestmentWidgetCreatorScreen extends StatefulWidget {
  final DashboardWidget? remixWidget;
  final String? selectedTemplate;
  final bool isRemixMode;
  
  const InvestmentWidgetCreatorScreen({
    Key? key,
    this.remixWidget,
    this.selectedTemplate,
    this.isRemixMode = false,
  }) : super(key: key);

  @override
  State<InvestmentWidgetCreatorScreen> createState() => _InvestmentWidgetCreatorScreenState();
}

class _InvestmentWidgetCreatorScreenState extends State<InvestmentWidgetCreatorScreen> 
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
  String _creationMode = 'standard'; // standard, template, remix, remix_template
  
  // User info
  String? _currentUsername;
  String? _currentUserId;
  
  // Investment-focused templates
  final List<InvestmentTemplate> _templates = [
    InvestmentTemplate(
      id: 'portfolio',
      title: 'Portfolio',
      icon: CupertinoIcons.briefcase_fill,
      description: 'Portfolio tracking & analysis',
      color: CupertinoColors.systemIndigo,
      prompts: [
        'Create a diversified portfolio tracker with real-time prices and P&L analysis',
        'Build a portfolio rebalancing widget with AI-powered recommendations',
        'Design a dividend income tracker with yield analysis and payment calendar',
        'Make a risk-adjusted portfolio optimizer with Sharpe ratio calculations',
      ],
    ),
    InvestmentTemplate(
      id: 'stocks',
      title: 'Stocks',
      icon: CupertinoIcons.graph_square_fill,
      description: 'Equity market analysis',
      color: CupertinoColors.systemGreen,
      prompts: [
        'Create a stock screener with fundamental analysis and PE ratios',
        'Build a real-time stock price tracker with candlestick charts',
        'Design an earnings calendar widget with analyst estimates and surprises',
        'Make a market sentiment analyzer for S&P 500 stocks with fear/greed index',
      ],
    ),
    InvestmentTemplate(
      id: 'crypto',
      title: 'Crypto',
      icon: CupertinoIcons.bitcoin,
      description: 'Cryptocurrency tracking',
      color: CupertinoColors.systemOrange,
      prompts: [
        'Create a crypto portfolio dashboard with DeFi yields and staking rewards',
        'Build a Bitcoin dominance tracker with altcoin correlation analysis',
        'Design a DeFi protocol monitor with APY rates and TVL metrics',
        'Make an NFT collection tracker with floor prices and rarity scores',
      ],
    ),
    InvestmentTemplate(
      id: 'bonds',
      title: 'Bonds',
      icon: CupertinoIcons.doc_text_fill,
      description: 'Fixed income securities',
      color: CupertinoColors.systemBlue,
      prompts: [
        'Create a bond yield curve visualizer with duration analysis',
        'Build a treasury bond calculator with maturity and coupon payments',
        'Design a corporate bond screener with credit ratings and spreads',
        'Make a municipal bond analyzer with tax-equivalent yield calculator',
      ],
    ),
    InvestmentTemplate(
      id: 'etfs',
      title: 'ETFs',
      icon: CupertinoIcons.layers_fill,
      description: 'Fund investments',
      color: CupertinoColors.systemPurple,
      prompts: [
        'Create an ETF comparison tool with expense ratios and tracking error',
        'Build a sector rotation ETF tracker with momentum indicators',
        'Design a thematic ETF explorer with holdings and performance data',
        'Make an index fund analyzer with dividend yield and beta metrics',
      ],
    ),
    InvestmentTemplate(
      id: 'realestate',
      title: 'Real Estate',
      icon: CupertinoIcons.house_fill,
      description: 'Property investments',
      color: CupertinoColors.systemRed,
      prompts: [
        'Create a REIT portfolio tracker with dividend yields and FFO analysis',
        'Build a property valuation calculator with cap rate and cash flow',
        'Design a rental income analyzer with ROI and vacancy rate metrics',
        'Make a real estate market heatmap with price trends and inventory',
      ],
    ),
    InvestmentTemplate(
      id: 'forex',
      title: 'Forex',
      icon: CupertinoIcons.money_dollar_circle_fill,
      description: 'Currency trading',
      color: CupertinoColors.systemTeal,
      prompts: [
        'Create a forex pair tracker with real-time exchange rates',
        'Build a currency correlation matrix with volatility analysis',
        'Design a carry trade calculator with interest rate differentials',
        'Make a forex sentiment indicator with positioning data',
      ],
    ),
    InvestmentTemplate(
      id: 'commodities',
      title: 'Commodities',
      icon: CupertinoIcons.cube_box_fill,
      description: 'Raw materials & resources',
      color: CupertinoColors.systemYellow,
      prompts: [
        'Create a commodity futures tracker with contango/backwardation analysis',
        'Build a precious metals portfolio with gold/silver ratio charts',
        'Design an energy commodities dashboard with oil, gas, and uranium',
        'Make an agricultural commodities monitor with seasonal patterns',
      ],
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
    
    // Determine creation mode and initialize
    _determineCreationMode();
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
  
  void _determineCreationMode() {
    if (widget.isRemixMode && widget.remixWidget != null) {
      if (widget.selectedTemplate != null) {
        // Mode 4: Remix with template
        _creationMode = 'remix_template';
        _selectedTemplate = widget.selectedTemplate;
        _initializeRemixWithTemplate();
      } else {
        // Mode 3: Simple remix
        _creationMode = 'remix';
        _initializeRemix();
      }
    } else if (widget.selectedTemplate != null) {
      // Mode 2: Template-based creation
      _creationMode = 'template';
      _selectedTemplate = widget.selectedTemplate;
      _initializeWithTemplate();
    } else {
      // Mode 1: Standard creation
      _creationMode = 'standard';
      _selectedTemplate = null;
    }
  }
  
  void _initializeRemix() {
    _titleController.text = 'Remix of ${widget.remixWidget!.title ?? "Widget"}';
    _promptController.text = 'Create an improved version of "${widget.remixWidget!.title}" with ';
    
    // Try to detect original template
    final metadata = widget.remixWidget!.metadata;
    if (metadata != null && metadata['template'] != null) {
      _selectedTemplate = metadata['template'];
    }
  }
  
  void _initializeRemixWithTemplate() {
    final template = _templates.firstWhere(
      (t) => t.id == widget.selectedTemplate,
      orElse: () => _templates.first,
    );
    
    _titleController.text = '${template.title} Remix: ${widget.remixWidget!.title}';
    _promptController.text = 'Transform "${widget.remixWidget!.title}" into a ${template.title.toLowerCase()} widget with ';
  }
  
  void _initializeWithTemplate() {
    final template = _templates.firstWhere(
      (t) => t.id == widget.selectedTemplate,
      orElse: () => _templates.first,
    );
    
    _titleController.text = 'My ${template.title} Widget';
    // Show template examples
    Future.delayed(Duration.zero, () => _showTemplateExamples(template));
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
  
  void _selectTemplate(InvestmentTemplate template) {
    setState(() {
      _selectedTemplate = template.id;
      _errorMessage = null;
      
      // Update creation mode if needed
      if (_creationMode == 'standard') {
        _creationMode = 'template';
      } else if (_creationMode == 'remix') {
        _creationMode = 'remix_template';
      }
    });
    
    HapticFeedback.lightImpact();
    _showTemplateExamples(template);
  }
  
  void _showTemplateExamples(InvestmentTemplate template) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              '${template.title} Widget Examples',
              style: iOS18Theme.headline.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              template.description,
              style: iOS18Theme.subheadline.copyWith(
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: template.prompts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(16),
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () {
                        _promptController.text = template.prompts[index];
                        if (_titleController.text.isEmpty) {
                          _titleController.text = '${template.title} Widget ${index + 1}';
                        }
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                      },
                      child: Text(
                        template.prompts[index],
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoButton(
                color: template.color,
                borderRadius: BorderRadius.circular(12),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
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
      _showError('Please describe your investment widget');
      return;
    }
    
    // Auto-generate title if empty
    if (_titleController.text.trim().isEmpty) {
      final template = _selectedTemplate != null
          ? _templates.firstWhere((t) => t.id == _selectedTemplate).title
          : 'Investment';
      _titleController.text = '$template Widget';
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
      widgetType: _selectedTemplate ?? 'investment',
    );
    
    try {
      // Stage 1: Analyzing
      await _updateProgress('Analyzing investment requirements...', 0.15);
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Stage 2: Market Data
      await _updateProgress('Fetching market data...', 0.30);
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Stage 3: Generating
      await _updateProgress('Generating investment widget...', 0.50);
      
      // Prepare API request with all context
      final requestData = {
        'prompt': _promptController.text.trim(),
        'title': _titleController.text.trim(),
        'template': _selectedTemplate,
        'creation_mode': _creationMode,
        'username': _currentUsername,
        'user_id': _currentUserId,
      };
      
      // Add remix context if applicable
      if (widget.remixWidget != null) {
        requestData['remix_widget_id'] = widget.remixWidget!.id;
        requestData['remix_widget_title'] = widget.remixWidget!.title;
        requestData['remix_widget_template'] = widget.remixWidget!.metadata?['template'];
      }
      
      // Call API
      final response = await _apiService.createWidgetFromPrompt(
        _promptController.text.trim(),
      );
      
      if (response['success'] != true || response['widget'] == null) {
        throw Exception(response['message'] ?? 'Failed to generate widget');
      }
      
      // Stage 4: Applying financial models
      await _updateProgress('Applying financial models...', 0.70);
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stage 5: Optimizing visualizations
      await _updateProgress('Optimizing visualizations...', 0.85);
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stage 6: Finalizing
      await _updateProgress('Finalizing investment widget...', 0.95);
      
      // Process response
      final widgetData = response['widget'];
      widgetData['username'] = _currentUsername ?? 'Anonymous';
      widgetData['user_id'] = _currentUserId;
      widgetData['title'] = _titleController.text.trim();
      widgetData['original_prompt'] = _promptController.text.trim();
      widgetData['template'] = _selectedTemplate;
      widgetData['creation_mode'] = _creationMode;
      
      setState(() {
        _generatedWidget = widgetData;
        _generationProgress = 1.0;
        _currentStage = 'Complete!';
      });
      
      // Complete Dynamic Island activity
      DynamicIslandService().completeWidgetCreation(
        widgetTitle: widgetData['title'] ?? 'Investment Widget',
        success: true,
      );
      
      // Navigate to preview
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
      
      _showError(_errorMessage ?? 'Failed to generate investment widget');
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
    
    final widget = DashboardWidget(
      id: _generatedWidget!['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _generatedWidget!['title'] ?? _titleController.text.trim(),
      description: _generatedWidget!['description'] ?? '',
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
        'creation_mode': _creationMode,
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
  
  String _getCreationModeTitle() {
    switch (_creationMode) {
      case 'remix':
        return 'Remix Widget';
      case 'remix_template':
        return 'Remix with ${_templates.firstWhere((t) => t.id == _selectedTemplate).title}';
      case 'template':
        return 'Create ${_templates.firstWhere((t) => t.id == _selectedTemplate).title} Widget';
      default:
        return 'Create Investment Widget';
    }
  }
  
  String _getCreationModeSubtitle() {
    switch (_creationMode) {
      case 'remix':
        return 'Transforming: ${widget.remixWidget?.title}';
      case 'remix_template':
        return 'Applying template to: ${widget.remixWidget?.title}';
      case 'template':
        return 'Using ${_templates.firstWhere((t) => t.id == _selectedTemplate).title} template';
      default:
        return 'Build your custom investment tracker';
    }
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
        middle: Column(
          children: [
            Text(
              _getCreationModeTitle(),
              style: iOS18Theme.headline,
            ),
            if (_getCreationModeSubtitle().isNotEmpty)
              Text(
                _getCreationModeSubtitle(),
                style: iOS18Theme.caption1.copyWith(
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
          ],
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
            // Creation Mode Indicator
            if (_creationMode != 'standard')
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.systemIndigo.withOpacity(0.1),
                        CupertinoColors.systemPurple.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
                    border: Border.all(
                      color: CupertinoColors.systemIndigo.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _creationMode.contains('remix') 
                            ? CupertinoIcons.arrow_2_circlepath
                            : CupertinoIcons.sparkles,
                        color: CupertinoColors.systemIndigo,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _creationMode.contains('remix') ? 'Remix Mode' : 'Template Mode',
                              style: iOS18Theme.headline.copyWith(
                                color: CupertinoColors.systemIndigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getCreationModeSubtitle(),
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
              ),
            
            // Title Input
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      placeholder: 'e.g., My Portfolio Tracker',
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Template Selection
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Investment Templates',
                          style: iOS18Theme.headline.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? CupertinoColors.white : CupertinoColors.black,
                          ),
                        ),
                        if (_selectedTemplate != null)
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text(
                              'Clear',
                              style: iOS18Theme.footnote.copyWith(
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedTemplate = null;
                                if (_creationMode == 'template') {
                                  _creationMode = 'standard';
                                } else if (_creationMode == 'remix_template') {
                                  _creationMode = 'remix';
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 130,
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
                            onTap: () => _selectTemplate(template),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 110,
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
                                    maxLines: 2,
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
                ],
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
                          _creationMode.contains('remix') 
                              ? 'Remix Instructions' 
                              : 'Describe Your Investment Widget',
                          style: iOS18Theme.headline.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? CupertinoColors.white : CupertinoColors.black,
                          ),
                        ),
                        if (_selectedTemplate != null)
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
                            onPressed: () {
                              final template = _templates.firstWhere((t) => t.id == _selectedTemplate);
                              _showTemplateExamples(template);
                            },
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
                            placeholder: _creationMode.contains('remix')
                                ? 'How would you like to transform this widget?'
                                : 'Describe your investment tracking needs in detail...',
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
                          
                          // Info bar
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
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.info_circle_fill,
                                      size: 14,
                                      color: CupertinoColors.systemIndigo,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Be specific for better results',
                                      style: iOS18Theme.caption1.copyWith(
                                        color: CupertinoColors.secondaryLabel,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${_promptController.text.length} chars',
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
                        color: CupertinoColors.systemIndigo,
                        onPressed: _generateWidget,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _creationMode.contains('remix')
                                  ? CupertinoIcons.arrow_2_circlepath
                                  : CupertinoIcons.sparkles,
                              color: CupertinoColors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _creationMode.contains('remix') 
                                  ? 'Remix Widget' 
                                  : 'Generate Investment Widget',
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Creating as @${_currentUsername ?? "Anonymous"}',
                          style: iOS18Theme.caption1.copyWith(
                            color: CupertinoColors.secondaryLabel,
                          ),
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
                      CupertinoColors.systemGreen,
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
                child: Icon(
                  _selectedTemplate != null
                      ? _templates.firstWhere((t) => t.id == _selectedTemplate).icon
                      : CupertinoIcons.graph_square_fill,
                  color: CupertinoColors.white,
                  size: 60,
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Progress Text
            Text(
              'Creating Investment Widget',
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
                        CupertinoColors.systemIndigo,
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
            
            // Creation mode info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    _getCreationModeTitle(),
                    style: iOS18Theme.footnote.copyWith(
                      color: CupertinoColors.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by @${_currentUsername ?? "Anonymous"}',
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
    );
  }
}

// Investment Template Model
class InvestmentTemplate {
  final String id;
  final String title;
  final IconData icon;
  final String description;
  final Color color;
  final List<String> prompts;
  
  InvestmentTemplate({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
    required this.prompts,
  });
}