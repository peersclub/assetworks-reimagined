import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/dashboard_widget.dart';
import '../widgets/widget_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  List<DashboardWidget> _searchResults = [];
  List<String> _recentSearches = [];
  List<String> _popularTags = [
    'dashboard', 'portfolio', 'calendar', 'todo',
    'weather', 'analytics', 'timer', 'music',
    'news', 'fitness', 'chart', 'social',
  ];
  
  bool _isSearching = false;
  String _selectedFilter = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }
  
  Future<void> _loadRecentSearches() async {
    // Load from local storage
    setState(() {
      _recentSearches = [
        'portfolio tracker',
        'weather widget',
        'todo list',
        'calendar',
      ];
    });
  }
  
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() => _isSearching = true);
    
    // Add to recent searches
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    }
    
    try {
      final results = await _apiService.searchWidgets(
        query: query,
        filter: _selectedFilter,
      );
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }
  
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults.clear();
    });
    _searchFocus.requestFocus();
  }
  
  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.0),
        border: null,
        middle: const Text('Search'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Get.back(),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CupertinoSearchTextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    placeholder: 'Search widgets, users, tags...',
                    onSubmitted: _performSearch,
                    onSuffixTap: _clearSearch,
                    style: const TextStyle(fontSize: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Widgets', 'widgets'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Users', 'users'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Tags', 'tags'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CupertinoActivityIndicator(radius: 20),
                    )
                  : _searchResults.isNotEmpty
                      ? _buildSearchResults()
                      : _buildSuggestions(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = value);
        if (_searchController.text.isNotEmpty) {
          _performSearch(_searchController.text);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemIndigo
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? CupertinoColors.white
                : CupertinoColors.label,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: WidgetCard(
            widget: _searchResults[index],
            onAction: (action) {
              // Handle widget actions
            },
          ),
        );
      },
    );
  }
  
  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 14),
                  ),
                  onPressed: () {
                    setState(() => _recentSearches.clear());
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_recentSearches.map((search) => _buildRecentSearchTile(search))),
            const SizedBox(height: 24),
          ],
          
          // Popular Tags
          const Text(
            'Popular Tags',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularTags.map((tag) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = '#$tag';
                  _performSearch('#$tag');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemIndigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.number,
                        size: 14,
                        color: CupertinoColors.systemIndigo,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tag,
                        style: TextStyle(
                          color: CupertinoColors.systemIndigo,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Trending Searches
          const Text(
            'Trending Now',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildTrendingItem('Portfolio Dashboard', CupertinoIcons.chart_bar_alt_fill),
          _buildTrendingItem('Weather Widget', CupertinoIcons.cloud_sun_fill),
          _buildTrendingItem('Task Manager', CupertinoIcons.checkmark_square_fill),
          _buildTrendingItem('Music Player', CupertinoIcons.music_note),
        ],
      ),
    );
  }
  
  Widget _buildRecentSearchTile(String search) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        _searchController.text = search;
        _performSearch(search);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey5,
              width: 0.5,
            ),
          ),
        ),
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
                style: const TextStyle(fontSize: 16),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 18,
                color: CupertinoColors.systemGrey3,
              ),
              onPressed: () => _removeRecentSearch(search),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrendingItem(String title, IconData icon) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        _searchController.text = title;
        _performSearch(title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemIndigo.withOpacity(0.2),
                    CupertinoColors.systemPurple.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: CupertinoColors.systemIndigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(
              CupertinoIcons.arrow_up_right,
              size: 16,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}