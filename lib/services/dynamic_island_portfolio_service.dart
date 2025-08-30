import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

class DynamicIslandPortfolioService {
  static const platform = MethodChannel('com.assetworks.dynamicisland/portfolio');
  static final DynamicIslandPortfolioService _instance = 
      DynamicIslandPortfolioService._internal();
  
  factory DynamicIslandPortfolioService() => _instance;
  DynamicIslandPortfolioService._internal();
  
  final _portfolioController = StreamController<PortfolioUpdate>.broadcast();
  Stream<PortfolioUpdate> get portfolioStream => _portfolioController.stream;
  
  Timer? _updateTimer;
  Timer? _marketDataTimer;
  PortfolioData? _currentPortfolio;
  List<StockPosition> _positions = [];
  List<WatchlistItem> _watchlist = [];
  
  // Initialize portfolio service
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializePortfolio');
      _startRealtimeUpdates();
      _listenToNativeUpdates();
      await _loadInitialData();
    } catch (e) {
      print('Failed to initialize Dynamic Island portfolio: $e');
    }
  }
  
  // Load initial portfolio data
  Future<void> _loadInitialData() async {
    _currentPortfolio = PortfolioData(
      totalValue: 125432.50,
      dayChange: 1234.56,
      dayChangePercent: 0.98,
      totalGainLoss: 15432.50,
      totalGainLossPercent: 14.23,
      cashBalance: 10000.00,
      investedAmount: 110000.00,
    );
    
    _positions = [
      StockPosition(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        shares: 100,
        avgPrice: 150.00,
        currentPrice: 189.45,
        dayChange: 2.34,
        dayChangePercent: 1.25,
        totalValue: 18945.00,
        gainLoss: 3945.00,
        gainLossPercent: 26.30,
      ),
      StockPosition(
        symbol: 'GOOGL',
        name: 'Alphabet Inc.',
        shares: 50,
        avgPrice: 120.00,
        currentPrice: 142.67,
        dayChange: -0.89,
        dayChangePercent: -0.62,
        totalValue: 7133.50,
        gainLoss: 1133.50,
        gainLossPercent: 18.89,
      ),
      StockPosition(
        symbol: 'MSFT',
        name: 'Microsoft Corp.',
        shares: 75,
        avgPrice: 320.00,
        currentPrice: 378.91,
        dayChange: 4.56,
        dayChangePercent: 1.22,
        totalValue: 28418.25,
        gainLoss: 4418.25,
        gainLossPercent: 18.41,
      ),
    ];
    
    _watchlist = [
      WatchlistItem(
        symbol: 'TSLA',
        name: 'Tesla Inc.',
        price: 245.67,
        dayChange: 5.43,
        dayChangePercent: 2.26,
        alertPrice: 250.00,
        hasAlert: true,
      ),
      WatchlistItem(
        symbol: 'AMZN',
        name: 'Amazon.com Inc.',
        price: 178.34,
        dayChange: -1.23,
        dayChangePercent: -0.69,
      ),
    ];
    
    await _updateDynamicIsland();
  }
  
  // Start realtime updates
  void _startRealtimeUpdates() {
    // Update portfolio every 5 seconds during market hours
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_isMarketOpen()) {
        _updatePortfolioData();
      }
    });
    
    // Update market data every second for live feel
    _marketDataTimer?.cancel();
    _marketDataTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isMarketOpen()) {
        _updateMarketPrices();
      }
    });
  }
  
  // Listen to native updates
  void _listenToNativeUpdates() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPositionTapped':
          final symbol = call.arguments as String;
          _handlePositionTap(symbol);
          break;
        case 'onWatchlistTapped':
          final symbol = call.arguments as String;
          _handleWatchlistTap(symbol);
          break;
        case 'onPortfolioExpanded':
          _handlePortfolioExpand();
          break;
        case 'onAlertTriggered':
          final data = call.arguments as Map<dynamic, dynamic>;
          _handleAlertTriggered(data);
          break;
      }
    });
  }
  
  // Update portfolio data
  Future<void> _updatePortfolioData() async {
    if (_currentPortfolio == null) return;
    
    // Simulate portfolio value changes
    final random = math.Random();
    final changePercent = (random.nextDouble() - 0.5) * 0.02; // ±1% change
    
    final oldValue = _currentPortfolio!.totalValue;
    final newValue = oldValue * (1 + changePercent);
    final dayChange = newValue - oldValue;
    
    _currentPortfolio = _currentPortfolio!.copyWith(
      totalValue: newValue,
      dayChange: _currentPortfolio!.dayChange + dayChange,
      dayChangePercent: (_currentPortfolio!.dayChange + dayChange) / oldValue * 100,
    );
    
    final update = PortfolioUpdate(
      type: UpdateType.portfolioValue,
      timestamp: DateTime.now(),
      data: _currentPortfolio!.toJson(),
    );
    
    _portfolioController.add(update);
    await _updateDynamicIsland();
  }
  
  // Update market prices
  Future<void> _updateMarketPrices() async {
    final random = math.Random();
    
    // Update positions
    for (var i = 0; i < _positions.length; i++) {
      final position = _positions[i];
      final priceChange = (random.nextDouble() - 0.5) * 0.001 * position.currentPrice;
      final newPrice = position.currentPrice + priceChange;
      
      _positions[i] = position.copyWith(
        currentPrice: newPrice,
        dayChange: position.dayChange + priceChange,
        dayChangePercent: (position.dayChange + priceChange) / position.currentPrice * 100,
        totalValue: newPrice * position.shares,
        gainLoss: (newPrice - position.avgPrice) * position.shares,
        gainLossPercent: (newPrice - position.avgPrice) / position.avgPrice * 100,
      );
      
      // Check for price alerts
      _checkPriceAlerts(position.symbol, newPrice);
    }
    
    // Update watchlist
    for (var i = 0; i < _watchlist.length; i++) {
      final item = _watchlist[i];
      final priceChange = (random.nextDouble() - 0.5) * 0.001 * item.price;
      final newPrice = item.price + priceChange;
      
      _watchlist[i] = item.copyWith(
        price: newPrice,
        dayChange: item.dayChange + priceChange,
        dayChangePercent: (item.dayChange + priceChange) / item.price * 100,
      );
      
      // Check watchlist alerts
      if (item.hasAlert && item.alertPrice != null) {
        _checkPriceAlerts(item.symbol, newPrice, alertPrice: item.alertPrice);
      }
    }
    
    await _updateDynamicIslandPrices();
  }
  
  // Update Dynamic Island
  Future<void> _updateDynamicIsland() async {
    if (_currentPortfolio == null) return;
    
    try {
      await platform.invokeMethod('updatePortfolio', {
        'portfolio': _currentPortfolio!.toJson(),
        'positions': _positions.map((p) => p.toJson()).toList(),
        'watchlist': _watchlist.map((w) => w.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to update Dynamic Island portfolio: $e');
    }
  }
  
  // Update Dynamic Island prices only
  Future<void> _updateDynamicIslandPrices() async {
    try {
      await platform.invokeMethod('updatePrices', {
        'positions': _positions.map((p) => {
          'symbol': p.symbol,
          'price': p.currentPrice,
          'change': p.dayChange,
          'changePercent': p.dayChangePercent,
        }).toList(),
        'watchlist': _watchlist.map((w) => {
          'symbol': w.symbol,
          'price': w.price,
          'change': w.dayChange,
          'changePercent': w.dayChangePercent,
        }).toList(),
      });
    } catch (e) {
      print('Failed to update Dynamic Island prices: $e');
    }
  }
  
  // Check price alerts
  void _checkPriceAlerts(String symbol, double currentPrice, {double? alertPrice}) {
    if (alertPrice != null) {
      if (currentPrice >= alertPrice) {
        _triggerAlert(symbol, currentPrice, alertPrice, 'above');
      } else if (currentPrice <= alertPrice) {
        _triggerAlert(symbol, currentPrice, alertPrice, 'below');
      }
    }
  }
  
  // Trigger price alert
  void _triggerAlert(String symbol, double currentPrice, double alertPrice, String direction) {
    platform.invokeMethod('triggerAlert', {
      'symbol': symbol,
      'currentPrice': currentPrice,
      'alertPrice': alertPrice,
      'direction': direction,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    HapticFeedback.heavyImpact();
  }
  
  // Handle position tap
  void _handlePositionTap(String symbol) {
    print('Position tapped: $symbol');
    // Navigate to position details
  }
  
  // Handle watchlist tap
  void _handleWatchlistTap(String symbol) {
    print('Watchlist item tapped: $symbol');
    // Navigate to stock details
  }
  
  // Handle portfolio expand
  void _handlePortfolioExpand() {
    print('Portfolio expanded in Dynamic Island');
    // Show expanded portfolio view
  }
  
  // Handle alert triggered
  void _handleAlertTriggered(Map<dynamic, dynamic> data) {
    final symbol = data['symbol'] as String;
    final price = data['price'] as double;
    print('Alert triggered for $symbol at \$$price');
  }
  
  // Check if market is open
  bool _isMarketOpen() {
    final now = DateTime.now();
    final easternTime = now.toUtc().add(const Duration(hours: -5)); // EST
    
    // Check if weekday (Monday = 1, Friday = 5)
    if (easternTime.weekday > 5) return false;
    
    // Check market hours (9:30 AM - 4:00 PM EST)
    final marketOpen = DateTime(easternTime.year, easternTime.month, easternTime.day, 9, 30);
    final marketClose = DateTime(easternTime.year, easternTime.month, easternTime.day, 16, 0);
    
    return easternTime.isAfter(marketOpen) && easternTime.isBefore(marketClose);
  }
  
  // Add position to portfolio
  Future<void> addPosition(StockPosition position) async {
    _positions.add(position);
    await _updateDynamicIsland();
  }
  
  // Remove position from portfolio
  Future<void> removePosition(String symbol) async {
    _positions.removeWhere((p) => p.symbol == symbol);
    await _updateDynamicIsland();
  }
  
  // Add to watchlist
  Future<void> addToWatchlist(WatchlistItem item) async {
    _watchlist.add(item);
    await _updateDynamicIsland();
  }
  
  // Remove from watchlist
  Future<void> removeFromWatchlist(String symbol) async {
    _watchlist.removeWhere((w) => w.symbol == symbol);
    await _updateDynamicIsland();
  }
  
  // Set price alert
  Future<void> setPriceAlert(String symbol, double alertPrice) async {
    final index = _watchlist.indexWhere((w) => w.symbol == symbol);
    if (index != -1) {
      _watchlist[index] = _watchlist[index].copyWith(
        alertPrice: alertPrice,
        hasAlert: true,
      );
      await _updateDynamicIsland();
    }
  }
  
  // Get current portfolio
  PortfolioData? get currentPortfolio => _currentPortfolio;
  
  // Get positions
  List<StockPosition> get positions => List.unmodifiable(_positions);
  
  // Get watchlist
  List<WatchlistItem> get watchlist => List.unmodifiable(_watchlist);
  
  // Dispose service
  void dispose() {
    _updateTimer?.cancel();
    _marketDataTimer?.cancel();
    _portfolioController.close();
  }
}

// Portfolio data model
class PortfolioData {
  final double totalValue;
  final double dayChange;
  final double dayChangePercent;
  final double totalGainLoss;
  final double totalGainLossPercent;
  final double cashBalance;
  final double investedAmount;
  
  PortfolioData({
    required this.totalValue,
    required this.dayChange,
    required this.dayChangePercent,
    required this.totalGainLoss,
    required this.totalGainLossPercent,
    required this.cashBalance,
    required this.investedAmount,
  });
  
  PortfolioData copyWith({
    double? totalValue,
    double? dayChange,
    double? dayChangePercent,
    double? totalGainLoss,
    double? totalGainLossPercent,
    double? cashBalance,
    double? investedAmount,
  }) {
    return PortfolioData(
      totalValue: totalValue ?? this.totalValue,
      dayChange: dayChange ?? this.dayChange,
      dayChangePercent: dayChangePercent ?? this.dayChangePercent,
      totalGainLoss: totalGainLoss ?? this.totalGainLoss,
      totalGainLossPercent: totalGainLossPercent ?? this.totalGainLossPercent,
      cashBalance: cashBalance ?? this.cashBalance,
      investedAmount: investedAmount ?? this.investedAmount,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'totalValue': totalValue,
    'dayChange': dayChange,
    'dayChangePercent': dayChangePercent,
    'totalGainLoss': totalGainLoss,
    'totalGainLossPercent': totalGainLossPercent,
    'cashBalance': cashBalance,
    'investedAmount': investedAmount,
  };
}

// Stock position model
class StockPosition {
  final String symbol;
  final String name;
  final double shares;
  final double avgPrice;
  final double currentPrice;
  final double dayChange;
  final double dayChangePercent;
  final double totalValue;
  final double gainLoss;
  final double gainLossPercent;
  
  StockPosition({
    required this.symbol,
    required this.name,
    required this.shares,
    required this.avgPrice,
    required this.currentPrice,
    required this.dayChange,
    required this.dayChangePercent,
    required this.totalValue,
    required this.gainLoss,
    required this.gainLossPercent,
  });
  
  StockPosition copyWith({
    String? symbol,
    String? name,
    double? shares,
    double? avgPrice,
    double? currentPrice,
    double? dayChange,
    double? dayChangePercent,
    double? totalValue,
    double? gainLoss,
    double? gainLossPercent,
  }) {
    return StockPosition(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      shares: shares ?? this.shares,
      avgPrice: avgPrice ?? this.avgPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      dayChange: dayChange ?? this.dayChange,
      dayChangePercent: dayChangePercent ?? this.dayChangePercent,
      totalValue: totalValue ?? this.totalValue,
      gainLoss: gainLoss ?? this.gainLoss,
      gainLossPercent: gainLossPercent ?? this.gainLossPercent,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'shares': shares,
    'avgPrice': avgPrice,
    'currentPrice': currentPrice,
    'dayChange': dayChange,
    'dayChangePercent': dayChangePercent,
    'totalValue': totalValue,
    'gainLoss': gainLoss,
    'gainLossPercent': gainLossPercent,
  };
}

// Watchlist item model
class WatchlistItem {
  final String symbol;
  final String name;
  final double price;
  final double dayChange;
  final double dayChangePercent;
  final double? alertPrice;
  final bool hasAlert;
  
  WatchlistItem({
    required this.symbol,
    required this.name,
    required this.price,
    required this.dayChange,
    required this.dayChangePercent,
    this.alertPrice,
    this.hasAlert = false,
  });
  
  WatchlistItem copyWith({
    String? symbol,
    String? name,
    double? price,
    double? dayChange,
    double? dayChangePercent,
    double? alertPrice,
    bool? hasAlert,
  }) {
    return WatchlistItem(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      dayChange: dayChange ?? this.dayChange,
      dayChangePercent: dayChangePercent ?? this.dayChangePercent,
      alertPrice: alertPrice ?? this.alertPrice,
      hasAlert: hasAlert ?? this.hasAlert,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'price': price,
    'dayChange': dayChange,
    'dayChangePercent': dayChangePercent,
    'alertPrice': alertPrice,
    'hasAlert': hasAlert,
  };
}

// Portfolio update model
class PortfolioUpdate {
  final UpdateType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  
  PortfolioUpdate({
    required this.type,
    required this.timestamp,
    required this.data,
  });
}

enum UpdateType {
  portfolioValue,
  positionChange,
  watchlistChange,
  priceAlert,
  marketStatus,
}