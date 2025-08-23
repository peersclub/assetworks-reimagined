import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/widget_template.dart';
import '../../controllers/template_controller.dart';
import '../../controllers/widget_controller.dart';

class TemplateCustomizeScreen extends StatefulWidget {
  const TemplateCustomizeScreen({Key? key}) : super(key: key);
  
  @override
  State<TemplateCustomizeScreen> createState() => _TemplateCustomizeScreenState();
}

class _TemplateCustomizeScreenState extends State<TemplateCustomizeScreen> {
  late TemplateController _templateController;
  late WidgetController _widgetController;
  late WidgetTemplate template;
  String customPrompt = '';
  
  final Map<String, TextEditingController> _controllers = {};
  final _customPromptController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isGenerating = false;
  
  @override
  void initState() {
    super.initState();
    _templateController = Get.find<TemplateController>();
    _widgetController = Get.find<WidgetController>();
    
    // Get template and custom prompt from arguments
    if (Get.arguments is Map) {
      template = Get.arguments['template'] as WidgetTemplate;
      customPrompt = Get.arguments['customPrompt'] ?? '';
      _customPromptController.text = customPrompt;
    } else {
      template = Get.arguments as WidgetTemplate;
    }
    
    // Initialize controllers for customization fields
    // Parse prompt for placeholders like {field_name}
    final placeholders = _extractPlaceholders(template.prompt ?? '');
    for (String placeholder in placeholders) {
      _controllers[placeholder] = TextEditingController();
    }
  }
  
  Set<String> _extractPlaceholders(String prompt) {
    final pattern = RegExp(r'\{(\w+)\}');
    final matches = pattern.allMatches(prompt);
    return matches.map((m) => m.group(1)!).toSet();
  }
  
  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _customPromptController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Template'),
        actions: [
          IconButton(
            onPressed: _showPreview,
            icon: const Icon(LucideIcons.eye, size: 22),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Template Info Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(template.category),
                        size: 24,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              template.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (template.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.crown,
                                size: 12,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    template.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Customize the fields below to tailor the widget to your specific needs',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Custom Fields
            Text(
              'Customize Fields',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            
            // Dynamic Fields
            ..._controllers.keys.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppTextField(
                  label: _formatFieldLabel(field),
                  hint: 'Enter ${_formatFieldLabel(field).toLowerCase()}',
                  controller: _controllers[field]!,
                  maxLines: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              );
            }).toList(),
            
            // Custom Prompt Field
            if (customPrompt.isNotEmpty || true) ...[
              const SizedBox(height: 20),
              Text(
                'Custom Prompt',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Your Additional Instructions',
                hint: 'Add your own requirements or modifications to the template...',
                controller: _customPromptController,
                maxLines: 4,
                prefixIcon: const Icon(LucideIcons.messageSquare, size: 20),
              ),
            ],
            
            // Advanced Options (Optional)
            ExpansionTile(
              title: const Text('Advanced Options'),
              leading: const Icon(LucideIcons.settings2, size: 20),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Additional Instructions',
                        hint: 'Add any specific requirements or customizations',
                        maxLines: 3,
                        controller: TextEditingController(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Generate Button
            Obx(() => AppButton(
              text: 'Generate Widget',
              icon: LucideIcons.sparkles,
              onPressed: _generateWidget,
              isLoading: _widgetController.isLoading.value,
              isFullWidth: true,
              size: AppButtonSize.large,
            )),
            const SizedBox(height: 12),
            
            // Save as Draft Button
            AppButton(
              text: 'Save as Draft',
              icon: LucideIcons.save,
              type: AppButtonType.outline,
              onPressed: _saveDraft,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatFieldLabel(String field) {
    return field
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Analytics':
        return LucideIcons.barChart3;
      case 'Finance':
        return LucideIcons.dollarSign;
      case 'Marketing':
        return LucideIcons.trendingUp;
      case 'Sales':
        return LucideIcons.shoppingCart;
      case 'Operations':
        return LucideIcons.settings;
      case 'HR':
        return LucideIcons.users;
      default:
        return LucideIcons.layout;
    }
  }
  
  void _showPreview() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Build preview prompt
    String previewPrompt = template.prompt ?? '';
    _controllers.forEach((key, controller) {
      previewPrompt = previewPrompt.replaceAll('{$key}', controller.text);
    });
    
    // Add custom prompt if provided
    if (_customPromptController.text.trim().isNotEmpty) {
      previewPrompt = '$previewPrompt\n\n--- Additional Requirements ---\n${_customPromptController.text.trim()}';
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Preview Prompt',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neutral900 : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  previewPrompt,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _generateWidget() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      // Get custom values
      Map<String, String> customValues = {};
      _controllers.forEach((key, controller) {
        customValues[key] = controller.text;
      });
      
      // Use the template prompt directly
      String customizedPrompt = template.prompt ?? '';
      
      // Replace placeholders with custom values
      customValues.forEach((key, value) {
        customizedPrompt = customizedPrompt.replaceAll('{$key}', value);
      });
      
      // Add custom prompt if provided
      if (_customPromptController.text.trim().isNotEmpty) {
        customizedPrompt = '$customizedPrompt\n\nAdditional requirements: ${_customPromptController.text.trim()}';
      }
      
      // Generate widget with the customized prompt
      await _widgetController.generateWidget(
        prompt: customizedPrompt,
      );
      
      // Navigate to widget view
      if (_widgetController.generatedWidget.value != null) {
        Get.offNamed('/widget-view', arguments: _widgetController.generatedWidget.value);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate widget: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
  
  void _saveDraft() {
    // Save current values as draft
    Map<String, String> draftValues = {};
    _controllers.forEach((key, controller) {
      draftValues[key] = controller.text;
    });
    
    // TODO: Save to local storage
    Get.snackbar(
      'Draft Saved',
      'Your customization has been saved as a draft',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}