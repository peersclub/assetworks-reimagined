import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/widget_response_model.dart';
import '../../controllers/discovery_controller.dart';
import '../../widgets/trending_widgets_carousel.dart';

class WidgetDiscoveryScreen extends StatefulWidget {
  const WidgetDiscoveryScreen({Key? key}) : super(key: key);
  
  @override
  State<WidgetDiscoveryScreen> createState() => _WidgetDiscoveryScreenState();
}

class _WidgetDiscoveryScreenState extends State<WidgetDiscoveryScreen> {
  late DiscoveryController _controller;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  final List<String> _categories = [
    'All',
    'Financial',
    'Analytics',
    'Crypto',
    'Stocks',
    'Reports',
    'Custom',
  ];
  
  @override
  void initState() {
    super.initState();
    _controller = Get.put(DiscoveryController());
    
    // Setup scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        if (!_controller.isLoadingMore.value && _controller.hasMore.value) {
          _controller.loadWidgets();
        }
      }
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Widgets'),
        actions: [
          IconButton(
            onPressed: _showFilterOptions,
            icon: const Icon(LucideIcons.filter, size: 22),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/create-widget'),
            icon: const Icon(LucideIcons.plus, size: 22),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search widgets...',
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 20),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  _controller.searchWidgets(value);
                },
              ),
            ),
          ),
          
          // Category Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Obx(() => FilterChip(
                      label: Text(category),
                      selected: category == _controller.selectedCategory.value,
                      onSelected: (selected) {
                        _controller.filterByCategory(category);
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    )),
                  );
                },
              ),
            ),
          ),
          
          // Trending Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
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
                            'Trending This Week',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed('/trending-widgets'),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
                const TrendingWidgetsCarousel(),
              ],
            ),
          ),
          
          // Sort Options
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Widgets',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Obx(() => DropdownButton<String>(
                    value: _controller.sortBy.value,
                    items: ['Popular', 'Recent', 'Most Liked', 'Most Viewed']
                        .map((sort) => DropdownMenuItem(
                              value: sort,
                              child: Text(sort, style: const TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _controller.changeSortBy(value!);
                    },
                    underline: const SizedBox(),
                    icon: const Icon(LucideIcons.chevronDown, size: 20),
                  )),
                ],
              ),
            ),
          ),
          
          // Widgets Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: Obx(() {
              final widgets = _controller.filteredWidgets;
              
              if (_controller.isLoading.value && widgets.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              
              if (widgets.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No widgets found'),
                    ),
                  ),
                );
              }
              
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final widget = widgets[index];
                    return _buildWidgetCard(widget);
                  },
                  childCount: widgets.length,
                ),
              );
            }),
          ),
          
          // Loading indicator for pagination
          SliverToBoxAdapter(
            child: Obx(() => _controller.isLoadingMore.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink()),
          ),
          
          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWidgetCard(WidgetResponseModel widget) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      onTap: () => _openWidget(widget),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview Placeholder
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? AppColors.neutral900 : AppColors.neutral100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                _getCategoryIcon(widget.category),
                size: 32,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // Creator
          Row(
            children: [
              const Icon(LucideIcons.user, size: 12),
              const SizedBox(width: 4),
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
            ],
          ),
          const Spacer(),
          
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.heart,
                    size: 14,
                    color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.likes.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    LucideIcons.eye,
                    size: 14,
                    color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.shares.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Charts':
        return LucideIcons.barChart3;
      case 'Tables':
        return LucideIcons.table;
      case 'Dashboards':
        return LucideIcons.layoutDashboard;
      case 'Forms':
        return LucideIcons.formInput;
      case 'Analytics':
        return LucideIcons.trendingUp;
      case 'Reports':
        return LucideIcons.fileText;
      default:
        return LucideIcons.layout;
    }
  }
  
  void _openWidget(WidgetResponseModel widget) {
    Get.toNamed('/widget-view', arguments: widget);
  }
  
  void _showFilterOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Date Range
              const Text('Date Range', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Today', 'This Week', 'This Month', 'All Time'].map((range) {
                  return FilterChip(
                    label: Text(range),
                    selected: false,
                    onSelected: (selected) {},
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              
              // Widget Type
              const Text('Widget Type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Public', 'Private', 'Shared'].map((type) {
                  return FilterChip(
                    label: Text(type),
                    selected: false,
                    onSelected: (selected) {},
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Apply Button
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Reset',
                      type: AppButtonType.outline,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Apply Filters',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}