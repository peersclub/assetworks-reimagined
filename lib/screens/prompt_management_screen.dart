import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/prompt_management_service.dart';
import '../data/models/prompt_model.dart';

class PromptManagementScreen extends StatefulWidget {
  const PromptManagementScreen({Key? key}) : super(key: key);

  @override
  State<PromptManagementScreen> createState() => _PromptManagementScreenState();
}

class _PromptManagementScreenState extends State<PromptManagementScreen> 
    with SingleTickerProviderStateMixin {
  final PromptManagementService _promptService = Get.put(PromptManagementService());
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Fetch backend prompts on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptService.fetchBackendPrompts();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Prompt Management'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.arrow_down_doc),
              onPressed: _importPrompts,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.arrow_up_doc),
              onPressed: _exportPrompts,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.add),
              onPressed: _showAddPromptDialog,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Tab Bar - Wrapped in Material widget for compatibility
            Container(
              color: CupertinoColors.systemBackground,
              child: Material(
                color: CupertinoColors.systemBackground,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: CupertinoColors.activeBlue,
                  labelColor: CupertinoColors.activeBlue,
                  unselectedLabelColor: CupertinoColors.systemGrey,
                  tabs: [
                    Tab(text: 'System Prompts'),
                    Tab(text: 'User Prompts'),
                  ],
                ),
              ),
            ),
            
            // Tab Views - Also wrapped in Material
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSystemPromptsTab(),
                    _buildUserPromptsTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSystemPromptsTab() {
    return Obx(() {
      if (_promptService.isLoading.value) {
        return Center(child: CupertinoActivityIndicator());
      }
      
      if (_promptService.systemPrompts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.doc_text,
                size: 64,
                color: CupertinoColors.systemGrey3,
              ),
              SizedBox(height: 16),
              Text(
                'No system prompts available',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              CupertinoButton(
                child: Text('Load Default Prompts'),
                onPressed: () => _promptService.loadDefaultPrompts(),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _promptService.systemPrompts.length,
        itemBuilder: (context, index) {
          final prompt = _promptService.systemPrompts[index];
          return _buildPromptCard(prompt);
        },
      );
    });
  }
  
  Widget _buildUserPromptsTab() {
    return Obx(() {
      if (_promptService.isLoading.value) {
        return Center(child: CupertinoActivityIndicator());
      }
      
      if (_promptService.userPrompts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.person_crop_circle,
                size: 64,
                color: CupertinoColors.systemGrey3,
              ),
              SizedBox(height: 16),
              Text(
                'No user prompts created',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              CupertinoButton(
                child: Text('Create User Prompt'),
                onPressed: () => _showAddPromptDialog(isUserPrompt: true),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _promptService.userPrompts.length,
        itemBuilder: (context, index) {
          final prompt = _promptService.userPrompts[index];
          return _buildPromptCard(prompt);
        },
      );
    });
  }
  
  Widget _buildPromptCard(PromptModel prompt) {
    final isSelected = prompt.type == PromptType.system
        ? _promptService.selectedSystemPrompt.value?.id == prompt.id
        : _promptService.selectedUserPrompt.value?.id == prompt.id;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(
          color: CupertinoColors.activeBlue,
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: prompt.isDefault 
                  ? CupertinoColors.systemGrey6 
                  : _getProviderColor(prompt.provider).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Provider Icon
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getProviderColor(prompt.provider),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getProviderIcon(prompt.provider),
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                
                // Name and metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            prompt.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (prompt.isDefault) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey4,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Provider: ${prompt.provider.toString().split('.').last.capitalize}',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions
                if (!prompt.isDefault) ...[
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      CupertinoIcons.pencil,
                      size: 20,
                      color: CupertinoColors.systemBlue,
                    ),
                    onPressed: () => _showEditPromptDialog(prompt),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      CupertinoIcons.trash,
                      size: 20,
                      color: CupertinoColors.systemRed,
                    ),
                    onPressed: () => _confirmDelete(prompt),
                  ),
                ],
                
                // Selection button
                CupertinoButton(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: isSelected 
                      ? CupertinoColors.activeGreen 
                      : CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(6),
                  child: Text(
                    isSelected ? 'Selected' : 'Select',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? CupertinoColors.white 
                          : CupertinoColors.label,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (prompt.type == PromptType.system) {
                      _promptService.selectedSystemPrompt.value = prompt;
                    } else {
                      _promptService.selectedUserPrompt.value = prompt;
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Content Preview
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content Preview:',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CupertinoColors.systemGrey5,
                      width: 1,
                    ),
                  ),
                  constraints: BoxConstraints(maxHeight: 100),
                  child: SingleChildScrollView(
                    child: Text(
                      prompt.content,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'SF Mono',
                        color: CupertinoColors.label,
                      ),
                    ),
                  ),
                ),
                
                // Metadata
                if (prompt.metadata != null) ...[
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: prompt.metadata!.entries.map((entry) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(fontSize: 11),
                      ),
                    )).toList(),
                  ),
                ],
                
                // Timestamps
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Created: ${_formatDate(prompt.createdAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: CupertinoColors.systemGrey2,
                      ),
                    ),
                    if (prompt.updatedAt != null)
                      Text(
                        'Updated: ${_formatDate(prompt.updatedAt!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: CupertinoColors.systemGrey2,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddPromptDialog({bool isUserPrompt = false}) {
    final nameController = TextEditingController();
    final contentController = TextEditingController();
    AIProvider selectedProvider = AIProvider.claude;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey5,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    isUserPrompt ? 'New User Prompt' : 'New System Prompt',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      if (nameController.text.isEmpty || contentController.text.isEmpty) {
                        _showError('Please fill in all fields');
                        return;
                      }
                      
                      final success = await _promptService.createPrompt(
                        name: nameController.text,
                        content: contentController.text,
                        type: isUserPrompt ? PromptType.user : PromptType.system,
                        provider: selectedProvider,
                      );
                      
                      if (success) {
                        Navigator.pop(context);
                        _showSuccess('Prompt created successfully');
                      } else {
                        _showError(_promptService.errorMessage.value);
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    Text(
                      'Prompt Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    SizedBox(height: 8),
                    CupertinoTextField(
                      controller: nameController,
                      placeholder: 'Enter prompt name',
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Provider selection
                    Text(
                      'AI Provider',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    SizedBox(height: 8),
                    CupertinoSegmentedControl<AIProvider>(
                      children: {
                        AIProvider.claude: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Claude'),
                        ),
                        AIProvider.openai: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('OpenAI'),
                        ),
                        AIProvider.gemini: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Gemini'),
                        ),
                        AIProvider.perplexity: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Perplexity'),
                        ),
                      },
                      onValueChanged: (value) {
                        selectedProvider = value;
                      },
                      groupValue: selectedProvider,
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Content field
                    Text(
                      'Prompt Content',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CupertinoTextField(
                        controller: contentController,
                        placeholder: isUserPrompt 
                            ? 'Enter your user prompt...' 
                            : 'Enter system instructions...\n\nFor system prompts, include:\n- Financial context\n- Widget generation instructions\n- Output format specifications',
                        padding: EdgeInsets.all(12),
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: null,
                        style: TextStyle(
                          fontFamily: 'SF Mono',
                          fontSize: 13,
                        ),
                      ),
                    ),
                    
                    // Tips
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: CupertinoColors.systemYellow.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            CupertinoIcons.lightbulb,
                            size: 16,
                            color: CupertinoColors.systemYellow,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isUserPrompt
                                  ? 'User prompts are combined with system prompts to generate widgets. Keep them focused on the specific widget requirements.'
                                  : 'System prompts define how the AI should generate widgets. Include instructions for HTML output format and financial context.',
                              style: TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.label,
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
          ],
        ),
      ),
    );
  }
  
  void _showEditPromptDialog(PromptModel prompt) {
    final nameController = TextEditingController(text: prompt.name);
    final contentController = TextEditingController(text: prompt.content);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey5,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Edit Prompt',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Update',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      final success = await _promptService.updatePrompt(
                        id: prompt.id,
                        name: nameController.text,
                        content: contentController.text,
                      );
                      
                      if (success) {
                        Navigator.pop(context);
                        _showSuccess('Prompt updated successfully');
                      } else {
                        _showError(_promptService.errorMessage.value);
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    Text(
                      'Prompt Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    SizedBox(height: 8),
                    CupertinoTextField(
                      controller: nameController,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Content field
                    Text(
                      'Prompt Content',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CupertinoTextField(
                        controller: contentController,
                        padding: EdgeInsets.all(12),
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: null,
                        style: TextStyle(
                          fontFamily: 'SF Mono',
                          fontSize: 13,
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
  
  void _confirmDelete(PromptModel prompt) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Delete Prompt'),
        content: Text('Are you sure you want to delete "${prompt.name}"? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Delete'),
            onPressed: () async {
              Navigator.pop(context);
              final success = await _promptService.deletePrompt(prompt.id);
              if (success) {
                _showSuccess('Prompt deleted successfully');
              } else {
                _showError(_promptService.errorMessage.value);
              }
            },
          ),
        ],
      ),
    );
  }
  
  void _importPrompts() {
    // TODO: Implement file picker and import
    _showError('Import feature coming soon');
  }
  
  void _exportPrompts() {
    final data = _promptService.exportPrompts();
    // TODO: Implement file save
    _showSuccess('Exported ${data['system_prompts'].length} system prompts and ${data['user_prompts'].length} user prompts');
  }
  
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: CupertinoColors.systemRed.withOpacity(0.9),
      colorText: CupertinoColors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
  }
  
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: CupertinoColors.activeGreen.withOpacity(0.9),
      colorText: CupertinoColors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
  }
  
  Color _getProviderColor(AIProvider provider) {
    switch (provider) {
      case AIProvider.claude:
        return Color(0xFF6B4C9A);
      case AIProvider.openai:
        return Color(0xFF10A37F);
      case AIProvider.gemini:
        return Color(0xFF4285F4);
      case AIProvider.perplexity:
        return Color(0xFF00D4FF);
    }
  }
  
  IconData _getProviderIcon(AIProvider provider) {
    switch (provider) {
      case AIProvider.claude:
        return CupertinoIcons.chat_bubble_2;
      case AIProvider.openai:
        return CupertinoIcons.sparkles;
      case AIProvider.gemini:
        return CupertinoIcons.star_circle;
      case AIProvider.perplexity:
        return CupertinoIcons.search_circle;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}