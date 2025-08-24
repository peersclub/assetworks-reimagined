import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class HomeWidgetMedium {
  static const String widgetName = 'AssetWorksMediumWidget';
  static const String widgetId = 'com.assetworks.widget.medium';
  static const platform = MethodChannel('com.assetworks.homewidget/medium');
  
  // Widget data keys
  static const String keyPortfolioValue = 'portfolio_value_medium';
  static const String keyDayChange = 'day_change_medium';
  static const String keyDayChangePercent = 'day_change_percent_medium';
  static const String keyTopMovers = 'top_movers_medium';
  static const String keyWatchlist = 'watchlist_medium';
  static const String keyMarketStatus = 'market_status_medium';
  static const String keyLastUpdate = 'last_update_medium';
  
  // Initialize medium widget
  static Future<void> initialize() async {
    try {
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId('group.com.assetworks.widgets');
      }
      
      await _registerWidget();
      await _setupDefaultData();
      print('Medium home widget initialized');
    } catch (e) {
      print('Failed to initialize medium widget: $e');
    }
  }
  
  // Register widget with system
  static Future<void> _registerWidget() async {
    try {
      await platform.invokeMethod('registerWidget', {
        'widgetId': widgetId,
        'widgetName': widgetName,
        'size': 'medium',
      });
    } catch (e) {
      print('Failed to register widget: $e');
    }
  }
  
  // Setup default widget data
  static Future<void> _setupDefaultData() async {
    await updatePortfolioData(
      portfolioValue: 0.0,
      dayChange: 0.0,
      dayChangePercent: 0.0,
      topMovers: [],
    );
  }
  
  // Update portfolio data with top movers
  static Future<void> updatePortfolioData({
    required double portfolioValue,
    required double dayChange,
    required double dayChangePercent,
    required List<StockMover> topMovers,
  }) async {
    try {
      await HomeWidget.saveWidgetData<double>(keyPortfolioValue, portfolioValue);
      await HomeWidget.saveWidgetData<double>(keyDayChange, dayChange);
      await HomeWidget.saveWidgetData<double>(keyDayChangePercent, dayChangePercent);
      await HomeWidget.saveWidgetData<String>(
        keyTopMovers,
        jsonEncode(topMovers.map((m) => m.toJson()).toList()),
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
      await platform.invokeMethod('updateData', {
        'portfolioValue': portfolioValue,
        'dayChange': dayChange,
        'dayChangePercent': dayChangePercent,
        'topMovers': topMovers.map((m) => m.toJson()).toList(),
        'lastUpdate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to update portfolio data: $e');
    }
  }
  
  // Update watchlist
  static Future<void> updateWatchlist(List<WatchlistStock> stocks) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        keyWatchlist,
        jsonEncode(stocks.map((s) => s.toJson()).toList()),
      );
      
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
      );
      
      await platform.invokeMethod('updateWatchlist', {
        'stocks': stocks.map((s) => s.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to update watchlist: $e');
    }
  }
  
  // Update market status
  static Future<void> updateMarketStatus({
    required bool isOpen,
    String? statusMessage,
    DateTime? nextEvent,
  }) async {
    try {
      final status = {
        'isOpen': isOpen,
        'message': statusMessage,
        'nextEvent': nextEvent?.toIso8601String(),
      };
      
      await HomeWidget.saveWidgetData<String>(
        keyMarketStatus,
        jsonEncode(status),
      );
      
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
      );
    } catch (e) {
      print('Failed to update market status: $e');
    }
  }
  
  // Configure widget interactions
  static Future<void> configureInteractions({
    required Map<String, String> stockTapActions,
    String? portfolioTapAction,
    String? watchlistTapAction,
  }) async {
    try {
      await HomeWidget.registerInteractivityCallback(_handleWidgetInteraction);
      
      await platform.invokeMethod('configureInteractions', {
        'stockTapActions': stockTapActions,
        'portfolioTapAction': portfolioTapAction,
        'watchlistTapAction': watchlistTapAction,
      });
    } catch (e) {
      print('Failed to configure interactions: $e');
    }
  }
  
  // Handle widget interaction
  static Future<void> _handleWidgetInteraction(Uri? uri) async {
    if (uri == null) return;
    
    print('Medium widget interaction: $uri');
    
    final path = uri.path;
    final params = uri.queryParameters;
    
    switch (path) {
      case '/stock':
        final symbol = params['symbol'];
        // Navigate to stock details
        break;
      case '/portfolio':
        // Navigate to portfolio
        break;
      case '/watchlist':
        // Navigate to watchlist
        break;
      default:
        // Default navigation
        break;
    }
  }
  
  // Request widget update
  static Future<void> requestUpdate() async {
    try {
      await HomeWidget.updateWidget(
        name: widgetName,
        iOSName: widgetName,
      );
    } catch (e) {
      print('Failed to request widget update: $e');
    }
  }
}

