import 'package:get/get.dart';
import 'dart:io';
import '../../services/ai_provider_service.dart';
import '../../services/api_service.dart';
import '../../data/models/ai_provider_model.dart';
import '../../core/utils/storage_helper.dart';
import 'package:get_storage/get_storage.dart';

enum WidgetType {
  chart,
  table,
  dashboard,
  form,
  custom,
}

class AIWidgetController extends GetxController {
  final _aiService = Get.find<AIProviderService>();
  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();
  
  // Observable states
  final isCreating = false.obs;
  final isLoading = false.obs;
  final selectedType = WidgetType.chart.obs;
  final selectedProvider = AIProvider.openai.obs;
  
  // Provider configurations
  final providerConfigs = <AIProviderConfig>[].obs;
  final availableCredits = 0.obs;
  final estimatedCost = 1.obs;
  
  // Advanced options
  final useRealTimeData = false.obs;
  final isInteractive = true.obs;
  final isPublic = false.obs;
  final enableAPI = false.obs;
  
  // Widget history with provider info
  final widgetHistory = <Map<String, dynamic>>[].obs;
  
  // Generation result
  final generatedContent = ''.obs;
  final isStreaming = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  Future<void> _initializeController() async {
    await loadProviderConfigurations();
    await loadWidgetHistory();
    _loadSavedProvider();
    await checkCreditsForProvider(selectedProvider.value);
  }
  
  void _loadSavedProvider() {
    final savedProvider = _storage.read('last_used_provider');
    if (savedProvider != null) {
      try {
        selectedProvider.value = AIProvider.values.firstWhere(
          (e) => e.toString().split('.').last == savedProvider,
        );
      } catch (e) {
        selectedProvider.value = AIProvider.openai;
      }
    }
  }
  
