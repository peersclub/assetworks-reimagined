import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../widgets/ios/ios_widget_card.dart';
import '../../../widgets/ios/ios_empty_state.dart';
import '../../../widgets/ios/ios_shimmer_loader.dart';
// import '../notifications/ios_notifications_screen.dart';

class iOSDashboardScreen extends StatefulWidget {
  const iOSDashboardScreen({Key? key}) : super(key: key);

  @override
  State<iOSDashboardScreen> createState() => _iOSDashboardScreenState();
}

class _iOSDashboardScreenState extends State<iOSDashboardScreen> {
  final DashboardController _controller = Get.find<DashboardController>();
  final ScrollController _scrollController = ScrollController();
  
  // For pull to refresh
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadDashboardWidgets();
    await _controller.loadTrendingWidgets();
  }

  Future<void> _handleRefresh() async {
    iOS18Theme.mediumImpact();
    setState(() => _isRefreshing = true);
    await _loadData();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.systemGroupedBackground.resolveFrom(context),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // iOS 18 Large Title Navigation Bar
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Dashboard'),
            backgroundColor: iOS18Theme.systemBackground.resolveFrom(context).withOpacity(0.94),
            border: null,
            stretch: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    iOS18Theme.lightImpact();
                    _showSearchModal();
                  },
                  child: Icon(
                    CupertinoIcons.search,
                    size: 22,
                    color: iOS18Theme.label.resolveFrom(context),
                  ),
                ),
                const SizedBox(width: 8),
                // Notifications
                const iOSNotificationIcon(),
              ],
            ),
          ),
          
          // Pull to refresh
          CupertinoSliverRefreshControl(
            onRefresh: _handleRefresh,
          ),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
            sliver: Obx(() {
              if (_controller.isLoading.value && _controller.widgets.isEmpty) {
                return _buildLoadingState();
              }
              
              if (_controller.widgets.isEmpty) {
                return _buildEmptyState();
              }
              
              return _buildDashboardContent();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const iOSShimmerLoader(),
        childCount: 5,
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: iOSEmptyState(
          icon: CupertinoIcons.square_grid_2x2,
          title: 'No Widgets Yet',
          message: 'Create your first widget to start building your investment dashboard',
          actionTitle: 'Create Widget',
          onAction: () {
            iOS18Theme.mediumImpact();
            Get.toNamed('/create');
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Portfolio Overview Card
        _buildPortfolioOverview(),
        
        const SizedBox(height: iOS18Theme.spacing20),
        
        // Quick Stats
        _buildQuickStats(),
        
        const SizedBox(height: iOS18Theme.spacing20),
        
        // Section Header
        _buildSectionHeader('Your Widgets', onSeeAll: () {
          Get.toNamed('/profile');
        }),
        
        const SizedBox(height: iOS18Theme.spacing12),
        
        // User Widgets
        ..._controller.widgets.map((widget) => Padding(
          padding: const EdgeInsets.only(bottom: iOS18Theme.spacing12),
          child: iOSWidgetCard(
            widget: widget,
            onTap: () {
              iOS18Theme.lightImpact();
              Get.toNamed('/widget/${widget.id}');
            },
            onLongPress: () {
              iOS18Theme.mediumImpact();
              _showWidgetPreview(widget);
            },
          ),
        )).toList(),
        
        const SizedBox(height: iOS18Theme.spacing20),
        
        // Trending Section
        _buildSectionHeader('Trending Now', onSeeAll: () {
          Get.toNamed('/discovery');
        }),
        
        const SizedBox(height: iOS18Theme.spacing12),
        
        // Trending Widgets Horizontal Scroll
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _controller.trendingWidgets.length,
            itemBuilder: (context, index) {
              final widget = _controller.trendingWidgets[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: iOS18Theme.spacing12,
                  left: index == 0 ? 0 : 0,
                ),
                child: SizedBox(
                  width: 280,
                  child: iOSWidgetCard(
                    widget: widget,
                    isCompact: true,
                    onTap: () {
                      iOS18Theme.lightImpact();
                      Get.toNamed('/widget/${widget.id}');
                    },
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 100), // Bottom padding for tab bar
      ]),
    );
  }

  Widget _buildPortfolioOverview() {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                'Portfolio Value',
                style: iOS18Theme.footnote.copyWith(
                  color: iOS18Theme.secondaryLabel.resolveFrom(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: iOS18Theme.systemGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.arrow_up_right,
                      size: 12,
                      color: iOS18Theme.systemGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+12.5%',
                      style: iOS18Theme.caption1.copyWith(
                        color: iOS18Theme.systemGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: iOS18Theme.spacing8),
          
          Text(
            '\$125,430.50',
            style: iOS18Theme.largeTitle.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          
          const SizedBox(height: iOS18Theme.spacing16),
          
          // Mini chart
          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 3),
                      FlSpot(1, 1.5),
                      FlSpot(2, 3.5),
                      FlSpot(3, 2),
                      FlSpot(4, 4),
                      FlSpot(5, 3),
                      FlSpot(6, 4.5),
                    ],
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        iOS18Theme.systemBlue,
                        iOS18Theme.systemBlue.withOpacity(0.5),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          iOS18Theme.systemBlue.withOpacity(0.3),
                          iOS18Theme.systemBlue.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: CupertinoIcons.chart_bar_fill,
            title: 'Widgets',
            value: '${_controller.widgets.length}',
            color: iOS18Theme.systemBlue,
          ),
        ),
        const SizedBox(width: iOS18Theme.spacing12),
        Expanded(
          child: _buildStatCard(
            icon: CupertinoIcons.eye_fill,
            title: 'Views',
            value: '1.2K',
            color: iOS18Theme.systemPurple,
          ),
        ),
        const SizedBox(width: iOS18Theme.spacing12),
        Expanded(
          child: _buildStatCard(
            icon: CupertinoIcons.heart_fill,
            title: 'Likes',
            value: '342',
            color: iOS18Theme.systemPink,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(iOS18Theme.spacing12),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: iOS18Theme.spacing8),
          Text(
            value,
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          Text(
            title,
            style: iOS18Theme.caption2.copyWith(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: iOS18Theme.title3.copyWith(
            color: iOS18Theme.label.resolveFrom(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null)
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              iOS18Theme.lightImpact();
              onSeeAll();
            },
            child: Text(
              'See All',
              style: iOS18Theme.subheadline.copyWith(
                color: iOS18Theme.systemBlue,
              ),
            ),
          ),
      ],
    );
  }

  void _showSearchModal() {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: iOS18Theme.systemBackground.resolveFrom(context),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Search'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Done'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: Text('Search implementation'),
            ),
          ),
        ),
      ),
    );
  }

  void _showWidgetPreview(dynamic widget) {
    // Widget preview modal implementation
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: iOS18Theme.systemBackground.resolveFrom(context),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(widget.title ?? 'Widget Preview'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Done'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: Text('Widget preview implementation'),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}