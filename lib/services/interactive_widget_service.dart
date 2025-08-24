import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';
import 'dart:convert';

class InteractiveWidgetService {
  static const platform = MethodChannel('com.assetworks.widget/interactive');
  static final InteractiveWidgetService _instance = 
      InteractiveWidgetService._internal();
  
  factory InteractiveWidgetService() => _instance;
  InteractiveWidgetService._internal();
  
  final _interactionController = StreamController<WidgetInteraction>.broadcast();
  Stream<WidgetInteraction> get interactionStream => _interactionController.stream;
  
  final Map<String, InteractionHandler> _handlers = {};
  
  // Initialize interactive widget service
  Future<void> initialize() async {
    try {
      // Register callback for widget interactions
      await HomeWidget.registerInteractivityCallback(_handleWidgetCallback);
      
      // Setup platform channel
      await platform.invokeMethod('initializeInteractive');
      
      // Listen for native interactions
      _listenToNativeInteractions();
      
      print('Interactive widget service initialized');
    } catch (e) {
      print('Failed to initialize interactive widgets: $e');
    }
  }
  
  // Listen to native interactions
  void _listenToNativeInteractions() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onLongPress':
          _handleLongPress(call.arguments);
          break;
        case 'onDoubleTap':
          _handleDoubleTap(call.arguments);
          break;
        case 'onSwipe':
          _handleSwipe(call.arguments);
          break;
        case 'onForceTouch':
          _handleForceTouch(call.arguments);
          break;
        case 'onDrag':
          _handleDrag(call.arguments);
          break;
        case 'onPinch':
          _handlePinch(call.arguments);
          break;
      }
    });
  }
  
  // Handle widget callback
  Future<void> _handleWidgetCallback(Uri? uri) async {
    if (uri == null) return;
    
    final interaction = WidgetInteraction(
      type: InteractionType.tap,
      widgetId: uri.queryParameters['widgetId'] ?? '',
      elementId: uri.queryParameters['elementId'],
      data: uri.queryParameters,
      timestamp: DateTime.now(),
    );
    
    _processInteraction(interaction);
  }
  
  // Handle long press
  void _handleLongPress(dynamic arguments) {
    final args = Map<String, dynamic>.from(arguments);
    
    final interaction = WidgetInteraction(
      type: InteractionType.longPress,
      widgetId: args['widgetId'],
      elementId: args['elementId'],
      position: InteractionPosition(
        x: args['x']?.toDouble() ?? 0,
        y: args['y']?.toDouble() ?? 0,
      ),
      duration: Duration(milliseconds: args['duration'] ?? 0),
      data: args,
      timestamp: DateTime.now(),
    );
    
    _processInteraction(interaction);
    
    // Provide haptic feedback
    HapticFeedback.mediumImpact();
  }
  
  // Handle double tap
  void _handleDoubleTap(dynamic arguments) {
    final args = Map<String, dynamic>.from(arguments);
    
    final interaction = WidgetInteraction(
      type: InteractionType.doubleTap,
      widgetId: args['widgetId'],
      elementId: args['elementId'],
      position: InteractionPosition(
        x: args['x']?.toDouble() ?? 0,
        y: args['y']?.toDouble() ?? 0,
      ),
      data: args,
      timestamp: DateTime.now(),
    );
    
    _processInteraction(interaction);
    HapticFeedback.lightImpact();
  }
  
  // Handle swipe
  void _handleSwipe(dynamic arguments) {
    final args = Map<String, dynamic>.from(arguments);
    
    final interaction = WidgetInteraction(
      type: InteractionType.swipe,
      widgetId: args['widgetId'],
      elementId: args['elementId'],
      swipeDirection: _parseSwipeDirection(args['direction']),
      velocity: args['velocity']?.toDouble(),
      data: args,
      timestamp: DateTime.now(),
    );
    
    _processInteraction(interaction);
  }
  
  // Handle force touch
  void _handleForceTouch(dynamic arguments) {
    final args = Map<String, dynamic>.from(arguments);
    
    final interaction = WidgetInteraction(
      type: InteractionType.forceTouch,
      widgetId: args['widgetId'],
      elementId: args['elementId'],
      position: InteractionPosition(
        x: args['x']?.toDouble() ?? 0,
        y: args['y']?.toDouble() ?? 0,
      ),
      pressure: args['pressure']?.toDouble() ?? 0,
      data: args,
      timestamp: DateTime.now(),
    );
    
    _processInteraction(interaction);
    HapticFeedback.heavyImpact();
  }
  
  // Handle drag
  void _handleDrag(dynamic arguments) {
    final args = Map<String, dynamic>.from(arguments);
    
    final interaction = WidgetInteraction(
      type: InteractionType.drag,
      widgetId: args['widgetId'],
      elementId: args['elementId'],
      dragData: DragData(
        startX: args['startX']?.toDouble() ?? 0,
        startY: args['startY']?.toDouble() ?? 0,
        endX: args['endX']?.toDouble() ?? 0,
        endY: args['endY']?.toDouble() ?? 0,
        deltaX: args['deltaX']?.toDouble() ?? 0,
        deltaY: args['deltaY']?.toDouble() ?? 0,
      ),
      data: args,
      timestamp: DateTime.now(),
    );
    
    _processInteraction(interaction);
  }
  
  // Handle pinch
  void _handlePinch(dynamic arguments) {
    final args = Map<String, dynamic>.from(arguments);
    
    final interaction = WidgetInteraction(
      type: InteractionType.pinch,
      widgetId: args['widgetId'],
      elementId: args['elementId'],
      scale: args['scale']?.toDouble() ?? 1.0,
      data: args,
      timestamp: DateTime.now(),
    );
    
    _processInteraction(interaction);
  }
  
  // Process interaction
  void _processInteraction(WidgetInteraction interaction) {
    // Add to stream
    _interactionController.add(interaction);
    
    // Check for registered handler
    final handlerKey = '${interaction.widgetId}_${interaction.elementId ?? 'widget'}';
    if (_handlers.containsKey(handlerKey)) {
      _handlers[handlerKey]!.handle(interaction);
    }
    
    // Log analytics
    _logInteractionAnalytics(interaction);
  }
  
  // Register interaction handler
  void registerHandler({
    required String widgetId,
    String? elementId,
    required InteractionHandler handler,
  }) {
    final key = '${widgetId}_${elementId ?? 'widget'}';
    _handlers[key] = handler;
  }
  
  // Configure widget interactions
  static Future<void> configureWidgetInteractions({
    required String widgetId,
    required InteractionConfig config,
  }) async {
    try {
      await platform.invokeMethod('configureInteractions', {
        'widgetId': widgetId,
        'config': config.toJson(),
      });
    } catch (e) {
      print('Failed to configure widget interactions: $e');
    }
  }
  
  // Enable long press menu
  static Future<void> enableLongPressMenu({
    required String widgetId,
    required List<LongPressMenuItem> menuItems,
  }) async {
    try {
      await platform.invokeMethod('enableLongPressMenu', {
        'widgetId': widgetId,
        'menuItems': menuItems.map((item) => item.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to enable long press menu: $e');
    }
  }
  
  // Configure gesture recognizers
  static Future<void> configureGestures({
    required String widgetId,
    required GestureConfig config,
  }) async {
    try {
      await platform.invokeMethod('configureGestures', {
        'widgetId': widgetId,
        'config': config.toJson(),
      });
    } catch (e) {
      print('Failed to configure gestures: $e');
    }
  }
  
  // Parse swipe direction
  SwipeDirection _parseSwipeDirection(String? direction) {
    switch (direction) {
      case 'left':
        return SwipeDirection.left;
      case 'right':
        return SwipeDirection.right;
      case 'up':
        return SwipeDirection.up;
      case 'down':
        return SwipeDirection.down;
      default:
        return SwipeDirection.unknown;
    }
  }
  
  // Log interaction analytics
  void _logInteractionAnalytics(WidgetInteraction interaction) {
    print('Widget interaction: ${interaction.type} on ${interaction.widgetId}');
  }
  
  // Dispose service
  void dispose() {
    _interactionController.close();
  }
}

// Widget interaction model
class WidgetInteraction {
  final InteractionType type;
  final String widgetId;
  final String? elementId;
  final InteractionPosition? position;
  final Duration? duration;
  final SwipeDirection? swipeDirection;
  final double? velocity;
  final double? pressure;
  final DragData? dragData;
  final double? scale;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  WidgetInteraction({
    required this.type,
    required this.widgetId,
    this.elementId,
    this.position,
    this.duration,
    this.swipeDirection,
    this.velocity,
    this.pressure,
    this.dragData,
    this.scale,
    required this.data,
    required this.timestamp,
  });
}

// Interaction type
enum InteractionType {
  tap,
  longPress,
  doubleTap,
  swipe,
  forceTouch,
  drag,
  pinch,
}

// Swipe direction
enum SwipeDirection {
  left,
  right,
  up,
  down,
  unknown,
}

// Interaction position
class InteractionPosition {
  final double x;
  final double y;
  
  InteractionPosition({
    required this.x,
    required this.y,
  });
}

// Drag data
class DragData {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double deltaX;
  final double deltaY;
  
  DragData({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.deltaX,
    required this.deltaY,
  });
}

// Interaction handler
abstract class InteractionHandler {
  void handle(WidgetInteraction interaction);
}

// Interaction configuration
class InteractionConfig {
  final bool enableTap;
  final bool enableLongPress;
  final bool enableDoubleTap;
  final bool enableSwipe;
  final bool enableForceTouch;
  final bool enableDrag;
  final bool enablePinch;
  final int longPressDuration; // milliseconds
  final double swipeThreshold;
  final double forceTouchThreshold;
  
  InteractionConfig({
    this.enableTap = true,
    this.enableLongPress = true,
    this.enableDoubleTap = false,
    this.enableSwipe = false,
    this.enableForceTouch = false,
    this.enableDrag = false,
    this.enablePinch = false,
    this.longPressDuration = 500,
    this.swipeThreshold = 50.0,
    this.forceTouchThreshold = 0.5,
  });
  
  Map<String, dynamic> toJson() => {
    'enableTap': enableTap,
    'enableLongPress': enableLongPress,
    'enableDoubleTap': enableDoubleTap,
    'enableSwipe': enableSwipe,
    'enableForceTouch': enableForceTouch,
    'enableDrag': enableDrag,
    'enablePinch': enablePinch,
    'longPressDuration': longPressDuration,
    'swipeThreshold': swipeThreshold,
    'forceTouchThreshold': forceTouchThreshold,
  };
}

// Long press menu item
class LongPressMenuItem {
  final String id;
  final String title;
  final IconData? icon;
  final String? action;
  final Map<String, dynamic>? data;
  
  LongPressMenuItem({
    required this.id,
    required this.title,
    this.icon,
    this.action,
    this.data,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'icon': icon?.codePoint,
    'action': action,
    'data': data,
  };
}

// Gesture configuration
class GestureConfig {
  final bool enablePanGesture;
  final bool enableScaleGesture;
  final bool enableRotationGesture;
  final double panThreshold;
  final double scaleThreshold;
  final double rotationThreshold;
  
  GestureConfig({
    this.enablePanGesture = false,
    this.enableScaleGesture = false,
    this.enableRotationGesture = false,
    this.panThreshold = 10.0,
    this.scaleThreshold = 0.1,
    this.rotationThreshold = 0.1,
  });
  
  Map<String, dynamic> toJson() => {
    'enablePanGesture': enablePanGesture,
    'enableScaleGesture': enableScaleGesture,
    'enableRotationGesture': enableRotationGesture,
    'panThreshold': panThreshold,
    'scaleThreshold': scaleThreshold,
    'rotationThreshold': rotationThreshold,
  };
}

// Example interaction handlers
class TradingInteractionHandler extends InteractionHandler {
  @override
  void handle(WidgetInteraction interaction) {
    if (interaction.type == InteractionType.longPress) {
      // Show quick trade menu
      _showQuickTradeMenu(interaction);
    } else if (interaction.type == InteractionType.swipe) {
      // Handle swipe to trade
      _handleSwipeToTrade(interaction);
    }
  }
  
  void _showQuickTradeMenu(WidgetInteraction interaction) {
    // Implementation
  }
  
  void _handleSwipeToTrade(WidgetInteraction interaction) {
    // Implementation
  }
}

class PortfolioInteractionHandler extends InteractionHandler {
  @override
  void handle(WidgetInteraction interaction) {
    if (interaction.type == InteractionType.forceTouch) {
      // Show detailed view
      _showDetailedView(interaction);
    } else if (interaction.type == InteractionType.pinch) {
      // Handle zoom
      _handleZoom(interaction);
    }
  }
  
  void _showDetailedView(WidgetInteraction interaction) {
    // Implementation
  }
  
  void _handleZoom(WidgetInteraction interaction) {
    // Implementation
  }
}