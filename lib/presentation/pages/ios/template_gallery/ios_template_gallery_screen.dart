import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../controllers/template_controller.dart';

class iOSTemplateGalleryScreen extends StatefulWidget {
  const iOSTemplateGalleryScreen({Key? key}) : super(key: key);

  @override
  State<iOSTemplateGalleryScreen> createState() => _iOSTemplateGalleryScreenState();
}

class _iOSTemplateGalleryScreenState extends State<iOSTemplateGalleryScreen>
    with TickerProviderStateMixin {
  final TemplateController _controller = Get.find<TemplateController>();
  final ScrollController _scrollController = ScrollController();
  
  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Categories
  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'All', 'icon': CupertinoIcons.square_grid_2x2},
    {'id': 'stocks', 'name': 'Stocks', 'icon': CupertinoIcons.chart_line},
    {'id': 'crypto', 'name': 'Crypto', 'icon': CupertinoIcons.bitcoin},
    {'id': 'portfolio', 'name': 'Portfolio', 'icon': CupertinoIcons.chart_pie_fill},
    {'id': 'analytics', 'name': 'Analytics', 'icon': CupertinoIcons.chart_bar_alt_fill},
    {'id': 'alerts', 'name': 'Alerts', 'icon': CupertinoIcons.bell},
  ];
  
  String _selectedCategory = 'all';
  String _selectedSort = 'popular';
  bool _showPremiumOnly = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadTemplates();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: iOS18Theme.springCurve,
    ));
    
    _animationController.forward();
    _cardAnimationController.forward();
  }

  Future<void> _loadTemplates() async {
    await _controller.loadTemplates(
      category: _selectedCategory,
      sort: _selectedSort,
      premiumOnly: _showPremiumOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.systemBackground.resolveFrom(context).withOpacity(0.94),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.arrow_left,
            color: iOS18Theme.label.resolveFrom(context),
          ),
        ),
        middle: const Text('Template Gallery'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            iOS18Theme.lightImpact();
            _showFilterOptions();
          },
          child: Icon(
            CupertinoIcons.slider_horizontal_3,
            size: 22,
            color: iOS18Theme.label.resolveFrom(context),
          ),
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Featured template
              SliverToBoxAdapter(
                child: _buildFeaturedTemplate(),
              ),
              
              // Category selector
              SliverToBoxAdapter(
                child: _buildCategorySelector(),
              ),
              
              // Templates grid
              SliverPadding(
                padding: const EdgeInsets.all(iOS18Theme.spacing16),
                sliver: Obx(() {
                  if (_controller.isLoading.value) {
                    return _buildLoadingGrid();
                  }
                  
                  if (_controller.templates.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    );
                  }
                  
                  return _buildTemplateGrid();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedTemplate() {
    return Container(
      margin: const EdgeInsets.all(iOS18Theme.spacing16),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            iOS18Theme.systemPurple,
            iOS18Theme.systemBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
        boxShadow: [
          BoxShadow(
            color: iOS18Theme.systemPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(
              CupertinoIcons.sparkles,
              size: 150,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.star_fill,
                        size: 12,
                        color: iOS18Theme.systemYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'FEATURED',
                        style: iOS18Theme.caption2.copyWith(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: iOS18Theme.spacing12),
                Text(
                  'Advanced Portfolio Tracker',
                  style: iOS18Theme.title1.copyWith(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: iOS18Theme.spacing8),
                Text(
                  'Professional portfolio management with real-time analytics, AI predictions, and risk assessment',
                  style: iOS18Theme.footnote.copyWith(
                    color: CupertinoColors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: iOS18Theme.spacing8,
                        vertical: iOS18Theme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: iOS18Theme.systemGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
                      ),
                      child: Text(
                        'NEW',
                        style: iOS18Theme.caption2.copyWith(
                          color: iOS18Theme.systemGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: iOS18Theme.spacing8),
                    Icon(
                      CupertinoIcons.cloud_download,
                      size: 16,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '5.2K',
                      style: iOS18Theme.caption1.copyWith(
                        color: CupertinoColors.white,
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: iOS18Theme.spacing16,
                        vertical: iOS18Theme.spacing8,
                      ),
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
                      onPressed: () {
                        iOS18Theme.mediumImpact();
                        _useTemplate('featured');
                      },
                      child: Text(
                        'Use Template',
                        style: iOS18Theme.footnote.copyWith(
                          color: iOS18Theme.systemPurple,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildCategorySelector() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['id'];
          
          return GestureDetector(
            onTap: () {
              iOS18Theme.lightImpact();
              setState(() => _selectedCategory = category['id'] as String);
              _loadTemplates();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              margin: const EdgeInsets.only(right: iOS18Theme.spacing12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? iOS18Theme.systemBlue
                          : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
                      borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
                      border: Border.all(
                        color: isSelected
                            ? iOS18Theme.systemBlue
                            : iOS18Theme.separator.resolveFrom(context),
                        width: isSelected ? 0 : 1,
                      ),
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      size: 28,
                      color: isSelected
                          ? CupertinoColors.white
                          : iOS18Theme.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: iOS18Theme.spacing8),
                  Text(
                    category['name'] as String,
                    style: iOS18Theme.caption1.copyWith(
                      color: isSelected
                          ? iOS18Theme.systemBlue
                          : iOS18Theme.label.resolveFrom(context),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: iOS18Theme.spacing12,
        mainAxisSpacing: iOS18Theme.spacing12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final template = _controller.templates[index];
          return ScaleTransition(
            scale: _scaleAnimation,
            child: _buildTemplateCard(template),
          );
        },
        childCount: _controller.templates.length,
      ),
    );
  }

  Widget _buildTemplateCard(dynamic template) {
    final isPremium = template.isPremium ?? false;
    
    return GestureDetector(
      onTap: () {
        iOS18Theme.lightImpact();
        _previewTemplate(template);
      },
      onLongPress: () {
        iOS18Theme.mediumImpact();
        _showTemplateOptions(template);
      },
      child: Container(
        decoration: BoxDecoration(
          color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
          border: isPremium
              ? Border.all(
                  color: iOS18Theme.systemYellow.withOpacity(0.5),
                  width: 2,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview image
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getTemplateGradient(template.category),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(iOS18Theme.largeRadius),
                  topRight: Radius.circular(iOS18Theme.largeRadius),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getCategoryIcon(template.category),
                      size: 50,
                      color: CupertinoColors.white.withOpacity(0.5),
                    ),
                  ),
                  if (isPremium)
                    Positioned(
                      top: iOS18Theme.spacing8,
                      right: iOS18Theme.spacing8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: iOS18Theme.spacing8,
                          vertical: iOS18Theme.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: iOS18Theme.systemYellow,
                          borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.star_fill,
                              size: 10,
                              color: CupertinoColors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'PRO',
                              style: iOS18Theme.caption2.copyWith(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Template info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(iOS18Theme.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name ?? 'Template',
                      style: iOS18Theme.footnote.copyWith(
                        color: iOS18Theme.label.resolveFrom(context),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: iOS18Theme.spacing4),
                    Text(
                      template.description ?? '',
                      style: iOS18Theme.caption2.copyWith(
                        color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.cloud_download,
                          size: 12,
                          color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          template.downloads ?? '0',
                          style: iOS18Theme.caption2.copyWith(
                            color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                          ),
                        ),
                        const SizedBox(width: iOS18Theme.spacing8),
                        Icon(
                          CupertinoIcons.star,
                          size: 12,
                          color: iOS18Theme.systemYellow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          template.rating ?? '0.0',
                          style: iOS18Theme.caption2.copyWith(
                            color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getTemplateGradient(String? category) {
    switch (category) {
      case 'stocks':
        return [iOS18Theme.systemBlue, iOS18Theme.systemBlue.withOpacity(0.6)];
      case 'crypto':
        return [iOS18Theme.systemOrange, iOS18Theme.systemOrange.withOpacity(0.6)];
      case 'portfolio':
        return [iOS18Theme.systemGreen, iOS18Theme.systemGreen.withOpacity(0.6)];
      case 'analytics':
        return [iOS18Theme.systemPurple, iOS18Theme.systemPurple.withOpacity(0.6)];
      case 'alerts':
        return [iOS18Theme.systemRed, iOS18Theme.systemRed.withOpacity(0.6)];
      default:
        return [iOS18Theme.systemGray, iOS18Theme.systemGray.withOpacity(0.6)];
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'stocks':
        return CupertinoIcons.chart_line;
      case 'crypto':
        return CupertinoIcons.bitcoin;
      case 'portfolio':
        return CupertinoIcons.chart_pie_fill;
      case 'analytics':
        return CupertinoIcons.chart_bar_alt_fill;
      case 'alerts':
        return CupertinoIcons.bell_fill;
      default:
        return CupertinoIcons.square_grid_2x2;
    }
  }

  Widget _buildLoadingGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: iOS18Theme.spacing12,
        mainAxisSpacing: iOS18Theme.spacing12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          decoration: BoxDecoration(
            color: iOS18Theme.systemGray6.resolveFrom(context),
            borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
          ),
        ),
        childCount: 6,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.doc_text,
            size: 60,
            color: iOS18Theme.tertiaryLabel.resolveFrom(context),
          ),
          const SizedBox(height: iOS18Theme.spacing20),
          Text(
            'No Templates Found',
            style: iOS18Theme.title3.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing8),
          Text(
            'Try adjusting your filters',
            style: iOS18Theme.body.copyWith(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  void _previewTemplate(dynamic template) {
    Get.toNamed('/template/preview/${template.id}');
  }

  void _useTemplate(String templateId) {
    Get.toNamed('/create', arguments: {'templateId': templateId});
  }

  void _showTemplateOptions(dynamic template) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(template.name ?? 'Template'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _previewTemplate(template);
            },
            child: const Text('Preview'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _useTemplate(template.id);
            },
            child: const Text('Use Template'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Share template
            },
            child: const Text('Share'),
          ),
          if (template.isPremium != true)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                // Save template
              },
              child: const Text('Save to Library'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: iOS18Theme.systemBackground.resolveFrom(context),
      builder: (context) => Container(
        height: 400,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Filter & Sort'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Apply'),
              onPressed: () {
                Navigator.pop(context);
                _loadTemplates();
              },
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(iOS18Theme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SORT BY',
                    style: iOS18Theme.caption1.copyWith(
                      color: iOS18Theme.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: iOS18Theme.spacing12),
                  _buildSortOption('Most Popular', 'popular'),
                  _buildSortOption('Newest', 'newest'),
                  _buildSortOption('Highest Rated', 'rating'),
                  _buildSortOption('Most Downloaded', 'downloads'),
                  
                  const SizedBox(height: iOS18Theme.spacing24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Premium Templates Only',
                        style: iOS18Theme.body.copyWith(
                          color: iOS18Theme.label.resolveFrom(context),
                        ),
                      ),
                      CupertinoSwitch(
                        value: _showPremiumOnly,
                        onChanged: (value) {
                          setState(() => _showPremiumOnly = value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value) {
    final isSelected = _selectedSort == value;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedSort = value);
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
              title,
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }
}