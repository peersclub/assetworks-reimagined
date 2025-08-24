import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class HomeWidgetExtraLarge {
  static const String widgetName = 'AssetWorksExtraLargeWidget';
  static const String widgetId = 'com.assetworks.widget.extralarge';
  static const platform = MethodChannel('com.assetworks.homewidget/extralarge');
  
  // Widget data keys - Extra large widget for iPad
  static const String keyPortfolioSummary = 'portfolio_summary_xl';
  static const String keyDetailedPositions = 'detailed_positions_xl';
  static const String keyMultiChart = 'multi_chart_xl';
  static const String keyMarketOverview = 'market_overview_xl';
  static const String keyNewsAnalysis = 'news_analysis_xl';
  static const String keyPerformanceMetrics = 'performance_metrics_xl';
  static const String keyWatchlistExtended = 'watchlist_extended_xl';
  static const String keyLastUpdate = 'last_update_xl';
  
  // Initialize extra large widget (iPad)
  static Future<void> initialize() async {
    try {
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId('group.com.assetworks.widgets');
      }
      
      await _registerWidget();
      await _setupDefaultData();
      print('Extra large home widget initialized');
    } catch (e) {
      print('Failed to initialize extra large widget: $e');
    }
  }
  
  // Register widget with system
  static Future<void> _registerWidget() async {
    try {
      await platform.invokeMethod('registerWidget', {
        'widgetId': widgetId,
        'widgetName': widgetName,
        'size': 'extralarge',
        'platform': 'iPad',
      });
    } catch (e) {
      print('Failed to register widget: $e');
    }
  }
  
  // Setup default widget data
  static Future<void> _setupDefaultData() async {
    await updateFullDashboard(
      portfolioSummary: PortfolioSummary.empty(),
      detailedPositions: [],
      multiChartData: MultiChartData.empty(),
      marketOverview: MarketOverview.empty(),
      newsAnalysis: [],
      performanceMetrics: PerformanceMetrics.empty(),
      watchlistExtended: [],
    );
  }
  
  // Update full dashboard data
  static Future<void> updateFullDashboard({
    required PortfolioSummary portfolioSummary,
    required List<DetailedPosition> detailedPositions,
    required MultiChartData multiChartData,
    required MarketOverview marketOverview,
    required List<NewsAnalysis> newsAnalysis,
    required PerformanceMetrics performanceMetrics,
    required List<ExtendedWatchlistItem> watchlistExtended,
  }) async {
    try {
      final data = {
        'portfolioSummary': portfolioSummary.toJson(),
        'detailedPositions': detailedPositions.map((p) => p.toJson()).toList(),
        'multiChartData': multiChartData.toJson(),
        'marketOverview': marketOverview.toJson(),
        'newsAnalysis': newsAnalysis.map((n) => n.toJson()).toList(),
        'performanceMetrics': performanceMetrics.toJson(),
        'watchlistExtended': watchlistExtended.map((w) => w.toJson()).toList(),
        'lastUpdate': DateTime.now().toIso8601String(),
      };
      
      // Save all data
      await HomeWidget.saveWidgetData<String>(
        keyPortfolioSummary,
        jsonEncode(portfolioSummary.toJson()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyDetailedPositions,
        jsonEncode(detailedPositions.map((p) => p.toJson()).toList()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyMultiChart,
        jsonEncode(multiChartData.toJson()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyMarketOverview,
        jsonEncode(marketOverview.toJson()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyNewsAnalysis,
        jsonEncode(newsAnalysis.map((n) => n.toJson()).toList()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyPerformanceMetrics,
        jsonEncode(performanceMetrics.toJson()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyWatchlistExtended,
        jsonEncode(watchlistExtended.map((w) => w.toJson()).toList()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyLastUpdate,
        DateTime.now().toIso8601String(),
      );
      
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
      );
      
      // Send update to native
      await platform.invokeMethod('updateFullDashboard', data);
    } catch (e) {
      print('Failed to update extra large widget data: $e');
    }
  }
  
  // Configure complex interactions
  static Future<void> configureComplexInteractions({
    required Map<String, Map<String, String>> sectionInteractions,
    required bool enableGestures,
    required bool enableDragAndDrop,
  }) async {
    try {
      await HomeWidget.registerInteractivityCallback(_handleComplexInteraction);
      
      await platform.invokeMethod('configureComplexInteractions', {
        'sectionInteractions': sectionInteractions,
        'enableGestures': enableGestures,
        'enableDragAndDrop': enableDragAndDrop,
      });
    } catch (e) {
      print('Failed to configure complex interactions: $e');
    }
  }
  
  // Handle complex widget interaction
  static Future<void> _handleComplexInteraction(Uri? uri) async {
    if (uri == null) return;
    
    print('Extra large widget interaction: $uri');
    
    final path = uri.path;
    final params = uri.queryParameters;
    final action = params['action'];
    
    switch (path) {
      case '/dashboard':
        final section = params['section'];
        // Handle dashboard section interaction
        break;
      case '/chart':
        final chartType = params['type'];
        final symbol = params['symbol'];
        // Handle chart interaction
        break;
      case '/position':
        final positionId = params['id'];
        if (action == 'trade') {
          // Open trade dialog
        } else if (action == 'details') {
          // Show position details
        }
        break;
      case '/news':
        final articleId = params['id'];
        if (action == 'read') {
          // Open full article
        } else if (action == 'share') {
          // Share article
        }
        break;
      default:
        // Default navigation
        break;
    }
  }
}

// Portfolio summary model for iPad
class PortfolioSummary {
  final double totalValue;
  final double dayChange;
  final double dayChangePercent;
  final double weekChange;
  final double weekChangePercent;
  final double monthChange;
  final double monthChangePercent;
  final double yearChange;
  final double yearChangePercent;
  final double cashBalance;
  final double investedAmount;
  final double totalGainLoss;
  final Map<String, double> allocation;
  
  PortfolioSummary({
    required this.totalValue,
    required this.dayChange,
    required this.dayChangePercent,
    required this.weekChange,
    required this.weekChangePercent,
    required this.monthChange,
    required this.monthChangePercent,
    required this.yearChange,
    required this.yearChangePercent,
    required this.cashBalance,
    required this.investedAmount,
    required this.totalGainLoss,
    required this.allocation,
  });
  
  factory PortfolioSummary.empty() {
    return PortfolioSummary(
      totalValue: 0,
      dayChange: 0,
      dayChangePercent: 0,
      weekChange: 0,
      weekChangePercent: 0,
      monthChange: 0,
      monthChangePercent: 0,
      yearChange: 0,
      yearChangePercent: 0,
      cashBalance: 0,
      investedAmount: 0,
      totalGainLoss: 0,
      allocation: {},
    );
  }
  
  Map<String, dynamic> toJson() => {
    'totalValue': totalValue,
    'dayChange': dayChange,
    'dayChangePercent': dayChangePercent,
    'weekChange': weekChange,
    'weekChangePercent': weekChangePercent,
    'monthChange': monthChange,
    'monthChangePercent': monthChangePercent,
    'yearChange': yearChange,
    'yearChangePercent': yearChangePercent,
    'cashBalance': cashBalance,
    'investedAmount': investedAmount,
    'totalGainLoss': totalGainLoss,
    'allocation': allocation,
  };
}

// Detailed position model
class DetailedPosition {
  final String id;
  final String symbol;
  final String name;
  final String sector;
  final double shares;
  final double avgCost;
  final double currentPrice;
  final double marketValue;
  final double dayChange;
  final double totalGainLoss;
  final double percentOfPortfolio;
  final Map<String, dynamic> metrics;
  final List<double> sparkline;
  
  DetailedPosition({
    required this.id,
    required this.symbol,
    required this.name,
    required this.sector,
    required this.shares,
    required this.avgCost,
    required this.currentPrice,
    required this.marketValue,
    required this.dayChange,
    required this.totalGainLoss,
    required this.percentOfPortfolio,
    required this.metrics,
    required this.sparkline,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'name': name,
    'sector': sector,
    'shares': shares,
    'avgCost': avgCost,
    'currentPrice': currentPrice,
    'marketValue': marketValue,
    'dayChange': dayChange,
    'totalGainLoss': totalGainLoss,
    'percentOfPortfolio': percentOfPortfolio,
    'metrics': metrics,
    'sparkline': sparkline,
  };
}

// Multi-chart data model
class MultiChartData {
  final Map<String, List<ChartDataPoint>> charts;
  final String primaryChart;
  final Map<String, ChartConfiguration> configurations;
  
  MultiChartData({
    required this.charts,
    required this.primaryChart,
    required this.configurations,
  });
  
  factory MultiChartData.empty() {
    return MultiChartData(
      charts: {},
      primaryChart: 'portfolio',
      configurations: {},
    );
  }
  
  Map<String, dynamic> toJson() => {
    'charts': charts.map((k, v) => MapEntry(k, v.map((p) => p.toJson()).toList())),
    'primaryChart': primaryChart,
    'configurations': configurations.map((k, v) => MapEntry(k, v.toJson())),
  };
}

// Chart data point
class ChartDataPoint {
  final DateTime timestamp;
  final double value;
  final double? volume;
  final double? high;
  final double? low;
  final double? open;
  final double? close;
  
  ChartDataPoint({
    required this.timestamp,
    required this.value,
    this.volume,
    this.high,
    this.low,
    this.open,
    this.close,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'value': value,
    'volume': volume,
    'high': high,
    'low': low,
    'open': open,
    'close': close,
  };
}

// Chart configuration
class ChartConfiguration {
  final String type;
  final String period;
  final bool showVolume;
  final bool showIndicators;
  final List<String> indicators;
  
  ChartConfiguration({
    required this.type,
    required this.period,
    required this.showVolume,
    required this.showIndicators,
    required this.indicators,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'period': period,
    'showVolume': showVolume,
    'showIndicators': showIndicators,
    'indicators': indicators,
  };
}

// Market overview model
class MarketOverview {
  final Map<String, IndexData> indices;
  final Map<String, SectorPerformance> sectors;
  final MarketSentiment sentiment;
  final Map<String, dynamic> globalMarkets;
  
  MarketOverview({
    required this.indices,
    required this.sectors,
    required this.sentiment,
    required this.globalMarkets,
  });
  
  factory MarketOverview.empty() {
    return MarketOverview(
      indices: {},
      sectors: {},
      sentiment: MarketSentiment.neutral(),
      globalMarkets: {},
    );
  }
  
  Map<String, dynamic> toJson() => {
    'indices': indices.map((k, v) => MapEntry(k, v.toJson())),
    'sectors': sectors.map((k, v) => MapEntry(k, v.toJson())),
    'sentiment': sentiment.toJson(),
    'globalMarkets': globalMarkets,
  };
}

// Index data
class IndexData {
  final String name;
  final double value;
  final double change;
  final double changePercent;
  final double dayHigh;
  final double dayLow;
  final double volume;
  
  IndexData({
    required this.name,
    required this.value,
    required this.change,
    required this.changePercent,
    required this.dayHigh,
    required this.dayLow,
    required this.volume,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'change': change,
    'changePercent': changePercent,
    'dayHigh': dayHigh,
    'dayLow': dayLow,
    'volume': volume,
  };
}

// Sector performance
class SectorPerformance {
  final String name;
  final double performance;
  final int gainers;
  final int losers;
  final double volume;
  
  SectorPerformance({
    required this.name,
    required this.performance,
    required this.gainers,
    required this.losers,
    required this.volume,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'performance': performance,
    'gainers': gainers,
    'losers': losers,
    'volume': volume,
  };
}

// Market sentiment
class MarketSentiment {
  final double bullishPercent;
  final double bearishPercent;
  final double neutralPercent;
  final String overall;
  
  MarketSentiment({
    required this.bullishPercent,
    required this.bearishPercent,
    required this.neutralPercent,
    required this.overall,
  });
  
  factory MarketSentiment.neutral() {
    return MarketSentiment(
      bullishPercent: 33.33,
      bearishPercent: 33.33,
      neutralPercent: 33.34,
      overall: 'neutral',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'bullishPercent': bullishPercent,
    'bearishPercent': bearishPercent,
    'neutralPercent': neutralPercent,
    'overall': overall,
  };
}

// News analysis model
class NewsAnalysis {
  final String id;
  final String title;
  final String summary;
  final String source;
  final DateTime publishedAt;
  final String sentiment;
  final double sentimentScore;
  final List<String> relatedSymbols;
  final Map<String, dynamic> impact;
  final String? imageUrl;
  
  NewsAnalysis({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.publishedAt,
    required this.sentiment,
    required this.sentimentScore,
    required this.relatedSymbols,
    required this.impact,
    this.imageUrl,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'source': source,
    'publishedAt': publishedAt.toIso8601String(),
    'sentiment': sentiment,
    'sentimentScore': sentimentScore,
    'relatedSymbols': relatedSymbols,
    'impact': impact,
    'imageUrl': imageUrl,
  };
}

// Performance metrics
class PerformanceMetrics {
  final double sharpeRatio;
  final double beta;
  final double alpha;
  final double standardDeviation;
  final double maxDrawdown;
  final double winRate;
  final Map<String, double> returns;
  
  PerformanceMetrics({
    required this.sharpeRatio,
    required this.beta,
    required this.alpha,
    required this.standardDeviation,
    required this.maxDrawdown,
    required this.winRate,
    required this.returns,
  });
  
  factory PerformanceMetrics.empty() {
    return PerformanceMetrics(
      sharpeRatio: 0,
      beta: 0,
      alpha: 0,
      standardDeviation: 0,
      maxDrawdown: 0,
      winRate: 0,
      returns: {},
    );
  }
  
  Map<String, dynamic> toJson() => {
    'sharpeRatio': sharpeRatio,
    'beta': beta,
    'alpha': alpha,
    'standardDeviation': standardDeviation,
    'maxDrawdown': maxDrawdown,
    'winRate': winRate,
    'returns': returns,
  };
}

// Extended watchlist item
class ExtendedWatchlistItem {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double volume;
  final double marketCap;
  final double peRatio;
  final double dividendYield;
  final double fiftyTwoWeekHigh;
  final double fiftyTwoWeekLow;
  final List<double> miniChart;
  final Map<String, dynamic> technicals;
  final bool hasAlert;
  final AlertConfiguration? alert;
  
  ExtendedWatchlistItem({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.marketCap,
    required this.peRatio,
    required this.dividendYield,
    required this.fiftyTwoWeekHigh,
    required this.fiftyTwoWeekLow,
    required this.miniChart,
    required this.technicals,
    required this.hasAlert,
    this.alert,
  });
  
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'price': price,
    'change': change,
    'changePercent': changePercent,
    'volume': volume,
    'marketCap': marketCap,
    'peRatio': peRatio,
    'dividendYield': dividendYield,
    'fiftyTwoWeekHigh': fiftyTwoWeekHigh,
    'fiftyTwoWeekLow': fiftyTwoWeekLow,
    'miniChart': miniChart,
    'technicals': technicals,
    'hasAlert': hasAlert,
    'alert': alert?.toJson(),
  };
}

// Alert configuration
class AlertConfiguration {
  final String type;
  final double targetPrice;
  final String condition;
  final bool enabled;
  
  AlertConfiguration({
    required this.type,
    required this.targetPrice,
    required this.condition,
    required this.enabled,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'targetPrice': targetPrice,
    'condition': condition,
    'enabled': enabled,
  };
}