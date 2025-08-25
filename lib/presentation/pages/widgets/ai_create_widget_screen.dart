import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../controllers/ai_widget_controller.dart';
import '../../widgets/ai_provider_selector.dart';
import '../../../data/models/ai_provider_model.dart';
import '../../../core/theme/app_colors.dart';

class AICreateWidgetScreen extends StatefulWidget {
  const AICreateWidgetScreen({Key? key}) : super(key: key);

  @override
  State<AICreateWidgetScreen> createState() => _AICreateWidgetScreenState();
}

class _AICreateWidgetScreenState extends State<AICreateWidgetScreen> {
  final AIWidgetController controller = Get.put(AIWidgetController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProviderSection(),
                    const SizedBox(height: 24),
                    _buildWidgetTypeSelector(),
                    const SizedBox(height: 24),
                    _buildInputFields(),
                    const SizedBox(height: 24),
                    _buildAdvancedOptions(),
                    const SizedBox(height: 24),
                    _buildCreditInfo(),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          CupertinoIcons.back,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Create AI Widget',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.headlineSmall?.color,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            LucideIcons.history,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: _showHistory,
        ),
      ],
    );
  }

  Widget _buildProviderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AI Provider',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            TextButton.icon(
              onPressed: _showProviderDetails,
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('Compare'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => AIProviderSelector(
          selectedProvider: controller.selectedProvider.value,
          onProviderChanged: controller.changeProvider,
          showDescription: true,
          isCompact: false,
        )),
      ],
    );
  }

  Widget _buildWidgetTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Widget Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: WidgetType.values.map((type) {
            final isSelected = controller.selectedType.value == type;
            return GestureDetector(
              onTap: () => controller.changeWidgetType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).dividerColor.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      size: 18,
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTypeName(type),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _titleController,
          label: 'Widget Title',
          hint: 'Enter a descriptive title',
          icon: Icons.title,
          maxLines: 1,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _promptController,
          label: 'AI Prompt',
          hint: 'Describe what you want to create...',
          icon: Icons.psychology,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description (Optional)',
          hint: 'Add additional context or requirements',
          icon: Icons.description,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              prefixIcon: maxLines == 1
                  ? Icon(icon, size: 20, color: Theme.of(context).iconTheme.color)
                  : Padding(
                      padding: const EdgeInsets.only(left: 12, top: 12),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
                      ),
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Options',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
          children: [
            _buildOptionTile(
              title: 'Real-time Data',
              subtitle: 'Enable live data updates',
              value: controller.useRealTimeData.value,
              onChanged: (_) => controller.toggleRealTimeData(),
              icon: Icons.sync,
            ),
            _buildOptionTile(
              title: 'Interactive',
              subtitle: 'Allow user interactions',
              value: controller.isInteractive.value,
              onChanged: (_) => controller.toggleInteractive(),
              icon: Icons.touch_app,
            ),
            _buildOptionTile(
              title: 'Public',
              subtitle: 'Make widget publicly accessible',
              value: controller.isPublic.value,
              onChanged: (_) => controller.togglePublic(),
              icon: Icons.public,
            ),
            _buildOptionTile(
              title: 'API Access',
              subtitle: 'Enable API endpoints',
              value: controller.enableAPI.value,
              onChanged: (_) => controller.toggleAPI(),
              icon: Icons.api,
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        trailing: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildCreditInfo() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.selectedProvider.value.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.selectedProvider.value.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: controller.selectedProvider.value.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Credit Cost',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${controller.estimatedCost.value} credits',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: controller.selectedProvider.value.color,
                        ),
                      ),
                      TextSpan(
                        text: ' for ${controller.selectedProvider.value.name}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Balance: ${controller.availableCredits.value}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: controller.availableCredits.value >= controller.estimatedCost.value
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
      ),
      child: Obx(() => ElevatedButton(
        onPressed: controller.isCreating.value ? null : _createWidget,
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.selectedProvider.value.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.isCreating.value
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(controller.selectedProvider.value.icon),
                  const SizedBox(width: 8),
                  Text(
                    'Create with ${controller.selectedProvider.value.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      )),
    );
  }

  void _createWidget() async {
    if (_titleController.text.isEmpty || _promptController.text.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please provide both title and prompt',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await controller.createWidget(
      title: _titleController.text,
      prompt: _promptController.text,
      description: _descriptionController.text.isEmpty 
          ? null 
          : _descriptionController.text,
      streamResponse: true,
    );

    if (result != null) {
      // Navigate to preview or success screen
      Get.toNamed('/widget-preview', arguments: result);
    }
  }

  void _showProviderDetails() {
    AIProviderBottomSheet.show(
      context,
      currentProvider: controller.selectedProvider.value,
      onSelected: controller.changeProvider,
    );
  }

  void _showHistory() {
    Get.toNamed('/widget-history');
  }

  IconData _getTypeIcon(WidgetType type) {
    switch (type) {
      case WidgetType.chart:
        return Icons.bar_chart;
      case WidgetType.table:
        return Icons.table_chart;
      case WidgetType.dashboard:
        return Icons.dashboard;
      case WidgetType.form:
        return Icons.edit_note;
      case WidgetType.custom:
        return Icons.widgets;
    }
  }

  String _getTypeName(WidgetType type) {
    switch (type) {
      case WidgetType.chart:
        return 'Chart';
      case WidgetType.table:
        return 'Table';
      case WidgetType.dashboard:
        return 'Dashboard';
      case WidgetType.form:
        return 'Form';
      case WidgetType.custom:
        return 'Custom';
    }
  }
}