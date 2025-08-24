import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class HomeWidgetLarge {
  static const String widgetName = 'AssetWorksLargeWidget';
  static const String widgetId = 'com.assetworks.widget.large';
  static const platform = MethodChannel('com.assetworks.homewidget/large');
  
  // Widget data keys
  static const String keyPortfolioValue = 'portfolio_value_large';
  static const String keyDayChange = 'day_change_large';
  static const String keyPositions = 'positions_large';
  static const String keyChart = 'chart_data_large';
  static const String keyIndices = 'indices_large';
  static const String keyNews = 'news_large';
  static const String keyLastUpdate = 'last_update_large';
  
  // Initialize large widget
  static Future<void> initialize() async {
    try {
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId('group.com.assetworks.widgets');
      }
      
      await _registerWidget();
      await _setupDefaultData();
      print('Large home widget initialized');
    } catch (e) {
      print('Failed to initialize large widget: $e');
    }
  }
  
  // Register widget with system
  static Future<void> _registerWidget() async {
    try {
      await platform.invokeMethod('registerWidget', {
        'widgetId': widgetId,
        'widgetName': widgetName,
        'size': 'large',
      });
    } catch (e) {
      print('Failed to register widget: $e');
    }
  }
  
  // Setup default widget data
  static Future<void> _setupDefaultData() async {
    await updateCompleteData(
      portfolioValue: 0.0,
      dayChange: 0.0,
      dayChangePercent: 0.0,
      positions: [],
      chartData: [],
      indices: [],
      news: [],
    );
  }
  
  // Update complete widget data
  static Future<void> updateCompleteData({
    required double portfolioValue,
    required double dayChange,
    required double dayChangePercent,
    required List<PortfolioPosition> positions,
    required List<ChartPoint> chartData,
    required List<MarketIndex> indices,
    required List<NewsItem> news,
  }) async {
    try {
      final data = {
        'portfolioValue': portfolioValue,
        'dayChange': dayChange,
        'dayChangePercent': dayChangePercent,
        'positions': positions.map((p) => p.toJson()).toList(),
        'chartData': chartData.map((c) => c.toJson()).toList(),
        'indices': indices.map((i) => i.toJson()).toList(),
        'news': news.map((n) => n.toJson()).toList(),
        'lastUpdate': DateTime.now().toIso8601String(),
      };
      
      // Save all data
      await HomeWidget.saveWidgetData<double>(keyPortfolioValue, portfolioValue);
      await HomeWidget.saveWidgetData<double>(keyDayChange, dayChange);
      await HomeWidget.saveWidgetData<String>(
        keyPositions,
        jsonEncode(positions.map((p) => p.toJson()).toList()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyChart,
        jsonEncode(chartData.map((c) => c.toJson()).toList()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyIndices,
        jsonEncode(indices.map((i) => i.toJson()).toList()),
      );
      await HomeWidget.saveWidgetData<String>(
        keyNews,
        jsonEncode(news.map((n) => n.toJson()).toList()),
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
      await platform.invokeMethod('updateData', data);
    } catch (e) {
      print('Failed to update large widget data: $e');
    }
  }
  
  // Update chart data only
  static Future<void> updateChartData(List<ChartPoint> chartData) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        keyChart,
        jsonEncode(chartData.map((c) => c.toJson()).toList()),
      );
      
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
      );
      
      await platform.invokeMethod('updateChart', {
        'chartData': chartData.map((c) => c.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to update chart data: $e');
    }
  }
  
  // Configure interactions
  static Future<void> configureInteractions({
    required Map<String, String> sectionActions,
    Map<String, String>? stockActions,
    Map<String, String>? newsActions,
  }) async {
    try {
      await HomeWidget.registerInteractivityCallback(_handleWidgetInteraction);
      
      await platform.invokeMethod('configureInteractions', {
        'sectionActions': sectionActions,
        'stockActions': stockActions,
        'newsActions': newsActions,
      });
    } catch (e) {
      print('Failed to configure interactions: $e');
    }
  }
  
  // Handle widget interaction
  static Future<void> _handleWidgetInteraction(Uri? uri) async {
    if (uri == null) return;
    
    print('Large widget interaction: $uri');
    
    final path = uri.path;
    final params = uri.queryParameters;
    
    switch (path) {
      case '/portfolio':
        // Navigate to portfolio
        break;
      case '/position':
        final symbol = params['symbol'];
        // Navigate to position details
        break;
      case '/news':
        final newsId = params['id'];
        // Open news article
        break;
      case '/chart':
        // Navigate to chart view
        break;
      default:
        // Default navigation
        break;
    }
  }
}

// Portfolio position model
class PortfolioPosition {
  final String symbol;
  final String name;
  final double shares;
  final double currentPrice;
  final double dayChange;
  final double dayChangePercent;
  final double totalValue;
  final double gainLoss;
  final double gainLossPercent;
  
  PortfolioPosition({
    required this.symbol,
    required this.name,
    required this.shares,
    required this.currentPrice,
    required this.dayChange,
    required this.dayChangePercent,
    required this.totalValue,
    required this.gainLoss,
    required this.gainLossPercent,
  });
  
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'shares': shares,
    'currentPrice': currentPrice,
    'dayChange': dayChange,
    'dayChangePercent': dayChangePercent,
    'totalValue': totalValue,
    'gainLoss': gainLoss,
    'gainLossPercent': gainLossPercent,
  };
}

