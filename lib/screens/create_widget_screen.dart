import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';
import '../models/dashboard_widget.dart';

class CreateWidgetScreen extends StatefulWidget {
  const CreateWidgetScreen({Key? key}) : super(key: key);

  @override
  State<CreateWidgetScreen> createState() => _CreateWidgetScreenState();
}

class _CreateWidgetScreenState extends State<CreateWidgetScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final TextEditingController _promptController = TextEditingController();
  
  bool _isGenerating = false;
  DashboardWidget? _generatedWidget;
  String? _errorMessage;
  
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  // Example prompts
  final List<String> _examplePrompts = [
    'Create a modern portfolio tracker with real-time stock prices',
    'Build a weather widget with animated backgrounds',
    'Design a todo list with drag and drop functionality',
    'Make a countdown timer with custom animations',
    'Create a music player widget with visualizer',
    'Build a calendar widget with event reminders',
    'Design a fitness tracker with progress charts',
    'Make a news feed widget with category filters',
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _promptController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _generateWidget() async {
    if (_promptController.text.trim().isEmpty) {
      _showError('Please enter a prompt');
      return;
    }
    
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedWidget = null;
    });
    
    _animationController.repeat(reverse: true);
    
    // Update Dynamic Island
    DynamicIslandService().updateStatus(
      'Generating widget...',
      icon: CupertinoIcons.wand_stars,
    );
    
    try {
      final result = await _apiService.createWidgetFromPrompt(
        _promptController.text.trim(),
      );
      
      if (result['success'] == true && result['widget'] != null) {
        setState(() {
          _generatedWidget = DashboardWidget.fromJson(result['widget']);
          _isGenerating = false;
        });
        
        _animationController.stop();
        _animationController.reset();
        
        DynamicIslandService().updateStatus(
          'Widget generated!',
          icon: CupertinoIcons.checkmark_circle_fill,
        );
        
        // Navigate to preview
        _showWidgetPreview();
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to generate widget';
          _isGenerating = false;
        });
        
        _animationController.stop();
        _animationController.reset();
        
        DynamicIslandService().updateStatus(
          'Generation failed',
          icon: CupertinoIcons.xmark_circle_fill,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isGenerating = false;
      });
      
      _animationController.stop();
      _animationController.reset();
    }
  }
  
  void _showWidgetPreview() {
    if (_generatedWidget == null) return;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Widget Preview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Preview content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.cube_box_fill,
                        size: 64,
                        color: CupertinoColors.systemIndigo,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _generatedWidget!.title ?? 'Generated Widget',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to open in full view',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      color: CupertinoColors.systemGrey5,
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _generatedWidget = null;
                          _promptController.clear();
                        });
                      },
                      child: const Text(
                        'Generate Another',
                        style: TextStyle(
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      color: CupertinoColors.systemIndigo,
                      onPressed: () async {
                        Navigator.pop(context);
                        
                        // Save widget
                        final success = await _apiService.saveWidgetToProfile(
                          _generatedWidget!.id,
                        );
                        
                        if (success) {
                          DynamicIslandService().updateStatus(
                            'Widget saved!',
                            icon: CupertinoIcons.bookmark_fill,
                          );
                          
                          // Navigate to widget preview
                          Get.toNamed('/widget-preview', 
                            arguments: _generatedWidget,
                          );
                        }
                      },
                      child: const Text('Save & View'),
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
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.0),
        border: null,
        middle: const Text('Create Widget'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.clock),
          onPressed: () => Get.toNamed('/prompt-history'),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isGenerating ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CupertinoColors.systemIndigo,
                              CupertinoColors.systemPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          _isGenerating 
                              ? CupertinoIcons.wand_stars
                              : CupertinoIcons.cube_box_fill,
                          size: 50,
                          color: CupertinoColors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Center(
                child: Text(
                  'What would you like to create?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Center(
                child: Text(
                  'Describe your widget idea and AI will generate it',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Prompt Input
              CupertinoTextField(
                controller: _promptController,
                placeholder: 'Enter your widget idea...',
                maxLines: 4,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                enabled: !_isGenerating,
              ),
              
              const SizedBox(height: 16),
              
              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CupertinoButton(
                  color: CupertinoColors.systemIndigo,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _isGenerating ? null : _generateWidget,
                  child: _isGenerating
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        )
                      : const Text(
                          'Generate Widget',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              // Error Message
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_circle,
                        color: CupertinoColors.systemRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Example Prompts
              Text(
                'Try these examples:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _examplePrompts.take(4).map((prompt) {
                  return GestureDetector(
                    onTap: () {
                      if (!_isGenerating) {
                        setState(() {
                          _promptController.text = prompt;
                        });
                        HapticFeedback.lightImpact();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemIndigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        prompt.split(' ').take(4).join(' ') + '...',
                        style: TextStyle(
                          color: CupertinoColors.systemIndigo,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}