  // Load available provider configurations
  Future<void> loadProviderConfigurations() async {
    try {
      isLoading.value = true;
      providerConfigs.value = await _aiService.getProviderConfigurations();
    } catch (e) {
      print('Error loading provider configs: $e');
      // Use default configurations
      providerConfigs.value = AIProvider.values.map((provider) => 
        AIProviderConfig(
          provider: provider,
          isEnabled: true,
          isPremium: provider == AIProvider.claude || provider == AIProvider.perplexity,
        )
      ).toList();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Change selected AI provider
  Future<void> changeProvider(AIProvider provider) async {
    selectedProvider.value = provider;
    _storage.write('last_used_provider', provider.toString().split('.').last);
    _aiService.setCurrentProvider(provider);
    await checkCreditsForProvider(provider);
    
    // Update estimated cost based on provider
    switch (provider) {
      case AIProvider.claude:
        estimatedCost.value = 3;
        break;
      case AIProvider.openai:
        estimatedCost.value = 2;
        break;
      case AIProvider.gemini:
        estimatedCost.value = 1;
        break;
      case AIProvider.perplexity:
        estimatedCost.value = 4;
        break;
    }
  }
  
  // Check credits for selected provider
  Future<void> checkCreditsForProvider(AIProvider provider) async {
    try {
      final creditInfo = await _aiService.checkProviderCredits(provider);
      availableCredits.value = creditInfo['available'] ?? 0;
      estimatedCost.value = creditInfo['required'] ?? 1;
      
      if (!(creditInfo['canUse'] ?? false)) {
        Get.snackbar(
          'Insufficient Credits',
          'You need ${estimatedCost.value} credits to use ${provider.name}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error checking credits: $e');
    }
  }
  
  // Create widget with selected AI provider
  Future<Map<String, dynamic>?> createWidget({
    required String prompt,
    required String title,
    String? description,
    List<File>? attachments,
    bool streamResponse = false,
  }) async {
    try {
      isCreating.value = true;
      generatedContent.value = '';
      
      // Check credits first
      if (availableCredits.value < estimatedCost.value) {
        Get.snackbar(
          'Insufficient Credits',
          'You need ${estimatedCost.value} credits. You have ${availableCredits.value}.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
      
      // Prepare enhanced prompt with widget context
      final enhancedPrompt = _buildEnhancedPrompt(
        prompt: prompt,
        title: title,
        type: selectedType.value,
      );
      
      Map<String, dynamic> result;
      
      if (streamResponse && attachments == null) {
        // Stream response for better UX
        isStreaming.value = true;
        final stream = _aiService.streamProviderResponse(
          prompt: enhancedPrompt,
          provider: selectedProvider.value,
          additionalParams: {
            'title': title,
            'type': selectedType.value.toString().split('.').last,
            'settings': {
              'realTimeData': useRealTimeData.value,
              'interactive': isInteractive.value,
            },
          },
        );
        
        await for (final chunk in stream) {
          generatedContent.value += chunk;
        }
        
        result = {
          'content': generatedContent.value,
          'provider': selectedProvider.value.name,
        };
      } else {
        // Regular request
        final response = await _aiService.generateWidget(
          prompt: enhancedPrompt,
          provider: selectedProvider.value,
          additionalParams: {
            'title': title,
            'description': description,
            'type': selectedType.value.toString().split('.').last,
            'settings': {
              'realTimeData': useRealTimeData.value,
              'interactive': isInteractive.value,
              'public': isPublic.value,
              'apiEnabled': enableAPI.value,
            },
          },
          attachments: attachments,
        );
        
        generatedContent.value = response.result;
        
        result = {
          'content': response.result,
          'provider': response.provider.name,
          'tokensUsed': response.tokensUsed,
          'creditsUsed': response.creditsUsed,
          'processingTime': response.processingTime?.inMilliseconds,
        };
      }
      
      // Save to history with provider info
      final widgetData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'description': description ?? '',
        'prompt': prompt,
        'type': selectedType.value.toString().split('.').last,
        'provider': selectedProvider.value.name,
        'providerIcon': selectedProvider.value.icon.codePoint,
        'providerColor': selectedProvider.value.color.value,
        'createdAt': DateTime.now().toIso8601String(),
        'result': result,
      };
      
      await saveToHistory(widgetData);
      
      // Update credits
      int creditsToDeduct = (result['creditsUsed'] ?? estimatedCost.value).toInt();
      availableCredits.value = availableCredits.value - creditsToDeduct;
      
      Get.snackbar(
        'Success',
        'Widget created with ${selectedProvider.value.name}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: selectedProvider.value.color.withOpacity(0.9),
        colorText: Get.theme.colorScheme.onPrimary,
      );
      
      return widgetData;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create widget: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return null;
    } finally {
      isCreating.value = false;
      isStreaming.value = false;
    }
  }
  
  // Build enhanced prompt based on widget type
  String _buildEnhancedPrompt({
    required String prompt,
    required String title,
    required WidgetType type,
  }) {
    final typeContext = _getTypeContext(type);
    
    return '''
Create a $typeContext widget with the following requirements:
Title: $title
User Request: $prompt

Please generate a comprehensive solution that includes:
1. Data structure and schema
2. Visual representation details
3. Interactive features if applicable
4. Real-time update capabilities if needed
5. API integration points if required

Focus on creating a production-ready widget that is both functional and visually appealing.
''';
  }
  
  String _getTypeContext(WidgetType type) {
    switch (type) {
      case WidgetType.chart:
        return 'data visualization chart';
      case WidgetType.table:
        return 'interactive data table';
      case WidgetType.dashboard:
        return 'comprehensive dashboard';
      case WidgetType.form:
        return 'dynamic input form';
      case WidgetType.custom:
        return 'custom interactive component';
    }
  }
  
  // Save widget to history
  Future<void> saveToHistory(Map<String, dynamic> widgetData) async {
    widgetHistory.insert(0, widgetData);
    
    // Keep only last 50 items
    if (widgetHistory.length > 50) {
      widgetHistory.removeRange(50, widgetHistory.length);
    }
    
    // Persist to storage
    await _storage.write('widget_history', widgetHistory);
  }
  
  // Load widget history
  Future<void> loadWidgetHistory() async {
    final history = _storage.read('widget_history');
    if (history != null) {
      widgetHistory.value = List<Map<String, dynamic>>.from(history);
    }
  }
  
  // Get provider statistics
  Future<Map<String, dynamic>> getProviderStats() async {
    try {
      return await _aiService.getProviderStats();
    } catch (e) {
      print('Error getting provider stats: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Clear widget history
  void clearHistory() {
    widgetHistory.clear();
    _storage.remove('widget_history');
    Get.snackbar(
      'Success',
      'Widget history cleared',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // Toggle advanced options
  void toggleRealTimeData() => useRealTimeData.toggle();
  void toggleInteractive() => isInteractive.toggle();
  void togglePublic() => isPublic.toggle();
  void toggleAPI() => enableAPI.toggle();
  
  // Change widget type
  void changeWidgetType(WidgetType type) {
    selectedType.value = type;
  }
}