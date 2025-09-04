import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/services/haptic_service.dart';
import '../../controllers/optimized_dashboard_controller.dart';
import '../../widgets/interactive_compact_widget_card.dart';

class OptimizedDashboardScreen extends StatefulWidget {
  const OptimizedDashboardScreen({Key? key}) : super(key: key);
  
  @override
  State<OptimizedDashboardScreen> createState() => _OptimizedDashboardScreenState();
}

class _OptimizedDashboardScreenState extends State<OptimizedDashboardScreen> 
    with AutomaticKeepAliveClientMixin {
  late OptimizedDashboardController _controller;
  final ScrollController _scrollController = ScrollController();
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _controller = Get.put(OptimizedDashboardController());
    _setupScrollListener();
  }
  
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        _controller.loadMore();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_getGreeting()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticService.lightImpact();
              Get.toNamed('/notifications');
            },
            icon: Badge(
              label: Obx(() => Text('${_controller.dashboardWidgets.length}')),
              child: const Icon(LucideIcons.bell),
            ),
          ),
          IconButton(
            onPressed: () {
              HapticService.lightImpact();
              Get.toNamed('/search');
            },
            icon: const Icon(LucideIcons.search),
          ),
        ],
      ),
      body: Obx(() => RefreshIndicator(
        onRefresh: _controller.refresh,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Stats Card
            SliverToBoxAdapter(
              child: _buildStatsCard(isDark),
            ),
            
            // Filter Chips
            SliverToBoxAdapter(
              child: _buildFilterChips(),
            ),
            
            // Quick Actions
            SliverToBoxAdapter(
              child: _buildQuickActions(context),
            ),
            
            // Trending Widgets Section
            SliverToBoxAdapter(
              child: _buildTrendingSection(isDark),
            ),
            
            // Main Widgets List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Widgets',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        HapticService.lightImpact();
                        Get.toNamed('/widget-discovery');
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),
            
            // Widgets Grid/List
            _buildWidgetsList(isDark),
            
            // Loading More Indicator
            if (_controller.isLoadingMore.value)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      )),
    );
  }
  
  Widget _buildStatsCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppCard(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.trendingUp,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Portfolio Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (_controller.dashboardState.value == LoadingState.loading) {
                  return const ShimmerText(width: 100, height: 32);
                }
                return Text(
                  '${_controller.filteredDashboardWidgets.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
              const Text(
                'Active Widgets',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                '${_controller.filteredTrendingWidgets.length} trending • ${_controller.popularAnalysis.length} analyses',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Row(
        children: [
          FilterChip(
            label: const Text('All Widgets'),
            selected: !_controller.showOnlyMyWidgets.value,
            onSelected: (selected) {
              if (_controller.showOnlyMyWidgets.value) {
                _controller.toggleMyWidgetsFilter();
              }
            },
            selectedColor: AppColors.primary.withOpacity(0.2),
            checkmarkColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('By Me'),
            selected: _controller.showOnlyMyWidgets.value,
            onSelected: (selected) {
              if (!_controller.showOnlyMyWidgets.value) {
                _controller.toggleMyWidgetsFilter();
              }
            },
            selectedColor: AppColors.primary.withOpacity(0.2),
            checkmarkColor: AppColors.primary,
          ),
        ],
      )),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.0,
            children: [
              _QuickActionCard(
                icon: LucideIcons.sparkles,
                title: 'Create',
                color: AppColors.primary,
                onTap: () => Get.toNamed('/create-widget'),
              ),
              _QuickActionCard(
                icon: LucideIcons.search,
                title: 'Discover',
                color: AppColors.info,
                onTap: () => Get.toNamed('/widget-discovery'),
              ),
              _QuickActionCard(
                icon: LucideIcons.brain,
                title: 'Analyse',
                color: AppColors.success,
                onTap: () => Get.toNamed('/main', arguments: 2),
              ),
              _QuickActionCard(
                icon: LucideIcons.history,
                title: 'History',
                color: AppColors.warning,
                onTap: () => Get.toNamed('/prompt-history'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildTrendingSection(bool isDark) {
    return Obx(() {
      switch (_controller.trendingState.value) {
        case LoadingState.loading:
        case LoadingState.initial:
          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: ShimmerCard(),
              ),
            ),
          );
          
        case LoadingState.empty:
          return const SizedBox.shrink();
          
        case LoadingState.error:
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ErrorStateWidget.networkError(
              onRetry: () => _controller.loadInitialData(),
            ),
          );
          
        case LoadingState.loaded:
          if (_controller.filteredTrendingWidgets.isEmpty) return const SizedBox.shrink();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.trendingUp,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trending Now',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        HapticService.lightImpact();
                        Get.toNamed('/trending');
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _controller.filteredTrendingWidgets.take(5).length,
                  itemBuilder: (context, index) {
                    final widget = _controller.filteredTrendingWidgets[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 280,
                        child: InteractiveCompactWidgetCard(
                          widget: widget,
                          onTap: () {
                            HapticService.lightImpact();
                            Get.toNamed('/widget-detail', arguments: widget);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
      }
    });
  }
  
  Widget _buildWidgetsList(bool isDark) {
    return Obx(() {
      switch (_controller.dashboardState.value) {
        case LoadingState.initial:
        case LoadingState.loading:
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => const ShimmerCard(),
                childCount: 6,
              ),
            ),
          );
          
        case LoadingState.empty:
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget.noWidgets(
              onCreateWidget: () {
                HapticService.mediumImpact();
                Get.toNamed('/create-widget');
              },
            ),
          );
          
        case LoadingState.error:
          return SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateWidget.networkError(
              onRetry: _controller.retry,
            ),
          );
          
        case LoadingState.loaded:
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final widget = _controller.filteredDashboardWidgets[index];
                  return InteractiveCompactWidgetCard(
                    widget: widget,
                    onTap: () {
                      HapticService.lightImpact();
                      Get.toNamed('/widget-detail', arguments: widget);
                    },
                  );
                },
                childCount: _controller.filteredDashboardWidgets.length,
              ),
            ),
          );
      }
    });
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 18) return 'Afternoon';
    return 'Evening';
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}