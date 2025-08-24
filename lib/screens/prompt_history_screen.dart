import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';

class PromptHistoryScreen extends StatefulWidget {
  const PromptHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PromptHistoryScreen> createState() => _PromptHistoryScreenState();
}

class _PromptHistoryScreenState extends State<PromptHistoryScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  
  List<PromptHistoryItem> _promptHistory = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadPromptHistory();
  }
  
  Future<void> _loadPromptHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final history = await _apiService.getPromptHistory();
      
      setState(() {
        _promptHistory = history.map((item) => 
          PromptHistoryItem.fromJson(item)
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _deletePrompt(String promptId) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Prompt'),
        content: const Text('Are you sure you want to delete this prompt from history?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _apiService.deletePromptHistory(promptId);
      _loadPromptHistory();
      
      DynamicIslandService().updateStatus(
        'Prompt deleted',
        icon: CupertinoIcons.trash,
      );
    }
  }
  
  void _usePrompt(String prompt) {
    HapticFeedback.lightImpact();
    Get.back(result: prompt);
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.0),
        border: null,
        middle: const Text('Prompt History'),
        trailing: _promptHistory.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Clear All'),
                onPressed: () async {
                  final confirmed = await showCupertinoDialog<bool>(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Clear History'),
                      content: const Text('Are you sure you want to clear all prompt history?'),
                      actions: [
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          child: const Text('Clear'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed == true) {
                    await _apiService.clearPromptHistory();
                    setState(() => _promptHistory.clear());
                  }
                },
              )
            : null,
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _promptHistory.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.clock,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No prompt history',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your prompts will appear here',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryList() {
    // Group prompts by date
    final Map<String, List<PromptHistoryItem>> groupedHistory = {};
    
    for (var prompt in _promptHistory) {
      final dateKey = _getDateKey(prompt.createdAt);
      if (!groupedHistory.containsKey(dateKey)) {
        groupedHistory[dateKey] = [];
      }
      groupedHistory[dateKey]!.add(prompt);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: groupedHistory.length,
      itemBuilder: (context, index) {
        final dateKey = groupedHistory.keys.elementAt(index);
        final prompts = groupedHistory[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
            
            // Prompts for this date
            ...prompts.map((prompt) => _buildPromptTile(prompt)),
          ],
        );
      },
    );
  }
  
  Widget _buildPromptTile(PromptHistoryItem prompt) {
    return Dismissible(
      key: Key(prompt.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: CupertinoColors.systemRed,
        child: const Icon(
          CupertinoIcons.delete,
          color: CupertinoColors.white,
        ),
      ),
      onDismissed: (direction) => _deletePrompt(prompt.id),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _usePrompt(prompt.prompt),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.systemGrey5,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: prompt.success
                      ? CupertinoColors.systemGreen.withOpacity(0.1)
                      : CupertinoColors.systemRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  prompt.success
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.xmark_circle_fill,
                  size: 20,
                  color: prompt.success
                      ? CupertinoColors.systemGreen
                      : CupertinoColors.systemRed,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Prompt details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt.prompt,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (prompt.widgetId != null) ...[
                          Icon(
                            CupertinoIcons.cube_box,
                            size: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Widget created',
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          _getTimeString(prompt.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Use button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemIndigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Use',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemIndigo,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  String _getTimeString(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class PromptHistoryItem {
  final String id;
  final String prompt;
  final bool success;
  final String? widgetId;
  final DateTime createdAt;
  
  PromptHistoryItem({
    required this.id,
    required this.prompt,
    required this.success,
    this.widgetId,
    required this.createdAt,
  });
  
  factory PromptHistoryItem.fromJson(Map<String, dynamic> json) {
    return PromptHistoryItem(
      id: json['id'] ?? '',
      prompt: json['prompt'] ?? '',
      success: json['success'] ?? false,
      widgetId: json['widget_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}