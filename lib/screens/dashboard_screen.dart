import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../presentation/widgets/ios/ios_empty_state.dart';
import '../widgets/widget_card_shimmer.dart';
import '../services/dynamic_island_service.dart';
import '../services/api_service.dart';
import '../models/dashboard_widget.dart';
import '../widgets/widget_card_v2.dart';
import '../screens/widget_preview_screen.dart';
import '../screens/widget_remix_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  final ScrollController _scrollController = ScrollController();
  
  List<DashboardWidget> _widgets = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _selectedFilter = 'all';
  String _sortBy = 'recent';
  
  @override
  void initState() {
    super.initState();
    _loadWidgets();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreWidgets();
      }
    }
  }
  
  Future<void> _loadWidgets() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _widgets.clear();
    });
    
    DynamicIslandService().updateStatus(
      'Loading widgets...',
      icon: CupertinoIcons.square_stack_3d_up,
    );
    
    final filters = <String, String>{};
    if (_selectedFilter != 'all') {
      filters['filter'] = _selectedFilter;
    }
    filters['sort'] = _sortBy;
    
    try {
      final widgets = await _apiService.fetchDashboardWidgets(
        page: _currentPage,
        limit: 10,
        filters: filters,
      );
      
      setState(() {
        _widgets = widgets;
        _hasMore = widgets.length == 10;
        _isLoading = false;
      });
      
      DynamicIslandService().updateStatus(
        'Widgets loaded',
        icon: CupertinoIcons.checkmark_circle_fill,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load widgets');
    }
  }
  
  Future<void> _loadMoreWidgets() async {
    setState(() {
      _isLoading = true;
      _currentPage++;
    });
    
    final filters = <String, String>{};
    if (_selectedFilter != 'all') {
      filters['filter'] = _selectedFilter;
    }
    filters['sort'] = _sortBy;
    
    try {
      final widgets = await _apiService.fetchDashboardWidgets(
        page: _currentPage,
        limit: 10,
        filters: filters,
      );
      
      setState(() {
        _widgets.addAll(widgets);
        _hasMore = widgets.length == 10;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentPage--;
      });
    }
  }
  
  void _showFilterOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Filter Widgets'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedFilter = 'all');
              _loadWidgets();
            },
            child: const Text('All Widgets'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedFilter = 'saved');
              _loadWidgets();
            },
            child: const Text('Saved'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedFilter = 'liked');
              _loadWidgets();
            },
            child: const Text('Liked'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedFilter = 'following');
              _loadWidgets();
            },
            child: const Text('Following'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
  
  void _showSortOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Sort By'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _sortBy = 'recent');
              _loadWidgets();
            },
            child: const Text('Most Recent'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _sortBy = 'popular');
              _loadWidgets();
            },
            child: const Text('Most Popular'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _sortBy = 'name');
              _loadWidgets();
            },
            child: const Text('Name (A-Z)'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
  
  void _showError(String message) {
    HapticFeedback.heavyImpact();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleWidgetAction(DashboardWidget widget, String action) async {
    HapticFeedback.lightImpact();
    
    switch (action) {
      case 'preview':
        Get.to(() => const WidgetPreviewScreen(), 
          arguments: widget,
          transition: Transition.cupertino,
        );
        break;
        
      case 'remix':
        Get.to(() => const WidgetRemixScreen(), 
          arguments: widget,
          transition: Transition.cupertino,
        );
        break;
        
      case 'save':
        final success = await _apiService.saveWidgetToProfile(widget.id);
        if (success) {
          setState(() => widget.save = true);
          DynamicIslandService().updateStatus(
            'Widget saved!',
            icon: CupertinoIcons.bookmark_fill,
          );
        }
        break;
      case 'like':
        final success = widget.like 
            ? await _apiService.dislikeWidget(widget.id)
            : await _apiService.likeWidget(widget.id);
        if (success) {
          setState(() => widget.like = !widget.like);
          DynamicIslandService().updateStatus(
            widget.like ? 'Liked!' : 'Unliked',
            icon: widget.like ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          );
        }
        break;
      case 'follow':
        final success = widget.follow
            ? await _apiService.unfollowWidget(widget.id)
            : await _apiService.followWidget(widget.id);
        if (success) {
          setState(() => widget.follow = !widget.follow);
          DynamicIslandService().updateStatus(
            widget.follow ? 'Following!' : 'Unfollowed',
            icon: CupertinoIcons.bell_fill,
          );
        }
        break;
      case 'share':
        // TODO: Implement share functionality
        break;
      case 'preview':
        Get.toNamed('/widget-preview', arguments: widget);
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Dashboard'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.line_horizontal_3_decrease),
                  onPressed: _showFilterOptions,
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.arrow_up_arrow_down),
                  onPressed: _showSortOptions,
                ),
              ],
            ),
          ),
          
          CupertinoSliverRefreshControl(
            onRefresh: _loadWidgets,
          ),
          
          if (_selectedFilter != 'all' || _sortBy != 'recent')
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    if (_selectedFilter != 'all')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemIndigo
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _selectedFilter.capitalize!,
                          style: TextStyle(
                            color: CupertinoColors.systemIndigo,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_selectedFilter != 'all')
                      const SizedBox(width: 8),
                    if (_sortBy != 'recent')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemPurple
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _sortBy == 'popular'
                              ? 'Popular'
                              : 'A-Z',
                          style: TextStyle(
                            color: CupertinoColors.systemPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'all';
                          _sortBy = 'recent';
                        });
                        _loadWidgets();
                      },
                    ),
                  ],
                ),
              ),
            ),
          
          if (_widgets.isEmpty && !_isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.square_stack_3d_up,
                      size: 64,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No widgets yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first widget or explore trending',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CupertinoButton.filled(
                      onPressed: () => Get.toNamed('/create-widget'),
                      child: const Text('Create Widget'),
                    ),
                  ],
                ),
              ),
            )
          else if (_isLoading && _widgets.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: WidgetCardShimmer(count: 5),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < _widgets.length) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: WidgetCardV2(
                          widget: _widgets[index],
                          onAction: (action) => _handleWidgetAction(
                            _widgets[index],
                            action,
                          ),
                        ),
                      );
                    } else if (_isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CupertinoActivityIndicator(),
                        ),
                      );
                    }
                    return null;
                  },
                  childCount: _widgets.length + (_isLoading ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}