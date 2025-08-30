import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/services/haptic_service.dart';
import '../../controllers/widget_controller.dart';
import '../../../core/utils/responsive_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late WidgetController _widgetController;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _widgetController = Get.find<WidgetController>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    await _widgetController.loadDashboardWidgets(refresh: true);
    await _widgetController.loadTrendingWidgets();
    await _widgetController.loadPopularAnalysis();
  }
  
  @override
  Widget build(BuildContext context) {
    print('Dashboard building with tab index: ${_tabController.index}');
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final themeController = Get.find<ThemeController>();
    
    return Container(
      color: isDark ? CupertinoColors.black : CupertinoColors.systemBackground,
      child: Column(
        children: [
            // Header with title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good ${_getGreeting()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          themeController.isDarkMode 
                              ? CupertinoIcons.sun_max_fill
                              : CupertinoIcons.moon_fill,
                          size: 24,
                        ),
                        onPressed: () {
                          themeController.toggleTheme();
                        },
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.bell, size: 24),
                        onPressed: () {
                          Get.toNamed('/notifications');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemGrey6,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? CupertinoColors.systemGrey5.darkColor : CupertinoColors.systemGrey4,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () {
                        setState(() {
                          _tabController.animateTo(0);
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            'My Analysis',
                            style: TextStyle(
                              color: _tabController.index == 0
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.systemGrey,
                              fontSize: 16,
                              fontWeight: _tabController.index == 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            color: _tabController.index == 0
                                ? CupertinoColors.activeBlue
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () {
                        setState(() {
                          _tabController.animateTo(1);
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            'Saved Analysis',
                            style: TextStyle(
                              color: _tabController.index == 1
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.systemGrey,
                              fontSize: 16,
                              fontWeight: _tabController.index == 1
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            color: _tabController.index == 1
                                ? CupertinoColors.activeBlue
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Tab Content
          Expanded(
            child: _tabController.index == 0 ? (
                // My Analysis Tab
                CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: _loadData,
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                    padding: EdgeInsets.all(ResponsiveUtils.getAdaptivePadding(context)),
                    margin: ResponsiveUtils.getAdaptiveMargins(context),
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
                style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
              ),
              const SizedBox(height: 16),
              ResponsiveUtils.isTablet(context) 
                ? GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: ResponsiveUtils.getGridColumns(context, 
                      phoneColumns: 2,
                      tabletPortraitColumns: 4,
                      tabletLandscapeColumns: 4
                    ),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0, // Square aspect ratio for icon + text cards
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
                  )
                : Column(
                    children: [
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
                    ],
                  ),
              const SizedBox(height: 24),
              
              // Recent Widgets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Widgets',
                    style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
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
                
                final widgetsToShow = ResponsiveUtils.isTablet(context) ? 6 : 3;
                final widgets = _widgetController.dashboardWidgets
                    .take(widgetsToShow)
                    .toList();
                
                if (ResponsiveUtils.isTablet(context)) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.getGridColumns(context,
                        phoneColumns: 1,
                        tabletPortraitColumns: 2,
                        tabletLandscapeColumns: 3,
                      ),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: ResponsiveUtils.isLandscape(context) ? 2.0 : 1.8,
                    ),
                    itemCount: widgets.length,
                    itemBuilder: (context, index) => _WidgetCard(widget: widgets[index]),
                  );
                } else {
                  return Column(
                    children: widgets
                        .map((widget) => _WidgetCard(widget: widget))
                        .toList(),
                  );
                }
              }),
              
              const SizedBox(height: 24),
              
              // Popular Analysis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Analysis',
                    style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
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
                  ],
                )
              ) : (
                // Saved Analysis Tab
                CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () async {
                        await _widgetController.loadSavedWidgets();
                      },
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Saved Widgets Header
                        Text(
                          'Your Saved Analysis',
                          style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Access your saved widgets and analysis',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Saved Widgets List
                        Obx(() {
                          final savedWidgets = _widgetController.dashboardWidgets
                              .where((w) => w.save ?? false)
                              .toList();
                          
                          if (_widgetController.isLoading.value) {
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
                          
                          if (savedWidgets.isEmpty) {
                            return AppCard(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      Icon(
                                        LucideIcons.bookmark,
                                        size: 48,
                                        color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No saved analysis yet',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Save widgets from your analysis to access them here',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton.icon(
                                        onPressed: () {
                                          _tabController.animateTo(0);
                                        },
                                        icon: const Icon(LucideIcons.arrowLeft, size: 16),
                                        label: const Text('Go to My Analysis'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          return Column(
                            children: savedWidgets.map((widget) {
                              return _SavedWidgetCard(widget: widget);
                            }).toList(),
                          );
                        }),
                        
                        const SizedBox(height: 24),
                        
                        // Categories Section
                        Text(
                          'Browse by Category',
                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _CategoryChip(label: 'Finance', icon: LucideIcons.dollarSign),
                            _CategoryChip(label: 'Analytics', icon: LucideIcons.barChart3),
                            _CategoryChip(label: 'Marketing', icon: LucideIcons.megaphone),
                            _CategoryChip(label: 'Sales', icon: LucideIcons.trendingUp),
                            _CategoryChip(label: 'Operations', icon: LucideIcons.settings),
                            _CategoryChip(label: 'HR', icon: LucideIcons.users),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ),
                  ],
                )
              ),
          ),
          ],
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
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
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
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
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
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
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

class _SavedWidgetCard extends StatelessWidget {
  final dynamic widget;
  
  const _SavedWidgetCard({required this.widget});
  
  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Get.toNamed('/widget-view', arguments: widget),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.bookmark,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title ?? 'Saved Widget',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      LucideIcons.bookmark,
                      size: 16,
                      color: AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.summary ?? 'Saved for later',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Saved ${_formatDate(widget.savedAt ?? widget.createdAt ?? DateTime.now())}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                  ),
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
  
  String _formatDate(dynamic date) {
    DateTime dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      dateTime = DateTime.now();
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  
  const _CategoryChip({required this.label, required this.icon});
  
  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minSize: 0,
      onPressed: () {
        Get.toNamed('/widget-discovery', arguments: {'category': label});
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isDark ? CupertinoColors.white : CupertinoColors.black),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}