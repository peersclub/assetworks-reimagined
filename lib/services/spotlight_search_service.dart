import 'package:flutter/services.dart';
import 'dart:async';

class SpotlightSearchService {
  static const platform = MethodChannel('com.assetworks.spotlight');
  static final SpotlightSearchService _instance = SpotlightSearchService._internal();
  
  factory SpotlightSearchService() => _instance;
  SpotlightSearchService._internal();
  
  final _searchController = StreamController<SpotlightSearchEvent>.broadcast();
  Stream<SpotlightSearchEvent> get searchStream => _searchController.stream;
  
  // Initialize Spotlight Search
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeSpotlightSearch');
      _listenToSearchEvents();
      await _indexDefaultContent();
    } catch (e) {
      print('Failed to initialize Spotlight Search: $e');
    }
  }
  
  // Index searchable item
  Future<void> indexSearchableItem({
    required SpotlightItem item,
  }) async {
    try {
      await platform.invokeMethod('indexSearchableItem', item.toJson());
    } catch (e) {
      print('Failed to index searchable item: $e');
    }
  }
  
  // Index multiple items
  Future<void> indexSearchableItems({
    required List<SpotlightItem> items,
  }) async {
    try {
      await platform.invokeMethod('indexSearchableItems', {
        'items': items.map((i) => i.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to index searchable items: $e');
    }
  }
  
  // Index default content
  Future<void> _indexDefaultContent() async {
    final items = [
      SpotlightItem(
        uniqueIdentifier: 'portfolio_overview',
        domainIdentifier: 'com.assetworks.portfolio',
        title: 'Portfolio Overview',
        contentDescription: 'View your investment portfolio performance and holdings',
        keywords: ['portfolio', 'investments', 'stocks', 'holdings', 'performance'],
        thumbnailData: null,
        userInfo: {'screen': 'portfolio'},
        expirationDate: null,
      ),
      SpotlightItem(
        uniqueIdentifier: 'trade_stocks',
        domainIdentifier: 'com.assetworks.trade',
        title: 'Trade Stocks',
        contentDescription: 'Buy and sell stocks quickly',
        keywords: ['trade', 'buy', 'sell', 'stocks', 'trading'],
        thumbnailData: null,
        userInfo: {'screen': 'trade'},
        expirationDate: null,
      ),
      SpotlightItem(
        uniqueIdentifier: 'watchlist',
        domainIdentifier: 'com.assetworks.watchlist',
        title: 'Stock Watchlist',
        contentDescription: 'Monitor your favorite stocks',
        keywords: ['watchlist', 'favorites', 'monitor', 'track'],
        thumbnailData: null,
        userInfo: {'screen': 'watchlist'},
        expirationDate: null,
      ),
      SpotlightItem(
        uniqueIdentifier: 'market_news',
        domainIdentifier: 'com.assetworks.news',
        title: 'Market News',
        contentDescription: 'Latest financial news and market updates',
        keywords: ['news', 'market', 'financial', 'updates', 'headlines'],
        thumbnailData: null,
        userInfo: {'screen': 'news'},
        expirationDate: null,
      ),
    ];
    
    await indexSearchableItems(items: items);
  }
  
  // Index stock
  Future<void> indexStock({
    required String symbol,
    required String companyName,
    required double price,
    required double changePercent,
    required String? description,
  }) async {
    final item = SpotlightItem(
      uniqueIdentifier: 'stock_$symbol',
      domainIdentifier: 'com.assetworks.stocks',
      title: '$symbol - $companyName',
      contentDescription: description ?? 'Stock price: \$$price (${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%)',
      keywords: [symbol, companyName, 'stock', 'equity'],
      thumbnailData: null,
      userInfo: {
        'type': 'stock',
        'symbol': symbol,
        'price': price,
      },
      expirationDate: DateTime.now().add(const Duration(days: 1)),
    );
    
    await indexSearchableItem(item: item);
  }
  
  // Index transaction
  Future<void> indexTransaction({
    required String transactionId,
    required String type,
    required String symbol,
    required double quantity,
    required double price,
    required DateTime date,
  }) async {
    final item = SpotlightItem(
      uniqueIdentifier: 'transaction_$transactionId',
      domainIdentifier: 'com.assetworks.transactions',
      title: '$type $symbol',
      contentDescription: '$quantity shares at \$$price on ${date.toString().split(' ')[0]}',
      keywords: [type, symbol, 'transaction', 'trade', 'history'],
      thumbnailData: null,
      userInfo: {
        'type': 'transaction',
        'transactionId': transactionId,
        'symbol': symbol,
      },
      expirationDate: null,
    );
    
    await indexSearchableItem(item: item);
  }
  
  // Index news article
  Future<void> indexNewsArticle({
    required String articleId,
    required String title,
    required String summary,
    required String source,
    required DateTime publishedDate,
    required List<String> relatedSymbols,
  }) async {
    final item = SpotlightItem(
      uniqueIdentifier: 'news_$articleId',
      domainIdentifier: 'com.assetworks.news',
      title: title,
      contentDescription: summary,
      keywords: ['news', source, ...relatedSymbols],
      thumbnailData: null,
      userInfo: {
        'type': 'news',
        'articleId': articleId,
        'source': source,
      },
      expirationDate: DateTime.now().add(const Duration(days: 7)),
    );
    
    await indexSearchableItem(item: item);
  }
  
  // Update searchable item
  Future<void> updateSearchableItem({
    required String uniqueIdentifier,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await platform.invokeMethod('updateSearchableItem', {
        'uniqueIdentifier': uniqueIdentifier,
        'updates': updates,
      });
    } catch (e) {
      print('Failed to update searchable item: $e');
    }
  }
  
  // Delete searchable item
  Future<void> deleteSearchableItem(String uniqueIdentifier) async {
    try {
      await platform.invokeMethod('deleteSearchableItem', {
        'uniqueIdentifier': uniqueIdentifier,
      });
    } catch (e) {
      print('Failed to delete searchable item: $e');
    }
  }
  
  // Delete searchable items with identifiers
  Future<void> deleteSearchableItems(List<String> identifiers) async {
    try {
      await platform.invokeMethod('deleteSearchableItems', {
        'identifiers': identifiers,
      });
    } catch (e) {
      print('Failed to delete searchable items: $e');
    }
  }
  
  // Delete all searchable items in domain
  Future<void> deleteAllItemsInDomain(String domainIdentifier) async {
    try {
      await platform.invokeMethod('deleteAllItemsInDomain', {
        'domainIdentifier': domainIdentifier,
      });
    } catch (e) {
      print('Failed to delete items in domain: $e');
    }
  }
  
  // Delete all searchable items
  Future<void> deleteAllSearchableItems() async {
    try {
      await platform.invokeMethod('deleteAllSearchableItems');
    } catch (e) {
      print('Failed to delete all searchable items: $e');
    }
  }
  
  // Listen to search events
  void _listenToSearchEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onSearchItemTapped':
          final identifier = call.arguments['uniqueIdentifier'];
          final userInfo = Map<String, dynamic>.from(call.arguments['userInfo'] ?? {});
          _searchController.add(SpotlightSearchEvent(
            type: SpotlightSearchEventType.itemTapped,
            uniqueIdentifier: identifier,
            userInfo: userInfo,
            timestamp: DateTime.now(),
          ));
          _handleSearchItemTapped(identifier, userInfo);
          break;
          
        case 'onSearchQueryPerformed':
          final query = call.arguments['query'];
          _searchController.add(SpotlightSearchEvent(
            type: SpotlightSearchEventType.queryPerformed,
            query: query,
            timestamp: DateTime.now(),
          ));
          break;
          
        case 'onContinueUserActivity':
          final activityType = call.arguments['activityType'];
          final userInfo = Map<String, dynamic>.from(call.arguments['userInfo'] ?? {});
          _searchController.add(SpotlightSearchEvent(
            type: SpotlightSearchEventType.continueActivity,
            activityType: activityType,
            userInfo: userInfo,
            timestamp: DateTime.now(),
          ));
          _handleContinueActivity(activityType, userInfo);
          break;
      }
    });
  }
  
  // Handle search item tapped
  void _handleSearchItemTapped(String identifier, Map<String, dynamic> userInfo) {
    final type = userInfo['type'];
    
    switch (type) {
      case 'stock':
        final symbol = userInfo['symbol'];
        // Navigate to stock details
        break;
      case 'transaction':
        final transactionId = userInfo['transactionId'];
        // Navigate to transaction details
        break;
      case 'news':
        final articleId = userInfo['articleId'];
        // Navigate to news article
        break;
      default:
        final screen = userInfo['screen'];
        if (screen != null) {
          // Navigate to specified screen
        }
        break;
    }
  }
  
  // Handle continue activity
  void _handleContinueActivity(String activityType, Map<String, dynamic> userInfo) {
    // Handle different activity types
    switch (activityType) {
      case 'com.assetworks.viewStock':
        final symbol = userInfo['symbol'];
        // Navigate to stock
        break;
      case 'com.assetworks.viewPortfolio':
        // Navigate to portfolio
        break;
      case 'com.assetworks.trade':
        // Navigate to trade
        break;
    }
  }
  
  // Set user activity
  Future<void> setUserActivity({
    required String activityType,
    required String title,
    required Map<String, dynamic> userInfo,
    String? webpageURL,
    bool eligibleForSearch = true,
    bool eligibleForHandoff = true,
  }) async {
    try {
      await platform.invokeMethod('setUserActivity', {
        'activityType': activityType,
        'title': title,
        'userInfo': userInfo,
        'webpageURL': webpageURL,
        'eligibleForSearch': eligibleForSearch,
        'eligibleForHandoff': eligibleForHandoff,
      });
    } catch (e) {
      print('Failed to set user activity: $e');
    }
  }
  
  void dispose() {
    _searchController.close();
  }
}

