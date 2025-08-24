import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/dashboard_widget.dart';
import '../widgets/widget_card_final.dart';
import '../screens/widget_preview_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> 
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final ScrollController _scrollController = ScrollController();
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Data
  Map<String, List<HistoryItem>> _groupedHistory = {};
  List<HistoryItem> _allHistory = [];
  Map<String, dynamic> _statistics = {};
  
  // State
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedTimeRange = 'week';
  
  // Filters
  final Map<String, String> _filters = {
    'all': 'All Activity',
    'viewed': 'Viewed',
    'liked': 'Liked',
    'shared': 'Shared',
    'created': 'Created',
    'remixed': 'Remixed',
    'downloaded': 'Downloaded',
  };
  
  final Map<String, String> _timeRanges = {
    'today': 'Today',
    'week': 'This Week',
    'month': 'This Month',
    'year': 'This Year',
    'all_time': 'All Time',
  };
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadHistory();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      // Fetch real user activity from API
      final activityData = await _apiService.fetchUserActivity(
        page: 1,
        limit: 50,
        filter: _selectedFilter != 'all' ? _selectedFilter : null,
      );
      
      // If we have real activity data, use it
      final history = <HistoryItem>[];
      
      if (activityData.isNotEmpty) {
        // Process real activity data
        for (final activity in activityData) {
          // Fetch widget details if needed
          final widgetId = activity['widget_id'] ?? activity['widgetId'];
          final widgetData = activity['widget'] ?? {};
          
          final widget = DashboardWidget(
            id: widgetId ?? 'unknown',
            title: widgetData['title'] ?? activity['widget_title'] ?? 'Widget',
            description: widgetData['description'] ?? '',
            username: widgetData['username'] ?? activity['username'],
            user_id: widgetData['user_id'] ?? activity['user_id'],
            likes_count: widgetData['likes_count'] ?? 0,
            views_count: widgetData['views_count'] ?? 0,
          );
          
          history.add(HistoryItem(
            id: activity['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            widget: widget,
            action: activity['action'] ?? 'viewed',
            timestamp: activity['timestamp'] != null
                ? DateTime.parse(activity['timestamp'])
                : DateTime.now(),
            details: _getActionDetails(activity['action'] ?? 'viewed', widget),
          ));
        }
      } else {
        // Fallback: Use real widgets to show sample history
        final widgets = await _apiService.fetchDashboardWidgets(
          page: 1,
          limit: 20,
        );
        
        // Create sample history from real widgets
        final now = DateTime.now();
        for (int i = 0; i < widgets.length && i < 10; i++) {
          final widget = widgets[i];
          final actions = ['viewed', 'liked', 'shared', 'remixed'];
          final action = actions[i % actions.length];
          
          history.add(HistoryItem(
            id: 'sample_${widget.id}_$i',
            widget: widget,
            action: action,
            timestamp: now.subtract(Duration(hours: i * 2)),
            details: _getActionDetails(action, widget),
          ));
        }
      }
      
      // Group history by date
      _groupHistory(history);
      
      // Calculate statistics
      _calculateStatistics(history);
      
      setState(() {
        _allHistory = history;
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      print('Error loading history: $e');
      setState(() => _isLoading = false);
    }
  }
  
  void _groupHistory(List<HistoryItem> history) {
    _groupedHistory.clear();
    
    for (final item in history) {
      final dateKey = _getDateKey(item.timestamp);
      if (!_groupedHistory.containsKey(dateKey)) {
        _groupedHistory[dateKey] = [];
      }
      _groupedHistory[dateKey]!.add(item);
    }
  }
  
  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);
    
    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday';
    } else if (itemDate.isAfter(today.subtract(Duration(days: 7)))) {
      return DateFormat('EEEE').format(date); // Day name
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
  
  void _calculateStatistics(List<HistoryItem> history) {
    final stats = <String, int>{};
    
    for (final item in history) {
      stats[item.action] = (stats[item.action] ?? 0) + 1;
    }
    
    // Calculate insights
    final totalActions = history.length;
    final uniqueWidgets = history.map((h) => h.widget.id).toSet().length;
    final mostActiveDay = _getMostActiveDay(history);
    final favoriteCategory = _getFavoriteCategory(history);
    
    _statistics = {
      'total_actions': totalActions,
      'unique_widgets': uniqueWidgets,
      'most_active_day': mostActiveDay,
      'favorite_category': favoriteCategory,
      'action_breakdown': stats,
    };
  }
  
  String _getMostActiveDay(List<HistoryItem> history) {
    final dayCounts = <String, int>{};
    
    for (final item in history) {
      final day = DateFormat('EEEE').format(item.timestamp);
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    
    if (dayCounts.isEmpty) return 'N/A';
    
    return dayCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  String _getFavoriteCategory(List<HistoryItem> history) {
    final categoryCounts = <String, int>{};
    
    for (final item in history) {
      final category = 'Investment'; // Default category for now
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
    
    if (categoryCounts.isEmpty) return 'N/A';
    
    return categoryCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  Map<String, dynamic> _getActionDetails(String action, DashboardWidget widget) {
    switch (action) {
      case 'viewed':
        return {
          'icon': CupertinoIcons.eye_fill,
          'color': CupertinoColors.systemBlue,
          'description': 'Viewed widget',
        };
      case 'liked':
        return {
          'icon': CupertinoIcons.heart_fill,
          'color': CupertinoColors.systemRed,
          'description': 'Liked widget',
        };
      case 'shared':
        return {
          'icon': CupertinoIcons.share_solid,
          'color': CupertinoColors.systemGreen,
          'description': 'Shared widget',
        };
      case 'remixed':
        return {
          'icon': CupertinoIcons.shuffle,
          'color': CupertinoColors.systemPurple,
          'description': 'Remixed widget',
        };
      case 'created':
        return {
          'icon': CupertinoIcons.plus_circle_fill,
          'color': CupertinoColors.systemOrange,
          'description': 'Created widget',
        };
      case 'downloaded':
        return {
          'icon': CupertinoIcons.cloud_download_fill,
          'color': CupertinoColors.systemIndigo,
          'description': 'Downloaded widget',
        };
      default:
        return {
          'icon': CupertinoIcons.circle_fill,
          'color': CupertinoColors.systemGrey,
          'description': 'Activity',
        };
    }
  }
  
  List<HistoryItem> _getFilteredHistory() {
    if (_selectedFilter == 'all') {
      return _allHistory;
    }
    
    return _allHistory.where((item) => item.action == _selectedFilter).toList();
  }
  
  void _clearHistory() {
    HapticFeedback.heavyImpact();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Clear History'),
        content: Text('Are you sure you want to clear your entire history? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Clear'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allHistory.clear();
                _groupedHistory.clear();
              });
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final filteredHistory = _getFilteredHistory();
    final groupedFiltered = <String, List<HistoryItem>>{};
    
    // Re-group filtered history
    for (final item in filteredHistory) {
      final dateKey = _getDateKey(item.timestamp);
      if (!groupedFiltered.containsKey(dateKey)) {
        groupedFiltered[dateKey] = [];
      }
      groupedFiltered[dateKey]!.add(item);
    }
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground.withOpacity(0.94),
        border: null,
        middle: Text('History'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.trash),
          onPressed: _allHistory.isEmpty ? null : _clearHistory,
        ),
      ),
      child: _isLoading
          ? Center(child: CupertinoActivityIndicator())
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Statistics Card
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildStatisticsCard(),
                  ),
                ),
                
                // Filter Pills
                SliverToBoxAdapter(
                  child: Container(
                    height: 44,
                    margin: EdgeInsets.symmetric(vertical: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final key = _filters.keys.elementAt(index);
                        final isSelected = _selectedFilter == key;
                        
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: CupertinoButton(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            color: isSelected
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(22),
                            onPressed: () {
                              setState(() => _selectedFilter = key);
                            },
                            child: Text(
                              _filters[key]!,
                              style: TextStyle(
                                color: isSelected
                                    ? CupertinoColors.white
                                    : CupertinoColors.label,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // History Items
                if (filteredHistory.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.clock,
                            size: 64,
                            color: CupertinoColors.systemGrey3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No history yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your activity will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...groupedFiltered.entries.map((entry) {
                    return [
                      SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = entry.value[index];
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: _buildHistoryItem(item),
                              );
                            },
                            childCount: entry.value.length,
                          ),
                        ),
                      ),
                    ];
                  }).expand((x) => x).toList(),
                
                // Bottom padding
                SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
    );
  }
  
  Widget _buildStatisticsCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Activity',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _timeRanges[_selectedTimeRange]!,
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '${_statistics['total_actions'] ?? 0}',
                  'Total Actions',
                  CupertinoIcons.bolt_fill,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  '${_statistics['unique_widgets'] ?? 0}',
                  'Widgets',
                  CupertinoIcons.square_stack_3d_up_fill,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  _statistics['most_active_day'] ?? 'N/A',
                  'Most Active',
                  CupertinoIcons.calendar,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  _statistics['favorite_category'] ?? 'N/A',
                  'Favorite',
                  CupertinoIcons.heart_fill,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Action Breakdown
          if (_statistics['action_breakdown'] != null) ...[
            Text(
              'Activity Breakdown',
              style: TextStyle(
                color: CupertinoColors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 40,
              child: Row(
                children: (_statistics['action_breakdown'] as Map<String, int>)
                    .entries
                    .map((entry) {
                  final percentage = entry.value / 
                      (_statistics['total_actions'] ?? 1) * 100;
                  final details = _getActionDetails(entry.key, 
                    DashboardWidget(
                      id: 'temp',
                      title: 'temp',
                    ));
                  
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            details['icon'],
                            size: 16,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 16,
                color: CupertinoColors.white.withOpacity(0.8),
              ),
              Text(
                value,
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: CupertinoColors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryItem(HistoryItem item) {
    final details = item.details;
    
    return GestureDetector(
      onTap: () {
        Get.to(() => const WidgetPreviewScreen(),
          arguments: item.widget,
          transition: Transition.cupertino,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Action Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (details['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  details['icon'],
                  color: details['color'],
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.widget.title ?? 'Untitled Widget',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        details['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      if (item.widget.username != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        Text(
                          '@${item.widget.username}',
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.activeBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Time
            Text(
              _formatTime(item.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}

// History Item Model
class HistoryItem {
  final String id;
  final DashboardWidget widget;
  final String action;
  final DateTime timestamp;
  final Map<String, dynamic> details;
  
  HistoryItem({
    required this.id,
    required this.widget,
    required this.action,
    required this.timestamp,
    required this.details,
  });
}