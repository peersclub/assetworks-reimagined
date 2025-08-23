import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../controllers/widget_controller.dart';
import '../../widgets/template_gallery.dart';
import '../../../data/models/widget_template.dart';
import '../../widgets/creative_loading_dialog.dart';

class AnalyseScreen extends StatefulWidget {
  const AnalyseScreen({Key? key}) : super(key: key);
  
  @override
  State<AnalyseScreen> createState() => _AnalyseScreenState();
}

class _AnalyseScreenState extends State<AnalyseScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _promptController = TextEditingController();
  final List<File> _attachments = [];
  late WidgetController _controller;
  WidgetTemplate? _selectedTemplate;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = Get.find<WidgetController>();
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
        title: Row(
          children: [
            SizedBox(
              width: 140,
              height: 32,
              child: SvgPicture.asset(
                'assets/assetworks_logo_full_black.svg',
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : AppColors.primary,
                  BlendMode.srcIn,
                ),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
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
            Tab(text: 'Prompt'),
            Tab(text: 'Templates'),
            Tab(text: 'Editor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPromptTab(),
          _buildTemplatesTab(),
          _buildEditorTab(),
        ],
      ),
    );
  }
  
  Widget _buildPromptTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Selected Template Card (if any)
                if (_selectedTemplate != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 20),
                ],
                
                // User Prompt Field with Enhance Button
                Container(
                  padding: const EdgeInsets.all(16),
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
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTemplate != null ? 'Additional Instructions' : 'Describe Your Analysis',
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
                        hint: _selectedTemplate != null 
                          ? 'Add your specific requirements or modifications...'
                          : 'What would you like to analyze or create?',
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Quick Actions Row
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Attachments',
                        icon: LucideIcons.paperclip,
                        type: AppButtonType.outline,
                        size: AppButtonSize.small,
                        onPressed: _pickFiles,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'History',
                        icon: LucideIcons.history,
                        type: AppButtonType.outline,
                        size: AppButtonSize.small,
                        onPressed: _showHistory,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Show attached files
                if (_attachments.isNotEmpty) ...[
                  Text(
                    'Attached Files (${_attachments.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_attachments.length, (index) {
                    final file = _attachments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.neutral800 : AppColors.neutral100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.file,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              file.path.split('/').last,
                              style: TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              setState(() {
                                _attachments.removeAt(index);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
                
                // Suggested Prompts
                Text(
                  'Suggested Prompts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSuggestionChip('Stock market analysis for tech sector'),
                    _buildSuggestionChip('Portfolio optimization dashboard'),
                    _buildSuggestionChip('Risk assessment calculator'),
                    _buildSuggestionChip('Financial statement analyzer'),
                    _buildSuggestionChip('Crypto market tracker'),
                    _buildSuggestionChip('Investment ROI calculator'),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Feature Categories
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildCategoryChip('Finance', LucideIcons.dollarSign),
                    _buildCategoryChip('Analytics', LucideIcons.barChart3),
                    _buildCategoryChip('Trading', LucideIcons.trendingUp),
                    _buildCategoryChip('Portfolio', LucideIcons.pieChart),
                    _buildCategoryChip('Risk', LucideIcons.shieldAlert),
                    _buildCategoryChip('Crypto', LucideIcons.bitcoin),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(() => AppButton(
                  text: 'Generate Analysis',
                  icon: LucideIcons.sparkles,
                  onPressed: _createWidget,
                  isLoading: _controller.isLoading.value,
                  isFullWidth: true,
                  size: AppButtonSize.large,
                )),
              ),
              const SizedBox(width: 12),
              AppButton(
                text: '',
                icon: LucideIcons.eye,
                onPressed: _previewWidget,
                type: AppButtonType.outline,
                size: AppButtonSize.large,
              ),
            ],
          ),
        ),
      ],
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
                  subtitle: const Text('Create analysis with template and custom prompt'),
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
              onPressed: () {
                Get.toNamed('/code-playground');
              },
              size: AppButtonSize.large,
            ),
          ],
        ),
      ),
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
      subtitle: 'Choose files to include with your analysis',
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
  
  void _showHistory() {
    Get.toNamed('/widget-history');
  }
  
  void _showHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('Analysis Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How to create an analysis:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Describe what you want to analyze in the prompt field'),
              Text('2. Add any relevant files or data'),
              Text('3. Choose from templates for quick start'),
              Text('4. Use the code editor for custom visualizations'),
              Text('5. Click Generate Analysis to create'),
              SizedBox(height: 16),
              Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Be specific about data sources'),
              Text('• Include example data if available'),
              Text('• Use templates for common analyses'),
              Text('• Preview before generating'),
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
        'No Analysis',
        'Generate an analysis first to preview',
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
    // Check if we have either a template or user prompt
    if (_selectedTemplate == null && _promptController.text.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please select a template or enter an analysis description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    
    // Show creative loading dialog
    CreativeLoadingDialog.show(
      context,
      title: 'Generating Analysis',
      onNotify: () async {
        // Handle notification request
        Get.snackbar(
          'Background Processing',
          'Your analysis is being generated in the background',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.info,
          colorText: Colors.white,
        );
        
        // Navigate back to home
        Get.offAllNamed('/');
      },
    );
    
    try {
      // Build the final prompt
      String finalPrompt = '';
      
      if (_selectedTemplate != null) {
        // Start with template prompt
        finalPrompt = _selectedTemplate!.prompt ?? '';
        
        // Add user's additional instructions if provided
        if (_promptController.text.isNotEmpty) {
          finalPrompt = '$finalPrompt\n\nAdditional requirements:\n${_promptController.text}';
        }
      } else {
        // Use only user's prompt
        finalPrompt = _promptController.text;
      }
      
      // Generate widget using AI
      await _controller.generateWidget(
        prompt: finalPrompt,
        attachments: _attachments,
      );
      
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
      print('Error generating analysis: $e');
    }
  }
}