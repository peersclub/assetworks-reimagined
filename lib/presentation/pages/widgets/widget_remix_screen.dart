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
      backgroundColor: isDark ? const Color(0xFF1B2838) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1B2838) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Remix Widget',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showRemixHelp,
            icon: Icon(
              LucideIcons.helpCircle,
              size: 22,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Author Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF253447) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.user,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'by You',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    LucideIcons.heart,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Remix Mode Selection
            Text(
              'Remix Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mode Options
            _buildModeOption(
              mode: 'modify',
              icon: LucideIcons.edit3,
              title: 'Modify',
              description: 'Change specific aspects of the widget',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildModeOption(
              mode: 'extend',
              icon: LucideIcons.plus,
              title: 'Extend',
              description: 'Add new features to the original widget',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildModeOption(
              mode: 'combine',
              icon: LucideIcons.layers,
              title: 'Combine',
              description: 'Merge this widget with another concept',
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            
            // Modification Instructions Label
            Row(
              children: [
                Icon(
                  LucideIcons.edit,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Modification Instructions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Remix Instructions Input
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF253447) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: TextField(
                controller: _remixController,
                maxLines: 5,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Additional requirements:\n${_getRemixHint()}',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Quick Actions
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionButton('Add charts', LucideIcons.barChart3),
                _buildQuickActionButton('Add filters', LucideIcons.filter),
                _buildQuickActionButton('Change layout', LucideIcons.layoutGrid),
                _buildQuickActionButton('Add export', LucideIcons.download),
              ],
            ),
            const SizedBox(height: 32),
            
            // Attribution Option with checkbox
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: true,
                    onChanged: (value) {},
                    activeColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Give credit to original creator',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Shows "Remixed from You"',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Generate Remix Button
            Obx(() => Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _controller.isLoading.value ? null : _generateRemix,
                  child: Center(
                    child: _controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                LucideIcons.sparkles,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Generate Remix',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 16),
            
            // Preview Original Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark ? const Color(0xFF253447) : Colors.grey[100],
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _previewOriginal,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.eye,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Preview Original',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF253447) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withOpacity(0.1)
                    : isDark
                        ? const Color(0xFF1B2838)
                        : Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? Colors.blue
                    : isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.blue
                          : isDark
                              ? Colors.white
                              : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 22,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionButton(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF253447) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _addQuickAction(label),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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