import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../controllers/widget_controller.dart';
import '../../../data/models/widget_response_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              width: 140,
              height: 32,
              child: SvgPicture.asset(
                'assets/assetworks_logo_full_black.svg',
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : AppColors.primary,
                  BlendMode.srcIn,
                ),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/widget-discovery'),
            icon: const Icon(LucideIcons.search, size: 22),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppTextField(
                  controller: _searchController,
                  hint: 'Search analysis, widgets, users...',
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  onTap: () => Get.toNamed('/widget-discovery'),
                  readOnly: true,
                ),
              ),
            ),
            
            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            context: context,
                            icon: LucideIcons.sparkles,
                            label: 'Create',
                            color: AppColors.primary,
                            onTap: () => Get.toNamed('/create-widget'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            context: context,
                            icon: LucideIcons.brain,
                            label: 'Analyse',
                            color: AppColors.success,
                            onTap: () {
                              Get.offAllNamed('/main');
                              Get.find<PageController>().jumpToPage(2);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAction(
                            context: context,
                            icon: LucideIcons.layout,
                            label: 'Templates',
                            color: AppColors.info,
                            onTap: () => Get.toNamed('/widget-templates'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Popular Analysis with Thumbnails
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Popular Analysis',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed('/widget-discovery'),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (_widgetController.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      if (_widgetController.dashboardWidgets.isEmpty) {
                        return _buildEmptyState(context, isDark);
                      }
                      
                      return SizedBox(
                        height: 320,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: _widgetController.dashboardWidgets.length.clamp(0, 5),
                          itemBuilder: (context, index) {
                            final widget = _widgetController.dashboardWidgets[index];
                            return _buildWidgetCard(context, widget, isDark);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            // Trending This Week - Real Data
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trending This Week',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _widgetController.loadTrendingWidgets(),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (_widgetController.trendingWidgets.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No trending widgets available',
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        );
                      }
                      
                      return Column(
                        children: _widgetController.trendingWidgets
                            .take(5)
                            .map((widget) => _buildTrendingItem(context, widget, isDark))
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWidgetCard(BuildContext context, WidgetResponseModel widget, bool isDark) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: AppCard(
        onTap: () => Get.toNamed('/widget-view', arguments: widget),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HTML Preview Thumbnail
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    // Preview placeholder with better design
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.neutral800 : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getWidgetIcon(widget.category),
                              size: 28,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Like indicator
                    if (widget.likes > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black54 : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.heart,
                                size: 12,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.likes.toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title with better typography
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Description - more compact
            Text(
              widget.summary.isNotEmpty ? widget.summary : widget.tagline,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Footer with user info
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.username,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.shares > 0) ...[
                    Icon(
                      LucideIcons.share2,
                      size: 12,
                      color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.shares.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getWidgetIcon(String category) {
    switch (category.toLowerCase()) {
      case 'analytics':
      case 'analysis':
        return LucideIcons.barChart3;
      case 'finance':
      case 'financial':
        return LucideIcons.dollarSign;
      case 'stocks':
      case 'stock':
        return LucideIcons.trendingUp;
      case 'crypto':
      case 'cryptocurrency':
        return LucideIcons.bitcoin;
      case 'dashboard':
        return LucideIcons.layoutDashboard;
      case 'report':
      case 'reports':
        return LucideIcons.fileText;
      case 'chart':
      case 'charts':
        return LucideIcons.pieChart;
      default:
        return LucideIcons.code2;
    }
  }
  
  Widget _buildTrendingItem(BuildContext context, WidgetResponseModel widget, bool isDark) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Get.toNamed('/widget-view', arguments: widget),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.neutral800 : AppColors.neutral100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                LucideIcons.trendingUp,
                color: AppColors.primary.withOpacity(0.5),
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
                  widget.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.tagline.isNotEmpty ? widget.tagline : 'Financial Analysis Widget',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      LucideIcons.heart,
                      size: 12,
                      color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.likes}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'by ${widget.username}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
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
  
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              LucideIcons.package,
              size: 64,
              color: isDark ? AppColors.neutral600 : AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              'No widgets available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first widget to get started',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/create-widget'),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Create Widget'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}