class SpotlightItem {
  final String uniqueIdentifier;
  final String domainIdentifier;
  final String title;
  final String? contentDescription;
  final List<String> keywords;
  final String? thumbnailData;
  final Map<String, dynamic>? userInfo;
  final DateTime? expirationDate;
  
  SpotlightItem({
    required this.uniqueIdentifier,
    required this.domainIdentifier,
    required this.title,
    this.contentDescription,
    required this.keywords,
    this.thumbnailData,
    this.userInfo,
    this.expirationDate,
  });
  
  Map<String, dynamic> toJson() => {
    'uniqueIdentifier': uniqueIdentifier,
    'domainIdentifier': domainIdentifier,
    'title': title,
    'contentDescription': contentDescription,
    'keywords': keywords,
    'thumbnailData': thumbnailData,
    'userInfo': userInfo,
    'expirationDate': expirationDate?.toIso8601String(),
  };
}

class SpotlightSearchEvent {
  final SpotlightSearchEventType type;
  final String? uniqueIdentifier;
  final String? query;
  final String? activityType;
  final Map<String, dynamic>? userInfo;
  final DateTime timestamp;
  
  SpotlightSearchEvent({
    required this.type,
    this.uniqueIdentifier,
    this.query,
    this.activityType,
    this.userInfo,
    required this.timestamp,
  });
}

enum SpotlightSearchEventType {
  itemTapped,
  queryPerformed,
  continueActivity,
}