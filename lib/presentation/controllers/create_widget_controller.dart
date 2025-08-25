import 'package:get/get.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../../core/utils/storage_helper.dart';
import '../../core/network/api_client.dart';

enum WidgetType {
  chart,
  table,
  dashboard,
  form,
  custom,
}

class CreateWidgetController extends GetxController {
  final _apiService = ApiService();
  final _apiClient = ApiClient();
  
  // Observable states
  final isCreating = false.obs;
  final isLoading = false.obs;
  final selectedType = WidgetType.chart.obs;
  
  // Advanced options
  final useRealTimeData = false.obs;
  final isInteractive = true.obs;
  final isPublic = false.obs;
  final enableAPI = false.obs;
  
  // Widget history
  final widgetHistory = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadWidgetHistory();
  }
  
  Future<void> createWidget({
    required String prompt,
    required String title,
    String? description,
    List<File>? attachments,
  }) async {
    try {
      isCreating.value = true;
      
      // Build full prompt with title and description
      String fullPrompt = prompt;
      if (title.isNotEmpty) {
        fullPrompt = "Title: $title\n$prompt";
      }
      if (description != null && description.isNotEmpty) {
        fullPrompt += "\nDescription: $description";
      }
      
      // Add widget type to prompt
      fullPrompt += "\nWidget Type: ${selectedType.value.toString().split('.').last}";
      
      // Call API to create widget from prompt
      final response = await _apiService.createWidgetFromPrompt(fullPrompt);
      
      if (response['success'] == true) {
        final widgetData = response['data'] ?? response;
        
        // Save to history
        final historyData = {
          'id': widgetData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'title': title,
          'description': description ?? '',
          'prompt': prompt,
          'type': selectedType.value.toString().split('.').last,
          'createdAt': DateTime.now().toIso8601String(),
        };
        await saveToHistory(historyData);
        
        Get.snackbar(
          'Success',
          'Widget created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
          colorText: Get.theme.colorScheme.primary,
        );
        
        // Navigate to widget view
        Get.toNamed('/widget-view', arguments: widgetData);
      } else {
        throw Exception(response['message'] ?? 'Failed to create widget');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create widget: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      isCreating.value = false;
    }
  }
  
  Future<void> generateFromTemplate(String templateId) async {
    try {
      isLoading.value = true;
      
      // Fetch all templates and find the one with matching ID
      final response = await _apiClient.getWidgetTemplates();
      
      if (response.statusCode == 200) {
        final templates = response.data['data'] ?? response.data['templates'] ?? [];
        
        // Find the template with matching ID
        Map<String, dynamic>? templateData;
        for (var t in templates) {
          if (t['id'] == templateId || t['_id'] == templateId) {
            templateData = t;
            break;
          }
        }
        
        if (templateData != null) {
          // Track template usage
          try {
            await _apiClient.trackTemplateUsage(templateId);
          } catch (e) {
            print('Error tracking template usage: $e');
          }
          
          // Prepare template data for form population
          final template = {
            'title': templateData['title'] ?? 'Template Widget',
            'description': templateData['description'] ?? '',
            'prompt': templateData['prompt'] ?? templateData['basePrompt'] ?? '',
            'type': templateData['type'] ?? 'chart',
            'category': templateData['category'] ?? 'Custom',
            'tags': templateData['tags'] ?? [],
          };
          
          // Return template data to populate form
          Get.back(result: template);
        } else {
          // Template not found, try to fetch directly if API supports it
          try {
            final directResponse = await _apiClient.dio.get(
              '/api/v1/widgets/templates/$templateId',
            );
            
            if (directResponse.statusCode == 200) {
              final templateData = directResponse.data['data'] ?? directResponse.data;
              
              // Track template usage
              try {
                await _apiClient.trackTemplateUsage(templateId);
              } catch (e) {
                print('Error tracking template usage: $e');
              }
              
              final template = {
                'title': templateData['title'] ?? 'Template Widget',
                'description': templateData['description'] ?? '',
                'prompt': templateData['prompt'] ?? templateData['basePrompt'] ?? '',
                'type': templateData['type'] ?? 'chart',
                'category': templateData['category'] ?? 'Custom',
                'tags': templateData['tags'] ?? [],
              };
              
              Get.back(result: template);
            } else {
              throw Exception('Template not found');
            }
          } catch (e) {
            // If direct fetch fails, show error
            throw Exception('Template not found');
          }
        }
      } else {
        throw Exception('Failed to fetch templates');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load template: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadWidgetHistory() async {
    try {
      final history = await StorageHelper.getList('widget_history');
      if (history != null) {
        widgetHistory.value = List<Map<String, dynamic>>.from(history);
      }
    } catch (e) {
      print('Error loading widget history: $e');
    }
  }
  
  Future<void> saveToHistory(Map<String, dynamic> widgetData) async {
    try {
      widgetData['createdAt'] = DateTime.now().toIso8601String();
      widgetHistory.insert(0, widgetData);
      
      // Keep only last 50 items
      if (widgetHistory.length > 50) {
        widgetHistory.removeRange(50, widgetHistory.length);
      }
      
      await StorageHelper.saveList('widget_history', widgetHistory);
    } catch (e) {
      print('Error saving to history: $e');
    }
  }
  
  void clearHistory() {
    widgetHistory.clear();
    StorageHelper.remove('widget_history');
  }
}