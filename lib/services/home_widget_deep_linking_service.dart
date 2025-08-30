import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';

class HomeWidgetDeepLinkingService {
  static const platform = MethodChannel('com.assetworks.homewidget/deeplink');
  static final HomeWidgetDeepLinkingService _instance = 
      HomeWidgetDeepLinkingService._internal();
  
  factory HomeWidgetDeepLinkingService() => _instance;
  HomeWidgetDeepLinkingService._internal();
  
  final _deepLinkController = StreamController<DeepLinkData>.broadcast();
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;
  
  // Navigation callback
  Function(DeepLinkData)? _navigationCallback;
  
  // Initialize deep linking
  Future<void> initialize({
    required Function(DeepLinkData) onNavigate,
  }) async {
    try {
      _navigationCallback = onNavigate;
      
      // Register callback for widget interactions
      await HomeWidget.registerInteractivityCallback(_handleWidgetInteraction);
      
      // Setup platform channel
      await platform.invokeMethod('initializeDeepLinking');
      
      // Listen for deep links from native
      _listenToNativeDeepLinks();
      
      print('Home widget deep linking initialized');
    } catch (e) {
      print('Failed to initialize deep linking: $e');
    }
  }
  
  // Listen to native deep links
  void _listenToNativeDeepLinks() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'handleDeepLink':
          final uri = call.arguments['uri'] as String;
          _handleDeepLink(Uri.parse(uri));
          break;
        case 'handleWidgetAction':
          final action = call.arguments as Map<dynamic, dynamic>;
          _handleWidgetAction(action);
          break;
      }
    });
  }
  
  // Handle widget interaction
  Future<void> _handleWidgetInteraction(Uri? uri) async {
    if (uri == null) return;
    
    final deepLink = DeepLinkData.fromUri(uri);
    _processDeepLink(deepLink);
  }
  
  // Handle deep link
  void _handleDeepLink(Uri uri) {
    final deepLink = DeepLinkData.fromUri(uri);
    _processDeepLink(deepLink);
  }
  
  // Handle widget action
  void _handleWidgetAction(Map<dynamic, dynamic> action) {
    final deepLink = DeepLinkData(
      route: action['route'] ?? '/',
      parameters: Map<String, String>.from(action['parameters'] ?? {}),
      source: DeepLinkSource.widget,
      widgetId: action['widgetId'],
      action: action['action'],
    );
    
    _processDeepLink(deepLink);
  }
  
  // Process deep link
  void _processDeepLink(DeepLinkData deepLink) {
    // Add to stream
    _deepLinkController.add(deepLink);
    
    // Call navigation callback
    _navigationCallback?.call(deepLink);
    
    // Log analytics
    _logDeepLinkAnalytics(deepLink);
  }
  
  // Configure widget deep links
  static Future<void> configureWidgetDeepLinks({
    required String widgetId,
    required Map<String, WidgetDeepLinkConfig> configs,
  }) async {
    try {
      final configData = configs.map((key, value) => 
        MapEntry(key, value.toJson()));
      
      await platform.invokeMethod('configureWidgetDeepLinks', {
        'widgetId': widgetId,
        'configs': configData,
      });
    } catch (e) {
      print('Failed to configure widget deep links: $e');
    }
  }
  
  // Register route handler
  void registerRouteHandler(String route, Function(Map<String, String>) handler) {
    _routeHandlers[route] = handler;
  }
  
  final Map<String, Function(Map<String, String>)> _routeHandlers = {};
  
  // Navigate from widget
  void navigateFromWidget(DeepLinkData deepLink) {
    // Check if route handler exists
    if (_routeHandlers.containsKey(deepLink.route)) {
      _routeHandlers[deepLink.route]!(deepLink.parameters);
    } else {
      // Default navigation
      _defaultNavigation(deepLink);
    }
  }
  
  // Default navigation
  void _defaultNavigation(DeepLinkData deepLink) {
    switch (deepLink.route) {
      case '/dashboard':
        // Navigate to dashboard
        break;
      case '/portfolio':
        // Navigate to portfolio
        break;
      case '/stock':
        final symbol = deepLink.parameters['symbol'];
        // Navigate to stock details
        break;
      case '/watchlist':
        // Navigate to watchlist
        break;
      case '/trade':
        final action = deepLink.parameters['action']; // buy/sell
        final symbol = deepLink.parameters['symbol'];
        // Open trade screen
        break;
      case '/alert':
        final alertId = deepLink.parameters['id'];
        // Navigate to alert
        break;
      case '/news':
        final newsId = deepLink.parameters['id'];
        // Open news article
        break;
      case '/settings':
        final section = deepLink.parameters['section'];
        // Navigate to settings
        break;
      default:
        // Navigate to home
        break;
    }
  }
  
  // Create deep link for widget
  static String createWidgetDeepLink({
    required String route,
    Map<String, String>? parameters,
    String? widgetId,
  }) {
    final uri = Uri(
      scheme: 'assetworks',
      host: 'widget',
      path: route,
      queryParameters: {
        if (parameters != null) ...parameters,
        if (widgetId != null) 'widgetId': widgetId,
      },
    );
    
    return uri.toString();
  }
  
  // Log deep link analytics
  void _logDeepLinkAnalytics(DeepLinkData deepLink) {
    // Log to analytics service
    print('Deep link: ${deepLink.route} from ${deepLink.source}');
  }
  
  // Dispose service
  void dispose() {
    _deepLinkController.close();
  }
}

