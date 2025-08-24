import 'package:flutter/services.dart';
import 'dart:async';

class UniversalLinksService {
  static const platform = MethodChannel('com.assetworks.universallinks');
  static final UniversalLinksService _instance = UniversalLinksService._internal();
  
  factory UniversalLinksService() => _instance;
  UniversalLinksService._internal();
  
  final _linkController = StreamController<UniversalLink>.broadcast();
  Stream<UniversalLink> get linkStream => _linkController.stream;
  
  String? _initialLink;
  
  // Initialize Universal Links
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeUniversalLinks');
      _listenToLinkEvents();
      await _getInitialLink();
      await _registerLinkHandlers();
    } catch (e) {
      print('Failed to initialize Universal Links: $e');
    }
  }
  
  // Get initial link
  Future<void> _getInitialLink() async {
    try {
      final link = await platform.invokeMethod<String>('getInitialLink');
      if (link != null) {
        _initialLink = link;
        _handleLink(link);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }
  }
  
  // Register link handlers
  Future<void> _registerLinkHandlers() async {
    final handlers = [
      LinkHandler(
        pattern: r'^https://assetworks\.com/portfolio/?$',
        handler: 'portfolio',
        priority: 1,
      ),
      LinkHandler(
        pattern: r'^https://assetworks\.com/stock/([A-Z]+)/?$',
        handler: 'stock',
        priority: 1,
      ),
      LinkHandler(
        pattern: r'^https://assetworks\.com/trade/([A-Z]+)/(buy|sell)/?$',
        handler: 'trade',
        priority: 1,
      ),
      LinkHandler(
        pattern: r'^https://assetworks\.com/watchlist/?$',
        handler: 'watchlist',
        priority: 1,
      ),
      LinkHandler(
        pattern: r'^https://assetworks\.com/news/(\d+)/?$',
        handler: 'news',
        priority: 1,
      ),
      LinkHandler(
        pattern: r'^https://assetworks\.com/alert/(\d+)/?$',
        handler: 'alert',
        priority: 1,
      ),
      LinkHandler(
        pattern: r'^https://assetworks\.com/share/portfolio/([a-zA-Z0-9]+)/?$',
        handler: 'sharedPortfolio',
        priority: 2,
      ),
      LinkHandler(
        pattern: r'^https://assetworks\.com/invite/([a-zA-Z0-9]+)/?$',
        handler: 'invite',
        priority: 2,
      ),
      LinkHandler(
        pattern: r'^https://assetworks\.com/widget/configure/([a-zA-Z0-9]+)/?$',
        handler: 'widgetConfig',
        priority: 2,
      ),
      LinkHandler(
        pattern: r'^https://assetworks\.com/auth/verify/([a-zA-Z0-9]+)/?$',
        handler: 'authVerify',
        priority: 3,
      ),
      LinkHandler(
        pattern: r'^https://assetworks\.com/auth/reset/([a-zA-Z0-9]+)/?$',
        handler: 'passwordReset',
        priority: 3,
      ),
    ];
    
    try {
      await platform.invokeMethod('registerLinkHandlers', {
        'handlers': handlers.map((h) => h.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to register link handlers: $e');
    }
  }
  
  // Handle incoming link
  void _handleLink(String link) {
    final uri = Uri.parse(link);
    final path = uri.path;
    final queryParams = uri.queryParameters;
    
    UniversalLink universalLink;
    
    // Portfolio
    if (path == '/portfolio') {
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.viewPortfolio,
        parameters: queryParams,
        timestamp: DateTime.now(),
      );
    }
    // Stock details
    else if (path.startsWith('/stock/')) {
      final symbol = path.split('/')[2];
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.viewStock,
        parameters: {'symbol': symbol, ...queryParams},
        timestamp: DateTime.now(),
      );
    }
    // Trade
    else if (path.startsWith('/trade/')) {
      final parts = path.split('/');
      final symbol = parts[2];
      final action = parts[3];
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.trade,
        parameters: {
          'symbol': symbol,
          'action': action,
          ...queryParams,
        },
        timestamp: DateTime.now(),
      );
    }
    // Watchlist
    else if (path == '/watchlist') {
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.viewWatchlist,
        parameters: queryParams,
        timestamp: DateTime.now(),
      );
    }
    // News
    else if (path.startsWith('/news/')) {
      final articleId = path.split('/')[2];
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.viewNews,
        parameters: {'articleId': articleId, ...queryParams},
        timestamp: DateTime.now(),
      );
    }
    // Alert
    else if (path.startsWith('/alert/')) {
      final alertId = path.split('/')[2];
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.viewAlert,
        parameters: {'alertId': alertId, ...queryParams},
        timestamp: DateTime.now(),
      );
    }
    // Shared portfolio
    else if (path.startsWith('/share/portfolio/')) {
      final shareId = path.split('/')[3];
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.viewSharedPortfolio,
        parameters: {'shareId': shareId, ...queryParams},
        timestamp: DateTime.now(),
      );
    }
    // Invite
    else if (path.startsWith('/invite/')) {
      final inviteCode = path.split('/')[2];
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.acceptInvite,
        parameters: {'inviteCode': inviteCode, ...queryParams},
        timestamp: DateTime.now(),
      );
    }
    // Widget configuration
    else if (path.startsWith('/widget/configure/')) {
      final widgetId = path.split('/')[3];
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.configureWidget,
        parameters: {'widgetId': widgetId, ...queryParams},
        timestamp: DateTime.now(),
      );
    }
    // Auth verification
    else if (path.startsWith('/auth/verify/')) {
      final token = path.split('/')[3];
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.verifyAuth,
        parameters: {'token': token, ...queryParams},
        timestamp: DateTime.now(),
      );
    }
    // Password reset
    else if (path.startsWith('/auth/reset/')) {
      final token = path.split('/')[3];
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.resetPassword,
        parameters: {'token': token, ...queryParams},
        timestamp: DateTime.now(),
      );
    }
    // Default
    else {
      universalLink = UniversalLink(
        url: link,
        path: path,
        action: LinkAction.unknown,
        parameters: queryParams,
        timestamp: DateTime.now(),
      );
    }
    
    _linkController.add(universalLink);
    _navigateToLink(universalLink);
  }
  
  // Navigate to link
  void _navigateToLink(UniversalLink link) {
    switch (link.action) {
      case LinkAction.viewPortfolio:
        // Navigate to portfolio
        break;
      case LinkAction.viewStock:
        final symbol = link.parameters['symbol'];
        // Navigate to stock details
        break;
      case LinkAction.trade:
        final symbol = link.parameters['symbol'];
        final action = link.parameters['action'];
        // Navigate to trade screen
        break;
      case LinkAction.viewWatchlist:
        // Navigate to watchlist
        break;
      case LinkAction.viewNews:
        final articleId = link.parameters['articleId'];
        // Navigate to news article
        break;
      case LinkAction.viewAlert:
        final alertId = link.parameters['alertId'];
        // Navigate to alert
        break;
      case LinkAction.viewSharedPortfolio:
        final shareId = link.parameters['shareId'];
        // Navigate to shared portfolio
        break;
      case LinkAction.acceptInvite:
        final inviteCode = link.parameters['inviteCode'];
        // Handle invite
        break;
      case LinkAction.configureWidget:
        final widgetId = link.parameters['widgetId'];
        // Configure widget
        break;
      case LinkAction.verifyAuth:
        final token = link.parameters['token'];
        // Verify authentication
        break;
      case LinkAction.resetPassword:
        final token = link.parameters['token'];
        // Reset password
        break;
      case LinkAction.unknown:
        // Handle unknown link
        break;
    }
  }
  
  // Listen to link events
  void _listenToLinkEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onLinkReceived':
          final link = call.arguments['link'];
          _handleLink(link);
          break;
        case 'onDynamicLinkReceived':
          final link = call.arguments['link'];
          final parameters = Map<String, dynamic>.from(call.arguments['parameters'] ?? {});
          _handleDynamicLink(link, parameters);
          break;
      }
    });
  }
  
  // Handle dynamic link
  void _handleDynamicLink(String link, Map<String, dynamic> parameters) {
    // Handle Firebase Dynamic Links or other dynamic link services
    _handleLink(link);
  }
  
  // Generate universal link
  String generateLink({
    required String path,
    Map<String, String>? queryParameters,
    bool useShortLink = false,
  }) {
    final uri = Uri(
      scheme: 'https',
      host: 'assetworks.com',
      path: path,
      queryParameters: queryParameters,
    );
    
    final link = uri.toString();
    
    if (useShortLink) {
      // Generate short link using link shortening service
      return _generateShortLink(link);
    }
    
    return link;
  }
  
  // Generate short link
  String _generateShortLink(String longLink) {
    // Implement link shortening logic
    return longLink; // Placeholder
  }
  
  // Generate stock link
  String generateStockLink(String symbol) {
    return generateLink(
      path: '/stock/$symbol',
    );
  }
  
  // Generate trade link
  String generateTradeLink({
    required String symbol,
    required String action,
    double? quantity,
    double? price,
  }) {
    return generateLink(
      path: '/trade/$symbol/$action',
      queryParameters: {
        if (quantity != null) 'quantity': quantity.toString(),
        if (price != null) 'price': price.toString(),
      },
    );
  }
  
  // Generate share portfolio link
  Future<String> generateSharePortfolioLink() async {
    try {
      final result = await platform.invokeMethod<String>('generateSharePortfolioLink');
      return result ?? '';
    } catch (e) {
      print('Failed to generate share portfolio link: $e');
      return '';
    }
  }
  
  // Generate invite link
  Future<String> generateInviteLink({
    required String inviteCode,
    String? referrerName,
  }) async {
    return generateLink(
      path: '/invite/$inviteCode',
      queryParameters: {
        if (referrerName != null) 'referrer': referrerName,
      },
    );
  }
  
  String? get initialLink => _initialLink;
  
  void dispose() {
    _linkController.close();
  }
}

class LinkHandler {
  final String pattern;
  final String handler;
  final int priority;
  
  LinkHandler({
    required this.pattern,
    required this.handler,
    required this.priority,
  });
  
  Map<String, dynamic> toJson() => {
    'pattern': pattern,
    'handler': handler,
    'priority': priority,
  };
}

class UniversalLink {
  final String url;
  final String path;
  final LinkAction action;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  
  UniversalLink({
    required this.url,
    required this.path,
    required this.action,
    required this.parameters,
    required this.timestamp,
  });
}

enum LinkAction {
  viewPortfolio,
  viewStock,
  trade,
  viewWatchlist,
  viewNews,
  viewAlert,
  viewSharedPortfolio,
  acceptInvite,
  configureWidget,
  verifyAuth,
  resetPassword,
  unknown,
}