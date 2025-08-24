import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/dashboard_widget.dart';
import '../widgets/widget_card_final.dart';
import '../widgets/widget_card_shimmer.dart';
import '../screens/widget_preview_screen.dart';
import '../screens/widget_creation_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/enhanced_search_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  // Data
  List<DashboardWidget> _featuredWidgets = [];
  List<DashboardWidget> _trendingWidgets = [];
  List<DashboardWidget> _newWidgets = [];
  List<Map<String, dynamic>> _topCreators = [];
  List<String> _categories = [
    'All',
    'Investment',
    'Finance',
    'Crypto',
    'Stocks',
    'Real Estate',
    'Analytics',
    'Portfolio',
  ];
  
  String _selectedCategory = 'All';
  bool _isLoading = true;
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _loadExploreData();
  }
  
  Future<void> _loadExploreData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load featured widgets
      final featured = await _apiService.fetchDashboardWidgets(
        page: 1,
        limit: 5,
        filters: {'sort': 'popular'},
      );
      
      // Load trending widgets
      final trending = await _apiService.fetchDashboardWidgets(
        page: 1,
        limit: 10,
        filters: {'sort': 'trending'},
      );
      
      // Load new widgets
      final newWidgets = await _apiService.fetchDashboardWidgets(
        page: 1,
        limit: 10,
        filters: {'sort': 'recent'},
      );
      
      // Load top creators from widgets data
      final creators = _extractTopCreators(trending);
      
      setState(() {
        _featuredWidgets = featured;
        _trendingWidgets = trending;
        _newWidgets = newWidgets;
        _topCreators = creators;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  List<Map<String, dynamic>> _extractTopCreators(List<DashboardWidget> widgets) {
    // Extract unique creators from widgets
    final Map<String, Map<String, dynamic>> creatorsMap = {};
    
    for (final widget in widgets) {
      if (widget.username != null && widget.user_id != null) {
        if (!creatorsMap.containsKey(widget.user_id)) {
          creatorsMap[widget.user_id!] = {
            'id': widget.user_id,
            'name': widget.username,
            'followers': 0, // Will be fetched from user profile API if needed
            'widgets': 1,
            'avatar': widget.username!.substring(0, 1).toUpperCase(),
          };
        } else {
          creatorsMap[widget.user_id]!['widgets'] += 1;
        }
      }
    }
    
    // Sort by followers and take top 5
    final creators = creatorsMap.values.toList();
    creators.sort((a, b) => (b['followers'] as int).compareTo(a['followers'] as int));
    return creators.take(5).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Navigation Bar with Search
          CupertinoSliverNavigationBar(
            largeTitle: Text('Explore'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.add_circled_solid),
              onPressed: () {
                Get.to(() => const WidgetCreationScreen(),
                  transition: Transition.cupertino,
                );
              },
            ),
          ),
          
          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search widgets, creators, tags...',
                onChanged: (value) {
                  setState(() => _isSearching = value.isNotEmpty);
                },
                onSubmitted: (value) {
                  Get.to(() => const EnhancedSearchScreen(),
                    transition: Transition.cupertino,
                  );
                },
              ),
            ),
          ),
          
          // Categories
          SliverToBoxAdapter(
            child: Container(
              height: 44,
              margin: EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      color: isSelected 
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(22),
                      onPressed: () {
                        setState(() => _selectedCategory = category);
                        _loadExploreData();
                      },
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected 
                              ? CupertinoColors.white
                              : CupertinoColors.label,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          if (_isLoading)
            SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: WidgetCardShimmer(count: 3),
              ),
            )
          else ...[
            // Featured Section
            if (_featuredWidgets.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader('Featured', 'Handpicked by our team'),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 320,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _featuredWidgets.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 300,
                        margin: EdgeInsets.only(right: 12),
                        child: _FeaturedCard(
                          widget: _featuredWidgets[index],
                          onTap: () => _navigateToPreview(_featuredWidgets[index]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            
            // Top Creators Section
            SliverToBoxAdapter(
              child: _buildSectionHeader('Top Creators', 'Most followed this month'),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _topCreators.length,
                  itemBuilder: (context, index) {
                    final creator = _topCreators[index];
                    return _CreatorCard(
                      name: creator['name'],
                      followers: creator['followers'],
                      widgets: creator['widgets'],
                      avatar: creator['avatar'],
                      onTap: () {
                        if (creator['id'] != null) {
                          Get.to(() => UserProfileScreen(
                            userId: creator['id'],
                            username: creator['name'],
                          ), transition: Transition.cupertino);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            
            // Trending Widgets
            if (_trendingWidgets.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader('Trending Now', '🔥 Hot widgets'),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return WidgetCardFinal(
                        widget: _trendingWidgets[index],
                        onAction: (action) => _handleWidgetAction(
                          _trendingWidgets[index],
                          action,
                        ),
                      );
                    },
                    childCount: _trendingWidgets.length > 5 ? 5 : _trendingWidgets.length,
                  ),
                ),
              ),
            ],
            
            // New Widgets
            if (_newWidgets.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader('Fresh Arrivals', 'Just published'),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return WidgetCardFinal(
                        widget: _newWidgets[index],
                        onAction: (action) => _handleWidgetAction(
                          _newWidgets[index],
                          action,
                        ),
                      );
                    },
                    childCount: _newWidgets.length > 5 ? 5 : _newWidgets.length,
                  ),
                ),
              ),
            ],
          ],
          
          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
        ],
      ),
    );
  }
  
  void _navigateToPreview(DashboardWidget widget) {
    Get.to(() => const WidgetPreviewScreen(),
      arguments: widget,
      transition: Transition.cupertino,
    );
  }
  
  void _handleWidgetAction(DashboardWidget widget, String action) {
    switch (action) {
      case 'preview':
        _navigateToPreview(widget);
        break;
      case 'remix':
        // Handle remix
        break;
      case 'share':
        // Handle share
        break;
    }
  }
}

// Featured Card Widget
class _FeaturedCard extends StatelessWidget {
  final DashboardWidget widget;
  final VoidCallback onTap;
  
  const _FeaturedCard({
    required this.widget,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.white.withOpacity(0.1),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'FEATURED',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Title
                  Text(
                    widget.title ?? 'Untitled Widget',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    widget.description ?? '',
                    style: TextStyle(
                      color: CupertinoColors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Creator info
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            widget.username?.substring(0, 1).toUpperCase() ?? 'A',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${widget.username ?? 'anonymous'}',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${widget.likes_count ?? 0} likes',
                              style: TextStyle(
                                color: CupertinoColors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.arrow_right_circle_fill,
                        color: CupertinoColors.white,
                        size: 32,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Creator Card Widget
class _CreatorCard extends StatelessWidget {
  final String name;
  final int followers;
  final int widgets;
  final String avatar;
  final VoidCallback onTap;
  
  const _CreatorCard({
    required this.name,
    required this.followers,
    required this.widgets,
    required this.avatar,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_formatCount(followers)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
                Text(
                  ' followers',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
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
}