// Chart point model
class ChartPoint {
  final DateTime timestamp;
  final double value;
  
  ChartPoint({
    required this.timestamp,
    required this.value,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'value': value,
  };
}

// Market index model
class MarketIndex {
  final String name;
  final String symbol;
  final double value;
  final double change;
  final double changePercent;
  
  MarketIndex({
    required this.name,
    required this.symbol,
    required this.value,
    required this.change,
    required this.changePercent,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'symbol': symbol,
    'value': value,
    'change': change,
    'changePercent': changePercent,
  };
}

// News item model
class NewsItem {
  final String id;
  final String title;
  final String summary;
  final String source;
  final DateTime publishedAt;
  final String? imageUrl;
  final String? url;
  
  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
    this.url,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'source': source,
    'publishedAt': publishedAt.toIso8601String(),
    'imageUrl': imageUrl,
    'url': url,
  };
}

// Large widget configuration
class LargeWidgetConfiguration {
  final bool showChart;
  final bool showPositions;
  final bool showIndices;
  final bool showNews;
  final String chartType; // 'line', 'candle', 'area'
  final String chartPeriod; // '1D', '1W', '1M', '3M', '1Y'
  final int maxPositions;
  final int maxNews;
  final bool autoRefresh;
  final int refreshIntervalMinutes;
  
  const LargeWidgetConfiguration({
    this.showChart = true,
    this.showPositions = true,
    this.showIndices = true,
    this.showNews = true,
    this.chartType = 'line',
    this.chartPeriod = '1D',
    this.maxPositions = 5,
    this.maxNews = 3,
    this.autoRefresh = true,
    this.refreshIntervalMinutes = 5,
  });
  
  Map<String, dynamic> toJson() => {
    'showChart': showChart,
    'showPositions': showPositions,
    'showIndices': showIndices,
    'showNews': showNews,
    'chartType': chartType,
    'chartPeriod': chartPeriod,
    'maxPositions': maxPositions,
    'maxNews': maxNews,
    'autoRefresh': autoRefresh,
    'refreshIntervalMinutes': refreshIntervalMinutes,
  };
  
  // Apply configuration
  Future<void> apply() async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'configuration_large',
        jsonEncode(toJson()),
      );
      await HomeWidget.updateWidget(
        name: HomeWidgetLarge.widgetName,
        iOSName: HomeWidgetLarge.widgetName,
      );
    } catch (e) {
      print('Failed to apply configuration: $e');
    }
  }
}