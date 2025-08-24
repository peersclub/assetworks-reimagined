import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../controllers/discovery_controller.dart';
import '../../../widgets/ios/ios_widget_card.dart';
import '../../../widgets/ios/ios_shimmer_loader.dart';

class iOSDiscoveryScreen extends StatefulWidget {
  const iOSDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<iOSDiscoveryScreen> createState() => _iOSDiscoveryScreenState();
}

class _iOSDiscoveryScreenState extends State<iOSDiscoveryScreen> 
    with SingleTickerProviderStateMixin {
  final DiscoveryController _controller = Get.find<DiscoveryController>();
  final ScrollController _scrollController = ScrollController();
  
  // Tab controller for categories
  late TabController _tabController;
  
  // Search
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;
  
  // Categories
  final List<String> _categories = [
    'All',
    'Trending',
    'Stocks',
    'Crypto',
    'ETFs',
    'Forex',
    'Commodities',
    'Indices',
  ];
  
  int _selectedCategoryIndex = 0;
  String _selectedSortOption = 'popularity';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadDiscoveryData();
  }

  Future<void> _loadDiscoveryData() async {
    await _controller.loadTrendingWidgets();
    await _controller.loadPopularCreators();
    await _controller.loadCategories();
  }

  Future<void> _handleRefresh() async {
    iOS18Theme.mediumImpact();
    await _loadDiscoveryData();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.systemGroupedBackground.resolveFrom(context),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // Navigation bar with search
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Discover'),
            backgroundColor: iOS18Theme.systemBackground.resolveFrom(context).withOpacity(0.94),
            border: null,
            stretch: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    iOS18Theme.lightImpact();
                    _showFilterSheet();
                  },
                  child: Icon(
                    CupertinoIcons.slider_horizontal_3,
                    size: 22,
                    color: iOS18Theme.label.resolveFrom(context),
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    iOS18Theme.lightImpact();
                    setState(() => _isSearching = !_isSearching);
                    if (_isSearching) {
                      _searchFocus.requestFocus();
                    }
                  },
                  child: Icon(
                    CupertinoIcons.search,
                    size: 22,
                    color: iOS18Theme.label.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          
          // Pull to refresh
          CupertinoSliverRefreshControl(
            onRefresh: _handleRefresh,
          ),
          
          // Search bar (animated)
          if (_isSearching)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: iOS18Theme.spacing16,
                  vertical: iOS18Theme.spacing8,
                ),
                child: _buildSearchBar(),
              ),
            ),
          
          // Category tabs
          SliverToBoxAdapter(
            child: Container(
              height: 44,
              margin: const EdgeInsets.only(top: iOS18Theme.spacing8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: iOS18Theme.spacing8),
                    child: GestureDetector(
                      onTap: () {
                        iOS18Theme.lightImpact();
                        setState(() => _selectedCategoryIndex = index);
                        _controller.filterByCategory(_categories[index]);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: iOS18Theme.spacing16,
                          vertical: iOS18Theme.spacing8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? iOS18Theme.systemBlue
                              : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
                          borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
                          border: Border.all(
                            color: isSelected
                                ? iOS18Theme.systemBlue
                                : iOS18Theme.separator.resolveFrom(context),
                            width: isSelected ? 0 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _categories[index],
                            style: iOS18Theme.footnote.copyWith(
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
                },
              ),
            ),
          ),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(iOS18Theme.spacing16),
            sliver: Obx(() {
              if (_controller.isLoading.value) {
                return _buildLoadingState();
              }
              
              return _buildDiscoveryContent();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: iOS18Theme.spacing12),
            child: Icon(
              CupertinoIcons.search,
              size: 20,
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: _searchController,
              focusNode: _searchFocus,
              placeholder: 'Search widgets, creators, symbols...',
              placeholderStyle: iOS18Theme.body.copyWith(
                color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              ),
              style: iOS18Theme.body.copyWith(
                color: iOS18Theme.label.resolveFrom(context),
              ),
              decoration: const BoxDecoration(),
              padding: const EdgeInsets.symmetric(
                horizontal: iOS18Theme.spacing8,
                vertical: iOS18Theme.spacing12,
              ),
              onSubmitted: (value) {
                _controller.search(value);
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            CupertinoButton(
              padding: const EdgeInsets.only(right: iOS18Theme.spacing8),
              onPressed: () {
                _searchController.clear();
                _controller.clearSearch();
              },
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 18,
                color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const iOSShimmerLoader(),
        childCount: 5,
      ),
    );
  }

  Widget _buildDiscoveryContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Featured section
        _buildSectionHeader('Featured Today', icon: CupertinoIcons.star_fill),
        const SizedBox(height: iOS18Theme.spacing12),
        _buildFeaturedCard(),
        
        const SizedBox(height: iOS18Theme.spacing24),
        
        // Popular creators
        _buildSectionHeader('Popular Creators', icon: CupertinoIcons.person_2_fill),
        const SizedBox(height: iOS18Theme.spacing12),
        _buildCreatorsList(),
        
        const SizedBox(height: iOS18Theme.spacing24),
        
        // Trending widgets
        _buildSectionHeader('Trending Widgets', icon: CupertinoIcons.flame_fill),
        const SizedBox(height: iOS18Theme.spacing12),
        ..._controller.trendingWidgets.map((widget) => Padding(
          padding: const EdgeInsets.only(bottom: iOS18Theme.spacing12),
          child: iOSWidgetCard(
            widget: widget,
            onTap: () {
              iOS18Theme.lightImpact();
              Get.toNamed('/widget/${widget.id}');
            },
          ),
        )).toList(),
        
        const SizedBox(height: iOS18Theme.spacing24),
        
        // New releases
        _buildSectionHeader('New Releases', icon: CupertinoIcons.sparkles),
        const SizedBox(height: iOS18Theme.spacing12),
        _buildNewReleasesGrid(),
        
        const SizedBox(height: 100), // Bottom padding
      ]),
    );
  }

  Widget _buildSectionHeader(String title, {required IconData icon}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iOS18Theme.systemBlue,
        ),
        const SizedBox(width: iOS18Theme.spacing8),
        Text(
          title,
          style: iOS18Theme.title3.copyWith(
            color: iOS18Theme.label.resolveFrom(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            iOS18Theme.systemBlue,
            iOS18Theme.systemPurple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
        boxShadow: [
          BoxShadow(
            color: iOS18Theme.systemBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -50,
            top: -50,
            child: Icon(
              CupertinoIcons.chart_line,
              size: 200,
              color: CupertinoColors.white.withOpacity(0.1),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(iOS18Theme.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: iOS18Theme.spacing8,
                    vertical: iOS18Theme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
                  ),
                  child: Text(
                    'WIDGET OF THE DAY',
                    style: iOS18Theme.caption2.copyWith(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: iOS18Theme.spacing12),
                Text(
                  'AI Portfolio Optimizer',
                  style: iOS18Theme.title1.copyWith(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: iOS18Theme.spacing8),
                Text(
                  'Advanced ML-powered portfolio rebalancing with real-time market analysis',
                  style: iOS18Theme.footnote.copyWith(
                    color: CupertinoColors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.star_fill,
                      size: 16,
                      color: CupertinoColors.systemYellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.9',
                      style: iOS18Theme.footnote.copyWith(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: iOS18Theme.spacing16),
                    Icon(
                      CupertinoIcons.cloud_download,
                      size: 16,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '12.3K',
                      style: iOS18Theme.footnote.copyWith(
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorsList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _controller.popularCreators.length.clamp(0, 10),
        itemBuilder: (context, index) {
          final creator = _controller.popularCreators[index];
          return Padding(
            padding: EdgeInsets.only(
              right: iOS18Theme.spacing12,
            ),
            child: GestureDetector(
              onTap: () {
                iOS18Theme.lightImpact();
                Get.toNamed('/profile/${creator.id}');
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: iOS18Theme.systemBlue,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Container(
                        color: iOS18Theme.systemGray5.resolveFrom(context),
                        child: Icon(
                          CupertinoIcons.person_fill,
                          size: 30,
                          color: iOS18Theme.secondaryLabel.resolveFrom(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: iOS18Theme.spacing8),
                  Text(
                    creator.name ?? 'Creator',
                    style: iOS18Theme.caption1.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewReleasesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: iOS18Theme.spacing12,
        mainAxisSpacing: iOS18Theme.spacing12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(iOS18Theme.spacing12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.app_badge,
                  size: 30,
                  color: iOS18Theme.systemBlue,
                ),
                const Spacer(),
                Text(
                  'Widget ${index + 1}',
                  style: iOS18Theme.footnote.copyWith(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'New today',
                  style: iOS18Theme.caption2.copyWith(
                    color: iOS18Theme.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: iOS18Theme.systemBackground.resolveFrom(context),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Filters & Sorting'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Apply'),
              onPressed: () {
                iOS18Theme.mediumImpact();
                Navigator.pop(context);
              },
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(iOS18Theme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort by
                  Text(
                    'Sort By',
                    style: iOS18Theme.headline.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: iOS18Theme.spacing12),
                  ..._buildSortOptions(),
                  
                  const SizedBox(height: iOS18Theme.spacing24),
                  
                  // Price range
                  Text(
                    'Price Range',
                    style: iOS18Theme.headline.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: iOS18Theme.spacing12),
                  _buildPriceRangeSlider(),
                  
                  const SizedBox(height: iOS18Theme.spacing24),
                  
                  // Rating
                  Text(
                    'Minimum Rating',
                    style: iOS18Theme.headline.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: iOS18Theme.spacing12),
                  _buildRatingFilter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSortOptions() {
    final options = [
      {'value': 'popularity', 'label': 'Most Popular'},
      {'value': 'rating', 'label': 'Highest Rated'},
      {'value': 'newest', 'label': 'Newest First'},
      {'value': 'price_low', 'label': 'Price: Low to High'},
      {'value': 'price_high', 'label': 'Price: High to Low'},
    ];

    return options.map((option) {
      final isSelected = _selectedSortOption == option['value'];
      return GestureDetector(
        onTap: () {
          setState(() => _selectedSortOption = option['value'] as String);
          iOS18Theme.lightImpact();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: iOS18Theme.spacing8),
          padding: const EdgeInsets.all(iOS18Theme.spacing12),
          decoration: BoxDecoration(
            color: isSelected
                ? iOS18Theme.systemBlue.withOpacity(0.1)
                : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
            border: Border.all(
              color: isSelected
                  ? iOS18Theme.systemBlue
                  : iOS18Theme.separator.resolveFrom(context),
            ),
          ),
          child: Row(
            children: [
              Text(
                option['label'] as String,
                style: iOS18Theme.body.copyWith(
                  color: isSelected
                      ? iOS18Theme.systemBlue
                      : iOS18Theme.label.resolveFrom(context),
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: 20,
                  color: iOS18Theme.systemBlue,
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPriceRangeSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Free',
              style: iOS18Theme.caption1.copyWith(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
            ),
            Text(
              '\$100+',
              style: iOS18Theme.caption1.copyWith(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
            ),
          ],
        ),
        CupertinoSlider(
          value: 50,
          min: 0,
          max: 100,
          onChanged: (value) {
            // Handle price range change
          },
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Row(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: iOS18Theme.spacing8),
          child: Icon(
            index < 4 ? CupertinoIcons.star_fill : CupertinoIcons.star,
            size: 30,
            color: iOS18Theme.systemYellow,
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}