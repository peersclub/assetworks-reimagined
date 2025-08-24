import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../../core/services/home_widget_service.dart';
import '../../../controllers/widget_details_controller.dart';

class iOSWidgetDetailsScreen extends StatefulWidget {
  final String widgetId;
  
  const iOSWidgetDetailsScreen({
    Key? key,
    required this.widgetId,
  }) : super(key: key);

  @override
  State<iOSWidgetDetailsScreen> createState() => _iOSWidgetDetailsScreenState();
}

class _iOSWidgetDetailsScreenState extends State<iOSWidgetDetailsScreen>
    with TickerProviderStateMixin {
  final WidgetDetailsController _controller = Get.find<WidgetDetailsController>();
  final HomeWidgetService _homeWidgetService = HomeWidgetService.to;
  final ScrollController _scrollController = ScrollController();
  
  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Tab controller for time periods
  late TabController _tabController;
  final List<String> _timePeriods = ['1D', '1W', '1M', '3M', '6M', '1Y', 'All'];
  int _selectedPeriodIndex = 0;
  
  // Widget state
  bool _isFavorite = false;
  bool _isExpanded = false;
  bool _showIndicators = false;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _tabController = TabController(length: _timePeriods.length, vsync: this);
    _loadWidgetDetails();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: iOS18Theme.springCurve,
    ));
    
    _animationController.forward();
    _chartAnimationController.forward();
  }

  Future<void> _loadWidgetDetails() async {
    await _controller.loadWidgetDetails(widget.widgetId);
    setState(() {
      _isFavorite = _controller.currentWidget.value?.isFavorite ?? false;
    });
  }

  Future<void> _handleRefresh() async {
    iOS18Theme.mediumImpact();
    await _loadWidgetDetails();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.systemBackground.resolveFrom(context),
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
        middle: Obx(() => Text(
          _controller.currentWidget.value?.title ?? 'Widget Details',
          style: const TextStyle(fontSize: 17),
        )),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                iOS18Theme.lightImpact();
                setState(() => _isFavorite = !_isFavorite);
                _controller.toggleFavorite();
              },
              child: Icon(
                _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: 22,
                color: _isFavorite 
                    ? iOS18Theme.systemPink 
                    : iOS18Theme.label.resolveFrom(context),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                iOS18Theme.lightImpact();
                _showMoreOptions();
              },
              child: Icon(
                CupertinoIcons.ellipsis,
                size: 22,
                color: iOS18Theme.label.resolveFrom(context),
              ),
            ),
          ],
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
              // Pull to refresh
              CupertinoSliverRefreshControl(
                onRefresh: _handleRefresh,
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Obx(() {
                  if (_controller.isLoading.value) {
                    return _buildLoadingState();
                  }
                  
                  return _buildWidgetContent();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: const Center(
        child: CupertinoActivityIndicator(radius: 20),
      ),
    );
  }

  Widget _buildWidgetContent() {
    final widget = _controller.currentWidget.value;
    if (widget == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price header
        _buildPriceHeader(),
        
        // Time period selector
        _buildTimePeriodSelector(),
        
        // Chart
        _buildChart(),
        
        // Chart controls
        _buildChartControls(),
        
        // Key stats
        _buildKeyStats(),
        
        // Description
        _buildDescription(),
        
        // Technical indicators
        if (_showIndicators) _buildTechnicalIndicators(),
        
        // Related widgets
        _buildRelatedWidgets(),
        
        // Action buttons
        _buildActionButtons(),
        
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPriceHeader() {
    return Container(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AAPL',
            style: iOS18Theme.caption1.copyWith(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$178.45',
                style: iOS18Theme.largeTitle.copyWith(
                  color: iOS18Theme.label.resolveFrom(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: iOS18Theme.spacing12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: iOS18Theme.spacing8,
                  vertical: iOS18Theme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: iOS18Theme.systemGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.arrow_up_right,
                      size: 12,
                      color: iOS18Theme.systemGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+2.34 (1.33%)',
                      style: iOS18Theme.caption1.copyWith(
                        color: iOS18Theme.systemGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: iOS18Theme.spacing4),
          Text(
            'Last updated: 2 minutes ago',
            style: iOS18Theme.caption2.copyWith(
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodSelector() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timePeriods.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedPeriodIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: iOS18Theme.spacing8),
            child: GestureDetector(
              onTap: () {
                iOS18Theme.lightImpact();
                setState(() => _selectedPeriodIndex = index);
                _controller.loadChartData(_timePeriods[index]);
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
                ),
                child: Center(
                  child: Text(
                    _timePeriods[index],
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
    );
  }

  Widget _buildChart() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        height: 300,
        margin: const EdgeInsets.all(iOS18Theme.spacing16),
        padding: const EdgeInsets.all(iOS18Theme.spacing16),
        decoration: BoxDecoration(
          color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: iOS18Theme.separator.resolveFrom(context),
                  strokeWidth: 0.5,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final labels = ['9AM', '10AM', '11AM', '12PM', '1PM', '2PM', '3PM', '4PM'];
                    if (value.toInt() < labels.length) {
                      return Text(
                        labels[value.toInt()],
                        style: iOS18Theme.caption2.copyWith(
                          color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  reservedSize: 45,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toInt()}',
                      style: iOS18Theme.caption2.copyWith(
                        color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 7,
            minY: 170,
            maxY: 180,
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 175),
                  FlSpot(1, 176.5),
                  FlSpot(2, 174),
                  FlSpot(3, 177),
                  FlSpot(4, 178),
                  FlSpot(5, 177.5),
                  FlSpot(6, 178.45),
                  FlSpot(7, 178.45),
                ],
                isCurved: true,
                gradient: LinearGradient(
                  colors: [
                    iOS18Theme.systemBlue,
                    iOS18Theme.systemBlue.withOpacity(0.5),
                  ],
                ),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      iOS18Theme.systemBlue.withOpacity(0.3),
                      iOS18Theme.systemBlue.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
      child: Row(
        children: [
          _buildChartControlButton(
            icon: CupertinoIcons.chart_line,
            label: 'Line',
            isSelected: true,
            onTap: () {},
          ),
          const SizedBox(width: iOS18Theme.spacing8),
          _buildChartControlButton(
            icon: CupertinoIcons.chart_bar,
            label: 'Candle',
            isSelected: false,
            onTap: () {},
          ),
          const SizedBox(width: iOS18Theme.spacing8),
          _buildChartControlButton(
            icon: CupertinoIcons.layers,
            label: 'Volume',
            isSelected: false,
            onTap: () {},
          ),
          const Spacer(),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing12),
            onPressed: () {
              iOS18Theme.lightImpact();
              setState(() => _showIndicators = !_showIndicators);
            },
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.waveform,
                  size: 18,
                  color: _showIndicators
                      ? iOS18Theme.systemBlue
                      : iOS18Theme.secondaryLabel.resolveFrom(context),
                ),
                const SizedBox(width: 4),
                Text(
                  'Indicators',
                  style: iOS18Theme.caption1.copyWith(
                    color: _showIndicators
                        ? iOS18Theme.systemBlue
                        : iOS18Theme.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartControlButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        iOS18Theme.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: iOS18Theme.spacing12,
          vertical: iOS18Theme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? iOS18Theme.systemBlue.withOpacity(0.1)
              : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? iOS18Theme.systemBlue
                  : iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: iOS18Theme.caption1.copyWith(
                color: isSelected
                    ? iOS18Theme.systemBlue
                    : iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyStats() {
    return Container(
      margin: const EdgeInsets.all(iOS18Theme.spacing16),
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Statistics',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing16),
          Row(
            children: [
              Expanded(child: _buildStatItem('Open', '\$176.11')),
              Expanded(child: _buildStatItem('High', '\$178.99')),
            ],
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          Row(
            children: [
              Expanded(child: _buildStatItem('Low', '\$173.85')),
              Expanded(child: _buildStatItem('Volume', '52.3M')),
            ],
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          Row(
            children: [
              Expanded(child: _buildStatItem('Market Cap', '\$2.78T')),
              Expanded(child: _buildStatItem('P/E Ratio', '29.45')),
            ],
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          Row(
            children: [
              Expanded(child: _buildStatItem('52W High', '\$198.23')),
              Expanded(child: _buildStatItem('52W Low', '\$124.17')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: iOS18Theme.caption1.copyWith(
            color: iOS18Theme.secondaryLabel.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: iOS18Theme.body.copyWith(
            color: iOS18Theme.label.resolveFrom(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          AnimatedCrossFade(
            firstChild: Text(
              'Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. The company offers iPhone, Mac, iPad, and wearables, home, and accessories...',
              style: iOS18Theme.body.copyWith(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              'Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. The company offers iPhone, Mac, iPad, and wearables, home, and accessories. It also provides AppleCare support services; cloud services; and operates various platforms, including the App Store, that allow customers to discover and download applications and digital content.',
              style: iOS18Theme.body.copyWith(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Text(
              _isExpanded ? 'Show Less' : 'Show More',
              style: iOS18Theme.footnote.copyWith(
                color: iOS18Theme.systemBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalIndicators() {
    return Container(
      margin: const EdgeInsets.all(iOS18Theme.spacing16),
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Indicators',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing16),
          _buildIndicatorRow('RSI (14)', '58.23', 'Neutral'),
          _buildIndicatorRow('MACD', '1.45', 'Bullish'),
          _buildIndicatorRow('Moving Avg (50)', '\$175.30', 'Above'),
          _buildIndicatorRow('Moving Avg (200)', '\$168.50', 'Above'),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow(String name, String value, String signal) {
    Color signalColor;
    switch (signal.toLowerCase()) {
      case 'bullish':
      case 'above':
        signalColor = iOS18Theme.systemGreen;
        break;
      case 'bearish':
      case 'below':
        signalColor = iOS18Theme.systemRed;
        break;
      default:
        signalColor = iOS18Theme.systemOrange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: iOS18Theme.spacing12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: iOS18Theme.body.copyWith(
                color: iOS18Theme.label.resolveFrom(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: iOS18Theme.body.copyWith(
                color: iOS18Theme.label.resolveFrom(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: iOS18Theme.spacing8,
                vertical: iOS18Theme.spacing4,
              ),
              decoration: BoxDecoration(
                color: signalColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
              ),
              child: Text(
                signal,
                style: iOS18Theme.caption1.copyWith(
                  color: signalColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedWidgets() {
    return Container(
      margin: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Widgets',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: iOS18Theme.spacing12),
                  padding: const EdgeInsets.all(iOS18Theme.spacing12),
                  decoration: BoxDecoration(
                    color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
                    borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.chart_line,
                        size: 24,
                        color: iOS18Theme.systemBlue,
                      ),
                      const Spacer(),
                      Text(
                        'Tech Portfolio',
                        style: iOS18Theme.footnote.copyWith(
                          color: iOS18Theme.label.resolveFrom(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'FAANG stocks tracker',
                        style: iOS18Theme.caption2.copyWith(
                          color: iOS18Theme.secondaryLabel.resolveFrom(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Column(
        children: [
          CupertinoButton.filled(
            onPressed: () {
              iOS18Theme.mediumImpact();
              _addToHomeScreen();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.add_circled, size: 20),
                SizedBox(width: iOS18Theme.spacing8),
                Text('Add to Home Screen'),
              ],
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing12),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: () {
                    iOS18Theme.lightImpact();
                    _shareWidget();
                  },
                  padding: const EdgeInsets.symmetric(vertical: iOS18Theme.spacing12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.share,
                        size: 18,
                        color: iOS18Theme.systemBlue,
                      ),
                      const SizedBox(width: iOS18Theme.spacing8),
                      Text(
                        'Share',
                        style: iOS18Theme.body.copyWith(
                          color: iOS18Theme.systemBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: iOS18Theme.spacing12),
              Expanded(
                child: CupertinoButton(
                  onPressed: () {
                    iOS18Theme.lightImpact();
                    _duplicateWidget();
                  },
                  padding: const EdgeInsets.symmetric(vertical: iOS18Theme.spacing12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.doc_on_doc,
                        size: 18,
                        color: iOS18Theme.systemBlue,
                      ),
                      const SizedBox(width: iOS18Theme.spacing8),
                      Text(
                        'Duplicate',
                        style: iOS18Theme.body.copyWith(
                          color: iOS18Theme.systemBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _editWidget();
            },
            child: const Text('Edit Widget'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _setAlerts();
            },
            child: const Text('Set Price Alerts'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _exportData();
            },
            child: const Text('Export Data'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _deleteWidget();
            },
            isDestructiveAction: true,
            child: const Text('Delete Widget'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _addToHomeScreen() async {
    final success = await _homeWidgetService.requestPinWidget();
    if (success) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Widget added to home screen'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void _shareWidget() {
    // Implement share functionality
  }

  void _duplicateWidget() {
    // Implement duplicate functionality
  }

  void _editWidget() {
    Get.toNamed('/widget/${widget.widgetId}/edit');
  }

  void _setAlerts() {
    // Show alerts configuration
  }

  void _exportData() {
    // Export widget data
  }

  void _deleteWidget() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Widget?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteWidget();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _chartAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}