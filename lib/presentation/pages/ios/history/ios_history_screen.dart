import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../controllers/history_controller.dart';

class iOSHistoryScreen extends StatefulWidget {
  const iOSHistoryScreen({Key? key}) : super(key: key);

  @override
  State<iOSHistoryScreen> createState() => _iOSHistoryScreenState();
}

class _iOSHistoryScreenState extends State<iOSHistoryScreen>
    with SingleTickerProviderStateMixin {
  final HistoryController _controller = Get.find<HistoryController>();
  final ScrollController _scrollController = ScrollController();
  
  // Tab controller
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Views', 'Edits', 'Shares'];
  
  // Date filter
  String _selectedDateRange = '7days';
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Group by date
  bool _groupByDate = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await _controller.loadHistory(
      dateRange: _selectedDateRange,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  Future<void> _handleRefresh() async {
    iOS18Theme.mediumImpact();
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.systemBackground.resolveFrom(context).withOpacity(0.94),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.arrow_left,
            color: iOS18Theme.label.resolveFrom(context),
          ),
        ),
        middle: const Text('History'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                iOS18Theme.lightImpact();
                _showDateRangePicker();
              },
              child: Icon(
                CupertinoIcons.calendar,
                size: 22,
                color: iOS18Theme.label.resolveFrom(context),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                iOS18Theme.lightImpact();
                _showHistoryOptions();
              },
              child: Icon(
                CupertinoIcons.ellipsis,
                size: 22,
                color: iOS18Theme.label.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Date range selector
            _buildDateRangeSelector(),
            
            // Tabs
            Container(
              decoration: BoxDecoration(
                color: iOS18Theme.systemBackground.resolveFrom(context),
                border: Border(
                  bottom: BorderSide(
                    color: iOS18Theme.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: iOS18Theme.label.resolveFrom(context),
                unselectedLabelColor: iOS18Theme.secondaryLabel.resolveFrom(context),
                indicatorColor: iOS18Theme.systemBlue,
                indicatorWeight: 3,
                labelStyle: iOS18Theme.body,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                onTap: (index) {
                  iOS18Theme.lightImpact();
                  _filterByType(_tabs[index].toLowerCase());
                },
              ),
            ),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllHistory(),
                  _buildViewHistory(),
                  _buildEditHistory(),
                  _buildShareHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final ranges = [
      {'label': 'Today', 'value': 'today'},
      {'label': '7 Days', 'value': '7days'},
      {'label': '30 Days', 'value': '30days'},
      {'label': 'All Time', 'value': 'all'},
    ];
    
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(
        horizontal: iOS18Theme.spacing16,
        vertical: iOS18Theme.spacing8,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ranges.length,
        itemBuilder: (context, index) {
          final range = ranges[index];
          final isSelected = _selectedDateRange == range['value'];
          
          return Padding(
            padding: const EdgeInsets.only(right: iOS18Theme.spacing8),
            child: GestureDetector(
              onTap: () {
                iOS18Theme.lightImpact();
                setState(() => _selectedDateRange = range['value'] as String);
                _loadHistory();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: iOS18Theme.spacing16,
                  vertical: iOS18Theme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? iOS18Theme.systemBlue
                      : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
                ),
                child: Center(
                  child: Text(
                    range['label'] as String,
                    style: iOS18Theme.footnote.copyWith(
                      color: isSelected
                          ? CupertinoColors.white
                          : iOS18Theme.label.resolveFrom(context),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllHistory() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CupertinoActivityIndicator(radius: 20),
        );
      }
      
      if (_controller.history.isEmpty) {
        return _buildEmptyState(
          icon: CupertinoIcons.clock,
          title: 'No History',
          message: 'Your activity history will appear here',
        );
      }
      
      return CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: _handleRefresh,
          ),
          
          if (_groupByDate)
            ..._buildGroupedHistory()
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _controller.history[index];
                  return _buildHistoryItem(item);
                },
                childCount: _controller.history.length,
              ),
            ),
        ],
      );
    });
  }

  List<Widget> _buildGroupedHistory() {
    final groupedHistory = _controller.getGroupedHistory();
    final widgets = <Widget>[];
    
    groupedHistory.forEach((date, items) {
      widgets.add(
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(
              left: iOS18Theme.spacing16,
              right: iOS18Theme.spacing16,
              top: iOS18Theme.spacing20,
              bottom: iOS18Theme.spacing8,
            ),
            child: Text(
              _formatDateHeader(date),
              style: iOS18Theme.headline.copyWith(
                color: iOS18Theme.label.resolveFrom(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
      
      widgets.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _buildHistoryItem(items[index]);
            },
            childCount: items.length,
          ),
        ),
      );
    });
    
    return widgets;
  }

  Widget _buildHistoryItem(dynamic item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: iOS18Theme.spacing20),
        color: iOS18Theme.systemRed,
        child: const Icon(
          CupertinoIcons.trash,
          color: CupertinoColors.white,
        ),
      ),
      onDismissed: (direction) {
        _controller.deleteHistoryItem(item.id);
        iOS18Theme.lightImpact();
      },
      child: GestureDetector(
        onTap: () {
          iOS18Theme.lightImpact();
          _handleHistoryItemTap(item);
        },
        onLongPress: () {
          iOS18Theme.mediumImpact();
          _showHistoryItemOptions(item);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: iOS18Theme.spacing16,
            vertical: iOS18Theme.spacing4,
          ),
          padding: const EdgeInsets.all(iOS18Theme.spacing12),
          decoration: BoxDecoration(
            color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getHistoryIconColor(item.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
                ),
                child: Icon(
                  _getHistoryIcon(item.type),
                  size: 20,
                  color: _getHistoryIconColor(item.type),
                ),
              ),
              
              const SizedBox(width: iOS18Theme.spacing12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? 'Activity',
                      style: iOS18Theme.body.copyWith(
                        color: iOS18Theme.label.resolveFrom(context),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: iOS18Theme.spacing2),
                    Text(
                      _getHistoryDescription(item),
                      style: iOS18Theme.caption1.copyWith(
                        color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(item.timestamp),
                    style: iOS18Theme.caption2.copyWith(
                      color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                    ),
                  ),
                  if (item.duration != null)
                    Text(
                      _formatDuration(item.duration),
                      style: iOS18Theme.caption2.copyWith(
                        color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewHistory() {
    return Obx(() {
      final viewHistory = _controller.history
          .where((item) => item.type == 'view')
          .toList();
      
      if (viewHistory.isEmpty) {
        return _buildEmptyState(
          icon: CupertinoIcons.eye,
          title: 'No Views',
          message: 'Widgets you view will appear here',
        );
      }
      
      return ListView.builder(
        itemCount: viewHistory.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(viewHistory[index]);
        },
      );
    });
  }

  Widget _buildEditHistory() {
    return Obx(() {
      final editHistory = _controller.history
          .where((item) => item.type == 'edit')
          .toList();
      
      if (editHistory.isEmpty) {
        return _buildEmptyState(
          icon: CupertinoIcons.pencil,
          title: 'No Edits',
          message: 'Your editing history will appear here',
        );
      }
      
      return ListView.builder(
        itemCount: editHistory.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(editHistory[index]);
        },
      );
    });
  }

  Widget _buildShareHistory() {
    return Obx(() {
      final shareHistory = _controller.history
          .where((item) => item.type == 'share')
          .toList();
      
      if (shareHistory.isEmpty) {
        return _buildEmptyState(
          icon: CupertinoIcons.share,
          title: 'No Shares',
          message: 'Widgets you share will appear here',
        );
      }
      
      return ListView.builder(
        itemCount: shareHistory.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(shareHistory[index]);
        },
      );
    });
  }

  IconData _getHistoryIcon(String type) {
    switch (type) {
      case 'view':
        return CupertinoIcons.eye_fill;
      case 'edit':
        return CupertinoIcons.pencil;
      case 'create':
        return CupertinoIcons.plus_circle_fill;
      case 'delete':
        return CupertinoIcons.trash_fill;
      case 'share':
        return CupertinoIcons.share_solid;
      case 'like':
        return CupertinoIcons.heart_fill;
      case 'comment':
        return CupertinoIcons.chat_bubble_fill;
      case 'download':
        return CupertinoIcons.cloud_download_fill;
      case 'export':
        return CupertinoIcons.square_arrow_up_fill;
      default:
        return CupertinoIcons.circle_fill;
    }
  }

  Color _getHistoryIconColor(String type) {
    switch (type) {
      case 'view':
        return iOS18Theme.systemBlue;
      case 'edit':
        return iOS18Theme.systemOrange;
      case 'create':
        return iOS18Theme.systemGreen;
      case 'delete':
        return iOS18Theme.systemRed;
      case 'share':
        return iOS18Theme.systemPurple;
      case 'like':
        return iOS18Theme.systemPink;
      case 'comment':
        return iOS18Theme.systemYellow;
      case 'download':
        return iOS18Theme.systemTeal;
      case 'export':
        return iOS18Theme.systemIndigo;
      default:
        return iOS18Theme.systemGray;
    }
  }

  String _getHistoryDescription(dynamic item) {
    switch (item.type) {
      case 'view':
        return 'Viewed ${item.targetType ?? 'item'}';
      case 'edit':
        return 'Edited ${item.targetType ?? 'item'}';
      case 'create':
        return 'Created ${item.targetType ?? 'item'}';
      case 'delete':
        return 'Deleted ${item.targetType ?? 'item'}';
      case 'share':
        return 'Shared ${item.targetType ?? 'item'}';
      case 'like':
        return 'Liked ${item.targetType ?? 'item'}';
      case 'comment':
        return 'Commented on ${item.targetType ?? 'item'}';
      case 'download':
        return 'Downloaded ${item.targetType ?? 'item'}';
      case 'export':
        return 'Exported ${item.targetType ?? 'item'}';
      default:
        return item.description ?? 'Activity';
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }

  void _handleHistoryItemTap(dynamic item) {
    switch (item.type) {
      case 'view':
      case 'edit':
      case 'create':
      case 'share':
      case 'like':
      case 'comment':
        if (item.targetId != null) {
          Get.toNamed('/widget/${item.targetId}');
        }
        break;
      default:
        // Handle other types
        break;
    }
  }

  void _showHistoryItemOptions(dynamic item) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(item.title ?? 'History Item'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // View details
            },
            child: const Text('View Details'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Copy
            },
            child: const Text('Copy'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteHistoryItem(item.id);
            },
            isDestructiveAction: true,
            child: const Text('Remove from History'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showDateRangePicker() {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: iOS18Theme.systemBackground.resolveFrom(context),
      builder: (context) => Container(
        height: 400,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(iOS18Theme.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Select Date Range',
                    style: iOS18Theme.headline.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Apply'),
                    onPressed: () {
                      Navigator.pop(context);
                      _loadHistory();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (DateTime newDate) {
                  // Handle date change
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('History Options'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _groupByDate = !_groupByDate);
            },
            child: Text(_groupByDate ? 'Show as List' : 'Group by Date'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _exportHistory();
            },
            child: const Text('Export History'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showClearHistoryDialog();
            },
            isDestructiveAction: true,
            child: const Text('Clear All History'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showClearHistoryDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear History'),
        content: const Text('This will permanently delete all your history. This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear'),
            onPressed: () {
              Navigator.pop(context);
              _controller.clearHistory();
              iOS18Theme.successImpact();
            },
          ),
        ],
      ),
    );
  }

  void _exportHistory() {
    // Export history functionality
  }

  void _filterByType(String type) {
    if (type != 'all') {
      _controller.filterByType(type);
    } else {
      _loadHistory();
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(iOS18Theme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iOS18Theme.systemGray6.resolveFrom(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
            ),
            const SizedBox(height: iOS18Theme.spacing20),
            Text(
              title,
              style: iOS18Theme.title3.copyWith(
                color: iOS18Theme.label.resolveFrom(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: iOS18Theme.spacing8),
            Text(
              message,
              style: iOS18Theme.body.copyWith(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}