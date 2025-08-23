import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/utils/storage_helper.dart';
import '../../controllers/widget_controller.dart';

class PromptHistoryScreen extends StatefulWidget {
  const PromptHistoryScreen({Key? key}) : super(key: key);
  
  @override
  State<PromptHistoryScreen> createState() => _PromptHistoryScreenState();
}

class _PromptHistoryScreenState extends State<PromptHistoryScreen> {
  late WidgetController _controller;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _controller = Get.find<WidgetController>();
    _controller.loadPromptHistory();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  List<Map<String, dynamic>> get filteredHistory {
    if (_searchQuery.isEmpty) {
      return _controller.promptHistory;
    }
    
    return _controller.promptHistory.where((item) {
      final prompt = (item['original_prompt'] ?? item['originalPrompt'] ?? '').toString().toLowerCase();
      final title = (item['title'] ?? '').toString().toLowerCase();
      return prompt.contains(_searchQuery.toLowerCase()) || 
             title.contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt History'),
        actions: [
          IconButton(
            onPressed: _clearHistory,
            icon: const Icon(LucideIcons.trash2, size: 22),
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                ),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search your prompts...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 20),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // History List
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final history = filteredHistory;
              
              if (history.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.history,
                        size: 64,
                        color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty 
                            ? 'No matching prompts found'
                            : 'No prompt history yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Your AI prompts will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _buildHistoryItem(item);
                },
              );
            }),
          ),
        ],
      ),
      
      // New Prompt FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _controller.startNewConversation();
          Get.toNamed('/create-widget');
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('New Prompt'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
  
  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final prompt = item['original_prompt'] ?? item['originalPrompt'] ?? 'No prompt';
    final title = item['title'] ?? 'Untitled';
    final tagline = item['tagline'] ?? '';
    final widgetId = item['widget_id'] ?? item['widgetId'];
    final sessionId = item['user_session_id'] ?? item['userSessionId'];
    final createdAt = item['created_at'] ?? item['createdAt'];
    final hasWidget = widgetId != null;
    final hasSession = sessionId != null;
    
    // Format date
    String formattedDate = '';
    if (createdAt != null) {
      try {
        if (createdAt is int) {
          final date = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
          formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);
        } else if (createdAt is String) {
          final date = DateTime.parse(createdAt);
          formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);
        }
      } catch (e) {
        formattedDate = 'Unknown date';
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => _openHistoryItem(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasSession)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.messageCircle,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            if (tagline.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                tagline,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const SizedBox(height: 8),
            
            // Original Prompt
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.neutral900 : AppColors.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.messageSquare,
                    size: 16,
                    color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prompt,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Footer
            Row(
              children: [
                // Date
                Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                  ),
                ),
                const Spacer(),
                
                // Actions
                if (hasWidget)
                  IconButton(
                    onPressed: () => _viewWidget(item),
                    icon: Icon(
                      LucideIcons.eye,
                      size: 18,
                      color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                    ),
                    tooltip: 'View Widget',
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                if (hasSession)
                  IconButton(
                    onPressed: () => _continueConversation(item),
                    icon: Icon(
                      LucideIcons.messageCircle,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Continue Conversation',
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                IconButton(
                  onPressed: () => _deleteHistoryItem(item),
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: AppColors.error,
                  ),
                  tooltip: 'Delete',
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _openHistoryItem(Map<String, dynamic> item) {
    final widgetId = item['widget_id'] ?? item['widgetId'];
    final sessionId = item['user_session_id'] ?? item['userSessionId'];
    
    if (widgetId != null) {
      _viewWidget(item);
    } else if (sessionId != null) {
      _continueConversation(item);
    }
  }
  
  void _viewWidget(Map<String, dynamic> item) {
    // Navigate to widget view
    // TODO: Load widget by ID from API
    Get.snackbar(
      'View Widget',
      'Loading widget...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void _continueConversation(Map<String, dynamic> item) {
    final sessionId = item['user_session_id'] ?? item['userSessionId'];
    final prompt = item['original_prompt'] ?? item['originalPrompt'] ?? '';
    
    if (sessionId != null) {
      _controller.currentSessionId.value = sessionId;
      Get.toNamed('/create-widget', arguments: {
        'sessionId': sessionId,
        'initialQuery': 'Continue: $prompt',
      });
    }
  }
  
  void _deleteHistoryItem(Map<String, dynamic> item) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Prompt'),
        content: const Text('Are you sure you want to delete this prompt from history?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Remove from history
              _controller.promptHistory.remove(item);
              setState(() {});
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  
  void _clearHistory() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all prompt history?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.promptHistory.clear();
              StorageHelper.remove('prompt_history');
            },
            child: Text(
              'Clear All',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}