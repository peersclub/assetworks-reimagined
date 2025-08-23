import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../data/models/widget_response_model.dart';

class DiscoveryController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  // Observable states
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isLoadingTrending = false.obs;
  final widgets = <WidgetResponseModel>[].obs;
  final trendingWidgets = <WidgetResponseModel>[].obs;
  final guestWidgets = <WidgetResponseModel>[].obs;
  
  // Filters
  final selectedCategory = 'All'.obs;
  final sortBy = 'Popular'.obs;
  final searchQuery = ''.obs;
  
  // Pagination
  final currentPage = 1.obs;
  final hasMore = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Load both widgets and trending in parallel for faster initial load
    Future.wait([
      loadWidgets(),
      loadTrendingWidgets(),
    ]);
  }
  
  Future<void> loadWidgets({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      widgets.clear();
      hasMore.value = true;
    }
    
    if (!hasMore.value) return;
    
    try {
      if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      
      final response = await _apiClient.getDashboardWidgets(
        page: currentPage.value,
        limit: 20,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        
        if (data.isEmpty) {
          hasMore.value = false;
        } else {
          final newWidgets = data
              .map((w) => WidgetResponseModel.fromJson(w))
              .toList();
          
          widgets.addAll(newWidgets);
          currentPage.value++;
        }
      }
    } catch (e) {
      print('Error loading widgets: $e');
      Get.snackbar(
        'Error',
        'Failed to load widgets',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
  
  Future<void> loadTrendingWidgets() async {
    try {
      isLoadingTrending.value = true;
      final response = await _apiClient.getTrendingWidgets();
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        trendingWidgets.value = data
            .map((w) => WidgetResponseModel.fromJson(w))
            .toList();
      }
    } catch (e) {
      print('Error loading trending widgets: $e');
    } finally {
      isLoadingTrending.value = false;
    }
  }
  
  Future<void> loadGuestWidgets() async {
    try {
      final response = await _apiClient.getGuestWidgets();
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        guestWidgets.value = data
            .map((w) => WidgetResponseModel.fromJson(w))
            .toList();
      }
    } catch (e) {
      print('Error loading guest widgets: $e');
    }
  }
  
  void searchWidgets(String query) {
    searchQuery.value = query;
    loadWidgets(refresh: true);
  }
  
  void filterByCategory(String category) {
    selectedCategory.value = category;
    loadWidgets(refresh: true);
  }
  
  void changeSortBy(String sort) {
    sortBy.value = sort;
    loadWidgets(refresh: true);
  }
  
  List<WidgetResponseModel> get filteredWidgets {
    var filtered = widgets.toList();
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((w) {
        return w.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
               w.summary.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
               w.tagline.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
    
    // Apply category filter
    if (selectedCategory.value != 'All') {
      filtered = filtered.where((w) => w.category == selectedCategory.value).toList();
    }
    
    // Apply sorting
    switch (sortBy.value) {
      case 'Popular':
        filtered.sort((a, b) => (b.likes + b.shares).compareTo(a.likes + a.shares));
        break;
      case 'Recent':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Most Liked':
        filtered.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case 'Most Viewed':
        filtered.sort((a, b) => b.shares.compareTo(a.shares));
        break;
    }
    
    return filtered;
  }
}