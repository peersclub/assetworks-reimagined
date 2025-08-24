import 'package:flutter/services.dart';
import 'dart:async';

class AppClipsService {
  static const platform = MethodChannel('com.assetworks.appclips');
  static final AppClipsService _instance = AppClipsService._internal();
  
  factory AppClipsService() => _instance;
  AppClipsService._internal();
  
  final _clipController = StreamController<AppClipEvent>.broadcast();
  Stream<AppClipEvent> get clipStream => _clipController.stream;
  
  AppClipInvocation? _currentInvocation;
  
  // Initialize App Clips
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeAppClips');
      _listenToClipEvents();
      await _checkForAppClipInvocation();
    } catch (e) {
      print('Failed to initialize App Clips: $e');
    }
  }
  
  // Check for App Clip invocation
  Future<void> _checkForAppClipInvocation() async {
    try {
      final result = await platform.invokeMethod<Map>('getAppClipInvocation');
      if (result != null) {
        _currentInvocation = AppClipInvocation.fromJson(Map<String, dynamic>.from(result));
        _handleAppClipInvocation(_currentInvocation!);
      }
    } catch (e) {
      print('Failed to check App Clip invocation: $e');
    }
  }
  
  // Handle App Clip invocation
  void _handleAppClipInvocation(AppClipInvocation invocation) {
    _clipController.add(AppClipEvent(
      type: AppClipEventType.invoked,
      invocation: invocation,
      timestamp: DateTime.now(),
    ));
    
    // Handle different App Clip experiences
    switch (invocation.experienceType) {
      case AppClipExperience.quickTrade:
        _handleQuickTrade(invocation);
        break;
      case AppClipExperience.viewStock:
        _handleViewStock(invocation);
        break;
      case AppClipExperience.portfolioSnapshot:
        _handlePortfolioSnapshot(invocation);
        break;
      case AppClipExperience.priceAlert:
        _handlePriceAlert(invocation);
        break;
      case AppClipExperience.marketNews:
        _handleMarketNews(invocation);
        break;
      case AppClipExperience.widgetSetup:
        _handleWidgetSetup(invocation);
        break;
      case AppClipExperience.sharePortfolio:
        _handleSharePortfolio(invocation);
        break;
      case AppClipExperience.quickSignup:
        _handleQuickSignup(invocation);
        break;
    }
  }
  
  // Handle quick trade
  void _handleQuickTrade(AppClipInvocation invocation) {
    final symbol = invocation.parameters['symbol'];
    final action = invocation.parameters['action'];
    final quantity = invocation.parameters['quantity'];
    // Show quick trade interface
  }
  
  // Handle view stock
  void _handleViewStock(AppClipInvocation invocation) {
    final symbol = invocation.parameters['symbol'];
    // Show stock details
  }
  
  // Handle portfolio snapshot
  void _handlePortfolioSnapshot(AppClipInvocation invocation) {
    // Show portfolio overview
  }
  
  // Handle price alert
  void _handlePriceAlert(AppClipInvocation invocation) {
    final symbol = invocation.parameters['symbol'];
    final targetPrice = invocation.parameters['targetPrice'];
    // Setup price alert
  }
  
  // Handle market news
  void _handleMarketNews(AppClipInvocation invocation) {
    final category = invocation.parameters['category'];
    // Show market news
  }
  
  // Handle widget setup
  void _handleWidgetSetup(AppClipInvocation invocation) {
    final widgetType = invocation.parameters['widgetType'];
    // Setup widget
  }
  
  // Handle share portfolio
  void _handleSharePortfolio(AppClipInvocation invocation) {
    final shareId = invocation.parameters['shareId'];
    // View shared portfolio
  }
  
  // Handle quick signup
  void _handleQuickSignup(AppClipInvocation invocation) {
    final referralCode = invocation.parameters['referralCode'];
    // Show quick signup
  }
  
  // Configure App Clip experiences
  Future<void> configureExperiences({
    required List<AppClipExperienceConfig> experiences,
  }) async {
    try {
      await platform.invokeMethod('configureAppClipExperiences', {
        'experiences': experiences.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to configure App Clip experiences: $e');
    }
  }
  
  // Set App Clip card
  Future<void> setAppClipCard({
    required AppClipCard card,
  }) async {
    try {
      await platform.invokeMethod('setAppClipCard', card.toJson());
    } catch (e) {
      print('Failed to set App Clip card: $e');
    }
  }
  
  // Update location-based App Clip
  Future<void> updateLocationBasedClip({
    required double latitude,
    required double longitude,
    required String placeId,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      await platform.invokeMethod('updateLocationBasedClip', {
        'latitude': latitude,
        'longitude': longitude,
        'placeId': placeId,
        'metadata': metadata,
      });
    } catch (e) {
      print('Failed to update location-based App Clip: $e');
    }
  }
  
  // Register NFC App Clip
  Future<void> registerNFCClip({
    required String nfcTagId,
    required AppClipExperience experience,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      await platform.invokeMethod('registerNFCClip', {
        'nfcTagId': nfcTagId,
        'experience': experience.toString(),
        'parameters': parameters,
      });
    } catch (e) {
      print('Failed to register NFC App Clip: $e');
    }
  }
  
  // Register QR Code App Clip
  Future<void> registerQRCodeClip({
    required String qrCodeData,
    required AppClipExperience experience,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      await platform.invokeMethod('registerQRCodeClip', {
        'qrCodeData': qrCodeData,
        'experience': experience.toString(),
        'parameters': parameters,
      });
    } catch (e) {
      print('Failed to register QR Code App Clip: $e');
    }
  }
  
  // Track App Clip conversion
  Future<void> trackConversion({
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await platform.invokeMethod('trackAppClipConversion', {
        'action': action,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to track App Clip conversion: $e');
    }
  }
  
  // Prompt full app download
  Future<void> promptFullAppDownload({
    String? customMessage,
    Map<String, dynamic>? incentive,
  }) async {
    try {
      await platform.invokeMethod('promptFullAppDownload', {
        'customMessage': customMessage,
        'incentive': incentive,
      });
    } catch (e) {
      print('Failed to prompt full app download: $e');
    }
  }
  
  // Transfer App Clip data to full app
  Future<void> transferDataToFullApp({
    required Map<String, dynamic> data,
  }) async {
    try {
      await platform.invokeMethod('transferDataToFullApp', {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to transfer data to full app: $e');
    }
  }
  
  // Listen to App Clip events
  void _listenToClipEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAppClipInvoked':
          final invocation = AppClipInvocation.fromJson(
            Map<String, dynamic>.from(call.arguments),
          );
          _currentInvocation = invocation;
          _handleAppClipInvocation(invocation);
          break;
          
        case 'onAppClipAction':
          final action = call.arguments['action'];
          final parameters = Map<String, dynamic>.from(call.arguments['parameters'] ?? {});
          _clipController.add(AppClipEvent(
            type: AppClipEventType.actionPerformed,
            action: action,
            parameters: parameters,
            timestamp: DateTime.now(),
          ));
          break;
          
        case 'onFullAppInstalled':
          _clipController.add(AppClipEvent(
            type: AppClipEventType.fullAppInstalled,
            timestamp: DateTime.now(),
          ));
          break;
          
        case 'onDataTransferRequested':
          final data = Map<String, dynamic>.from(call.arguments['data'] ?? {});
          _clipController.add(AppClipEvent(
            type: AppClipEventType.dataTransferRequested,
            parameters: data,
            timestamp: DateTime.now(),
          ));
          break;
      }
    });
  }
  
  // Check if running as App Clip
  Future<bool> isRunningAsAppClip() async {
    try {
      final result = await platform.invokeMethod<bool>('isRunningAsAppClip');
      return result ?? false;
    } catch (e) {
      print('Failed to check if running as App Clip: $e');
      return false;
    }
  }
  
  // Get App Clip size limit
  Future<int> getSizeLimit() async {
    try {
      final result = await platform.invokeMethod<int>('getAppClipSizeLimit');
      return result ?? 10485760; // 10 MB default
    } catch (e) {
      print('Failed to get App Clip size limit: $e');
      return 10485760;
    }
  }
  
  AppClipInvocation? get currentInvocation => _currentInvocation;
  
  void dispose() {
    _clipController.close();
  }
}

class AppClipInvocation {
  final String url;
  final AppClipExperience experienceType;
  final Map<String, dynamic> parameters;
  final AppClipSource source;
  final DateTime timestamp;
  
  AppClipInvocation({
    required this.url,
    required this.experienceType,
    required this.parameters,
    required this.source,
    required this.timestamp,
  });
  
  factory AppClipInvocation.fromJson(Map<String, dynamic> json) {
    return AppClipInvocation(
      url: json['url'],
      experienceType: AppClipExperience.values.firstWhere(
        (e) => e.toString() == json['experienceType'],
      ),
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      source: AppClipSource.values.firstWhere(
        (s) => s.toString() == json['source'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class AppClipExperienceConfig {
  final AppClipExperience type;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Map<String, dynamic> defaultParameters;
  final bool requiresAuth;
  final Duration? expirationDuration;
  
  AppClipExperienceConfig({
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.defaultParameters,
    this.requiresAuth = false,
    this.expirationDuration,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'title': title,
    'subtitle': subtitle,
    'imageUrl': imageUrl,
    'defaultParameters': defaultParameters,
    'requiresAuth': requiresAuth,
    'expirationDuration': expirationDuration?.inSeconds,
  };
}

class AppClipCard {
  final String title;
  final String subtitle;
  final String? headerImage;
  final String? logoImage;
  final String backgroundColor;
  final String tintColor;
  final String action;
  
  AppClipCard({
    required this.title,
    required this.subtitle,
    this.headerImage,
    this.logoImage,
    required this.backgroundColor,
    required this.tintColor,
    required this.action,
  });
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'headerImage': headerImage,
    'logoImage': logoImage,
    'backgroundColor': backgroundColor,
    'tintColor': tintColor,
    'action': action,
  };
}

class AppClipEvent {
  final AppClipEventType type;
  final AppClipInvocation? invocation;
  final String? action;
  final Map<String, dynamic>? parameters;
  final DateTime timestamp;
  
  AppClipEvent({
    required this.type,
    this.invocation,
    this.action,
    this.parameters,
    required this.timestamp,
  });
}

enum AppClipExperience {
  quickTrade,
  viewStock,
  portfolioSnapshot,
  priceAlert,
  marketNews,
  widgetSetup,
  sharePortfolio,
  quickSignup,
}

enum AppClipSource {
  qrCode,
  nfc,
  appClipCode,
  safari,
  messages,
  maps,
  siri,
  nearby,
}

enum AppClipEventType {
  invoked,
  actionPerformed,
  fullAppInstalled,
  dataTransferRequested,
}