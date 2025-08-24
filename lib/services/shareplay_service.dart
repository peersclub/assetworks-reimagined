import 'package:flutter/services.dart';
import 'dart:async';

class SharePlayService {
  static const platform = MethodChannel('com.assetworks.shareplay');
  static final SharePlayService _instance = SharePlayService._internal();
  
  factory SharePlayService() => _instance;
  SharePlayService._internal();
  
  final _sessionController = StreamController<SharePlaySession>.broadcast();
  Stream<SharePlaySession> get sessionStream => _sessionController.stream;
  
  SharePlaySession? _currentSession;
  
  // Initialize SharePlay
  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeSharePlay');
      _listenToSessionEvents();
    } catch (e) {
      print('Failed to initialize SharePlay: $e');
    }
  }
  
  // Start SharePlay session
  Future<void> startSession({
    required SharePlayActivity activity,
  }) async {
    try {
      await platform.invokeMethod('startSharePlaySession', activity.toJson());
    } catch (e) {
      print('Failed to start SharePlay session: $e');
    }
  }
  
  // Join SharePlay session
  Future<void> joinSession(String sessionId) async {
    try {
      await platform.invokeMethod('joinSharePlaySession', {'sessionId': sessionId});
    } catch (e) {
      print('Failed to join SharePlay session: $e');
    }
  }
  
  // Share content
  Future<void> shareContent({
    required SharePlayContent content,
  }) async {
    if (_currentSession == null) return;
    
    try {
      await platform.invokeMethod('shareContent', content.toJson());
    } catch (e) {
      print('Failed to share content: $e');
    }
  }
  
  // Synchronize state
  Future<void> synchronizeState(Map<String, dynamic> state) async {
    if (_currentSession == null) return;
    
    try {
      await platform.invokeMethod('synchronizeState', state);
    } catch (e) {
      print('Failed to synchronize state: $e');
    }
  }
  
  // End session
  Future<void> endSession() async {
    try {
      await platform.invokeMethod('endSharePlaySession');
      _currentSession = null;
    } catch (e) {
      print('Failed to end SharePlay session: $e');
    }
  }
  
  // Listen to session events
  void _listenToSessionEvents() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onSessionStarted':
          final data = Map<String, dynamic>.from(call.arguments);
          _currentSession = SharePlaySession.fromJson(data);
          _sessionController.add(_currentSession!);
          break;
        case 'onParticipantJoined':
        case 'onParticipantLeft':
        case 'onContentShared':
        case 'onStateUpdated':
        case 'onSessionEnded':
          // Handle session events
          break;
      }
    });
  }
  
  SharePlaySession? get currentSession => _currentSession;
  
  void dispose() {
    _sessionController.close();
  }
}

class SharePlaySession {
  final String id;
  final List<SharePlayParticipant> participants;
  final SharePlayActivity activity;
  final SessionState state;
  final DateTime startedAt;
  
  SharePlaySession({
    required this.id,
    required this.participants,
    required this.activity,
    required this.state,
    required this.startedAt,
  });
  
  factory SharePlaySession.fromJson(Map<String, dynamic> json) {
    return SharePlaySession(
      id: json['id'],
      participants: (json['participants'] as List)
          .map((p) => SharePlayParticipant.fromJson(p))
          .toList(),
      activity: SharePlayActivity.fromJson(json['activity']),
      state: SessionState.values.firstWhere(
        (e) => e.toString() == json['state'],
      ),
      startedAt: DateTime.parse(json['startedAt']),
    );
  }
}

class SharePlayActivity {
  final String type;
  final String title;
  final Map<String, dynamic> metadata;
  
  SharePlayActivity({
    required this.type,
    required this.title,
    required this.metadata,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    'metadata': metadata,
  };
  
  factory SharePlayActivity.fromJson(Map<String, dynamic> json) {
    return SharePlayActivity(
      type: json['type'],
      title: json['title'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class SharePlayContent {
  final String type;
  final Map<String, dynamic> data;
  final bool synchronized;
  
  SharePlayContent({
    required this.type,
    required this.data,
    this.synchronized = true,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'data': data,
    'synchronized': synchronized,
  };
}

class SharePlayParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isHost;
  
  SharePlayParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.isHost,
  });
  
  factory SharePlayParticipant.fromJson(Map<String, dynamic> json) {
    return SharePlayParticipant(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      isHost: json['isHost'] ?? false,
    );
  }
}

enum SessionState { waiting, active, paused, ended }