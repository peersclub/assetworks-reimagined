import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/services/haptic_service.dart';
import '../../controllers/widget_controller.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../services/api_service.dart';
import '../../../services/dynamic_island_service.dart';
import '../../../models/dashboard_widget.dart';
import '../../../data/models/widget_response_model.dart';
import '../../../widgets/widget_studio_launcher.dart';

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
                      // Create Widget Button
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CupertinoColors.systemPurple,
                                CupertinoColors.systemIndigo,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            CupertinoIcons.add,
                            size: 20,
                            color: CupertinoColors.white,
                          ),
                        ),
                        onPressed: () {
                          HapticService.lightImpact();
                          WidgetStudioLauncher.launch();
                        },
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.square_grid_3x2,
                          size: 24,
                        ),
                        onPressed: () {
                          _showDashboardVersions(context);
                        },
                      ),
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
                    childAspectRatio: 1.2, // Wider aspect ratio to prevent overflow
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
                              return _WidgetCard(widget: widget);
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
  
  void _showDashboardVersions(BuildContext context) {
    HapticService.lightImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Dashboard Versions'),
          message: const Text('Choose your preferred dashboard layout'),
          actions: [
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.rectangle_3_offgrid_fill, size: 20),
                  SizedBox(width: 8),
                  Text('Current Dashboard'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.square_grid_2x2, size: 20),
                  SizedBox(width: 8),
                  Text('Classic Dashboard'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                Get.offNamed('/classic-dashboard');
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.rectangle_stack, size: 20),
                  SizedBox(width: 8),
                  Text('Dashboard V2 (Feed)'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                Get.offNamed('/dashboard-v2');
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.rectangle_3_offgrid, size: 20),
                  SizedBox(width: 8),
                  Text('Dashboard V3 (Cards)'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                Get.offNamed('/dashboard-v3');
              },
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.lab_flask_solid, size: 20),
                  SizedBox(width: 8),
                  Text('Dashboard V4 Test (All Versions)'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                Get.offNamed('/dashboard-v4-test');
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.speedometer, size: 20),
                  SizedBox(width: 8),
                  Text('Optimized Dashboard'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                Get.offNamed('/optimized-dashboard');
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
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
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WidgetCard extends StatefulWidget {
  final dynamic widget;
  
  const _WidgetCard({required this.widget});
  
  @override
  State<_WidgetCard> createState() => _WidgetCardState();
}

class _WidgetCardState extends State<_WidgetCard> with TickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  late DashboardWidget dashboardWidget;
  
  late AnimationController _likeAnimationController;
  late AnimationController _saveAnimationController;
  late AnimationController _shareAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _saveScaleAnimation;
  late Animation<double> _shareScaleAnimation;
  
  @override
  void initState() {
    super.initState();
    // Convert to DashboardWidget if needed
    if (widget.widget is DashboardWidget) {
      dashboardWidget = widget.widget;
    } else if (widget.widget is WidgetResponseModel) {
      final w = widget.widget as WidgetResponseModel;
      dashboardWidget = DashboardWidget(
        id: w.id,
        title: w.title,
        tagline: w.tagline,
        summary: w.summary,
        username: w.username,
        created_at: DateTime.fromMillisecondsSinceEpoch(w.createdAt),
        likes_count: w.likes,
        shares_count: w.shares,
        saves_count: 0, // WidgetResponseModel doesn't track saves_count
        like: w.like ?? false,
        save: w.save ?? false,
      );
    } else {
      // Fallback for dynamic objects
      dashboardWidget = DashboardWidget(
        id: dashboardWidget.id ?? '',
        title: dashboardWidget.title,
        tagline: dashboardWidget.tagline,
        summary: dashboardWidget.summary,
        username: dashboardWidget.username,
        created_at: dashboardWidget.created_at,
        likes_count: dashboardWidget.likes_count ?? 0,
        shares_count: dashboardWidget.shares_count ?? 0,
        saves_count: dashboardWidget.saves_count ?? 0,
        like: dashboardWidget.like ?? false,
        save: dashboardWidget.save ?? false,
      );
    }
    _initAnimations();
  }
  
  void _initAnimations() {
    // Like animation
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Save animation
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _saveScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Share animation
    _shareAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shareScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _shareAnimationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _likeAnimationController.dispose();
    _saveAnimationController.dispose();
    _shareAnimationController.dispose();
    super.dispose();
  }
  
  Future<void> _handleLike() async {
    HapticFeedback.mediumImpact();
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    
    final success = dashboardWidget.like
        ? await _apiService.dislikeWidget(dashboardWidget.id)
        : await _apiService.likeWidget(dashboardWidget.id);
    
    if (success) {
      setState(() {
        dashboardWidget.like = !dashboardWidget.like;
      });
      HapticFeedback.heavyImpact();
      DynamicIslandService().updateStatus(
        dashboardWidget.like ? 'Liked!' : 'Unliked',
        icon: dashboardWidget.like ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
      );
    }
  }
  
  Future<void> _handleSave() async {
    HapticFeedback.mediumImpact();
    _saveAnimationController.forward().then((_) {
      _saveAnimationController.reverse();
    });
    
    final success = await _apiService.saveWidgetToProfile(dashboardWidget.id);
    
    if (success) {
      setState(() {
        dashboardWidget.save = !dashboardWidget.save;
        if (dashboardWidget.save) {
          dashboardWidget.saves_count = (dashboardWidget.saves_count ?? 0) + 1;
        } else if (dashboardWidget.saves_count != null && dashboardWidget.saves_count! > 0) {
          dashboardWidget.saves_count = dashboardWidget.saves_count! - 1;
        }
      });
      HapticFeedback.heavyImpact();
      DynamicIslandService().updateStatus(
        dashboardWidget.save ? 'Saved to dashboard!' : 'Removed from dashboard',
        icon: dashboardWidget.save ? Icons.bookmark : Icons.bookmark_border,
      );
    }
  }
  
  Future<void> _handleShare() async {
    HapticFeedback.mediumImpact();
    _shareAnimationController.forward().then((_) {
      _shareAnimationController.reverse();
    });
    
    // Show share options including remix
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Widget Options'),
          message: Text(dashboardWidget.title ?? 'Widget'),
          actions: [
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.share, size: 20),
                  SizedBox(width: 8),
                  Text('Share Widget'),
                ],
              ),
              onPressed: () async {
                Navigator.pop(context);
                await Share.share(
                  'Check out this amazing widget: ${dashboardWidget.title}\n'
                  'https://assetworks.ai/widget/${dashboardWidget.id}',
                  subject: 'AssetWorks Widget',
                );
                
                // Track share action
                _apiService.trackActivity(
                  action: 'shared',
                  widgetId: dashboardWidget.id,
                  metadata: {
                    'source': 'classic_dashboard',
                    'timestamp': DateTime.now().toIso8601String(),
                  },
                );
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.sparkles, size: 20, color: CupertinoColors.systemPurple),
                  SizedBox(width: 8),
                  Text('Remix Widget', style: TextStyle(color: CupertinoColors.systemPurple)),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                WidgetStudioLauncher.remix(
                  widgetTitle: dashboardWidget.title ?? 'Untitled Widget',
                  widgetDescription: dashboardWidget.description,
                );
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.doc_on_clipboard, size: 20),
                  SizedBox(width: 8),
                  Text('Copy Link'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(
                  text: 'https://assetworks.ai/widget/${dashboardWidget.id}'
                ));
                HapticService.success();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                // User Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      (dashboardWidget.username?.isNotEmpty == true
                          ? dashboardWidget.username![0]
                          : 'U').toUpperCase(),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Username and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dashboardWidget.username ?? 'Anonymous',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (dashboardWidget.created_at != null)
                        Text(
                          _getTimeAgo(dashboardWidget.created_at!),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
                // More options button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    size: 20,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  onPressed: () {
                    // Show more options
                  },
                ),
              ],
            ),
          ),
          
          // Main content
          GestureDetector(
            onTap: () => Get.toNamed('/widget-view', arguments: dashboardWidget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dashboardWidget.title ?? 'Untitled Widget',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dashboardWidget.tagline ?? dashboardWidget.summary ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Engagement buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                // Like button
                AnimatedBuilder(
                  animation: _likeScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _likeScaleAnimation.value,
                      child: _buildEngagementButton(
                        icon: dashboardWidget.like
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        count: dashboardWidget.likes_count ?? 0,
                        color: dashboardWidget.like
                            ? CupertinoColors.systemRed
                            : null,
                        onTap: _handleLike,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),
                // Save button
                AnimatedBuilder(
                  animation: _saveScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _saveScaleAnimation.value,
                      child: _buildEngagementButton(
                        icon: dashboardWidget.save
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        count: dashboardWidget.saves_count ?? 0,
                        color: dashboardWidget.save
                            ? CupertinoColors.systemBlue
                            : null,
                        onTap: _handleSave,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),
                // Share button
                AnimatedBuilder(
                  animation: _shareScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _shareScaleAnimation.value,
                      child: _buildEngagementButton(
                        icon: CupertinoIcons.share,
                        count: dashboardWidget.shares_count ?? 0,
                        onTap: _handleShare,
                      ),
                    );
                  },
                ),
                const Spacer(),
                // View detail
                Icon(
                  CupertinoIcons.arrow_right_circle,
                  size: 22,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEngagementButton({
    required IconData icon,
    required int count,
    Color? color,
    required VoidCallback onTap,
  }) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: color ?? defaultColor,
          ),
          const SizedBox(width: 6),
          Text(
            count > 0 ? _formatCount(count) : '',
            style: TextStyle(
              fontSize: 13,
              color: color ?? defaultColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
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
                  'Saved ${_formatDate(DateTime.fromMillisecondsSinceEpoch(widget.updatedAt))}',
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