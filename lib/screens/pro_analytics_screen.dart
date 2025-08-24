import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../services/api_service.dart';
import '../models/dashboard_widget.dart';

class ProAnalyticsScreen extends StatefulWidget {
  const ProAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<ProAnalyticsScreen> createState() => _ProAnalyticsScreenState();
}

class _ProAnalyticsScreenState extends State<ProAnalyticsScreen> 
    with TickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final ScrollController _scrollController = ScrollController();
  
  // Animation Controllers
  late AnimationController _mainAnimationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  // Data
  Map<String, dynamic> _analyticsData = {};
  List<Map<String, dynamic>> _performanceMetrics = [];
  List<Map<String, dynamic>> _widgetPerformance = [];
  List<Map<String, dynamic>> _userEngagement = [];
  
  // Filters
  String _selectedTimeRange = '7d';
  String _selectedMetric = 'views';
  bool _showComparison = false;
  
  bool _isLoading = true;
  
  final Map<String, String> _timeRanges = {
    '24h': '24 Hours',
    '7d': '7 Days',
    '30d': '30 Days',
    '90d': '3 Months',
    '1y': '1 Year',
  };
  
  final Map<String, Map<String, dynamic>> _metrics = {
    'views': {'name': 'Views', 'icon': CupertinoIcons.eye_fill, 'color': CupertinoColors.systemBlue},
    'likes': {'name': 'Likes', 'icon': CupertinoIcons.heart_fill, 'color': CupertinoColors.systemRed},
    'shares': {'name': 'Shares', 'icon': CupertinoIcons.share_solid, 'color': CupertinoColors.systemGreen},
    'engagement': {'name': 'Engagement', 'icon': CupertinoIcons.chart_bar_alt_fill, 'color': CupertinoColors.systemPurple},
    'revenue': {'name': 'Revenue', 'icon': CupertinoIcons.money_dollar_circle_fill, 'color': CupertinoColors.systemOrange},
  };
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAnalytics();
  }
  
  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _chartAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _mainAnimationController.forward();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _mainAnimationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    try {
      // Fetch real widgets data
      final widgets = await _apiService.fetchDashboardWidgets(
        page: 1,
        limit: 20,
      );
      
      // Generate analytics data
      _generateAnalyticsData(widgets);
      
      setState(() => _isLoading = false);
      
      _chartAnimationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  void _generateAnalyticsData(List<DashboardWidget> widgets) {
    // Generate time series data
    final now = DateTime.now();
    final dataPoints = <Map<String, dynamic>>[];
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      dataPoints.add({
        'date': date,
        'views': (math.Random().nextInt(500) + 100),
        'likes': (math.Random().nextInt(100) + 20),
        'shares': (math.Random().nextInt(50) + 10),
        'engagement': (math.Random().nextDouble() * 10 + 2).toStringAsFixed(1),
        'revenue': (math.Random().nextDouble() * 500 + 100).toStringAsFixed(2),
      });
    }
    
    // Calculate totals and growth
    final totalViews = dataPoints.fold<int>(0, (sum, d) => sum + (d['views'] as int));
    final totalLikes = dataPoints.fold<int>(0, (sum, d) => sum + (d['likes'] as int));
    final totalShares = dataPoints.fold<int>(0, (sum, d) => sum + (d['shares'] as int));
    
    // Widget performance
    _widgetPerformance = widgets.take(5).map((widget) => {
      'widget': widget,
      'views': math.Random().nextInt(1000) + 100,
      'likes': math.Random().nextInt(200) + 20,
      'engagement_rate': (math.Random().nextDouble() * 15 + 2).toStringAsFixed(1),
      'trend': math.Random().nextBool() ? 'up' : 'down',
      'trend_value': (math.Random().nextDouble() * 20).toStringAsFixed(1),
    }).toList();
    
    // User engagement data
    _userEngagement = [
      {'hour': 0, 'engagement': 20},
      {'hour': 6, 'engagement': 35},
      {'hour': 9, 'engagement': 80},
      {'hour': 12, 'engagement': 95},
      {'hour': 15, 'engagement': 75},
      {'hour': 18, 'engagement': 90},
      {'hour': 21, 'engagement': 60},
      {'hour': 23, 'engagement': 25},
    ];
    
    _analyticsData = {
      'total_views': totalViews,
      'total_likes': totalLikes,
      'total_shares': totalShares,
      'avg_engagement': (totalLikes / totalViews * 100).toStringAsFixed(1),
      'growth_rate': '+${(math.Random().nextDouble() * 30).toStringAsFixed(1)}%',
      'time_series': dataPoints,
      'top_category': 'Investment',
      'peak_hour': '9:00 PM',
      'best_day': 'Friday',
    };
    
    // Performance metrics
    _performanceMetrics = [
      {
        'name': 'Load Time',
        'value': '1.2s',
        'status': 'good',
        'change': '-0.3s',
      },
      {
        'name': 'Crash Rate',
        'value': '0.02%',
        'status': 'excellent',
        'change': '-0.01%',
      },
      {
        'name': 'API Latency',
        'value': '45ms',
        'status': 'good',
        'change': '+5ms',
      },
      {
        'name': 'User Retention',
        'value': '78%',
        'status': 'good',
        'change': '+3%',
      },
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Navigation Bar
          CupertinoSliverNavigationBar(
            largeTitle: Text('Analytics Pro'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.gear_solid),
              onPressed: _showSettings,
            ),
          ),
          
          if (_isLoading)
            SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            )
          else ...[
            // Time Range Selector
            SliverToBoxAdapter(
              child: Container(
                height: 44,
                margin: EdgeInsets.symmetric(vertical: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _timeRanges.length,
                  itemBuilder: (context, index) {
                    final key = _timeRanges.keys.elementAt(index);
                    final isSelected = _selectedTimeRange == key;
                    
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        color: isSelected
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(22),
                        onPressed: () {
                          setState(() => _selectedTimeRange = key);
                          _loadAnalytics();
                        },
                        child: Text(
                          _timeRanges[key]!,
                          style: TextStyle(
                            color: isSelected
                                ? CupertinoColors.white
                                : CupertinoColors.label,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Key Metrics Cards
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: _buildKeyMetrics(),
                    ),
                  );
                },
              ),
            ),
            
            // Main Chart
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _chartAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _chartAnimationController,
                    child: _buildMainChart(),
                  );
                },
              ),
            ),
            
            // Widget Performance
            SliverToBoxAdapter(
              child: _buildWidgetPerformance(),
            ),
            
            // Engagement Heatmap
            SliverToBoxAdapter(
              child: _buildEngagementHeatmap(),
            ),
            
            // Performance Metrics
            SliverToBoxAdapter(
              child: _buildPerformanceMetrics(),
            ),
            
            // Insights & Recommendations
            SliverToBoxAdapter(
              child: _buildInsights(),
            ),
            
            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildKeyMetrics() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _metrics.length,
        itemBuilder: (context, index) {
          final key = _metrics.keys.elementAt(index);
          final metric = _metrics[key]!;
          final value = key == 'views' ? _analyticsData['total_views'] :
                       key == 'likes' ? _analyticsData['total_likes'] :
                       key == 'shares' ? _analyticsData['total_shares'] :
                       key == 'engagement' ? '${_analyticsData['avg_engagement']}%' :
                       '\$${(math.Random().nextDouble() * 5000).toStringAsFixed(2)}';
          
          return Container(
            width: 140,
            margin: EdgeInsets.only(right: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (metric['color'] as Color).withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      metric['icon'],
                      size: 20,
                      color: metric['color'],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+12%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      metric['name'],
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMainChart() {
    final timeSeriesData = _analyticsData['time_series'] as List<Map<String, dynamic>>? ?? [];
    if (timeSeriesData.isEmpty) return SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      height: 300,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.arrow_2_circlepath,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _showComparison = !_showComparison);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: CupertinoColors.systemGrey5,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < timeSeriesData.length) {
                          final date = timeSeriesData[value.toInt()]['date'] as DateTime;
                          return Text(
                            '${date.day}/${date.month}',
                            style: TextStyle(
                              fontSize: 10,
                              color: CupertinoColors.systemGrey,
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 200,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.systemGrey,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: timeSeriesData.length - 1.0,
                minY: 0,
                maxY: 600,
                lineBarsData: [
                  LineChartBarData(
                    spots: timeSeriesData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value[_selectedMetric] ?? 0).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.activeBlue,
                        CupertinoColors.systemIndigo,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.activeBlue.withOpacity(0.2),
                          CupertinoColors.systemIndigo.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  if (_showComparison)
                    LineChartBarData(
                      spots: timeSeriesData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value[_selectedMetric] ?? 0).toDouble() * 0.8,
                        );
                      }).toList(),
                      isCurved: true,
                      color: CupertinoColors.systemGrey3,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWidgetPerformance() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Top Performing Widgets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._widgetPerformance.map((perf) {
            final widget = perf['widget'] as DashboardWidget;
            final isUp = perf['trend'] == 'up';
            
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Widget Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.title?.substring(0, 1).toUpperCase() ?? 'W',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Widget Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title ?? 'Untitled',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildMiniStat('Views', perf['views'].toString()),
                            const SizedBox(width: 16),
                            _buildMiniStat('Likes', perf['likes'].toString()),
                            const SizedBox(width: 16),
                            _buildMiniStat('Rate', '${perf['engagement_rate']}%'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Trend
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUp
                          ? CupertinoColors.systemGreen.withOpacity(0.1)
                          : CupertinoColors.systemRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isUp
                              ? CupertinoIcons.arrow_up_right
                              : CupertinoIcons.arrow_down_right,
                          size: 12,
                          color: isUp
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.systemRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${perf['trend_value']}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isUp
                                ? CupertinoColors.systemGreen
                                : CupertinoColors.systemRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEngagementHeatmap() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF6B6B).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Engagement Heatmap',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Peak activity: ${_analyticsData['peak_hour'] ?? '9:00 PM'}',
            style: TextStyle(
              color: CupertinoColors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Heatmap Grid
          Container(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _userEngagement.map((data) {
                final intensity = (data['engagement'] as int) / 100;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(intensity * 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 60 * intensity,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: CupertinoColors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4),
                          child: Text(
                            '${data['hour']}',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceMetrics() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _performanceMetrics.length,
            itemBuilder: (context, index) {
              final metric = _performanceMetrics[index];
              final statusColor = metric['status'] == 'excellent'
                  ? CupertinoColors.systemGreen
                  : metric['status'] == 'good'
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.systemOrange;
              
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            metric['name'],
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      metric['value'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      metric['change'],
                      style: TextStyle(
                        fontSize: 12,
                        color: metric['change'].toString().startsWith('+')
                            ? CupertinoColors.systemRed
                            : CupertinoColors.systemGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsights() {
    final insights = [
      {
        'icon': CupertinoIcons.lightbulb_fill,
        'title': 'Optimal Posting Time',
        'description': 'Your audience is most active at 9 PM. Schedule posts during this time for maximum engagement.',
        'color': CupertinoColors.systemYellow,
      },
      {
        'icon': CupertinoIcons.rocket_fill,
        'title': 'Growing Category',
        'description': 'Investment widgets show 45% growth this week. Consider creating more content in this category.',
        'color': CupertinoColors.systemPurple,
      },
      {
        'icon': CupertinoIcons.chart_bar_alt_fill,
        'title': 'Engagement Opportunity',
        'description': 'Friday shows highest engagement. Launch new widgets on Fridays for better visibility.',
        'color': CupertinoColors.systemGreen,
      },
    ];
    
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Insights & Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (insight['color'] as Color).withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (insight['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        insight['icon'] as IconData,
                        color: insight['color'] as Color,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight['title'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insight['description'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.systemGrey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  void _showSettings() {
    HapticFeedback.lightImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Analytics Settings'),
        actions: [
          CupertinoActionSheetAction(
            child: Text('Export Report'),
            onPressed: () {
              Navigator.pop(context);
              // Export functionality
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Schedule Reports'),
            onPressed: () {
              Navigator.pop(context);
              // Schedule functionality
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Customize Dashboard'),
            onPressed: () {
              Navigator.pop(context);
              // Customize functionality
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}