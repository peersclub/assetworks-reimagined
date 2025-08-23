import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/services/haptic_service.dart';
import '../../controllers/widget_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late WidgetController _widgetController;
  
  @override
  void initState() {
    super.initState();
    _widgetController = Get.find<WidgetController>();
    _loadData();
  }
  
  Future<void> _loadData() async {
    await _widgetController.loadDashboardWidgets(refresh: true);
    await _widgetController.loadTrendingWidgets();
    await _widgetController.loadPopularAnalysis();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeController = ThemeController.to;
    
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
              themeController.toggleTheme();
            },
            icon: Obx(() => Icon(
              themeController.isDarkMode 
                  ? LucideIcons.sun 
                  : LucideIcons.moon,
              size: 22,
            )),
          ),
          IconButton(
            onPressed: () {
              Get.toNamed('/notifications');
            },
            icon: Badge(
              backgroundColor: AppColors.error,
              smallSize: 8,
              child: const Icon(LucideIcons.bell, size: 22),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Widget Stats Card
              Obx(() => AppCard(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Widgets',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_widgetController.dashboardWidgets.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_widgetController.trendingWidgets.length} trending widgets available',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: LucideIcons.sparkles,
                      title: 'Create',
                      color: AppColors.primary,
                      onTap: () => Get.toNamed('/create-widget'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: LucideIcons.search,
                      title: 'Discover',
                      color: AppColors.info,
                      onTap: () => Get.toNamed('/widget-discovery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: LucideIcons.brain,
                      title: 'Analyse',
                      color: AppColors.success,
                      onTap: () => Get.toNamed('/main', arguments: 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: LucideIcons.history,
                      title: 'History',
                      color: AppColors.warning,
                      onTap: () => Get.toNamed('/prompt-history'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Recent Widgets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Widgets',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/widget-discovery'),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Obx(() {
                if (_widgetController.isLoading.value) {
                  // Show shimmer loading
                  return Column(
                    children: List.generate(
                      3,
                      (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: ShimmerWidgetCard(),
                      ),
                    ),
                  );
                }
                
                if (_widgetController.dashboardWidgets.isEmpty) {
                  return AppCard(
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.package,
                            size: 48,
                            color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No widgets yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Get.toNamed('/create-widget'),
                            child: const Text('Create your first widget'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: _widgetController.dashboardWidgets
                      .take(3)
                      .map((widget) => _WidgetCard(widget: widget))
                      .toList(),
                );
              }),
              
              const SizedBox(height: 24),
              
              // Popular Analysis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Analysis',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      _widgetController.loadPopularAnalysis();
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Obx(() {
                if (_widgetController.popularAnalysis.isEmpty) {
                  return AppCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No popular analysis available',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: _widgetController.popularAnalysis
                      .take(5)
                      .map((analysis) => _AnalysisCard(analysis: analysis))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
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
    
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetCard extends StatelessWidget {
  final dynamic widget;
  
  const _WidgetCard({required this.widget});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Get.toNamed('/widget-view', arguments: widget),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.sparkles,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? 'Untitled Widget',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.tagline ?? widget.summary ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: isDark ? AppColors.neutral600 : AppColors.neutral400,
          ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final Map<String, dynamic> analysis;
  
  const _AnalysisCard({required this.analysis});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            LucideIcons.brain,
            size: 20,
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              analysis['title'] ?? 'Analysis',
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            analysis['count']?.toString() ?? '0',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}