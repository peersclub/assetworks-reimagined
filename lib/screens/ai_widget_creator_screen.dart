import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator, AlwaysStoppedAnimation, Colors;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';
import '../models/dashboard_widget.dart';
import '../screens/widget_preview_screen.dart';

class AIWidgetCreatorScreen extends StatefulWidget {
  final DashboardWidget? remixWidget;
  final String? initialPrompt;
  
  const AIWidgetCreatorScreen({
    Key? key,
    this.remixWidget,
    this.initialPrompt,
  }) : super(key: key);

  @override
  State<AIWidgetCreatorScreen> createState() => _AIWidgetCreatorScreenState();
}

class _AIWidgetCreatorScreenState extends State<AIWidgetCreatorScreen> 
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Chat State
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isGenerating = false;
  String _currentContext = 'creator';
  
  // Widget Creation State
  Map<String, dynamic>? _generatedWidget;
  String? _widgetTitle;
  String? _widgetDescription;
  String? _widgetCategory;
  Map<String, dynamic>? _widgetData;
  
  // Remix State
  bool _isRemixMode = false;
  Map<String, dynamic>? _remixData;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    // Initialize with remix or initial prompt
    if (widget.remixWidget != null) {
      _initializeRemix();
    } else if (widget.initialPrompt != null) {
      _sendMessage(widget.initialPrompt!);
    } else {
      _addWelcomeMessage();
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _initializeRemix() {
    _isRemixMode = true;
    _remixData = {
      'original_id': widget.remixWidget!.id,
      'original_title': widget.remixWidget!.title,
      'original_type': widget.remixWidget!.metadata?['type'] ?? 'custom',
    };
    
    _messages.add(ChatMessage(
      text: 'I see you want to remix "${widget.remixWidget!.title}". Let\'s enhance it together! What modifications would you like to make?',
      isUser: false,
      timestamp: DateTime.now(),
      type: 'remix_start',
    ));
    
    // Add remix options
    _messages.add(ChatMessage(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      type: 'remix_options',
      options: [
        'Change visualization style',
        'Add more data points',
        'Modify color scheme',
        'Update refresh interval',
        'Add AI insights',
        'Combine with another widget',
      ],
    ));
  }
  
  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: 'Hi! I\'m your AI Widget Creator. I can help you build custom widgets for your investment dashboard. What would you like to create today?',
      isUser: false,
      timestamp: DateTime.now(),
      type: 'welcome',
    ));
    
    // Add quick action suggestions
    _messages.add(ChatMessage(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      type: 'suggestions',
      suggestions: [
        'Stock portfolio tracker',
        'Crypto dashboard',
        'Budget analyzer',
        'Market sentiment gauge',
        'Options chain viewer',
        'Economic calendar',
      ],
    ));
  }
  
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    
    _messageController.clear();
    _scrollToBottom();
    
    try {
      // Determine action type
      final action = _determineAction(text);
      
      if (action == 'create_widget') {
        await _createWidget(text);
      } else if (action == 'remix_widget') {
        await _remixWidget(text);
      } else if (action == 'modify_widget') {
        await _modifyWidget(text);
      } else {
        await _processAIResponse(text);
      }
    } catch (e) {
      print('Error sending message: $e');
      _addErrorMessage();
    } finally {
      setState(() => _isTyping = false);
    }
  }
  
  String _determineAction(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('create') || lowerText.contains('build') || 
        lowerText.contains('make') || lowerText.contains('generate')) {
      return 'create_widget';
    }
    
    if (_isRemixMode || lowerText.contains('remix') || lowerText.contains('modify')) {
      return 'remix_widget';
    }
    
    if (_generatedWidget != null && (lowerText.contains('change') || 
        lowerText.contains('update') || lowerText.contains('edit'))) {
      return 'modify_widget';
    }
    
    return 'chat';
  }
  
  Future<void> _createWidget(String prompt) async {
    setState(() => _isGenerating = true);
    
    // Start Live Activity
    DynamicIslandService().startWidgetCreation(
      prompt: prompt,
      widgetType: _currentContext,
    );
    
    try {
      // Stage 1: Analyzing
      DynamicIslandService().updateWidgetCreationProgress(
        stage: 'analyzing',
        progress: 0.2,
        detail: 'Understanding your requirements',
      );
      
      await Future.delayed(Duration(milliseconds: 500)); // Simulate processing
      
      // Stage 2: Generating
      DynamicIslandService().updateWidgetCreationProgress(
        stage: 'generating',
        progress: 0.5,
        detail: 'Creating widget structure',
      );
      
      // Call real API to generate widget
      final response = await _apiService.generateWidget({
        'prompt': prompt,
        'context': _currentContext,
        'user_preferences': await _getUserPreferences(),
      });
      
      // Stage 3: Optimizing
      DynamicIslandService().updateWidgetCreationProgress(
        stage: 'optimizing',
        progress: 0.7,
        detail: 'Enhancing design',
      );
      
      await Future.delayed(Duration(milliseconds: 300));
      
      if (response['success'] == true) {
        // Stage 4: Finalizing
        DynamicIslandService().updateWidgetCreationProgress(
          stage: 'finalizing',
          progress: 0.9,
          detail: 'Adding final touches',
        );
        
        await Future.delayed(Duration(milliseconds: 200));
        
        _generatedWidget = response['widget'];
        _widgetTitle = response['widget']['title'];
        _widgetDescription = response['widget']['description'];
        _widgetCategory = response['widget']['category'];
        _widgetData = response['widget']['data'];
        
        // Stage 5: Complete
        DynamicIslandService().completeWidgetCreation(
          widgetTitle: _widgetTitle ?? 'Custom Widget',
          success: true,
        );
        
        // Add success message with preview
        setState(() {
          _messages.add(ChatMessage(
            text: 'Great! I\'ve created your widget. Here\'s a preview:',
            isUser: false,
            timestamp: DateTime.now(),
            type: 'widget_preview',
            widgetData: _generatedWidget,
          ));
          
          // Add action buttons
          _messages.add(ChatMessage(
            text: '',
            isUser: false,
            timestamp: DateTime.now(),
            type: 'widget_actions',
            actions: [
              {'label': 'Save Widget', 'action': 'save'},
              {'label': 'Modify', 'action': 'modify'},
              {'label': 'Preview Full', 'action': 'preview'},
              {'label': 'Start Over', 'action': 'restart'},
            ],
          ));
        });
      } else {
        // Failed
        DynamicIslandService().completeWidgetCreation(
          widgetTitle: 'Widget',
          success: false,
          errorMessage: 'Failed to generate widget',
        );
        
        _addErrorMessage('Failed to generate widget. Please try again.');
      }
    } catch (e) {
      print('Widget generation error: $e');
      _addErrorMessage();
    } finally {
      setState(() => _isGenerating = false);
    }
  }
  
  Future<void> _remixWidget(String modifications) async {
    setState(() => _isGenerating = true);
    
    // Start remix Live Activity
    DynamicIslandService().startWidgetRemix(
      originalTitle: _remixData?['original_title'] ?? 'Widget',
      modifications: modifications,
    );
    
    try {
      // Update progress
      DynamicIslandService().updateWidgetCreationProgress(
        stage: 'analyzing',
        progress: 0.3,
        detail: 'Analyzing modifications',
      );
      
      await Future.delayed(Duration(milliseconds: 300));
      
      DynamicIslandService().updateWidgetCreationProgress(
        stage: 'generating',
        progress: 0.6,
        detail: 'Applying changes',
      );
      
      // Call remix API
      final response = await _apiService.remixWidget({
        'original_widget_id': _remixData?['original_id'],
        'modifications': modifications,
        'preserve_data': true,
      });
      
      if (response['success'] == true) {
        // Finalizing
        DynamicIslandService().updateWidgetCreationProgress(
          stage: 'finalizing',
          progress: 0.9,
          detail: 'Completing remix',
        );
        
        await Future.delayed(Duration(milliseconds: 200));
        
        _generatedWidget = response['widget'];
        
        // Complete
        DynamicIslandService().completeWidgetCreation(
          widgetTitle: _generatedWidget?['title'] ?? 'Remixed Widget',
          success: true,
        );
        
        setState(() {
          _messages.add(ChatMessage(
            text: 'Perfect! I\'ve remixed your widget with the requested changes:',
            isUser: false,
            timestamp: DateTime.now(),
            type: 'widget_preview',
            widgetData: _generatedWidget,
          ));
        });
      } else {
        // Failed
        DynamicIslandService().completeWidgetCreation(
          widgetTitle: 'Remix',
          success: false,
          errorMessage: 'Failed to remix widget',
        );
        
        _addErrorMessage('Failed to remix widget. Please try again.');
      }
    } catch (e) {
      print('Remix error: $e');
      _addErrorMessage();
    } finally {
      setState(() => _isGenerating = false);
    }
  }
  
  Future<void> _modifyWidget(String modifications) async {
    if (_generatedWidget == null) return;
    
    setState(() => _isGenerating = true);
    
    try {
      // Call modify API
      final response = await _apiService.modifyWidget({
        'widget': _generatedWidget,
        'modifications': modifications,
      });
      
      if (response['success'] == true) {
        _generatedWidget = response['widget'];
        
        setState(() {
          _messages.add(ChatMessage(
            text: 'I\'ve updated your widget with the requested changes:',
            isUser: false,
            timestamp: DateTime.now(),
            type: 'widget_preview',
            widgetData: _generatedWidget,
          ));
        });
      }
    } catch (e) {
      print('Modify error: $e');
      _addErrorMessage();
    } finally {
      setState(() => _isGenerating = false);
    }
  }
  
  Future<void> _processAIResponse(String message) async {
    try {
      // Get AI response for general chat
      final response = await _apiService.sendAIMessage(
        message,
        context: 'widget_creation',
      );
      
      if (response != null) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      print('AI response error: $e');
      _addErrorMessage();
    }
  }
  
  Future<void> _saveWidget() async {
    if (_generatedWidget == null) return;
    
    HapticFeedback.mediumImpact();
    setState(() => _isGenerating = true);
    
    try {
      // The widget is already created and saved through generateWidget
      // Just mark as successful
      final response = {'success': true, 'widget_id': _generatedWidget!['id'] ?? '0'};
      
      if (response['success'] == true) {
        DynamicIslandService().updateStatus(
          'Widget saved successfully!',
          icon: CupertinoIcons.checkmark_circle_fill,
        );
        
        // Navigate to preview
        final widget = DashboardWidget(
          id: response['widget_id'] ?? '0',
          title: _widgetTitle ?? 'Custom Widget',
          description: _widgetDescription ?? '',
          summary: _generatedWidget!['summary'] ?? '',
          original_prompt: _generatedWidget!['original_prompt'] ?? _messageController.text,
          preview_version_url: _generatedWidget!['preview_url'],
          full_version_url: _generatedWidget!['full_url'],
          code_url: _generatedWidget!['code_url'],
          created_at: DateTime.now(),
          metadata: {
            'type': _generatedWidget!['type'] ?? 'custom',
            'category': _widgetCategory ?? 'custom',
            'html_content': _generatedWidget!['html_content'] ?? '',
          },
        );
        
        Get.to(() => const WidgetPreviewScreen(), arguments: widget);
      } else {
        _addErrorMessage('Failed to save widget');
      }
    } catch (e) {
      print('Save widget error: $e');
      _addErrorMessage();
    } finally {
      setState(() => _isGenerating = false);
    }
  }
  
  Future<Map<String, dynamic>> _getUserPreferences() async {
    // Get user preferences from storage or API
    return {
      'theme': 'dark',
      'preferred_charts': ['line', 'bar', 'pie'],
      'data_refresh': 60, // seconds
      'animation': true,
    };
  }
  
  void _handleAction(String action) {
    switch (action) {
      case 'save':
        _saveWidget();
        break;
      case 'modify':
        _focusNode.requestFocus();
        break;
      case 'preview':
        if (_generatedWidget != null) {
          _showFullPreview();
        }
        break;
      case 'restart':
        setState(() {
          _messages.clear();
          _generatedWidget = null;
          _isRemixMode = false;
          _addWelcomeMessage();
        });
        break;
    }
  }
  
  void _showFullPreview() {
    if (_generatedWidget == null) return;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _widgetTitle ?? 'Widget Preview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(CupertinoIcons.xmark_circle_fill),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Widget HTML Preview\n\n${_generatedWidget!['html_content'] ?? ''}',
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _addErrorMessage([String? customMessage]) {
    setState(() {
      _messages.add(ChatMessage(
        text: customMessage ?? 'Sorry, something went wrong. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        type: 'error',
      ));
    });
  }
  
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground.withOpacity(0.94),
        border: null,
        middle: Text(_isRemixMode ? 'Remix Widget' : 'AI Widget Creator'),
        trailing: _generatedWidget != null
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: _isGenerating ? null : _saveWidget,
              )
            : null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Live Activity Progress Bar
            if (_isGenerating)
              StreamBuilder<double>(
                stream: DynamicIslandService().progressStream,
                builder: (context, snapshot) {
                  final progress = snapshot.data ?? 0.0;
                  return Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Progress Bar
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                CupertinoColors.activeBlue,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        // Status Text
                        StreamBuilder<DynamicIslandStatus>(
                          stream: DynamicIslandService().statusStream,
                          builder: (context, snapshot) {
                            final status = snapshot.data;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (status != null) ...[
                                  Icon(
                                    status.icon,
                                    size: 16,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  SizedBox(width: 6),
                                ],
                                Text(
                                  status?.message ?? 'Processing...',
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            
            // Chat Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessage(message);
                },
              ),
            ),
            
            // Typing Indicator
            if (_isTyping)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTypingDot(0),
                      SizedBox(width: 4),
                      _buildTypingDot(1),
                      SizedBox(width: 4),
                      _buildTypingDot(2),
                    ],
                  ),
                ),
              ),
            
            // Input Field
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey5,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      placeholder: _isRemixMode 
                          ? 'Describe your modifications...'
                          : 'Describe your widget idea...',
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.arrow_up,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () => _sendMessage(_messageController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMessage(ChatMessage message) {
    if (message.type == 'suggestions') {
      return _buildSuggestions(message.suggestions ?? []);
    }
    
    if (message.type == 'remix_options') {
      return _buildRemixOptions(message.options ?? []);
    }
    
    if (message.type == 'widget_preview') {
      return _buildWidgetPreview(message.widgetData!);
    }
    
    if (message.type == 'widget_actions') {
      return _buildActionButtons(message.actions ?? []);
    }
    
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemIndigo,
                    CupertinoColors.systemPurple,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.sparkles,
                color: CupertinoColors.white,
                size: 18,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? CupertinoColors.activeBlue
                    : message.type == 'error'
                        ? CupertinoColors.systemRed.withOpacity(0.1)
                        : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser 
                      ? CupertinoColors.white
                      : message.type == 'error'
                          ? CupertinoColors.systemRed
                          : CupertinoColors.label,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.person_fill,
                color: CupertinoColors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSuggestions(List<String> suggestions) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions.map((suggestion) {
          return GestureDetector(
            onTap: () => _sendMessage('Create a $suggestion'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemIndigo.withOpacity(0.1),
                    CupertinoColors.systemPurple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: CupertinoColors.systemIndigo.withOpacity(0.3),
                ),
              ),
              child: Text(
                suggestion,
                style: TextStyle(
                  color: CupertinoColors.systemIndigo,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildRemixOptions(List<String> options) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.map((option) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _sendMessage(option),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.arrow_right_circle,
                      color: CupertinoColors.systemIndigo,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      option,
                      style: TextStyle(
                        color: CupertinoColors.label,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildWidgetPreview(Map<String, dynamic> widgetData) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemIndigo,
                    CupertinoColors.systemPurple,
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.cube_box_fill,
                    color: CupertinoColors.white,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widgetData['title'] ?? 'Custom Widget',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widgetData['description'] != null)
                          Text(
                            widgetData['description'],
                            style: TextStyle(
                              color: CupertinoColors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.chart_bar_alt_fill,
                      size: 48,
                      color: CupertinoColors.systemGrey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Widget Preview',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widgetData['type'] ?? 'Custom',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey2,
                        fontSize: 14,
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
  
  Widget _buildActionButtons(List<Map<String, String>> actions) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((action) {
          final isPrimary = action['action'] == 'save';
          return CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: isPrimary ? CupertinoColors.activeBlue : null,
            borderRadius: BorderRadius.circular(20),
            onPressed: () => _handleAction(action['action']!),
            child: Text(
              action['label']!,
              style: TextStyle(
                color: isPrimary 
                    ? CupertinoColors.white 
                    : CupertinoColors.activeBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey.withOpacity(
              0.3 + (0.7 * value),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String type;
  final List<String>? suggestions;
  final List<String>? options;
  final Map<String, dynamic>? widgetData;
  final List<Map<String, String>>? actions;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = 'text',
    this.suggestions,
    this.options,
    this.widgetData,
    this.actions,
  });
}