// Deep link data model
class DeepLinkData {
  final String route;
  final Map<String, String> parameters;
  final DeepLinkSource source;
  final String? widgetId;
  final String? action;
  final DateTime timestamp;
  
  DeepLinkData({
    required this.route,
    required this.parameters,
    required this.source,
    this.widgetId,
    this.action,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  factory DeepLinkData.fromUri(Uri uri) {
    final source = uri.host == 'widget' 
        ? DeepLinkSource.widget 
        : DeepLinkSource.app;
    
    return DeepLinkData(
      route: uri.path,
      parameters: uri.queryParameters,
      source: source,
      widgetId: uri.queryParameters['widgetId'],
      action: uri.queryParameters['action'],
    );
  }
  
  Uri toUri() {
    return Uri(
      scheme: 'assetworks',
      host: source == DeepLinkSource.widget ? 'widget' : 'app',
      path: route,
      queryParameters: parameters,
    );
  }
}

// Deep link source
enum DeepLinkSource {
  widget,
  notification,
  app,
  external,
}

// Widget deep link configuration
class WidgetDeepLinkConfig {
  final String actionId;
  final String route;
  final Map<String, String>? defaultParameters;
  final bool requiresAuth;
  final bool animated;
  
  WidgetDeepLinkConfig({
    required this.actionId,
    required this.route,
    this.defaultParameters,
    this.requiresAuth = false,
    this.animated = true,
  });
  
  Map<String, dynamic> toJson() => {
    'actionId': actionId,
    'route': route,
    'defaultParameters': defaultParameters,
    'requiresAuth': requiresAuth,
    'animated': animated,
  };
}

// Common widget deep link routes
class WidgetDeepLinkRoutes {
  static const String dashboard = '/dashboard';
  static const String portfolio = '/portfolio';
  static const String stockDetail = '/stock';
  static const String watchlist = '/watchlist';
  static const String trade = '/trade';
  static const String alerts = '/alerts';
  static const String news = '/news';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String notifications = '/notifications';
  
  // Create stock detail deep link
  static String createStockDetailLink(String symbol) {
    return HomeWidgetDeepLinkingService.createWidgetDeepLink(
      route: stockDetail,
      parameters: {'symbol': symbol},
    );
  }
  
  // Create trade deep link
  static String tradeAction(String symbol, String action) {
    return HomeWidgetDeepLinkingService.createWidgetDeepLink(
      route: trade,
      parameters: {
        'symbol': symbol,
        'action': action,
      },
    );
  }
  
  // Create alert deep link
  static String alertDetail(String alertId) {
    return HomeWidgetDeepLinkingService.createWidgetDeepLink(
      route: alerts,
      parameters: {'id': alertId},
    );
  }
  
  // Create news deep link
  static String newsArticle(String newsId) {
    return HomeWidgetDeepLinkingService.createWidgetDeepLink(
      route: news,
      parameters: {'id': newsId},
    );
  }
}