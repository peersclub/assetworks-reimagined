import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/widget_response_model.dart';
import '../../controllers/widget_controller.dart';

class WidgetRemixScreen extends StatefulWidget {
  const WidgetRemixScreen({Key? key}) : super(key: key);
  
  @override
  State<WidgetRemixScreen> createState() => _WidgetRemixScreenState();
}

class _WidgetRemixScreenState extends State<WidgetRemixScreen> {
  late WidgetController _controller;
  late WidgetResponseModel originalWidget;
  final _remixController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedMode = 'modify'; // modify, extend, combine
  
  @override
  void initState() {
    super.initState();
    _controller = Get.find<WidgetController>();
    
    // Get original widget from arguments
    originalWidget = Get.arguments as WidgetResponseModel;
    
    // Pre-fill with original prompt
    _remixController.text = originalWidget.originalPrompt;
  }
  
  @override
  void dispose() {
    _remixController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remix Widget'),
        actions: [
          IconButton(
            onPressed: _showRemixHelp,
            icon: const Icon(LucideIcons.helpCircle, size: 22),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Original Widget Info
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.layout,
                        size: 24,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Original Widget',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              originalWidget.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.neutral900 : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      originalWidget.originalPrompt,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.user,
                        size: 14,
                        color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'by ${originalWidget.username}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        LucideIcons.heart,
                        size: 14,
                        color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        originalWidget.likes.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Remix Mode Selection
            Text(
              'Remix Mode',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            
            // Mode Options
            _buildModeOption(
              mode: 'modify',
              icon: LucideIcons.edit3,
              title: 'Modify',
              description: 'Change specific aspects of the widget',
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildModeOption(
              mode: 'extend',
              icon: LucideIcons.plus,
              title: 'Extend',
              description: 'Add new features to the original widget',
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildModeOption(
              mode: 'combine',
              icon: LucideIcons.merge,
              title: 'Combine',
              description: 'Merge this widget with another concept',
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            
            // Remix Instructions
            AppTextField(
              label: _getRemixLabel(),
              hint: _getRemixHint(),
              controller: _remixController,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide remix instructions';
                }
                if (value == originalWidget.originalPrompt) {
                  return 'Please modify the original prompt';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Quick Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickAction('Add charts', LucideIcons.barChart3),
                _buildQuickAction('Add filters', LucideIcons.filter),
                _buildQuickAction('Change layout', LucideIcons.layoutGrid),
                _buildQuickAction('Add export', LucideIcons.download),
              ],
            ),
            const SizedBox(height: 24),
            
            // Attribution Option
            CheckboxListTile(
              value: true,
              onChanged: (value) {},
              title: const Text('Give credit to original creator'),
              subtitle: Text(
                'Shows "Remixed from ${originalWidget.username}"',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            
            // Generate Button
            Obx(() => AppButton(
              text: 'Generate Remix',
              icon: LucideIcons.sparkles,
              onPressed: _generateRemix,
              isLoading: _controller.isLoading.value,
              isFullWidth: true,
              size: AppButtonSize.large,
            )),
            const SizedBox(height: 12),
            
            // Preview Original Button
            AppButton(
              text: 'Preview Original',
              icon: LucideIcons.eye,
              type: AppButtonType.outline,
              onPressed: _previewOriginal,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModeOption({
    required String mode,
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    final isSelected = _selectedMode == mode;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMode = mode;
          _updatePromptForMode();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark
                    ? AppColors.neutral800
                    : AppColors.neutral200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                LucideIcons.checkCircle,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickAction(String label, IconData icon) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
      onPressed: () {
        _addQuickAction(label);
      },
    );
  }
  
  String _getRemixLabel() {
    switch (_selectedMode) {
      case 'modify':
        return 'Modification Instructions';
      case 'extend':
        return 'Extension Instructions';
      case 'combine':
        return 'Combination Instructions';
      default:
        return 'Remix Instructions';
    }
  }
  
  String _getRemixHint() {
    switch (_selectedMode) {
      case 'modify':
        return 'Describe what you want to change...';
      case 'extend':
        return 'Describe what features to add...';
      case 'combine':
        return 'Describe what to combine with...';
      default:
        return 'Describe your remix...';
    }
  }
  
  void _updatePromptForMode() {
    final currentText = _remixController.text;
    final originalPrompt = originalWidget.originalPrompt;
    
    switch (_selectedMode) {
      case 'modify':
        if (currentText == originalPrompt) {
          _remixController.text = 'Modify the following: $originalPrompt\n\nChanges: ';
        }
        break;
      case 'extend':
        if (currentText == originalPrompt) {
          _remixController.text = 'Extend the following: $originalPrompt\n\nAdd: ';
        }
        break;
      case 'combine':
        if (currentText == originalPrompt) {
          _remixController.text = 'Combine the following: $originalPrompt\n\nWith: ';
        }
        break;
    }
  }
  
  void _addQuickAction(String action) {
    final currentText = _remixController.text;
    _remixController.text = '$currentText\n$action';
  }
  
  Future<void> _generateRemix() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      final remixPrompt = _remixController.text;
      
      // Add remix metadata
      final fullPrompt = '''
[REMIX of Widget: ${originalWidget.title}]
Original by: ${originalWidget.username}
Mode: $_selectedMode

$remixPrompt
''';
      
      // Generate the remixed widget
      await _controller.generateWidget(
        prompt: fullPrompt,
        updateData: true,
      );
      
      // Navigate to view the remixed widget
      if (_controller.generatedWidget.value != null) {
        Get.offNamed('/widget-view', arguments: _controller.generatedWidget.value);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate remix: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
  
  void _previewOriginal() {
    Get.toNamed('/widget-view', arguments: originalWidget);
  }
  
  void _showRemixHelp() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'How to Remix',
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
              _buildHelpItem(
                icon: LucideIcons.edit3,
                title: 'Modify Mode',
                description: 'Change colors, layout, or specific data points',
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                icon: LucideIcons.plus,
                title: 'Extend Mode',
                description: 'Add new features like filters, exports, or visualizations',
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                icon: LucideIcons.merge,
                title: 'Combine Mode',
                description: 'Merge with another concept or data source',
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                icon: LucideIcons.award,
                title: 'Attribution',
                description: 'Credit is automatically given to the original creator',
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}