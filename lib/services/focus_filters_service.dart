import 'package:flutter/services.dart';
import 'dart:async';

class FocusFiltersService {
  static const platform = MethodChannel('com.assetworks.focus');
  static final FocusFiltersService _instance = FocusFiltersService._internal();
  
  factory FocusFiltersService() => _instance;
  FocusFiltersService._internal();
  
  final _focusController = StreamController<FocusState>.broadcast();
  Stream<FocusState> get focusStream => _focusController.stream;
  
  FocusMode? _currentMode;
  
  // Initialize Focus Filters
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeFocusFilters');
      _listenToFocusChanges();
      await _getCurrentFocusMode();
    } catch (e) {
      print('Failed to initialize Focus Filters: $e');
    }
  }
  
  // Register focus filters
  Future<void> registerFocusFilters({
    required List<FocusFilter> filters,
  }) async {
    try {
      await platform.invokeMethod('registerFocusFilters', {
        'filters': filters.map((f) => f.toJson()).toList(),
      });
    } catch (e) {
      print('Failed to register focus filters: $e');
    }
  }
  
  // Get current focus mode
  Future<FocusMode?> _getCurrentFocusMode() async {
    try {
      final result = await platform.invokeMethod<String>('getCurrentFocusMode');
      _currentMode = _parseFocusMode(result);
      return _currentMode;
    } catch (e) {
      print('Failed to get focus mode: $e');
      return null;
    }
  }
  
  // Apply focus configuration
  Future<void> applyFocusConfiguration({
    required FocusMode mode,
    required FocusConfiguration config,
  }) async {
    try {
      await platform.invokeMethod('applyFocusConfiguration', {
        'mode': mode.toString(),
        'config': config.toJson(),
      });
    } catch (e) {
      print('Failed to apply focus configuration: $e');
    }
  }
  
  // Listen to focus changes
  void _listenToFocusChanges() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onFocusModeChanged':
          final mode = _parseFocusMode(call.arguments['mode']);
          _currentMode = mode;
          _focusController.add(FocusState(
            mode: mode ?? FocusMode.none,
            timestamp: DateTime.now(),
          ));
          break;
        case 'onFocusFilterApplied':
          final filterId = call.arguments['filterId'];
          // Handle filter application
          break;
      }
    });
  }
  
  FocusMode? _parseFocusMode(String? mode) {
    switch (mode) {
      case 'work':
        return FocusMode.work;
      case 'personal':
        return FocusMode.personal;
      case 'sleep':
        return FocusMode.sleep;
      case 'driving':
        return FocusMode.driving;
      case 'fitness':
        return FocusMode.fitness;
      case 'mindfulness':
        return FocusMode.mindfulness;
      case 'reading':
        return FocusMode.reading;
      case 'gaming':
        return FocusMode.gaming;
      case 'custom':
        return FocusMode.custom;
      default:
        return FocusMode.none;
    }
  }
  
  FocusMode? get currentMode => _currentMode;
  
  void dispose() {
    _focusController.close();
  }
}

class FocusFilter {
  final String id;
  final String name;
  final FocusMode mode;
  final FilterType type;
  final Map<String, dynamic> settings;
  
  FocusFilter({
    required this.id,
    required this.name,
    required this.mode,
    required this.type,
    required this.settings,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mode': mode.toString(),
    'type': type.toString(),
    'settings': settings,
  };
}

class FocusConfiguration {
  final bool hideNonEssentialNotifications;
  final bool limitWidgetData;
  final List<String> allowedNotificationCategories;
  final List<String> visibleWidgets;
  final Map<String, dynamic> customSettings;
  
  FocusConfiguration({
    this.hideNonEssentialNotifications = true,
    this.limitWidgetData = false,
    this.allowedNotificationCategories = const [],
    this.visibleWidgets = const [],
    this.customSettings = const {},
  });
  
  Map<String, dynamic> toJson() => {
    'hideNonEssentialNotifications': hideNonEssentialNotifications,
    'limitWidgetData': limitWidgetData,
    'allowedNotificationCategories': allowedNotificationCategories,
    'visibleWidgets': visibleWidgets,
    'customSettings': customSettings,
  };
}

class FocusState {
  final FocusMode mode;
  final DateTime timestamp;
  
  FocusState({
    required this.mode,
    required this.timestamp,
  });
}

enum FocusMode {
  none,
  work,
  personal,
  sleep,
  driving,
  fitness,
  mindfulness,
  reading,
  gaming,
  custom,
}

enum FilterType {
  notifications,
  widgets,
  apps,
  contacts,
  all,
}