import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../data/models/widget_template_model.dart';
import '../../data/models/widget_template.dart';
import '../../data/templates/finance_templates.dart';
import '../../core/utils/storage_helper.dart';

class TemplateController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  // Observable states
  final isLoading = false.obs;
  final templates = <WidgetTemplate>[].obs;
  final recentTemplates = <WidgetTemplate>[].obs;
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  
  // Categories
  final categories = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadTemplates();
    loadCategories();
  }
  
  void loadCategories() {
    categories.value = ['All', ...FinanceTemplates.getCategories()];
  }
  
  Future<void> loadTemplates() async {
    try {
      isLoading.value = true;
      
      // Try to load from API first
      final response = await _apiClient.getWidgetTemplates();
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        
        // If we get templates from API, use them
        if (data.isNotEmpty) {
          // Convert API templates to our model
          final apiTemplates = data.map((t) {
            return WidgetTemplate(
              id: t['id']?.toString() ?? '',
              title: t['title'] ?? '',
              description: t['description'] ?? '',
              prompt: t['prompt'] ?? t['basePrompt'] ?? '',
              type: t['type'] ?? 'custom',
              icon: _getIconForCategory(t['category'] ?? ''),
              tags: List<String>.from(t['tags'] ?? []),
              category: t['category'] ?? 'Custom',
              usageCount: t['usageCount'] ?? 0,
            );
          }).toList();
          
          // Combine with finance templates
          templates.value = [...FinanceTemplates.templates, ...apiTemplates];
        } else {
          // If no API templates, use hardcoded finance templates
          print('[TemplateController] No templates returned from API, using fallback finance templates');
          _logTemplateFallback('No API templates available');
          templates.value = FinanceTemplates.templates;
        }
      } else {
        // If API fails, use hardcoded finance templates
        print('[TemplateController] API request failed with status: ${response.statusCode}, using fallback templates');
        _logTemplateFallback('API request failed: Status ${response.statusCode}');
        templates.value = FinanceTemplates.templates;
      }
      
      // Sort by usage count
      templates.sort((a, b) => b.usageCount.compareTo(a.usageCount));
      
      // Load recent templates from local storage
      _loadRecentTemplates();
      
    } catch (e) {
      print('[TemplateController] Error loading templates: $e');
      print('[TemplateController] Stack trace: ${StackTrace.current}');
      _logTemplateFallback('Exception: ${e.toString()}');
      // Load offline templates as fallback
      templates.value = FinanceTemplates.templates;
      
      // Show user-friendly notification about fallback
      if (Get.isSnackbarOpen != true) {
        Get.snackbar(
          'Offline Mode',
          'Using cached templates. Some templates may not be available.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Get.theme.colorScheme.surface,
          colorText: Get.theme.colorScheme.onSurface,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  void _loadRecentTemplates() {
    // Load recently used templates from local storage
    final recentIds = StorageHelper.getList('recent_templates') ?? [];
    recentTemplates.value = templates
        .where((t) => recentIds.contains(t.id))
        .take(5)
        .toList();
  }
  
  Future<void> useTemplate(WidgetTemplate template) async {
    try {
      // Track template usage
      await _apiClient.trackTemplateUsage(template.id);
      
      // Update local recent templates
      final recentIds = StorageHelper.getList('recent_templates') ?? [];
      recentIds.remove(template.id);
      recentIds.insert(0, template.id);
      
      // Keep only last 10
      if (recentIds.length > 10) {
        recentIds.removeRange(10, recentIds.length);
      }
      
      await StorageHelper.saveList('recent_templates', recentIds);
      _loadRecentTemplates();
      
    } catch (e) {
      print('Error tracking template usage: $e');
    }
  }
  
  List<WidgetTemplate> get filteredTemplates {
    var filtered = templates.where((template) {
      // Category filter
      if (selectedCategory.value != 'All' && template.category != selectedCategory.value) {
        return false;
      }
      
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        return template.title.toLowerCase().contains(query) ||
               template.description.toLowerCase().contains(query) ||
               template.tags.any((tag) => tag.toLowerCase().contains(query));
      }
      
      return true;
    }).toList();
    
    // Sort by usage count
    filtered.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    
    return filtered;
  }
  
  List<WidgetTemplate> getPopularTemplates({int limit = 10}) {
    return FinanceTemplates.getPopular(limit: limit);
  }
  
  List<WidgetTemplate> getTemplatesByCategory(String category) {
    if (category == 'All') {
      return templates;
    }
    return templates.where((t) => t.category == category).toList();
  }
  
  void setCategory(String category) {
    selectedCategory.value = category;
  }
  
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  dynamic _getIconForCategory(String category) {
    // Return appropriate icon based on category
    switch (category.toLowerCase()) {
      case 'finance':
      case 'financial':
        return 56; // LucideIcons.dollarSign code
      case 'analytics':
        return 57; // LucideIcons.barChart code
      case 'sales':
        return 58; // LucideIcons.trendingUp code
      default:
        return 59; // LucideIcons.layout code
    }
  }
  
  void _logTemplateFallback(String reason) {
    // Log template fallback event for monitoring
    final fallbackEvent = {
      'timestamp': DateTime.now().toIso8601String(),
      'reason': reason,
      'templatesLoaded': templates.length,
      'networkAvailable': Get.isSnackbarOpen != null, // Simple network check
    };
    
    // Save to local storage for debugging/analytics
    try {
      final fallbackLogs = StorageHelper.getList('template_fallback_logs') ?? [];
      fallbackLogs.add(fallbackEvent);
      
      // Keep only last 50 logs
      if (fallbackLogs.length > 50) {
        fallbackLogs.removeRange(0, fallbackLogs.length - 50);
      }
      
      StorageHelper.saveList('template_fallback_logs', fallbackLogs);
    } catch (e) {
      print('[TemplateController] Error logging fallback: $e');
    }
  }
}