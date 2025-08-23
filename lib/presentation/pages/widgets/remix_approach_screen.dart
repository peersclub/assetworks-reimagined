import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/widget_response_model.dart';
import '../../controllers/widget_controller.dart';
import '../../widgets/remix_info_card.dart';

class RemixApproachScreen extends StatefulWidget {
  const RemixApproachScreen({Key? key}) : super(key: key);
  
  @override
  State<RemixApproachScreen> createState() => _RemixApproachScreenState();
}

class _RemixApproachScreenState extends State<RemixApproachScreen> 
    with SingleTickerProviderStateMixin {
  late WidgetResponseModel originalWidget;
  late WidgetController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  String selectedApproach = 'modify';
  final _customPromptController = TextEditingController();
  
  final List<Map<String, dynamic>> remixApproaches = [
    {
      'id': 'modify',
      'title': 'Modify & Enhance',
      'description': 'Keep the core concept but add your own improvements and features',
      'icon': LucideIcons.sparkles,
      'color': AppColors.primary,
      'prompts': [
        'Add more interactive features',
        'Improve the visual design',
        'Add real-time data updates',
        'Enhance mobile responsiveness',
      ],
    },
    {
      'id': 'combine',
      'title': 'Combine with Another',
      'description': 'Merge this widget with another concept for something unique',
      'icon': LucideIcons.gitMerge,
      'color': AppColors.success,
      'prompts': [
        'Combine with dashboard metrics',
        'Add AI-powered insights',
        'Integrate with portfolio tracking',
        'Merge with notification system',
      ],
    },
    {
      'id': 'simplify',
      'title': 'Simplify',
      'description': 'Strip down to essentials for a cleaner, focused experience',
      'icon': LucideIcons.minimize2,
      'color': AppColors.info,
      'prompts': [
        'Remove complex features',
        'Focus on core functionality',
        'Minimize to key metrics only',
        'Create mobile-first version',
      ],
    },
    {
      'id': 'transform',
      'title': 'Transform Purpose',
      'description': 'Change the widget\'s purpose while keeping its structure',
      'icon': LucideIcons.shuffle,
      'color': AppColors.warning,
      'prompts': [
        'Convert to different asset class',
        'Change from analysis to tracking',
        'Transform to educational tool',
        'Adapt for different industry',
      ],
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _controller = Get.find<WidgetController>();
    
    // Get widget from arguments
    final args = Get.arguments;
    if (args is WidgetResponseModel) {
      originalWidget = args;
    } else {
      // Fallback - shouldn't happen
      Get.back();
      return;
    }
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Remix Widget'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.gitBranch,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Choose Your Remix Approach',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select how you want to transform "${originalWidget.title}"',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Original Widget Info
                          RemixInfoCard(
                            widget: originalWidget,
                            onViewOriginal: () {
                              Get.back();
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Approach Selection
                          Text(
                            'Select Remix Approach',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Approach Options Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: remixApproaches.length,
                            itemBuilder: (context, index) {
                              final approach = remixApproaches[index];
                              final isSelected = selectedApproach == approach['id'];
                              
                              return AppCard(
                                onTap: () {
                                  setState(() {
                                    selectedApproach = approach['id'];
                                  });
                                },
                                padding: const EdgeInsets.all(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: isSelected
                                      ? Border.all(
                                          color: approach['color'] as Color,
                                          width: 2,
                                        )
                                      : null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: (approach['color'] as Color).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          approach['icon'] as IconData,
                                          size: 24,
                                          color: approach['color'] as Color,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        approach['title'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark 
                                            ? AppColors.textPrimaryDark 
                                            : AppColors.textPrimaryLight,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        approach['description'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark 
                                            ? AppColors.textSecondaryDark 
                                            : AppColors.textSecondaryLight,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Suggested Prompts
                          if (selectedApproach.isNotEmpty) ...[
                            Text(
                              'Suggested Modifications',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final prompt in (remixApproaches.firstWhere(
                                  (a) => a['id'] == selectedApproach,
                                )['prompts'] as List<String>))
                                  InkWell(
                                    onTap: () {
                                      _customPromptController.text = prompt;
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark 
                                          ? AppColors.neutral800 
                                          : AppColors.neutral100,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isDark 
                                            ? AppColors.neutral700 
                                            : AppColors.neutral200,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            LucideIcons.plus,
                                            size: 14,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            prompt,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark 
                                                ? AppColors.textPrimaryDark 
                                                : AppColors.textPrimaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                          
                          // Custom Instructions
                          Text(
                            'Your Instructions (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _customPromptController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Describe how you want to remix this widget...',
                              filled: true,
                              fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Cancel',
                type: AppButtonType.outline,
                onPressed: () => Get.back(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton(
                text: 'Start Remixing',
                icon: LucideIcons.arrowRight,
                onPressed: _startRemix,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _startRemix() {
    // Set the widget as remix source
    _controller.setRemixWidget(originalWidget);
    
    // Build initial prompt based on approach
    String initialPrompt = '';
    final approach = remixApproaches.firstWhere((a) => a['id'] == selectedApproach);
    
    if (_customPromptController.text.isNotEmpty) {
      initialPrompt = _customPromptController.text;
    } else {
      initialPrompt = 'I want to ${approach['title'].toString().toLowerCase()} this widget';
    }
    
    // Build remix context data
    final remixData = {
      'type': 'remix',
      'originalWidget': originalWidget,
      'approach': approach,
      'approachId': selectedApproach,
      'approachTitle': approach['title'],
      'approachDescription': approach['description'],
      'customInstructions': _customPromptController.text,
      'initialPrompt': initialPrompt,
      'remixContext': 'Remixing "${originalWidget.title}" by @${originalWidget.username} - ${approach['description']}',
    };
    
    // Navigate to create widget screen with remix data
    Get.offNamed('/create-widget', arguments: remixData);
    
    Get.snackbar(
      'Remix Started',
      'Original creator will be attributed in your remix',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      icon: const Icon(
        LucideIcons.gitBranch,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
    );
  }
}