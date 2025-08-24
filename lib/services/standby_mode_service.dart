import 'package:flutter/services.dart';
import 'dart:async';

class StandByModeService {
  static const platform = MethodChannel('com.assetworks.standby');
  static final StandByModeService _instance = StandByModeService._internal();
  
  factory StandByModeService() => _instance;
  StandByModeService._internal();
  
  final _standbyController = StreamController<StandByEvent>.broadcast();
  Stream<StandByEvent> get standbyStream => _standbyController.stream;
  
  // Initialize StandBy Mode
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeStandBy');
      _listenToStandByEvents();
    } catch (e) {
      print('Failed to initialize StandBy Mode: $e');
    }
  }
  
  // Configure StandBy display
  Future<void> configureStandByDisplay({
    required StandByConfiguration config,
  }) async {
    try {
      await platform.invokeMethod('configureStandBy', config.toJson());
    } catch (e) {
      print('Failed to configure StandBy: $e');
    }
  }
  
  // Update StandBy content
  Future<void> updateContent({
    required StandByContent content,
  }) async {
    try {
      await platform.invokeMethod('updateStandByContent', content.toJson());
    } catch (e) {
      print('Failed to update StandBy content: $e');
    }
  }
  
  // Listen to StandBy events
  void _listenToStandByEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStandByActivated':
          _standbyController.add(StandByEvent(
            type: StandByEventType.activated,
            timestamp: DateTime.now(),
          ));
          break;
        case 'onStandByDeactivated':
          _standbyController.add(StandByEvent(
            type: StandByEventType.deactivated,
            timestamp: DateTime.now(),
          ));
          break;
        case 'onStandByInteraction':
          final data = call.arguments as Map;
          _standbyController.add(StandByEvent(
            type: StandByEventType.interaction,
            interactionData: data,
            timestamp: DateTime.now(),
          ));
          break;
      }
    });
  }
  
  void dispose() {
    _standbyController.close();
  }
}

class StandByConfiguration {
  final bool enabled;
  final StandByLayout layout;
  final StandByTheme theme;
  final List<StandByWidget> widgets;
  final Duration updateInterval;
  final bool showClock;
  final bool showDate;
  final bool showWeather;
  
  StandByConfiguration({
    this.enabled = true,
    this.layout = StandByLayout.standard,
    this.theme = StandByTheme.auto,
    this.widgets = const [],
    this.updateInterval = const Duration(minutes: 1),
    this.showClock = true,
    this.showDate = true,
    this.showWeather = false,
  });
  
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'layout': layout.toString(),
    'theme': theme.toString(),
    'widgets': widgets.map((w) => w.toJson()).toList(),
    'updateInterval': updateInterval.inSeconds,
    'showClock': showClock,
    'showDate': showDate,
    'showWeather': showWeather,
  };
}

class StandByContent {
  final String primaryText;
  final String? secondaryText;
  final Map<String, dynamic>? data;
  final List<StandByDataPoint>? dataPoints;
  
  StandByContent({
    required this.primaryText,
    this.secondaryText,
    this.data,
    this.dataPoints,
  });
  
  Map<String, dynamic> toJson() => {
    'primaryText': primaryText,
    'secondaryText': secondaryText,
    'data': data,
    'dataPoints': dataPoints?.map((d) => d.toJson()).toList(),
  };
}

class StandByWidget {
  final String id;
  final StandByWidgetType type;
  final Map<String, dynamic> configuration;
  
  StandByWidget({
    required this.id,
    required this.type,
    required this.configuration,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'configuration': configuration,
  };
}

class StandByDataPoint {
  final String label;
  final String value;
  final String? icon;
  final String? color;
  
  StandByDataPoint({
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });
  
  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
    'icon': icon,
    'color': color,
  };
}

class StandByEvent {
  final StandByEventType type;
  final Map<String, dynamic>? interactionData;
  final DateTime timestamp;
  
  StandByEvent({
    required this.type,
    this.interactionData,
    required this.timestamp,
  });
}

enum StandByLayout { standard, compact, expanded, custom }
enum StandByTheme { auto, light, dark }
enum StandByWidgetType { portfolio, chart, watchlist, news, custom }
enum StandByEventType { activated, deactivated, interaction }