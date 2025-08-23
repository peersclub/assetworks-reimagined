import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../core/network/api_client.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/haptic_service.dart';
import '../../data/models/widget_model.dart';
import '../../data/models/analysis_model.dart';

enum LoadingState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

class OptimizedDashboardController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final CacheService _cacheService = CacheService();
  
  // Loading states - separate for each section
  final dashboardState = LoadingState.initial.obs;
  final trendingState = LoadingState.initial.obs;
  final analysisState = LoadingState.initial.obs;
  
  // Loading indicators
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  
  // Error handling
  final error = Rxn<String>();
  final retryCount = 0.obs;
  final maxRetries = 3;
  
  // Data
  final dashboardWidgets = <WidgetModel>[].obs;
  final trendingWidgets = <WidgetModel>[].obs;
  final popularAnalysis = <AnalysisModel>[].obs;
  
  // Pagination
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final pageSize = 20;
  
  // Performance optimization
  Timer? _debounceTimer;
  final _loadingQueue = <String, Completer>{};
  
  @override
  void onInit() {
    super.onInit();
    // Load all data in parallel with proper error handling
    loadInitialData();
  }
  
  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
  
  // Load all initial data in parallel
  Future<void> loadInitialData() async {
    // Load from cache first for instant display
    await _loadFromCache();
    
    // Then fetch fresh data in parallel
    await Future.wait([
      _loadDashboardWidgets(useCache: false),
      _loadTrendingWidgets(useCache: false),
      _loadPopularAnalysis(useCache: false),
    ], eagerError: false); // Don't fail all if one fails
  }
  
  // Load cached data for instant display
  Future<void> _loadFromCache() async {
    try {
      // Load all cached data in parallel
      final results = await Future.wait([
        _cacheService.getOrFetch(
          key: CacheService.dashboardKey(1),
          fetcher: () async => <WidgetModel>[],
          ttl: CacheService.mediumCache,
        ),
        _cacheService.getOrFetch(
          key: CacheService.trendingKey(),
          fetcher: () async => <WidgetModel>[],
          ttl: CacheService.longCache,
        ),
        _cacheService.getOrFetch(
          key: CacheService.analysisKey(),
          fetcher: () async => <AnalysisModel>[],
          ttl: CacheService.longCache,
        ),
      ]);
      
      // Update UI with cached data
      if (results[0] is List && (results[0] as List).isNotEmpty) {
        dashboardWidgets.value = results[0] as List<WidgetModel>;
        dashboardState.value = LoadingState.loaded;
      }
      
      if (results[1] is List && (results[1] as List).isNotEmpty) {
        trendingWidgets.value = results[1] as List<WidgetModel>;
        trendingState.value = LoadingState.loaded;
      }
      
      if (results[2] is List && (results[2] as List).isNotEmpty) {
        popularAnalysis.value = results[2] as List<AnalysisModel>;
        analysisState.value = LoadingState.loaded;
      }
    } catch (e) {
      print('Cache load error: $e');
    }
  }
  
  // Load dashboard widgets with retry logic
  Future<void> _loadDashboardWidgets({bool useCache = true}) async {
    // Prevent duplicate requests
    final key = 'dashboard_${currentPage.value}';
    if (_loadingQueue.containsKey(key)) {
      return _loadingQueue[key]!.future;
    }
    
    final completer = Completer<void>();
    _loadingQueue[key] = completer;
    
    try {
      if (currentPage.value == 1) {
        dashboardState.value = LoadingState.loading;
      }
      
      final widgets = await _cacheService.getOrFetch(
        key: CacheService.dashboardKey(currentPage.value),
        fetcher: () async {
          final response = await _apiClient.getDashboardWidgets(
            page: currentPage.value,
            limit: pageSize,
          );
          
          if (response.statusCode == 200 && response.data != null) {
            final data = response.data['data'] ?? [];
            return (data as List).map((w) => WidgetModel.fromJson(w)).toList();
          }
          throw Exception('Failed to load dashboard widgets');
        },
        ttl: CacheService.mediumCache,
        forceRefresh: !useCache,
      );
      
      if (currentPage.value == 1) {
        dashboardWidgets.value = widgets;
      } else {
        dashboardWidgets.addAll(widgets);
      }
      
      hasMore.value = widgets.length >= pageSize;
      dashboardState.value = dashboardWidgets.isEmpty 
          ? LoadingState.empty 
          : LoadingState.loaded;
      
      completer.complete();
    } catch (e) {
      dashboardState.value = LoadingState.error;
      error.value = e.toString();
      completer.completeError(e);
      
      // Retry with exponential backoff
      if (retryCount.value < maxRetries) {
        final delay = Duration(seconds: 2 << retryCount.value);
        retryCount.value++;
        await Future.delayed(delay);
        await _loadDashboardWidgets(useCache: useCache);
      }
    } finally {
      _loadingQueue.remove(key);
    }
  }
  
  // Load trending widgets
  Future<void> _loadTrendingWidgets({bool useCache = true}) async {
    try {
      trendingState.value = LoadingState.loading;
      
      final widgets = await _cacheService.getOrFetch(
        key: CacheService.trendingKey(),
        fetcher: () async {
          final response = await _apiClient.getTrendingWidgets();
          
          if (response.statusCode == 200 && response.data != null) {
            final data = response.data['data'] ?? [];
            return (data as List).map((w) => WidgetModel.fromJson(w)).toList();
          }
          throw Exception('Failed to load trending widgets');
        },
        ttl: CacheService.longCache,
        forceRefresh: !useCache,
      );
      
      trendingWidgets.value = widgets;
      trendingState.value = widgets.isEmpty 
          ? LoadingState.empty 
          : LoadingState.loaded;
    } catch (e) {
      trendingState.value = LoadingState.error;
      print('Error loading trending: $e');
    }
  }
  
  // Load popular analysis
  Future<void> _loadPopularAnalysis({bool useCache = true}) async {
    try {
      analysisState.value = LoadingState.loading;
      
      final analyses = await _cacheService.getOrFetch(
        key: CacheService.analysisKey(),
        fetcher: () async {
          final response = await _apiClient.getPopularAnalysis();
          
          if (response.statusCode == 200 && response.data != null) {
            final data = response.data['data'] ?? [];
            return (data as List).map((a) => AnalysisModel.fromJson(a)).toList();
          }
          throw Exception('Failed to load popular analysis');
        },
        ttl: CacheService.longCache,
        forceRefresh: !useCache,
      );
      
      popularAnalysis.value = analyses;
      analysisState.value = analyses.isEmpty 
          ? LoadingState.empty 
          : LoadingState.loaded;
    } catch (e) {
      analysisState.value = LoadingState.error;
      print('Error loading analysis: $e');
    }
  }
  
  // Pull to refresh
  Future<void> refresh() async {
    if (isRefreshing.value) return;
    
    HapticService.mediumImpact();
    isRefreshing.value = true;
    currentPage.value = 1;
    hasMore.value = true;
    error.value = null;
    retryCount.value = 0;
    
    try {
      await Future.wait([
        _loadDashboardWidgets(useCache: false),
        _loadTrendingWidgets(useCache: false),
        _loadPopularAnalysis(useCache: false),
      ], eagerError: false);
      
      HapticService.success();
    } catch (e) {
      HapticService.error();
      Get.snackbar(
        'Refresh Failed',
        'Pull down to try again',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isRefreshing.value = false;
    }
  }
  
  // Load more (pagination)
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    
    isLoadingMore.value = true;
    currentPage.value++;
    
    try {
      await _loadDashboardWidgets(useCache: false);
    } finally {
      isLoadingMore.value = false;
    }
  }
  
  // Retry failed requests
  Future<void> retry() async {
    error.value = null;
    retryCount.value = 0;
    await loadInitialData();
  }
  
  // Search with debouncing
  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Implement search logic
      _performSearch(query);
    });
  }
  
  Future<void> _performSearch(String query) async {
    // Implementation for search
  }
  
  // Optimistic UI updates
  void likeWidget(String widgetId) {
    // Update UI immediately
    final index = dashboardWidgets.indexWhere((w) => w.id == widgetId);
    if (index != -1) {
      final widget = dashboardWidgets[index];
      dashboardWidgets[index] = widget.copyWith(
        isLiked: !widget.isLiked,
        likes: widget.isLiked ? widget.likes - 1 : widget.likes + 1,
      );
    }
    
    // Then make API call
    _apiClient.likeWidget(widgetId).catchError((e) {
      // Revert on error
      if (index != -1) {
        final widget = dashboardWidgets[index];
        dashboardWidgets[index] = widget.copyWith(
          isLiked: !widget.isLiked,
          likes: widget.isLiked ? widget.likes - 1 : widget.likes + 1,
        );
      }
    });
  }
  
  // Clear cache
  Future<void> clearCache() async {
    await _cacheService.clearAll();
  }
  
  // Check if any data is loading
  bool get isLoading => 
      dashboardState.value == LoadingState.loading ||
      trendingState.value == LoadingState.loading ||
      analysisState.value == LoadingState.loading;
  
  // Check if all data is loaded
  bool get isAllLoaded =>
      dashboardState.value == LoadingState.loaded &&
      trendingState.value == LoadingState.loaded &&
      analysisState.value == LoadingState.loaded;
  
  // Check if any error occurred
  bool get hasError =>
      dashboardState.value == LoadingState.error ||
      trendingState.value == LoadingState.error ||
      analysisState.value == LoadingState.error;
}