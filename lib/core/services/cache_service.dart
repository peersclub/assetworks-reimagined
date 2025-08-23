import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration ttl;
  
  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });
  
  bool get isExpired {
    return DateTime.now().difference(timestamp) > ttl;
  }
  
  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'ttl': ttl.inSeconds,
  };
  
  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      ttl: Duration(seconds: json['ttl']),
    );
  }
}

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();
  
  final _memoryCache = <String, CacheEntry>{};
  final _storage = GetStorage('app_cache');
  
  // Cache durations for different types of data
  static const Duration shortCache = Duration(minutes: 1);
  static const Duration mediumCache = Duration(minutes: 5);
  static const Duration longCache = Duration(minutes: 30);
  static const Duration veryLongCache = Duration(hours: 24);
  
  // Get data from cache or fetch if not available/expired
  Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration ttl = mediumCache,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      // Check memory cache first
      final memoryCached = _getFromMemory<T>(key);
      if (memoryCached != null) {
        return memoryCached;
      }
      
      // Check disk cache
      final diskCached = await _getFromDisk<T>(key);
      if (diskCached != null) {
        // Put back in memory cache for faster access
        _saveToMemory(key, diskCached, ttl);
        return diskCached;
      }
    }
    
    // Fetch fresh data
    try {
      final data = await fetcher();
      await save(key, data, ttl);
      return data;
    } catch (e) {
      // If fetch fails, try to return stale cache if available
      final staleData = _getStaleData<T>(key);
      if (staleData != null) {
        return staleData;
      }
      rethrow;
    }
  }
  
  // Save data to cache
  Future<void> save(String key, dynamic data, Duration ttl) async {
    final entry = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
    
    // Save to memory
    _saveToMemory(key, data, ttl);
    
    // Save to disk
    await _saveToDisk(key, entry);
  }
  
  // Get from memory cache
  T? _getFromMemory<T>(String key) {
    final entry = _memoryCache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }
    if (entry?.isExpired == true) {
      _memoryCache.remove(key);
    }
    return null;
  }
  
  // Save to memory cache
  void _saveToMemory(String key, dynamic data, Duration ttl) {
    _memoryCache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
  }
  
  // Get from disk cache
  Future<T?> _getFromDisk<T>(String key) async {
    try {
      final json = _storage.read(key);
      if (json != null) {
        final entry = CacheEntry.fromJson(json);
        if (!entry.isExpired) {
          return entry.data as T;
        }
        // Remove expired entry
        await _storage.remove(key);
      }
    } catch (e) {
      print('Cache read error: $e');
    }
    return null;
  }
  
  // Save to disk cache
  Future<void> _saveToDisk(String key, CacheEntry entry) async {
    try {
      await _storage.write(key, entry.toJson());
    } catch (e) {
      print('Cache write error: $e');
    }
  }
  
  // Get stale data (expired but still available)
  T? _getStaleData<T>(String key) {
    // Check memory first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null) {
      return memoryEntry.data as T;
    }
    
    // Check disk
    try {
      final json = _storage.read(key);
      if (json != null) {
        final entry = CacheEntry.fromJson(json);
        return entry.data as T;
      }
    } catch (e) {
      print('Stale cache read error: $e');
    }
    return null;
  }
  
  // Clear specific cache
  Future<void> clear(String key) async {
    _memoryCache.remove(key);
    await _storage.remove(key);
  }
  
  // Clear all cache
  Future<void> clearAll() async {
    _memoryCache.clear();
    await _storage.erase();
  }
  
  // Preload multiple cache entries
  Future<void> preload(Map<String, Future<dynamic> Function()> loaders) async {
    final futures = <Future>[];
    
    for (final entry in loaders.entries) {
      futures.add(
        getOrFetch(
          key: entry.key,
          fetcher: entry.value,
          ttl: mediumCache,
        ),
      );
    }
    
    await Future.wait(futures);
  }
  
  // Get cache size
  int get memoryCacheSize => _memoryCache.length;
  
  // Cache keys for different data types
  static String dashboardKey(int page) => 'dashboard_$page';
  static String trendingKey() => 'trending_widgets';
  static String profileKey(String? userId) => 'profile_${userId ?? 'self'}';
  static String notificationsKey() => 'notifications';
  static String templatesKey() => 'widget_templates';
  static String historyKey(int page) => 'history_$page';
  static String followersKey(String userId) => 'followers_$userId';
  static String followingKey(String userId) => 'following_$userId';
  static String analysisKey() => 'popular_analysis';
}