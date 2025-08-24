import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/widget_model.dart';
import '../../data/models/analysis_model.dart';

enum DashboardTab { saved, history }
enum SortBy { date, name, popularity, rating }
enum FilterType { all, widgets, analysis, shared }

class DashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Observable states
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = ''.obs;
  final currentTab = DashboardTab.saved.obs;
  final sortBy = SortBy.date.obs;
  final filterType = FilterType.all.obs;
  
  // Data
  final dashboardWidgets = <WidgetModel>[].obs;
  final historyItems = <dynamic>[].obs;
  final savedWidgets = <WidgetModel>[].obs;
  final recentAnalysis = <AnalysisModel>[].obs;
  
  // Removed market data - no backend support
  
  // Pagination
  int _currentPage = 1;
  final hasMore = true.obs;
  final int _pageSize = 20;
  
  // Search and filter
  final searchQuery = ''.obs;
  final selectedTags = <String>[].obs;
  final dateRange = Rxn<DateTimeRange>();
  
  // Refresh control
  Timer? _refreshTimer;
  final lastRefreshTime = DateTime.now().obs;
  
  @override
  void onInit() {
    super.onInit();
    // Load data immediately on init with loading state
    isLoading.value = true;
    loadDashboardData();
    _setupAutoRefresh();
  }
  
  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
  
  // ============== Data Loading ==============
  
  Future<void> loadDashboardData({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      hasMore.value = true;
      dashboardWidgets.clear();
      historyItems.clear();
    }
    
    // Skip loading check only for non-reset calls
    if (!reset && (isLoading.value || !hasMore.value)) return;
    
    try {
      // Only set loading if not already set (e.g., from onInit)
      if (!isLoading.value) {
        isLoading.value = true;
      }
      error.value = '';
      
      // First try to load from cache for instant display
      if (_currentPage == 1 && !reset) {
        await _loadFromCache();
      }
      
      // Load based on current tab
      if (currentTab.value == DashboardTab.saved) {
        await _loadSavedWidgets();
      } else {
        await _loadHistory();
      }
      
      // Market data removed - no backend support
      
      // Update last refresh time
      lastRefreshTime.value = DateTime.now();
      
      // Cache data for offline access
      await _cacheData();
      
    } catch (e) {
      error.value = e.toString();
      
      // Try to load from cache if network fails and we haven't already
      if (dashboardWidgets.isEmpty && historyItems.isEmpty) {
        await _loadFromCache();
      }
      
      // Only show error if we have no data at all
      if (dashboardWidgets.isEmpty && historyItems.isEmpty) {
        Get.snackbar(
          'Error',
          'Failed to load dashboard data: ${error.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _loadSavedWidgets() async {
    final filter = _buildFilterQuery();
    final sort = _getSortQuery();
    
    final widgets = await _apiService.getDashboardWidgets(
      page: _currentPage,
      filter: filter,
      sortBy: sort,
    );
    
    if (widgets.isEmpty) {
      hasMore.value = false;
    } else {
      if (_currentPage == 1) {
        savedWidgets.value = widgets;
        dashboardWidgets.value = widgets;
      } else {
        savedWidgets.addAll(widgets);
        dashboardWidgets.addAll(widgets);
      }
      
      if (widgets.length < _pageSize) {
        hasMore.value = false;
      }
    }
  }
  
  Future<void> _loadHistory() async {
    final history = await _apiService.getAnalysisHistory(page: _currentPage);
    
    if (history.isEmpty) {
      hasMore.value = false;
    } else {
      if (_currentPage == 1) {
        historyItems.value = history;
      } else {
        historyItems.addAll(history);
      }
      
      if (history.length < _pageSize) {
        hasMore.value = false;
      }
    }
  }
  
  // Market data loading removed - no backend support
  
  // ============== Pagination ==============
  
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    
    try {
      isLoadingMore.value = true;
      _currentPage++;
      await loadDashboardData();
    } finally {
      isLoadingMore.value = false;
    }
  }
  
  Future<void> refresh() async {
    await loadDashboardData(reset: true);
  }
  
  // ============== Filtering & Sorting ==============
  
  void changeTab(DashboardTab tab) {
    if (currentTab.value != tab) {
      currentTab.value = tab;
      loadDashboardData(reset: true);
    }
  }
  
  void changeSortBy(SortBy sort) {
    if (sortBy.value != sort) {
      sortBy.value = sort;
      loadDashboardData(reset: true);
    }
  }
  
  void changeFilter(FilterType filter) {
    if (filterType.value != filter) {
      filterType.value = filter;
      loadDashboardData(reset: true);
    }
  }
  
  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    loadDashboardData(reset: true);
  }
  
  void setDateRange(DateTimeRange? range) {
    dateRange.value = range;
    loadDashboardData(reset: true);
  }
  
  void search(String query) {
    searchQuery.value = query;
    
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchQuery.value == query) {
        loadDashboardData(reset: true);
      }
    });
  }
  
  void clearFilters() {
    filterType.value = FilterType.all;
    selectedTags.clear();
    dateRange.value = null;
    searchQuery.value = '';
    loadDashboardData(reset: true);
  }
  
  String _buildFilterQuery() {
    final filters = <String>[];
    
    if (filterType.value != FilterType.all) {
      filters.add('type:${filterType.value.name}');
    }
    
    if (selectedTags.isNotEmpty) {
      filters.add('tags:${selectedTags.join(',')}');
    }
    
    if (dateRange.value != null) {
      filters.add('from:${dateRange.value!.start.toIso8601String()}');
      filters.add('to:${dateRange.value!.end.toIso8601String()}');
    }
    
    if (searchQuery.value.isNotEmpty) {
      filters.add('q:${searchQuery.value}');
    }
    
    return filters.join('&');
  }
  
  String _getSortQuery() {
    switch (sortBy.value) {
      case SortBy.date:
        return '-created_at';
      case SortBy.name:
        return 'title';
      case SortBy.popularity:
        return '-views';
      case SortBy.rating:
        return '-rating';
    }
  }
  
  // ============== Widget Actions ==============
  
  Future<void> saveWidget(String widgetId) async {
    try {
      await _apiService.saveWidget(widgetId);
      
      // Update local state
      final index = dashboardWidgets.indexWhere((w) => w.id == widgetId);
      if (index != -1) {
        dashboardWidgets[index] = dashboardWidgets[index].copyWith(isSaved: true);
      }
      
      Get.snackbar(
        'Saved',
        'Widget saved to your dashboard',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save widget: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> unsaveWidget(String widgetId) async {
    try {
      await _apiService.unsaveWidget(widgetId);
      
      // Remove from saved widgets
      savedWidgets.removeWhere((w) => w.id == widgetId);
      dashboardWidgets.removeWhere((w) => w.id == widgetId);
      
      Get.snackbar(
        'Removed',
        'Widget removed from your dashboard',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove widget: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> likeWidget(String widgetId) async {
    try {
      await _apiService.likeWidget(widgetId);
      
      // Update local state
      final index = dashboardWidgets.indexWhere((w) => w.id == widgetId);
      if (index != -1) {
        dashboardWidgets[index] = dashboardWidgets[index].copyWith(
          isLiked: true,
          likes: dashboardWidgets[index].likes + 1,
        );
      }
    } catch (e) {
      print('Failed to like widget: $e');
    }
  }
  
  Future<void> unlikeWidget(String widgetId) async {
    try {
      await _apiService.unlikeWidget(widgetId);
      
      // Update local state
      final index = dashboardWidgets.indexWhere((w) => w.id == widgetId);
      if (index != -1) {
        dashboardWidgets[index] = dashboardWidgets[index].copyWith(
          isLiked: false,
          likes: dashboardWidgets[index].likes - 1,
        );
      }
    } catch (e) {
      print('Failed to unlike widget: $e');
    }
  }
  
  Future<String?> shareWidget(String widgetId) async {
    try {
      final response = await _apiService.shareWidget(widgetId);
      return response['share_url'];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share widget: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }
  
  Future<bool> reportWidget(String widgetId, String reason) async {
    try {
      await _apiService.reportWidget(widgetId, reason);
      
      Get.snackbar(
        'Reported',
        'Thank you for your feedback. We will review this widget.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to report widget: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  Future<void> deleteWidget(String widgetId) async {
    try {
      // Show confirmation dialog
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Widget'),
          content: const Text('Are you sure you want to delete this widget? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirm == true) {
        await _apiService.deleteWidget(widgetId);
        
        // Remove from local state
        savedWidgets.removeWhere((w) => w.id == widgetId);
        dashboardWidgets.removeWhere((w) => w.id == widgetId);
        
        Get.snackbar(
          'Deleted',
          'Widget has been deleted',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete widget: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // ============== Cache Management ==============
  
  Future<void> _cacheData() async {
    try {
      // Cache widgets
      await _storageService.saveCache(
        'dashboard_widgets',
        dashboardWidgets.map((w) => w.toJson()).toList(),
        validFor: const Duration(hours: 1),
      );
      
      // Cache history
      await _storageService.saveCache(
        'dashboard_history',
        historyItems,
        validFor: const Duration(hours: 1),
      );
      
      // Market data caching removed - no backend support
    } catch (e) {
      print('Failed to cache data: $e');
    }
  }
  
  Future<void> _loadFromCache() async {
    try {
      // Load cached widgets
      final cachedWidgets = _storageService.getCache('dashboard_widgets');
      if (cachedWidgets != null) {
        dashboardWidgets.value = (cachedWidgets as List)
            .map((json) => WidgetModel.fromJson(json))
            .toList();
      }
      
      // Load cached history
      final cachedHistory = _storageService.getCache('dashboard_history');
      if (cachedHistory != null) {
        historyItems.value = List.from(cachedHistory);
      }
      
      // Market data cache loading removed - no backend support
    } catch (e) {
      print('Failed to load from cache: $e');
    }
  }
  
  // ============== Auto Refresh ==============
  
  void _setupAutoRefresh() {
    // Auto refresh every 5 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!isLoading.value) {
        // Refresh dashboard data
        loadDashboardData();
      }
    });
  }
  
  // ============== Getters ==============
  
  bool get hasActiveFilters {
    return filterType.value != FilterType.all ||
        selectedTags.isNotEmpty ||
        dateRange.value != null ||
        searchQuery.value.isNotEmpty;
  }
  
  int get totalWidgets => savedWidgets.length;
  int get totalHistory => historyItems.length;
  
  // Portfolio getters removed - no backend support
}