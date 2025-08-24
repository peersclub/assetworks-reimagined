import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../models/dashboard_widget.dart';
import '../widgets/widget_card_final.dart';
import '../screens/widget_preview_screen.dart';
import '../screens/user_profile_screen.dart';

class EnhancedSearchScreen extends StatefulWidget {
  const EnhancedSearchScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends State<EnhancedSearchScreen> 
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Search state
  List<DashboardWidget> _searchResults = [];
  List<Map<String, dynamic>> _userResults = [];
  List<String> _recentSearches = [];
  List<String> _trendingSearches = [];
  List<String> _suggestions = [];
  
  bool _isSearching = false;
  bool _showFilters = false;
  String _searchQuery = '';
  Timer? _debounceTimer;
  
  // Filters
  String _selectedSort = 'relevance';
  String _selectedTimeRange = 'all';
  Set<String> _selectedCategories = {};
  double _minRating = 0;
  bool _verifiedOnly = false;
  
  // Sort options
  final Map<String, String> _sortOptions = {
    'relevance': 'Most Relevant',
    'popular': 'Most Popular',
    'recent': 'Recently Added',
    'trending': 'Trending',
    'rating': 'Highest Rated',
  };
  
  // Time ranges
  final Map<String, String> _timeRanges = {
    'all': 'All Time',
    'today': 'Today',
    'week': 'This Week',
    'month': 'This Month',
    'year': 'This Year',
  };
  
  // Categories
  final List<Map<String, dynamic>> _categories = [
    {'id': 'investment', 'name': 'Investment', 'icon': CupertinoIcons.graph_square_fill},
    {'id': 'crypto', 'name': 'Crypto', 'icon': CupertinoIcons.bitcoin},
    {'id': 'stocks', 'name': 'Stocks', 'icon': CupertinoIcons.chart_bar_alt_fill},
    {'id': 'realestate', 'name': 'Real Estate', 'icon': CupertinoIcons.building_2_fill},
    {'id': 'finance', 'name': 'Finance', 'icon': CupertinoIcons.money_dollar_circle_fill},
    {'id': 'analytics', 'name': 'Analytics', 'icon': CupertinoIcons.chart_pie_fill},
    {'id': 'portfolio', 'name': 'Portfolio', 'icon': CupertinoIcons.briefcase_fill},
    {'id': 'ai', 'name': 'AI-Powered', 'icon': CupertinoIcons.sparkles},
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadInitialData();
    _searchFocus.requestFocus();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadInitialData() async {
    // Load recent searches from local storage
    _recentSearches = [
      'crypto portfolio tracker',
      'stock market dashboard',
      'real estate ROI',
      'investment calculator',
      'budget planner',
    ];
    
    // Load trending searches
    _trendingSearches = [
      'AI trading bot',
      'cryptocurrency alerts',
      'dividend tracker',
      'tax calculator 2025',
      'retirement planner',
      'NFT portfolio',
      'ESG investments',
      'options tracker',
    ];
    
    setState(() {});
  }
  
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _searchQuery = value;
    
    if (value.isEmpty) {
      setState(() {
        _searchResults = [];
        _userResults = [];
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() => _isSearching = true);
    
    // Generate AI suggestions
    _generateSuggestions(value);
    
    // Debounce search
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _performSearch();
    });
  }
  
  void _generateSuggestions(String query) {
    // AI-powered suggestions based on query
    final suggestions = <String>[];
    
    if (query.contains('crypto') || query.contains('bitcoin')) {
      suggestions.addAll([
        '$query with real-time prices',
        '$query portfolio tracker',
        '$query alert system',
        '$query technical analysis',
      ]);
    } else if (query.contains('stock') || query.contains('equity')) {
      suggestions.addAll([
        '$query market scanner',
        '$query dividend tracker',
        '$query options chain',
        '$query earnings calendar',
      ]);
    } else if (query.contains('invest')) {
      suggestions.addAll([
        '$query ROI calculator',
        '$query risk analyzer',
        '$query portfolio optimizer',
        '$query performance tracker',
      ]);
    }
    
    setState(() {
      _suggestions = suggestions.take(4).toList();
    });
  }
  
  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;
    
