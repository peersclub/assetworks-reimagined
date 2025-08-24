import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/ios18_theme.dart';
import '../../../../core/services/dynamic_island_service.dart';

class iOSPlaygroundScreen extends StatefulWidget {
  const iOSPlaygroundScreen({super.key});

  @override
  State<iOSPlaygroundScreen> createState() => _iOSPlaygroundScreenState();
}

class _iOSPlaygroundScreenState extends State<iOSPlaygroundScreen>
    with TickerProviderStateMixin {
  late AnimationController _chartAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _chartAnimation;
  late Animation<double> _pulseAnimation;
  
  // Sandbox controls
  double _investmentAmount = 10000;
  double _monthlyContribution = 500;
  double _annualReturn = 8.5;
  int _yearsToInvest = 10;
  double _riskLevel = 0.5;
  
  // Portfolio allocation
  Map<String, double> _allocation = {
    'Stocks': 60,
    'Bonds': 25,
    'Real Estate': 10,
    'Commodities': 5,
  };
  
  // Calculation results
  double _futureValue = 0;
  double _totalContributions = 0;
  double _totalReturns = 0;
  List<FlSpot> _growthData = [];
  
  @override
  void initState() {
    super.initState();
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _calculateProjection();
    _chartAnimationController.forward();
  }
  
  @override
  void dispose() {
    _chartAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _calculateProjection() {
    _totalContributions = _investmentAmount + (_monthlyContribution * 12 * _yearsToInvest);
    
    // Calculate future value using compound interest formula with monthly contributions
    final monthlyRate = _annualReturn / 100 / 12;
    final months = _yearsToInvest * 12;
    
    // FV = P(1 + r)^n + PMT × (((1 + r)^n - 1) / r)
    _futureValue = _investmentAmount * math.pow(1 + monthlyRate, months) +
        _monthlyContribution * ((math.pow(1 + monthlyRate, months) - 1) / monthlyRate);
    
    _totalReturns = _futureValue - _totalContributions;
    
    // Generate growth data points
    _growthData = [];
    for (int year = 0; year <= _yearsToInvest; year++) {
      final monthsElapsed = year * 12;
      final value = _investmentAmount * math.pow(1 + monthlyRate, monthsElapsed) +
          _monthlyContribution * ((math.pow(1 + monthlyRate, monthsElapsed) - 1) / monthlyRate);
      _growthData.add(FlSpot(year.toDouble(), value));
    }
    
    setState(() {});
  }
  
  void _adjustAllocation(String category, double value) {
    setState(() {
      final oldValue = _allocation[category]!;
      final diff = value - oldValue;
      
      _allocation[category] = value;
      
      // Redistribute the difference among other categories
      final otherCategories = _allocation.keys.where((k) => k != category).toList();
      if (otherCategories.isNotEmpty) {
        final adjustment = -diff / otherCategories.length;
        for (final other in otherCategories) {
          _allocation[other] = (_allocation[other]! + adjustment).clamp(0, 100);
        }
      }
      
      // Ensure total is 100%
      final total = _allocation.values.reduce((a, b) => a + b);
      if (total != 100) {
        final scale = 100 / total;
        _allocation.forEach((key, value) {
          _allocation[key] = value * scale;
        });
      }
    });
  }
  
  void _randomizeScenario() {
    HapticFeedback.mediumImpact();
    final random = math.Random();
    
    setState(() {
      _investmentAmount = (random.nextDouble() * 50000 + 5000).roundToDouble();
      _monthlyContribution = (random.nextDouble() * 2000 + 100).roundToDouble();
      _annualReturn = random.nextDouble() * 15 + 3;
      _yearsToInvest = random.nextInt(25) + 5;
      _riskLevel = random.nextDouble();
      
      // Randomize allocation
      final values = List.generate(4, (_) => random.nextDouble());
      final sum = values.reduce((a, b) => a + b);
      final categories = _allocation.keys.toList();
      for (int i = 0; i < categories.length; i++) {
        _allocation[categories[i]] = (values[i] / sum * 100);
      }
      
      _calculateProjection();
    });
    
    _chartAnimationController.reset();
    _chartAnimationController.forward();
    
    DynamicIslandService.showAlert('Scenario randomized!');
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context).withOpacity(0.8),
        border: null,
        middle: const Text('Investment Playground'),
        previousPageTitle: 'Back',
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _randomizeScenario,
          child: Icon(
            CupertinoIcons.shuffle,
            color: iOS18Theme.systemBlue,
          ),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Results card
            SliverToBoxAdapter(
              child: _buildResultsCard(),
            ),
            
            // Growth chart
            SliverToBoxAdapter(
              child: _buildGrowthChart(),
            ),
            
            // Investment controls
            SliverToBoxAdapter(
              child: _buildControls(),
            ),
            
            // Portfolio allocation
            SliverToBoxAdapter(
              child: _buildAllocation(),
            ),
            
            // Risk meter
            SliverToBoxAdapter(
              child: _buildRiskMeter(),
            ),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultsCard() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  iOS18Theme.systemGreen,
                  iOS18Theme.systemTeal,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: iOS18Theme.systemGreen.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Future Value',
                  style: TextStyle(
                    color: CupertinoColors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${_futureValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildResultItem(
                      'Contributions',
                      '\$${_totalContributions.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      CupertinoColors.white.withOpacity(0.7),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: CupertinoColors.white.withOpacity(0.2),
                    ),
                    _buildResultItem(
                      'Returns',
                      '\$${_totalReturns.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      CupertinoColors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGrowthChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      height: 250,
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: AnimatedBuilder(
        animation: _chartAnimation,
        builder: (context, child) {
          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _futureValue / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: iOS18Theme.separator.resolveFrom(context),
                    strokeWidth: 0.5,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: _yearsToInvest / 4,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        'Y${value.toInt()}',
                        style: TextStyle(
                          color: iOS18Theme.secondaryLabel.resolveFrom(context),
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    interval: _futureValue / 4,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${(value / 1000).toStringAsFixed(0)}k',
                        style: TextStyle(
                          color: iOS18Theme.secondaryLabel.resolveFrom(context),
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: _yearsToInvest.toDouble(),
              minY: 0,
              maxY: _futureValue * 1.1,
              lineBarsData: [
                LineChartBarData(
                  spots: _growthData.map((spot) {
                    return FlSpot(spot.x, spot.y * _chartAnimation.value);
                  }).toList(),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      iOS18Theme.systemBlue,
                      iOS18Theme.systemIndigo,
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        iOS18Theme.systemBlue.withOpacity(0.3),
                        iOS18Theme.systemBlue.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      return LineTooltipItem(
                        'Year ${spot.x.toInt()}\n\$${spot.y.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        TextStyle(
                          color: iOS18Theme.label.resolveFrom(context),
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
                touchCallback: (_, __) => HapticFeedback.lightImpact(),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildControls() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Investment Parameters',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildSliderControl(
            'Initial Investment',
            '\$${_investmentAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            _investmentAmount,
            1000,
            100000,
            (value) {
              setState(() {
                _investmentAmount = value;
                _calculateProjection();
              });
            },
          ),
          
          _buildSliderControl(
            'Monthly Contribution',
            '\$${_monthlyContribution.toStringAsFixed(0)}',
            _monthlyContribution,
            0,
            5000,
            (value) {
              setState(() {
                _monthlyContribution = value;
                _calculateProjection();
              });
            },
          ),
          
          _buildSliderControl(
            'Annual Return',
            '${_annualReturn.toStringAsFixed(1)}%',
            _annualReturn,
            0,
            20,
            (value) {
              setState(() {
                _annualReturn = value;
                _calculateProjection();
              });
            },
          ),
          
          _buildSliderControl(
            'Years to Invest',
            '${_yearsToInvest} years',
            _yearsToInvest.toDouble(),
            1,
            30,
            (value) {
              setState(() {
                _yearsToInvest = value.toInt();
                _calculateProjection();
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSliderControl(
    String label,
    String value,
    double sliderValue,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: CupertinoSlider(
            value: sliderValue,
            min: min,
            max: max,
            onChanged: (value) {
              HapticFeedback.selectionFeedback();
              onChanged(value);
            },
            activeColor: iOS18Theme.systemBlue,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildAllocation() {
    final colors = [
      iOS18Theme.systemBlue,
      iOS18Theme.systemGreen,
      iOS18Theme.systemOrange,
      iOS18Theme.systemPurple,
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Allocation',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          ...List.generate(_allocation.length, (index) {
            final category = _allocation.keys.elementAt(index);
            final percentage = _allocation[category]!;
            final color = colors[index % colors.length];
            
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        color: iOS18Theme.label.resolveFrom(context),
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: iOS18Theme.secondaryLabel.resolveFrom(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: iOS18Theme.tertiarySystemGroupedBackground.resolveFrom(context),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildRiskMeter() {
    final riskLabel = _riskLevel < 0.33
        ? 'Conservative'
        : _riskLevel < 0.66
            ? 'Moderate'
            : 'Aggressive';
    
    final riskColor = _riskLevel < 0.33
        ? iOS18Theme.systemGreen
        : _riskLevel < 0.66
            ? iOS18Theme.systemOrange
            : iOS18Theme.systemRed;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Risk Level',
                style: TextStyle(
                  color: iOS18Theme.label.resolveFrom(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  riskLabel,
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 32,
            child: CupertinoSlider(
              value: _riskLevel,
              min: 0,
              max: 1,
              divisions: 100,
              onChanged: (value) {
                HapticFeedback.selectionFeedback();
                setState(() {
                  _riskLevel = value;
                });
              },
              activeColor: riskColor,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low Risk',
                style: TextStyle(
                  color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                  fontSize: 12,
                ),
              ),
              Text(
                'High Risk',
                style: TextStyle(
                  color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}