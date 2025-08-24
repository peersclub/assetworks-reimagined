import 'package:flutter/services.dart';
import 'dart:async';

class QuickActionsService {
  static const platform = MethodChannel('com.assetworks.quickactions');
  static final QuickActionsService _instance = QuickActionsService._internal();
  
  factory QuickActionsService() => _instance;
  QuickActionsService._internal();
  
  final _actionController = StreamController<QuickActionEvent>.broadcast();
  Stream<QuickActionEvent> get actionStream => _actionController.stream;
  
  // Initialize Quick Actions
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeQuickActions');
      _listenToActionEvents();
      await _registerDefaultActions();
    } catch (e) {
      print('Failed to initialize Quick Actions: $e');
    }
  }
  
  // Register Quick Actions
  Future<void> registerActions({
    required List<QuickAction> actions,
  }) async {
    try {
      await platform.invokeMethod('registerQuickActions', {
        'actions': actions.map((a) => a.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to register Quick Actions: $e');
    }
  }
  
  // Register default actions
  Future<void> _registerDefaultActions() async {
    final actions = [
      QuickAction(
        type: 'com.assetworks.trade',
        localizedTitle: 'Trade',
        localizedSubtitle: 'Buy or sell stocks',
        icon: QuickActionIcon.add,
        userInfo: {'action': 'trade'},
      ),
      QuickAction(
        type: 'com.assetworks.portfolio',
        localizedTitle: 'Portfolio',
        localizedSubtitle: 'View your holdings',
        icon: QuickActionIcon.compose,
        userInfo: {'action': 'portfolio'},
      ),
      QuickAction(
        type: 'com.assetworks.watchlist',
        localizedTitle: 'Watchlist',
        localizedSubtitle: 'Check your watchlist',
        icon: QuickActionIcon.favorite,
        userInfo: {'action': 'watchlist'},
      ),
      QuickAction(
        type: 'com.assetworks.search',
        localizedTitle: 'Search',
        localizedSubtitle: 'Find stocks',
        icon: QuickActionIcon.search,
        userInfo: {'action': 'search'},
      ),
    ];
    
    await registerActions(actions: actions);
  }
  
  // Update dynamic Quick Actions
  Future<void> updateDynamicActions({
    required List<DynamicQuickAction> actions,
  }) async {
    try {
      await platform.invokeMethod('updateDynamicQuickActions', {
        'actions': actions.map((a) => a.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to update dynamic Quick Actions: $e');
    }
  }
  
  // Add recent stock action
  Future<void> addRecentStockAction({
    required String symbol,
    required String companyName,
    required double price,
  }) async {
    final action = DynamicQuickAction(
      type: 'com.assetworks.stock.$symbol',
      localizedTitle: symbol,
      localizedSubtitle: '\$$price - $companyName',
      icon: QuickActionIcon.custom,
      iconName: 'stock_icon',
      userInfo: {
        'action': 'viewStock',
        'symbol': symbol,
        'price': price,
      },
    );
    
    await updateDynamicActions(actions: [action]);
  }
  
  // Handle 3D Touch peek
  Future<PeekPreview?> handlePeek({
    required String itemId,
    required PeekContext context,
  }) async {
    try {
      final result = await platform.invokeMethod<Map>('handlePeek', {
        'itemId': itemId,
        'context': context.toJson(),
      });
      
      if (result != null) {
        return PeekPreview.fromJson(result);
      }
      return null;
    } catch (e) {
      print('Failed to handle peek: $e');
      return null;
    }
  }
  
  // Handle 3D Touch pop
  Future<void> handlePop({
    required String itemId,
    required PopAction action,
  }) async {
    try {
      await platform.invokeMethod('handlePop', {
        'itemId': itemId,
        'action': action.toString(),
      });
    } catch (e) {
      print('Failed to handle pop: $e');
    }
  }
  
  // Register force touch handler
  void registerForceTouchHandler({
    required String widgetId,
    required ForceTouchHandler handler,
  }) {
    _forceTouchHandlers[widgetId] = handler;
  }
  
  final Map<String, ForceTouchHandler> _forceTouchHandlers = {};
  
  // Listen to action events
  void _listenToActionEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onQuickActionTriggered':
          final type = call.arguments['type'];
          final userInfo = Map<String, dynamic>.from(call.arguments['userInfo'] ?? {});
          _actionController.add(QuickActionEvent(
            type: QuickActionEventType.triggered,
            actionType: type,
            userInfo: userInfo,
            timestamp: DateTime.now(),
          ));
          _handleQuickAction(type, userInfo);
          break;
          
        case 'onForceTouchBegan':
          final widgetId = call.arguments['widgetId'];
          final force = call.arguments['force'];
          _actionController.add(QuickActionEvent(
            type: QuickActionEventType.forceTouchBegan,
            widgetId: widgetId,
            force: force,
            timestamp: DateTime.now(),
          ));
          break;
          
        case 'onForceTouchChanged':
          final widgetId = call.arguments['widgetId'];
          final force = call.arguments['force'];
          _actionController.add(QuickActionEvent(
            type: QuickActionEventType.forceTouchChanged,
            widgetId: widgetId,
            force: force,
            timestamp: DateTime.now(),
          ));
          _handleForceTouch(widgetId, force);
          break;
          
        case 'onForceTouchEnded':
          final widgetId = call.arguments['widgetId'];
          _actionController.add(QuickActionEvent(
            type: QuickActionEventType.forceTouchEnded,
            widgetId: widgetId,
            timestamp: DateTime.now(),
          ));
          break;
          
        case 'onPeekRequested':
          final itemId = call.arguments['itemId'];
          final context = PeekContext.fromJson(call.arguments['context']);
          final preview = await handlePeek(itemId: itemId, context: context);
          return preview?.toJson();
          
        case 'onPopRequested':
          final itemId = call.arguments['itemId'];
          final action = PopAction.values.firstWhere(
            (a) => a.toString() == call.arguments['action'],
          );
          await handlePop(itemId: itemId, action: action);
          break;
      }
    });
  }
  
  // Handle Quick Action
  void _handleQuickAction(String type, Map<String, dynamic> userInfo) {
    final action = userInfo['action'];
    
    switch (action) {
      case 'trade':
        // Navigate to trade screen
        break;
      case 'portfolio':
        // Navigate to portfolio
        break;
      case 'watchlist':
        // Navigate to watchlist
        break;
      case 'search':
        // Navigate to search
        break;
      case 'viewStock':
        final symbol = userInfo['symbol'];
        // Navigate to stock details
        break;
    }
  }
  
  // Handle force touch
  void _handleForceTouch(String widgetId, double force) {
    final handler = _forceTouchHandlers[widgetId];
    if (handler != null) {
      if (force > 0.5 && force < 0.8) {
        handler.onLightPress?.call();
      } else if (force >= 0.8) {
        handler.onDeepPress?.call();
      }
    }
  }
  
  // Clear all Quick Actions
  Future<void> clearAllActions() async {
    try {
      await platform.invokeMethod('clearAllQuickActions');
    } catch (e) {
      print('Failed to clear Quick Actions: $e');
    }
  }
  
  // Check if 3D Touch is available
  Future<bool> is3DTouchAvailable() async {
    try {
      final result = await platform.invokeMethod<bool>('is3DTouchAvailable');
      return result ?? false;
    } catch (e) {
      print('Failed to check 3D Touch availability: $e');
      return false;
    }
  }
  
  // Check if Haptic Touch is available
  Future<bool> isHapticTouchAvailable() async {
    try {
      final result = await platform.invokeMethod<bool>('isHapticTouchAvailable');
      return result ?? false;
    } catch (e) {
      print('Failed to check Haptic Touch availability: $e');
      return false;
    }
  }
  
  void dispose() {
    _actionController.close();
    _forceTouchHandlers.clear();
  }
}

class QuickAction {
  final String type;
  final String localizedTitle;
  final String? localizedSubtitle;
  final QuickActionIcon icon;
  final Map<String, dynamic> userInfo;
  
  QuickAction({
    required this.type,
    required this.localizedTitle,
    this.localizedSubtitle,
    required this.icon,
    required this.userInfo,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'localizedTitle': localizedTitle,
    'localizedSubtitle': localizedSubtitle,
    'icon': icon.toString(),
    'userInfo': userInfo,
  };
}

class DynamicQuickAction {
  final String type;
  final String localizedTitle;
  final String? localizedSubtitle;
  final QuickActionIcon icon;
  final String? iconName;
  final Map<String, dynamic> userInfo;
  
  DynamicQuickAction({
    required this.type,
    required this.localizedTitle,
    this.localizedSubtitle,
    required this.icon,
    this.iconName,
    required this.userInfo,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'localizedTitle': localizedTitle,
    'localizedSubtitle': localizedSubtitle,
    'icon': icon.toString(),
    'iconName': iconName,
    'userInfo': userInfo,
  };
}

class QuickActionEvent {
  final QuickActionEventType type;
  final String? actionType;
  final String? widgetId;
  final double? force;
  final Map<String, dynamic>? userInfo;
  final DateTime timestamp;
  
  QuickActionEvent({
    required this.type,
    this.actionType,
    this.widgetId,
    this.force,
    this.userInfo,
    required this.timestamp,
  });
}

class PeekContext {
  final String sourceView;
  final Map<String, dynamic> sourceRect;
  final Map<String, dynamic>? previewData;
  
  PeekContext({
    required this.sourceView,
    required this.sourceRect,
    this.previewData,
  });
  
  Map<String, dynamic> toJson() => {
    'sourceView': sourceView,
    'sourceRect': sourceRect,
    'previewData': previewData,
  };
  
  factory PeekContext.fromJson(Map<String, dynamic> json) {
    return PeekContext(
      sourceView: json['sourceView'],
      sourceRect: json['sourceRect'],
      previewData: json['previewData'],
    );
  }
}

class PeekPreview {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final List<PreviewAction> actions;
  
  PeekPreview({
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.actions,
  });
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'imageUrl': imageUrl,
    'actions': actions.map((a) => a.toJson()).toList(),
  };
  
  factory PeekPreview.fromJson(Map<String, dynamic> json) {
    return PeekPreview(
      title: json['title'],
      subtitle: json['subtitle'],
      imageUrl: json['imageUrl'],
      actions: (json['actions'] as List)
          .map((a) => PreviewAction.fromJson(a))
          .toList(),
    );
  }
}

class PreviewAction {
  final String title;
  final String style;
  final String handler;
  
  PreviewAction({
    required this.title,
    required this.style,
    required this.handler,
  });
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'style': style,
    'handler': handler,
  };
  
  factory PreviewAction.fromJson(Map<String, dynamic> json) {
    return PreviewAction(
      title: json['title'],
      style: json['style'],
      handler: json['handler'],
    );
  }
}

class ForceTouchHandler {
  final VoidCallback? onLightPress;
  final VoidCallback? onDeepPress;
  
  ForceTouchHandler({
    this.onLightPress,
    this.onDeepPress,
  });
}

enum QuickActionIcon {
  compose,
  play,
  pause,
  add,
  location,
  search,
  share,
  prohibit,
  contact,
  home,
  markLocation,
  favorite,
  love,
  cloud,
  invitation,
  confirmation,
  mail,
  message,
  date,
  time,
  capturePhoto,
  captureVideo,
  task,
  taskCompleted,
  alarm,
  bookmark,
  shuffle,
  audio,
  update,
  custom,
}

enum QuickActionEventType {
  triggered,
  forceTouchBegan,
  forceTouchChanged,
  forceTouchEnded,
}

enum PopAction {
  open,
  share,
  favorite,
  delete,
}

typedef VoidCallback = void Function();