import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../controllers/search_controller.dart' as app;
import '../../../widgets/ios/ios_widget_card.dart';
import '../../../widgets/ios/ios_shimmer_loader.dart';

class iOSSearchScreen extends StatefulWidget {
  const iOSSearchScreen({Key? key}) : super(key: key);

  @override
  State<iOSSearchScreen> createState() => _iOSSearchScreenState();
}

class _iOSSearchScreenState extends State<iOSSearchScreen>
    with TickerProviderStateMixin {
  final app.SearchController _controller = Get.find<app.SearchController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _resultsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Search state
  bool _isSearching = false;
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedSort = 'relevance';
  final List<String> _recentSearches = [
    'Apple stock',
    'Crypto dashboard',
    'Portfolio tracker',
    'Tesla analysis',
    'Market overview',
  ];
  
  // Filters
  final Map<String, bool> _filters = {
    'widgets': true,
    'users': true,
    'tags': true,
  };
  
  // Search suggestions
  final List<String> _trendingSearches = [
    'AI predictions',
    'Dividend tracker',
    'Options flow',
    'Earnings calendar',
    'Technical indicators',
    'Risk management',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _searchFocus.requestFocus();
    _searchController.addListener(_onSearchChanged);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _resultsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resultsAnimationController,
      curve: iOS18Theme.springCurve,
    ));
    
    _animationController.forward();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query != _searchQuery) {
      _searchQuery = query;
      if (query.isNotEmpty) {
        setState(() => _isSearching = true);
        _performSearch(query);
      } else {
        setState(() => _isSearching = false);
        _controller.clearSearch();
      }
    }
  }

  Future<void> _performSearch(String query) async {
    _resultsAnimationController.reset();
    await _controller.search(
      query: query,
      category: _selectedCategory,
      filters: _filters,
      sort: _selectedSort,
    );
    _resultsAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.systemBackground.resolveFrom(context),
      child: SafeArea(
        child: Column(
          children: [
            // Search header
            _buildSearchHeader(),
            
            // Filter chips
            if (_isSearching) _buildFilterChips(),
            
            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _isSearching
                    ? _buildSearchResults()
                    : _buildSearchSuggestions(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      decoration: BoxDecoration(
        color: iOS18Theme.systemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: iOS18Theme.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: Icon(
                  CupertinoIcons.arrow_left,
                  color: iOS18Theme.label.resolveFrom(context),
                ),
              ),
              
              // Search field
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: iOS18Theme.systemGray6.resolveFrom(context),
                    borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: iOS18Theme.spacing8),
                        child: Icon(
                          CupertinoIcons.search,
                          size: 18,
                          color: iOS18Theme.secondaryLabel.resolveFrom(context),
                        ),
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          placeholder: 'Search widgets, users, or tags',
                          placeholderStyle: iOS18Theme.footnote.copyWith(
                            color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                          ),
                          style: iOS18Theme.body.copyWith(
                            color: iOS18Theme.label.resolveFrom(context),
                          ),
                          decoration: const BoxDecoration(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: iOS18Theme.spacing8,
                            vertical: iOS18Theme.spacing8,
                          ),
                          clearButtonMode: OverlayVisibilityMode.editing,
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _addToRecentSearches(value);
                            }
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        CupertinoButton(
                          padding: const EdgeInsets.only(right: iOS18Theme.spacing8),
                          onPressed: () {
                            _searchController.clear();
                          },
                          child: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: 18,
                            color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Filter button
              CupertinoButton(
                padding: const EdgeInsets.only(left: iOS18Theme.spacing8),
                onPressed: () {
                  iOS18Theme.lightImpact();
                  _showFilterOptions();
                },
                child: Icon(
                  CupertinoIcons.slider_horizontal_3,
                  color: iOS18Theme.systemBlue,
                ),
              ),
            ],
          ),
          
          // Search scope selector
          if (_isSearching)
            Container(
              margin: const EdgeInsets.only(top: iOS18Theme.spacing12),
              child: Row(
                children: [
                  _buildScopeButton('All', 'all'),
                  _buildScopeButton('Widgets', 'widgets'),
                  _buildScopeButton('Users', 'users'),
                  _buildScopeButton('Tags', 'tags'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScopeButton(String title, String value) {
    final isSelected = _selectedCategory == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          iOS18Theme.lightImpact();
          setState(() => _selectedCategory = value);
          if (_searchQuery.isNotEmpty) {
            _performSearch(_searchQuery);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing4),
          padding: const EdgeInsets.symmetric(vertical: iOS18Theme.spacing8),
          decoration: BoxDecoration(
            color: isSelected
                ? iOS18Theme.systemBlue
                : iOS18Theme.systemGray6.resolveFrom(context),
            borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
          ),
          child: Center(
            child: Text(
              title,
              style: iOS18Theme.caption1.copyWith(
                color: isSelected
                    ? CupertinoColors.white
                    : iOS18Theme.label.resolveFrom(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Recent', _selectedSort == 'recent'),
          _buildFilterChip('Popular', _selectedSort == 'popular'),
          _buildFilterChip('Trending', _selectedSort == 'trending'),
          _buildFilterChip('Top Rated', _selectedSort == 'rating'),
          _buildFilterChip('Most Viewed', _selectedSort == 'views'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: iOS18Theme.spacing8),
      child: GestureDetector(
        onTap: () {
          iOS18Theme.lightImpact();
          // Update sort option
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: iOS18Theme.spacing12,
            vertical: iOS18Theme.spacing6,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? iOS18Theme.systemBlue.withOpacity(0.1)
                : iOS18Theme.systemGray6.resolveFrom(context),
            borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
            border: Border.all(
              color: isSelected
                  ? iOS18Theme.systemBlue
                  : iOS18Theme.separator.resolveFrom(context),
            ),
          ),
          child: Text(
            label,
            style: iOS18Theme.caption1.copyWith(
              color: isSelected
                  ? iOS18Theme.systemBlue
                  : iOS18Theme.label.resolveFrom(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionHeader(
              'Recent Searches',
              action: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() => _recentSearches.clear());
                },
                child: Text(
                  'Clear',
                  style: iOS18Theme.footnote.copyWith(
                    color: iOS18Theme.systemBlue,
                  ),
                ),
              ),
            ),
            ..._recentSearches.map((search) => _buildRecentSearchItem(search)),
          ],
          
          const SizedBox(height: iOS18Theme.spacing24),
          
          // Trending searches
          _buildSectionHeader('Trending Searches'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
            child: Wrap(
              spacing: iOS18Theme.spacing8,
              runSpacing: iOS18Theme.spacing8,
              children: _trendingSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    iOS18Theme.lightImpact();
                    _searchController.text = search;
                    _performSearch(search);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: iOS18Theme.spacing12,
                      vertical: iOS18Theme.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: iOS18Theme.systemGray6.resolveFrom(context),
                      borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.flame,
                          size: 14,
                          color: iOS18Theme.systemOrange,
                        ),
                        const SizedBox(width: iOS18Theme.spacing4),
                        Text(
                          search,
                          style: iOS18Theme.footnote.copyWith(
                            color: iOS18Theme.label.resolveFrom(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: iOS18Theme.spacing24),
          
          // Popular categories
          _buildSectionHeader('Popular Categories'),
          _buildCategoryGrid(),
          
          const SizedBox(height: iOS18Theme.spacing32),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        iOS18Theme.lightImpact();
        _searchController.text = search;
        _performSearch(search);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: iOS18Theme.spacing16,
          vertical: iOS18Theme.spacing12,
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.clock,
              size: 18,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
            ),
            const SizedBox(width: iOS18Theme.spacing12),
            Expanded(
              child: Text(
                search,
                style: iOS18Theme.body.copyWith(
                  color: iOS18Theme.label.resolveFrom(context),
                ),
              ),
            ),
            Icon(
              CupertinoIcons.arrow_up_left,
              size: 16,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Stocks', 'icon': CupertinoIcons.chart_line, 'color': iOS18Theme.systemBlue},
      {'name': 'Crypto', 'icon': CupertinoIcons.bitcoin, 'color': iOS18Theme.systemOrange},
      {'name': 'ETFs', 'icon': CupertinoIcons.chart_pie_fill, 'color': iOS18Theme.systemGreen},
      {'name': 'Options', 'icon': CupertinoIcons.graph_square, 'color': iOS18Theme.systemPurple},
      {'name': 'Forex', 'icon': CupertinoIcons.money_dollar_circle, 'color': iOS18Theme.systemPink},
      {'name': 'Futures', 'icon': CupertinoIcons.chart_bar_alt_fill, 'color': iOS18Theme.systemYellow},
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: iOS18Theme.spacing12,
          mainAxisSpacing: iOS18Theme.spacing12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              iOS18Theme.lightImpact();
              _searchController.text = category['name'] as String;
              _performSearch(category['name'] as String);
            },
            child: Container(
              decoration: BoxDecoration(
                color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
                borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 28,
                    color: category['color'] as Color,
                  ),
                  const SizedBox(height: iOS18Theme.spacing8),
                  Text(
                    category['name'] as String,
                    style: iOS18Theme.caption1.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (_controller.isSearching.value) {
        return _buildLoadingState();
      }
      
      if (_controller.searchResults.isEmpty) {
        return _buildEmptyResults();
      }
      
      return SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Results header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(iOS18Theme.spacing16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_controller.searchResults.length} results',
                      style: iOS18Theme.footnote.copyWith(
                        color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        iOS18Theme.lightImpact();
                        _showSortOptions();
                      },
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.arrow_up_arrow_down,
                            size: 16,
                            color: iOS18Theme.systemBlue,
                          ),
                          const SizedBox(width: iOS18Theme.spacing4),
                          Text(
                            'Sort',
                            style: iOS18Theme.footnote.copyWith(
                              color: iOS18Theme.systemBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Results list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final result = _controller.searchResults[index];
                  return _buildSearchResultItem(result);
                },
                childCount: _controller.searchResults.length,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchResultItem(dynamic result) {
    // Determine result type
    if (result.type == 'widget') {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: iOS18Theme.spacing16,
          vertical: iOS18Theme.spacing4,
        ),
        child: iOSWidgetCard(
          widget: result,
          onTap: () {
            iOS18Theme.lightImpact();
            Get.toNamed('/widget/${result.id}');
          },
        ),
      );
    } else if (result.type == 'user') {
      return _buildUserResultItem(result);
    } else if (result.type == 'tag') {
      return _buildTagResultItem(result);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildUserResultItem(dynamic user) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        iOS18Theme.lightImpact();
        Get.toNamed('/profile/${user.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(iOS18Theme.spacing16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iOS18Theme.systemGray5.resolveFrom(context),
              ),
              child: Icon(
                CupertinoIcons.person_fill,
                size: 25,
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
            ),
            const SizedBox(width: iOS18Theme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'User',
                    style: iOS18Theme.body.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '@${user.username ?? 'username'}',
                    style: iOS18Theme.caption1.copyWith(
                      color: iOS18Theme.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                  if (user.bio != null)
                    Text(
                      user.bio!,
                      style: iOS18Theme.caption1.copyWith(
                        color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: iOS18Theme.spacing12,
                vertical: iOS18Theme.spacing6,
              ),
              decoration: BoxDecoration(
                color: iOS18Theme.systemBlue,
                borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
              ),
              child: Text(
                'Follow',
                style: iOS18Theme.caption1.copyWith(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagResultItem(dynamic tag) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        iOS18Theme.lightImpact();
        // Navigate to tag results
      },
      child: Container(
        padding: const EdgeInsets.all(iOS18Theme.spacing16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iOS18Theme.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
              ),
              child: Icon(
                CupertinoIcons.tag_fill,
                size: 20,
                color: iOS18Theme.systemBlue,
              ),
            ),
            const SizedBox(width: iOS18Theme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${tag.name}',
                    style: iOS18Theme.body.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${tag.count ?? 0} widgets',
                    style: iOS18Theme.caption1.copyWith(
                      color: iOS18Theme.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      itemCount: 5,
      itemBuilder: (context, index) => const iOSShimmerLoader(),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(iOS18Theme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.search,
              size: 60,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
            ),
            const SizedBox(height: iOS18Theme.spacing20),
            Text(
              'No results found',
              style: iOS18Theme.title3.copyWith(
                color: iOS18Theme.label.resolveFrom(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: iOS18Theme.spacing8),
            Text(
              'Try adjusting your search or filters',
              style: iOS18Theme.body.copyWith(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  void _addToRecentSearches(String search) {
    if (!_recentSearches.contains(search)) {
      setState(() {
        _recentSearches.insert(0, search);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
  }

  void _showFilterOptions() {
    // Show filter modal
  }

  void _showSortOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Sort Results'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedSort = 'relevance');
              _performSearch(_searchQuery);
            },
            child: const Text('Most Relevant'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedSort = 'recent');
              _performSearch(_searchQuery);
            },
            child: const Text('Most Recent'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedSort = 'popular');
              _performSearch(_searchQuery);
            },
            child: const Text('Most Popular'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedSort = 'rating');
              _performSearch(_searchQuery);
            },
            child: const Text('Highest Rated'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _resultsAnimationController.dispose();
    super.dispose();
  }
}