    try {
      // Add to recent searches
      if (!_recentSearches.contains(_searchQuery)) {
        _recentSearches.insert(0, _searchQuery);
        if (_recentSearches.length > 10) {
          _recentSearches.removeLast();
        }
      }
      
      // Build filters - convert to String map for API
      final filters = <String, String>{
        'query': _searchQuery,
        'sort': _selectedSort,
      };
      
      if (_selectedTimeRange != 'all') {
        filters['time_range'] = _selectedTimeRange;
      }
      
      if (_selectedCategories.isNotEmpty) {
        filters['categories'] = _selectedCategories.join(',');
      }
      
      if (_minRating > 0) {
        filters['min_rating'] = _minRating.toString();
      }
      
      if (_verifiedOnly) {
        filters['verified_only'] = 'true';
      }
      
      // Search widgets
      final widgets = await _apiService.fetchDashboardWidgets(
        page: 1,
        limit: 20,
        filters: filters,
      );
      
      // Extract users from results
      final usersMap = <String, Map<String, dynamic>>{};
      for (final widget in widgets) {
        if (widget.user_id != null && widget.username != null) {
          usersMap[widget.user_id!] = {
            'id': widget.user_id,
            'username': widget.username,
            'widgets_count': (usersMap[widget.user_id]?['widgets_count'] ?? 0) + 1,
          };
        }
      }
      
      setState(() {
        _searchResults = widgets;
        _userResults = usersMap.values.toList();
        _isSearching = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }
  
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
      _userResults = [];
      _suggestions = [];
      _isSearching = false;
    });
    _animationController.reverse();
  }
  
  void _showFilterSheet() {
    HapticFeedback.lightImpact();
    setState(() => _showFilters = true);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _FilterSheet(
        sortValue: _selectedSort,
        timeRange: _selectedTimeRange,
        selectedCategories: _selectedCategories,
        minRating: _minRating,
        verifiedOnly: _verifiedOnly,
        onApply: (sort, time, categories, rating, verified) {
          setState(() {
            _selectedSort = sort;
            _selectedTimeRange = time;
            _selectedCategories = categories;
            _minRating = rating;
            _verifiedOnly = verified;
            _showFilters = false;
          });
          _performSearch();
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground.withOpacity(0.94),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        middle: CupertinoSearchTextField(
          controller: _searchController,
          focusNode: _searchFocus,
          placeholder: 'Search widgets, creators, tags...',
          onChanged: _onSearchChanged,
          onSubmitted: (_) => _performSearch(),
          suffixIcon: Icon(CupertinoIcons.mic_fill),
          suffixMode: OverlayVisibilityMode.editing,
          onSuffixTap: () => _startVoiceSearch(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              Icon(CupertinoIcons.slider_horizontal_3),
              if (_selectedCategories.isNotEmpty || 
                  _minRating > 0 || 
                  _verifiedOnly)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: _showFilterSheet,
        ),
      ),
      child: CustomScrollView(
        slivers: [
          // Suggestions & Recent
          if (_searchQuery.isEmpty) ...[
            // Trending Searches
            SliverToBoxAdapter(
              child: _buildSection(
                'Trending Searches',
                CupertinoIcons.flame_fill,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _trendingSearches.map((search) {
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = search;
                        _onSearchChanged(search);
                        _performSearch();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFF6B6B),
                              Color(0xFFFF8E53),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          search,
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // Recent Searches
            if (_recentSearches.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildSection(
                  'Recent Searches',
                  CupertinoIcons.clock_fill,
                  child: Column(
                    children: _recentSearches.map((search) {
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.clock,
                                size: 18,
                                color: CupertinoColors.systemGrey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  search,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: CupertinoColors.label,
                                  ),
                                ),
                              ),
                              Icon(
                                CupertinoIcons.arrow_up_left,
                                size: 18,
                                color: CupertinoColors.systemGrey,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          _searchController.text = search;
                          _onSearchChanged(search);
                          _performSearch();
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            
            // Search Categories
            SliverToBoxAdapter(
              child: _buildSection(
                'Browse Categories',
                CupertinoIcons.square_grid_2x2_fill,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = category['name'];
                        _onSearchChanged(category['name']);
                        _performSearch();
                      },
                      child: Container(
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category['icon'],
                              size: 28,
                              color: CupertinoColors.activeBlue,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category['name'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          
          // AI Suggestions
          if (_suggestions.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.sparkles,
                          size: 18,
                          color: CupertinoColors.systemPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Suggestions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.systemPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._suggestions.map((suggestion) {
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.lightbulb,
                                size: 16,
                                color: CupertinoColors.systemGrey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.label,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          _searchController.text = suggestion;
                          _onSearchChanged(suggestion);
                          _performSearch();
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          
          // Search Results
          if (_searchResults.isNotEmpty || _userResults.isNotEmpty) ...[
            // Users Section
            if (_userResults.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creators',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _userResults.length,
                          itemBuilder: (context, index) {
                            final user = _userResults[index];
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => UserProfileScreen(
                                  userId: user['id'],
                                  username: user['username'],
                                ), transition: Transition.cupertino);
                              },
                              child: Container(
                                width: 70,
                                margin: EdgeInsets.only(right: 16),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF6366F1),
                                            Color(0xFF8B5CF6),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          user['username'].substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '@${user['username']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${user['widgets_count']} widgets',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Widgets Section
            if (_searchResults.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Widgets (${_searchResults.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _sortOptions[_selectedSort]!,
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(_fadeAnimation),
                          child: WidgetCardFinal(
                            widget: _searchResults[index],
                            onAction: (action) => _handleWidgetAction(
                              _searchResults[index],
                              action,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _searchResults.length,
                  ),
                ),
              ),
            ],
          ],
          
          // Loading State
          if (_isSearching)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoActivityIndicator(radius: 15),
                    const SizedBox(height: 16),
                    Text(
                      'Searching...',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // No Results
          if (!_isSearching && 
              _searchQuery.isNotEmpty && 
              _searchResults.isEmpty && 
              _userResults.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      size: 64,
                      color: CupertinoColors.systemGrey3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try different keywords or filters',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      borderRadius: BorderRadius.circular(25),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      child: Text('Clear Filters'),
                      onPressed: () {
                        setState(() {
                          _selectedCategories.clear();
                          _minRating = 0;
                          _verifiedOnly = false;
                          _selectedSort = 'relevance';
                          _selectedTimeRange = 'all';
                        });
                        _performSearch();
                      },
                    ),
                  ],
                ),
              ),
            ),
          
          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, IconData icon, {required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: CupertinoColors.activeBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
  
  void _startVoiceSearch() {
    HapticFeedback.heavyImpact();
    // Implement voice search
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Voice Search'),
        content: Container(
          height: 100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.mic_fill,
                  size: 40,
                  color: CupertinoColors.systemRed,
                ),
                const SizedBox(height: 8),
                Text('Listening...'),
              ],
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  void _handleWidgetAction(DashboardWidget widget, String action) {
    switch (action) {
      case 'preview':
        Get.to(() => const WidgetPreviewScreen(),
          arguments: widget,
          transition: Transition.cupertino,
        );
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

// Filter Sheet
class _FilterSheet extends StatefulWidget {
  final String sortValue;
  final String timeRange;
  final Set<String> selectedCategories;
  final double minRating;
  final bool verifiedOnly;
  final Function(String, String, Set<String>, double, bool) onApply;
  
  const _FilterSheet({
    required this.sortValue,
    required this.timeRange,
    required this.selectedCategories,
    required this.minRating,
    required this.verifiedOnly,
    required this.onApply,
  });
  
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _sort;
  late String _time;
  late Set<String> _categories;
  late double _rating;
  late bool _verified;
  
  @override
  void initState() {
    super.initState();
    _sort = widget.sortValue;
    _time = widget.timeRange;
    _categories = Set.from(widget.selectedCategories);
    _rating = widget.minRating;
    _verified = widget.verifiedOnly;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text('Reset'),
                  onPressed: () {
                    setState(() {
                      _sort = 'relevance';
                      _time = 'all';
                      _categories.clear();
                      _rating = 0;
                      _verified = false;
                    });
                  },
                ),
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'Apply',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    widget.onApply(_sort, _time, _categories, _rating, _verified);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          
          // Filters Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By
                  _buildFilterSection(
                    'Sort By',
                    Column(
                      children: ['relevance', 'popular', 'recent', 'trending', 'rating']
                          .map((value) => CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        value == 'relevance' ? 'Most Relevant' :
                                        value == 'popular' ? 'Most Popular' :
                                        value == 'recent' ? 'Recently Added' :
                                        value == 'trending' ? 'Trending' :
                                        'Highest Rated',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      if (_sort == value)
                                        Icon(
                                          CupertinoIcons.checkmark,
                                          color: CupertinoColors.activeBlue,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                                onPressed: () => setState(() => _sort = value),
                              ))
                          .toList(),
                    ),
                  ),
                  
                  // Time Range
                  _buildFilterSection(
                    'Time Range',
                    Column(
                      children: ['all', 'today', 'week', 'month', 'year']
                          .map((value) => CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        value == 'all' ? 'All Time' :
                                        value == 'today' ? 'Today' :
                                        value == 'week' ? 'This Week' :
                                        value == 'month' ? 'This Month' :
                                        'This Year',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      if (_time == value)
                                        Icon(
                                          CupertinoIcons.checkmark,
                                          color: CupertinoColors.activeBlue,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                                onPressed: () => setState(() => _time = value),
                              ))
                          .toList(),
                    ),
                  ),
                  
                  // Categories
                  _buildFilterSection(
                    'Categories',
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Investment', 'Crypto', 'Stocks', 'Real Estate',
                        'Finance', 'Analytics', 'Portfolio', 'AI-Powered'
                      ].map((category) {
                        final isSelected = _categories.contains(category.toLowerCase());
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _categories.remove(category.toLowerCase());
                              } else {
                                _categories.add(category.toLowerCase());
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.systemGrey5,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? CupertinoColors.white
                                    : CupertinoColors.label,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  // Minimum Rating
                  _buildFilterSection(
                    'Minimum Rating',
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoSlider(
                            value: _rating,
                            min: 0,
                            max: 5,
                            divisions: 5,
                            onChanged: (value) => setState(() => _rating = value),
                          ),
                        ),
                        Container(
                          width: 60,
                          child: Text(
                            _rating == 0 ? 'Any' : '${_rating.toStringAsFixed(1)}★',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Verified Only
                  _buildFilterSection(
                    'Other',
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Verified Creators Only',
                              style: TextStyle(fontSize: 16),
                            ),
                            CupertinoSwitch(
                              value: _verified,
                              onChanged: (value) => setState(() => _verified = value),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () => setState(() => _verified = !_verified),
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
  
  Widget _buildFilterSection(String title, Widget content) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}