// Stock mover model
class StockMover {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final bool isGainer;
  
  StockMover({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.isGainer,
  });
  
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'price': price,
    'change': change,
    'changePercent': changePercent,
    'isGainer': isGainer,
  };
  
  factory StockMover.fromJson(Map<String, dynamic> json) {
    return StockMover(
      symbol: json['symbol'],
      name: json['name'],
      price: json['price'],
      change: json['change'],
      changePercent: json['changePercent'],
      isGainer: json['isGainer'],
    );
  }
}

// Watchlist stock model
class WatchlistStock {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final bool hasAlert;
  final double? alertPrice;
  
  WatchlistStock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    this.hasAlert = false,
    this.alertPrice,
  });
  
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'price': price,
    'change': change,
    'changePercent': changePercent,
    'hasAlert': hasAlert,
    'alertPrice': alertPrice,
  };
  
  factory WatchlistStock.fromJson(Map<String, dynamic> json) {
    return WatchlistStock(
      symbol: json['symbol'],
      name: json['name'],
      price: json['price'],
      change: json['change'],
      changePercent: json['changePercent'],
      hasAlert: json['hasAlert'] ?? false,
      alertPrice: json['alertPrice'],
    );
  }
}

// Medium widget configuration
class MediumWidgetConfiguration {
  final bool showPortfolioSummary;
  final bool showTopMovers;
  final bool showWatchlist;
  final bool showMarketStatus;
  final int maxStocksToShow;
  final String layout; // 'grid', 'list', 'mixed'
  final bool autoRefresh;
  final int refreshIntervalMinutes;
  
  const MediumWidgetConfiguration({
    this.showPortfolioSummary = true,
    this.showTopMovers = true,
    this.showWatchlist = false,
    this.showMarketStatus = true,
    this.maxStocksToShow = 3,
    this.layout = 'mixed',
    this.autoRefresh = true,
    this.refreshIntervalMinutes = 5,
  });
  
  Map<String, dynamic> toJson() => {
    'showPortfolioSummary': showPortfolioSummary,
    'showTopMovers': showTopMovers,
    'showWatchlist': showWatchlist,
    'showMarketStatus': showMarketStatus,
    'maxStocksToShow': maxStocksToShow,
    'layout': layout,
    'autoRefresh': autoRefresh,
    'refreshIntervalMinutes': refreshIntervalMinutes,
  };
  
  factory MediumWidgetConfiguration.fromJson(Map<String, dynamic> json) {
    return MediumWidgetConfiguration(
      showPortfolioSummary: json['showPortfolioSummary'] ?? true,
      showTopMovers: json['showTopMovers'] ?? true,
      showWatchlist: json['showWatchlist'] ?? false,
      showMarketStatus: json['showMarketStatus'] ?? true,
      maxStocksToShow: json['maxStocksToShow'] ?? 3,
      layout: json['layout'] ?? 'mixed',
      autoRefresh: json['autoRefresh'] ?? true,
      refreshIntervalMinutes: json['refreshIntervalMinutes'] ?? 5,
    );
  }
  
  // Apply configuration to widget
  Future<void> apply() async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'configuration_medium',
        jsonEncode(toJson()),
      );
      await HomeWidget.updateWidget(
        name: HomeWidgetMedium.widgetName,
        iOSName: HomeWidgetMedium.widgetName,
      );
    } catch (e) {
      print('Failed to apply configuration: $e');
    }
  }
}