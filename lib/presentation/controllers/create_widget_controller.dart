import 'package:get/get.dart';
import 'dart:io';
import '../../data/services/api_service.dart';
import '../../core/utils/storage_helper.dart';

enum WidgetType {
  chart,
  table,
  dashboard,
  form,
  custom,
}

class CreateWidgetController extends GetxController {
  final _apiService = ApiService();
  
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
      
      // Prepare widget config
      final config = {
        'prompt': prompt,
        'type': selectedType.value.toString().split('.').last,
        'settings': {
          'realTimeData': useRealTimeData.value,
          'interactive': isInteractive.value,
          'public': isPublic.value,
          'apiEnabled': enableAPI.value,
        },
      };
      
      // Call API to create widget
      final widget = await _apiService.createWidget(
        title: title,
        description: description ?? '',
        config: config,
        tags: ['ai-generated'],
        thumbnail: attachments?.isNotEmpty == true ? attachments!.first : null,
      );
      
      // Save to history
      final widgetData = {
        'id': widget.id,
        'title': title,
        'description': description ?? '',
        'prompt': prompt,
        'type': selectedType.value.toString().split('.').last,
      };
      await saveToHistory(widgetData);
      
      Get.snackbar(
        'Success',
        'Widget created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Navigate to widget view
      Get.toNamed('/widget-view', arguments: widget.toJson());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create widget: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCreating.value = false;
    }
  }
  
  Future<void> generateFromTemplate(String templateId) async {
    try {
      isLoading.value = true;
      
      // For now, return a mock template
      // TODO: Implement API endpoint for templates
      final template = {
        'title': 'Template Widget',
        'description': 'Generated from template',
        'prompt': 'Template prompt',
        'type': 'chart',
      };
      
      // Return template data to populate form
      Get.back(result: template);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load template: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
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