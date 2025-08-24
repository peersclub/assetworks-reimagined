import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/dashboard_widget.dart';
import '../widgets/widget_card.dart';
import '../widgets/widget_card_shimmer.dart';
import '../screens/widget_preview_screen.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({Key? key}) : super(key: key);

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> 
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final ScrollController _scrollController = ScrollController();
  
  late TabController _tabController;
  
  List<DashboardWidget> _trendingWidgets = [];
  List<DashboardWidget> _topWidgets = [];
  List<DashboardWidget> _recentWidgets = [];
  
  bool _isLoading = true;
  int _selectedTab = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    _loadTrendingWidgets();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTrendingWidgets() async {
    setState(() => _isLoading = true);
    
    try {
      // Load trending widgets
      final trending = await _apiService.getTrendingWidgets();
      
      // Load top widgets (most liked)
      final top = await _apiService.fetchDashboardWidgets(
        filters: {'sort': 'popular'},
        limit: 20,
      );
      
      // Load recent widgets
      final recent = await _apiService.fetchDashboardWidgets(
        filters: {'sort': 'recent'},
        limit: 20,
      );
      
      setState(() {
        _trendingWidgets = trending;
        _topWidgets = top;
        _recentWidgets = recent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Widget _buildWidgetGrid(List<DashboardWidget> widgets) {
    if (widgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.sparkles,
              size: 64,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No widgets found',
              style: TextStyle(
                fontSize: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        final widget = widgets[index];
        return _TrendingWidgetCard(
          widget: widget,
          rank: _selectedTab == 0 ? index + 1 : null,
          onTap: () {
            HapticFeedback.lightImpact();
            Get.toNamed('/widget-preview', arguments: widget);
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.0),
        border: null,
        middle: const Text('Trending'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.search),
          onPressed: () => Get.toNamed('/search'),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedTab,
                onValueChanged: (value) {
                  if (value != null) {
                    _tabController.animateTo(value);
                  }
                },
                children: {
                  0: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.flame,
                          size: 16,
                          color: _selectedTab == 0
                              ? CupertinoColors.systemOrange
                              : CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        const Text('Trending'),
                      ],
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.star_fill,
                          size: 16,
                          color: _selectedTab == 1
                              ? CupertinoColors.systemYellow
                              : CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        const Text('Top'),
                      ],
                    ),
                  ),
                  2: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          size: 16,
                          color: _selectedTab == 2
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        const Text('Recent'),
                      ],
                    ),
                  ),
                },
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? Padding(
                      padding: EdgeInsets.all(16),
                      child: WidgetCardShimmer(count: 5),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildWidgetGrid(_trendingWidgets),
                        _buildWidgetGrid(_topWidgets),
                        _buildWidgetGrid(_recentWidgets),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingWidgetCard extends StatelessWidget {
  final DashboardWidget widget;
  final int? rank;
  final VoidCallback onTap;
  
  const _TrendingWidgetCard({
    Key? key,
    required this.widget,
    this.rank,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).brightness == Brightness.dark
              ? CupertinoColors.systemGrey6.darkColor
              : CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.systemIndigo.withOpacity(0.3),
                          CupertinoColors.systemPurple.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.play_circle_fill,
                        size: 40,
                        color: CupertinoColors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
                
                // Info
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title ?? 'Untitled',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${widget.username ?? 'anonymous'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.heart_fill,
                            size: 12,
                            color: CupertinoColors.systemRed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.likes_count ?? 0}',
                            style: TextStyle(
                              fontSize: 11,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            CupertinoIcons.eye,
                            size: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.views_count ?? 0}',
                            style: TextStyle(
                              fontSize: 11,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Rank badge
            if (rank != null && rank! <= 3)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: rank == 1
                        ? CupertinoColors.systemYellow
                        : rank == 2
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.number,
                        size: 12,
                        color: CupertinoColors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$rank',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
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
}