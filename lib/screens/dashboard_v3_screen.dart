import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../models/dashboard_widget.dart';
import '../screens/widget_preview_screen.dart';
import '../screens/investment_widget_creator_screen.dart';

class DashboardV3Screen extends StatefulWidget {
  const DashboardV3Screen({Key? key}) : super(key: key);

  @override
  State<DashboardV3Screen> createState() => _DashboardV3ScreenState();
}

class _DashboardV3ScreenState extends State<DashboardV3Screen> with TickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final PageController _pageController = PageController();
  
  List<DashboardWidget> _widgets = [];
  List<DashboardWidget> _filteredWidgets = [];
  List<DashboardWidget> _trendingWidgets = [];
  List<DashboardWidget> _filteredTrendingWidgets = [];
  List<DashboardWidget> _recentActivity = [];
  int _savedCount = 0;
  int _weeklyCount = 0;
  bool _isLoading = false;
  int _currentPage = 0;
  bool _showOnlyMyWidgets = false;
  String? _currentUserId;
  
  final List<String> _sections = [
    'Overview',
    'Trending',
    'Your Widgets',
    'Analytics',
  ];
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _getCurrentUser();
  }
  
  Future<void> _getCurrentUser() async {
    try {
      final userProfile = await _apiService.getUserProfile();
      if (mounted && userProfile != null) {
        setState(() {
          _currentUserId = userProfile.id;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  Widget _buildEngagementButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? CupertinoColors.secondaryLabel,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? CupertinoColors.secondaryLabel,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _loadData() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final widgets = await _apiService.fetchDashboardWidgets(
        page: 1,
        limit: 20,
      );
      
      final trending = await _apiService.fetchTrendingWidgets();
      
      // Calculate real stats from API data
      final now = DateTime.now();
      final weekAgo = now.subtract(Duration(days: 7));
      
      if (mounted) {
        setState(() {
          _widgets = widgets;
          _filteredWidgets = widgets;
          _trendingWidgets = trending;
          _filteredTrendingWidgets = trending;
          _recentActivity = widgets.take(3).toList();
          _applyFilter();
          
          // Count widgets created this week
          _weeklyCount = widgets.where((w) {
            final createdAt = w.created_at ?? DateTime.now();
            return createdAt.isAfter(weekAgo);
          }).length;
          
          // Count saved widgets
          _savedCount = widgets.where((w) => w.save == true).length;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _applyFilter() {
    if (_showOnlyMyWidgets && _currentUserId != null) {
      _filteredWidgets = _widgets.where((w) => 
        w.user_id == _currentUserId || 
        w.username == _currentUserId
      ).toList();
      _filteredTrendingWidgets = _trendingWidgets.where((w) => 
        w.user_id == _currentUserId || 
        w.username == _currentUserId
      ).toList();
    } else {
      _filteredWidgets = _widgets;
      _filteredTrendingWidgets = _trendingWidgets;
    }
  }
  
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: Text('All Widgets'),
            selected: !_showOnlyMyWidgets,
            onSelected: (selected) {
              setState(() {
                _showOnlyMyWidgets = false;
                _applyFilter();
              });
            },
            selectedColor: CupertinoColors.activeBlue.withOpacity(0.2),
            checkmarkColor: CupertinoColors.activeBlue,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text('By Me'),
            selected: _showOnlyMyWidgets,
            onSelected: (selected) {
              setState(() {
                _showOnlyMyWidgets = selected;
                _applyFilter();
              });
            },
            selectedColor: CupertinoColors.activeBlue.withOpacity(0.2),
            checkmarkColor: CupertinoColors.activeBlue,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOverviewSection() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard V3',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Card-based layout with sections',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 24),
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Widgets',
                        _widgets.length.toString(),
                        CupertinoColors.systemBlue,
                        CupertinoIcons.square_grid_2x2_fill,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Trending',
                        _trendingWidgets.length.toString(),
                        CupertinoColors.systemOrange,
                        CupertinoIcons.flame_fill,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'This Week',
                        _weeklyCount > 0 ? '+$_weeklyCount' : '0',
                        CupertinoColors.systemGreen,
                        CupertinoIcons.graph_square_fill,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Saved',
                        _savedCount.toString(),
                        CupertinoColors.systemPurple,
                        CupertinoIcons.bookmark_fill,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Recent Activity
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  _recentActivity.length.clamp(0, 3),
                  (index) => _buildActivityCard(_recentActivity[index]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    // Calculate percentage change (could be from API in future)
    final percentage = title == 'This Week' && _weeklyCount > 0 
        ? '+${(_weeklyCount * 100 / (_widgets.length > 0 ? _widgets.length : 1)).toStringAsFixed(0)}%'
        : '';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (percentage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    percentage,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityCard(DashboardWidget widget) {
    // Calculate time ago
    String timeAgo = 'Recently';
    if (widget.created_at != null) {
      final created = widget.created_at!;
      final diff = DateTime.now().difference(created);
      
      if (diff.inMinutes < 60) {
        timeAgo = '${diff.inMinutes} min ago';
      } else if (diff.inHours < 24) {
        timeAgo = '${diff.inHours} hours ago';
      } else if (diff.inDays == 1) {
        timeAgo = 'Yesterday';
      } else {
        timeAgo = '${diff.inDays} days ago';
      }
    }
    
    // Determine activity type and color
    IconData icon;
    String title;
    Color color;
    
    if (widget.save == true) {
      icon = CupertinoIcons.bookmark_fill;
      title = 'Saved widget';
      color = CupertinoColors.systemBlue;
    } else if ((widget.shares_count ?? 0) > 0) {
      icon = CupertinoIcons.share_solid;
      title = 'Shared widget';
      color = CupertinoColors.systemPurple;
    } else {
      icon = CupertinoIcons.plus_circle_fill;
      title = 'Created widget';
      color = CupertinoColors.systemGreen;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.title ?? 'Untitled Widget',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: TextStyle(
              fontSize: 11,
              color: CupertinoColors.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrendingSection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTrendingWidgets.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending Widgets',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _showOnlyMyWidgets 
                    ? 'Your trending widgets this week'
                    : 'Most popular widgets this week',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFilterChips(),
              ],
            ),
          );
        }
        
        if (index == 1 && _filteredTrendingWidgets.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.chart_bar,
                    size: 64,
                    color: CupertinoColors.systemGrey3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showOnlyMyWidgets 
                      ? 'No widgets by you are trending'
                      : 'No trending widgets',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        final widgetIndex = index - 2;
        if (widgetIndex >= _filteredTrendingWidgets.length) return SizedBox.shrink();
        
        final widget = _filteredTrendingWidgets[widgetIndex];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.flame_fill,
                          color: CupertinoColors.systemOrange,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '#${index}',
                          style: TextStyle(
                            color: CupertinoColors.systemOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    CupertinoIcons.ellipsis,
                    color: CupertinoColors.tertiaryLabel,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.title ?? 'Untitled Widget',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.description ?? widget.summary ?? 'No description',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Engagement buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEngagementButton(
                    icon: widget.like == true 
                        ? CupertinoIcons.heart_fill 
                        : CupertinoIcons.heart,
                    label: '${widget.likes_count ?? 0}',
                    color: widget.like == true 
                        ? CupertinoColors.systemRed 
                        : CupertinoColors.secondaryLabel,
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      final success = widget.like == true
                          ? await _apiService.dislikeWidget(widget.id)
                          : await _apiService.likeWidget(widget.id);
                      if (success) {
                        setState(() {
                          widget.like = !(widget.like ?? false);
                        });
                      }
                    },
                  ),
                  _buildEngagementButton(
                    icon: widget.save == true
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    label: 'Save',
                    color: widget.save == true
                        ? CupertinoColors.systemBlue
                        : CupertinoColors.secondaryLabel,
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      final success = await _apiService.saveWidgetToProfile(widget.id);
                      if (success) {
                        setState(() {
                          widget.save = !(widget.save ?? false);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(widget.save == true 
                                ? 'Saved to dashboard!' 
                                : 'Removed from dashboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  _buildEngagementButton(
                    icon: CupertinoIcons.share,
                    label: 'Share',
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      await Share.share(
                        'Check out this widget: ${widget.title}\n'
                        'https://assetworks.ai/widget/${widget.id}',
                        subject: 'AssetWorks Widget',
                      );
                    },
                  ),
                  _buildEngagementButton(
                    icon: CupertinoIcons.arrow_right_circle,
                    label: 'View',
                    color: CupertinoColors.activeBlue,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.to(() => WidgetPreviewScreen(), arguments: widget);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text('Dashboard V3'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.add),
          onPressed: () {
            Get.to(() => InvestmentWidgetCreatorScreen());
          },
        ),
      ),
      child: Column(
        children: [
          // Section selector
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: CupertinoTheme.of(context).barBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.systemGrey5,
                  width: 0.5,
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final isSelected = _currentPage == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentPage = index);
                    _pageController.animateToPage(
                      index,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? CupertinoTheme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _sections[index],
                      style: TextStyle(
                        color: isSelected
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.secondaryLabel,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? Center(child: CupertinoActivityIndicator())
                : PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildOverviewSection(),
                      _buildTrendingSection(),
                      _buildWidgetsGrid(),
                      _buildAnalyticsSection(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWidgetsGrid() {
    // Show filter chips at the top
    if (_filteredWidgets.isEmpty) {
      return Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.square_grid_2x2,
                    size: 64,
                    color: CupertinoColors.systemGrey3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showOnlyMyWidgets 
                      ? 'You have not created any widgets yet'
                      : 'No widgets available',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: _filteredWidgets.length,
            itemBuilder: (context, index) {
              final widget = _filteredWidgets[index];
              return Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Get.to(() => const WidgetPreviewScreen(), arguments: widget);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.chart_bar_square_fill,
                      color: CupertinoTheme.of(context).primaryColor,
                      size: 32,
                    ),
                    const Spacer(),
                    Text(
                      widget.title ?? 'Untitled Widget',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Investment Widget',
                      style: TextStyle(
                        fontSize: 11,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAnalyticsSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chart_bar_alt_fill,
            size: 64,
            color: CupertinoColors.tertiaryLabel,
          ),
          const SizedBox(height: 16),
          Text(
            'Analytics Coming Soon',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your widget performance',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}