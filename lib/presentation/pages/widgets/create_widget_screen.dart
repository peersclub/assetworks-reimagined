import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../data/models/widget_template.dart';
import '../../../data/models/widget_response_model.dart';
import '../../controllers/widget_controller.dart';
import '../../widgets/template_gallery.dart';
import '../../widgets/creative_loading_dialog.dart';
import '../../widgets/remix_info_card.dart';

class CreateWidgetScreen extends StatefulWidget {
  final String? initialQuery;
  
  const CreateWidgetScreen({Key? key, this.initialQuery}) : super(key: key);
  
  @override
  State<CreateWidgetScreen> createState() => _CreateWidgetScreenState();
}

class _CreateWidgetScreenState extends State<CreateWidgetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late WidgetController _controller;
  final _promptController = TextEditingController();
  final List<File> _attachments = [];
  WidgetTemplate? _selectedTemplate;
  Map<String, dynamic>? _remixData;
  String? _remixInstructions;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = Get.find<WidgetController>();
    
    // Handle arguments - could be string, map, or null
    final args = Get.arguments;
    if (args != null) {
      if (args is String) {
        _promptController.text = args;
      } else if (args is Map<String, dynamic>) {
        // Handle remix data
        if (args['type'] == 'remix') {
          _remixData = args;
          _remixInstructions = args['customInstructions'] ?? '';
          _promptController.text = args['initialPrompt'] ?? '';
          
          // Set the remix widget if not already set
          if (args['originalWidget'] != null && _controller.remixedWidget.value == null) {
            _controller.setRemixWidget(args['originalWidget'] as WidgetResponseModel);
          }
        } else if (args['sessionId'] != null) {
          // Handle session continuation
          // TODO: Load session data
        } else if (args['initialQuery'] != null) {
          _promptController.text = args['initialQuery'];
        }
      }
    } else if (widget.initialQuery != null) {
      _promptController.text = widget.initialQuery!;
    }
    
    // Check if we have a remix widget
    if (_controller.remixedWidget.value != null) {
      // Switch to prompt tab to show remix info
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tabController.animateTo(0);
      });
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _promptController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Widget'),
        actions: [
          IconButton(
            onPressed: _showHistory,
            icon: const Icon(LucideIcons.history, size: 22),
          ),
          IconButton(
            onPressed: _showHelp,
            icon: const Icon(LucideIcons.helpCircle, size: 22),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'AI Create', icon: Icon(LucideIcons.sparkles, size: 18)),
            Tab(text: 'Templates', icon: Icon(LucideIcons.layout, size: 18)),
            Tab(text: 'Editor', icon: Icon(LucideIcons.code2, size: 18)),
          ],
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAICreateTab(),
          _buildTemplatesTab(),
          _buildEditorTab(),
        ],
      ),
    );
  }
  
  Widget _buildAICreateTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Remix Info Card (if remixing)
          Obx(() {
            if (_controller.remixedWidget.value != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RemixInfoCard(
                    widget: _controller.remixedWidget.value!,
                    showInPromptArea: true,
                    onRemoveRemix: () {
                      _controller.clearRemixWidget();
                      setState(() {
                        _remixData = null;
                        _remixInstructions = null;
                      });
                    },
                    onViewOriginal: () {
                      final original = _controller.remixedWidget.value;
                      if (original != null) {
                        Get.toNamed('/widget-view', arguments: original);
                      }
                    },
                  ),
                  
                  // Show remix approach details if available
                  if (_remixData != null) ...[
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.gitBranch,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Remix Approach: ${_remixData!['approachTitle'] ?? 'Custom'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.neutral900 : AppColors.neutral50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _remixData!['approachDescription'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                                if (_remixInstructions != null && _remixInstructions!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Remix Instructions:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _remixInstructions!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Selected Template Card (if any)
          if (_selectedTemplate != null) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.layout,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Template: ${_selectedTemplate!.title}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          LucideIcons.x,
                          size: 18,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedTemplate = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.neutral900 : AppColors.neutral50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedTemplate!.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        if (_selectedTemplate!.prompt != null && _selectedTemplate!.prompt!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'Template Content:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedTemplate!.prompt!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // User Prompt Input Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.messageSquare,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getPromptLabel(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (_promptController.text.isNotEmpty)
                      TextButton.icon(
                        onPressed: _enhancePrompt,
                        icon: Icon(LucideIcons.sparkles, size: 16),
                        label: const Text('Enhance'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _promptController,
                  hint: _getPromptHint(),
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 12),
                
                // Attachment Section
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._attachments.map((file) => _buildAttachmentChip(file)),
                          _buildAddAttachmentButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          
          // Suggested Prompts
          Text(
            'Suggested Prompts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Stock price tracker with charts'),
              _buildSuggestionChip('Expense calculator with categories'),
              _buildSuggestionChip('Portfolio performance dashboard'),
              _buildSuggestionChip('Cryptocurrency price monitor'),
              _buildSuggestionChip('Budget planner with goals'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Preview',
                  icon: LucideIcons.eye,
                  type: AppButtonType.outline,
                  onPressed: _previewWidget,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => AppButton(
                  text: 'Generate Widget',
                  icon: LucideIcons.sparkles,
                  onPressed: _createWidget,
                  isLoading: _controller.isCreating.value,
                )),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildTemplatesTab() {
    return TemplateGallery(
      onTemplateSelected: (template) {
        setState(() {
          _selectedTemplate = template;
        });
        _tabController.animateTo(0); // Switch to Prompt tab
        Get.snackbar(
          'Template Selected',
          'Template loaded. Add your custom instructions below.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      },
    );
  }
  
  void _showTemplateOptions_old(WidgetTemplate template) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customPromptController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AnimatedPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.layout,
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            template.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Custom Prompt Field
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.messageSquare,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Custom Prompt (Optional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: customPromptController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add your own instructions or modifications to the template...',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This will be combined with the template prompt',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Options
                ListTile(
                  leading: Icon(LucideIcons.sparkles, color: AppColors.primary),
                  title: const Text('Generate Now'),
                  subtitle: const Text('Create widget with template and custom prompt'),
                  onTap: () async {
                    Navigator.pop(context);
                    // Combine template prompt with custom prompt
                    String finalPrompt = template.prompt ?? '';
                    if (customPromptController.text.trim().isNotEmpty) {
                      finalPrompt = '${template.prompt}\n\nAdditional requirements: ${customPromptController.text.trim()}';
                    }
                    // Generate widget
                    await _controller.generateWidget(
                      prompt: finalPrompt,
                    );
                    if (_controller.generatedWidget.value != null) {
                      Get.toNamed('/widget-view', arguments: _controller.generatedWidget.value);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(LucideIcons.edit3, color: AppColors.info),
                  title: const Text('Customize First'),
                  subtitle: const Text('Modify template parameters before generating'),
                  onTap: () {
                    Navigator.pop(context);
                    // Pass both template and custom prompt
                    Get.toNamed('/template-customize', arguments: {
                      'template': template,
                      'customPrompt': customPromptController.text.trim(),
                    });
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(LucideIcons.copy, color: AppColors.success),
                  title: const Text('Use as Starting Point'),
                  subtitle: const Text('Copy to prompt editor for further modification'),
                  onTap: () {
                    Navigator.pop(context);
                    // Combine prompts if custom prompt exists
                    String finalPrompt = template.prompt ?? '';
                    if (customPromptController.text.trim().isNotEmpty) {
                      finalPrompt = '${template.prompt}\n\n${customPromptController.text.trim()}';
                    }
                    _promptController.text = finalPrompt;
                    _tabController.animateTo(0);
                    Get.snackbar(
                      'Template Copied',
                      'You can now modify the prompt as needed',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEditorTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.code2,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Code Playground',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Write HTML, CSS, and JavaScript code with live preview',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Open Playground',
              icon: LucideIcons.play,
              onPressed: () => Get.toNamed('/code-playground'),
            ),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('Live preview as you type', LucideIcons.zap),
            _buildFeatureItem('Save as reusable templates', LucideIcons.save),
            _buildFeatureItem('Full-screen preview mode', LucideIcons.maximize2),
            _buildFeatureItem('Financial dashboard templates', LucideIcons.dollarSign),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAttachmentChip(File file) {
    return Chip(
      label: Text(
        file.path.split('/').last,
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(LucideIcons.x, size: 16),
      onDeleted: () {
        setState(() {
          _attachments.remove(file);
        });
      },
    );
  }
  
  Widget _buildAddAttachmentButton() {
    return ActionChip(
      label: const Text('Add File'),
      avatar: const Icon(LucideIcons.paperclip, size: 16),
      onPressed: _pickFiles,
    );
  }
  
  Widget _buildCategoryChip(String label, IconData icon) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      backgroundColor: AppColors.primary.withOpacity(0.1),
    );
  }
  
  
  Widget _buildSuggestionChip(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ActionChip(
      label: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      onPressed: () {
        _promptController.text = text;
      },
      backgroundColor: isDark ? AppColors.neutral800 : AppColors.neutral100,
      side: BorderSide(
        color: isDark ? AppColors.neutral700 : AppColors.neutral300,
      ),
    );
  }
  
  Future<void> _pickFiles() async {
    await AppBottomSheet.showOptions(
      title: 'Add Attachments',
      subtitle: 'Choose files to include with your widget',
      options: [
        BottomSheetOption(
          title: 'Images',
          subtitle: 'Photos and graphics',
          icon: LucideIcons.image,
          onTap: () async {
            // Pick images
          },
        ),
        BottomSheetOption(
          title: 'Data Files',
          subtitle: 'CSV, JSON, Excel',
          icon: LucideIcons.fileSpreadsheet,
          onTap: () async {
            // Pick data files
          },
        ),
        BottomSheetOption(
          title: 'Documents',
          subtitle: 'PDF, Word, Text',
          icon: LucideIcons.fileText,
          onTap: () async {
            // Pick documents
          },
        ),
      ],
    );
  }
  
  String _getPromptLabel() {
    if (_controller.remixedWidget.value != null) {
      if (_selectedTemplate != null) {
        return 'Your Custom Instructions';
      }
      return 'Remix Instructions';
    } else if (_selectedTemplate != null) {
      return 'Additional Instructions';
    }
    return 'Describe Your Widget';
  }
  
  String _getPromptHint() {
    if (_controller.remixedWidget.value != null) {
      if (_selectedTemplate != null) {
        return 'Combine remix and template with your custom requirements...';
      }
      return 'Describe how you want to remix this widget...';
    } else if (_selectedTemplate != null) {
      return 'Add your specific requirements or modifications...';
    }
    return 'E.g., Create a stock portfolio tracker with real-time prices...';
  }
  
  void _showHistory() {
    Get.toNamed('/widget-history');
  }
  
  void _showHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('Widget Creation Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How to create a widget:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Describe what you want in the prompt field'),
              Text('2. Add any relevant files or data'),
              Text('3. Choose the widget type'),
              Text('4. Configure advanced options if needed'),
              Text('5. Click Generate Widget to create'),
              SizedBox(height: 16),
              Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Be specific about data sources'),
              Text('• Include example data if available'),
              Text('• Use templates for quick start'),
              Text('• Preview before creating'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
  
  void _previewWidget() {
    if (_controller.generatedWidget.value != null) {
      // Preview existing generated widget
      Get.toNamed('/widget-view', arguments: _controller.generatedWidget.value);
    } else {
      Get.snackbar(
        'No Widget',
        'Generate a widget first to preview',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  void _enhancePrompt() async {
    // Enhance the user's prompt with AI suggestions
    final enhancedPrompt = await _controller.enhancePrompt(_promptController.text);
    if (enhancedPrompt != null) {
      setState(() {
        _promptController.text = enhancedPrompt;
      });
    }
  }
  
  Future<void> _createWidget() async {
    // Check if we have either a template, remix, or user prompt
    if (_selectedTemplate == null && 
        _controller.remixedWidget.value == null && 
        _promptController.text.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please select a template or enter a widget description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    
    // Show creative loading dialog
    CreativeLoadingDialog.show(
      context,
      title: 'Creating Widget',
      onNotify: () async {
        // Handle notification request
        Get.snackbar(
          'Background Processing',
          'Your widget is being created in the background',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.info,
          colorText: Colors.white,
        );
        
        // Navigate back to home
        Get.offAllNamed('/');
      },
    );
    
    try {
      // Build the final prompt combining all contexts
      String finalPrompt = '';
      List<String> promptParts = [];
      
      // 1. Add remix context if present
      if (_controller.remixedWidget.value != null && _remixData != null) {
        promptParts.add('REMIX CONTEXT:');
        promptParts.add('I want to remix the widget "${_controller.remixedWidget.value!.title}"');
        promptParts.add('Remix Approach: ${_remixData!['approachTitle']} - ${_remixData!['approachDescription']}');
        if (_remixInstructions != null && _remixInstructions!.isNotEmpty) {
          promptParts.add('Remix Instructions: $_remixInstructions');
        }
        promptParts.add('Original widget prompt: ${_controller.remixedWidget.value!.originalPrompt}');
        promptParts.add('');
      }
      
      // 2. Add template content if selected
      if (_selectedTemplate != null) {
        promptParts.add('TEMPLATE CONTEXT:');
        promptParts.add(_selectedTemplate!.prompt ?? '');
        promptParts.add('');
      }
      
      // 3. Add user's custom prompt
      if (_promptController.text.isNotEmpty) {
        if (_controller.remixedWidget.value != null || _selectedTemplate != null) {
          promptParts.add('USER INSTRUCTIONS:');
        }
        promptParts.add(_promptController.text);
      }
      
      // Combine all parts
      finalPrompt = promptParts.where((part) => part.isNotEmpty).join('\n');
      
      // Ensure we have some prompt
      if (finalPrompt.isEmpty) {
        Get.snackbar(
          'Missing Prompt',
          'Please describe what you want to create',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        CreativeLoadingDialog.hide();
        return;
      }
      
      // Generate widget using AI (remix or regular)
      if (_controller.remixedWidget.value != null) {
        await _controller.generateRemixedWidget(
          prompt: finalPrompt,
          attachments: _attachments,
        );
      } else {
        await _controller.generateWidget(
          prompt: finalPrompt,
          attachments: _attachments,
        );
      }
      
      // Close loading dialog
      CreativeLoadingDialog.hide();
      
      // Navigate to view the generated widget if successful
      if (_controller.generatedWidget.value != null) {
        // Use offNamed to replace current route, so back goes to home
        Get.offNamed('/widget-view', arguments: _controller.generatedWidget.value);
      }
    } catch (e) {
      // Close loading dialog on error
      CreativeLoadingDialog.hide();
      print('Error creating widget: $e');
    }
  }
}