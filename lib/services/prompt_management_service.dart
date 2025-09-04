import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';
import '../data/models/prompt_model.dart';
import '../core/services/storage_service.dart';
import 'api_service.dart';

class PromptManagementService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Observable lists
  final RxList<PromptModel> systemPrompts = <PromptModel>[].obs;
  final RxList<PromptModel> userPrompts = <PromptModel>[].obs;
  
  // Selected prompts for widget generation
  final Rx<PromptModel?> selectedSystemPrompt = Rx<PromptModel?>(null);
  final Rx<PromptModel?> selectedUserPrompt = Rx<PromptModel?>(null);
  
  // Loading states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDefaultPrompts();
    loadSavedPrompts();
  }
  
  /// Load default prompts from backend structure
  void loadDefaultPrompts() {
    // Load default system prompts
    for (var provider in AIProvider.values) {
      final defaultSystemPrompt = PromptModel(
        id: 'default_system_${provider.toString().split('.').last}',
        name: 'Default ${provider.toString().split('.').last.capitalize} System',
        content: DefaultPrompts.systemPrompts[provider] ?? '',
        type: PromptType.system,
        provider: provider,
        isDefault: true,
        isActive: true,
        createdAt: DateTime.now(),
      );
      systemPrompts.add(defaultSystemPrompt);
      
      final defaultIntentionPrompt = PromptModel(
        id: 'default_intention_${provider.toString().split('.').last}',
        name: 'Default ${provider.toString().split('.').last.capitalize} Intention',
        content: DefaultPrompts.intentionPrompts[provider] ?? '',
        type: PromptType.system,
        provider: provider,
        isDefault: true,
        isActive: true,
        createdAt: DateTime.now(),
      );
      systemPrompts.add(defaultIntentionPrompt);
    }
    
    // Set default selected prompts
    if (systemPrompts.isNotEmpty) {
      selectedSystemPrompt.value = systemPrompts.firstWhere(
        (p) => p.provider == AIProvider.claude && p.name.contains('System'),
        orElse: () => systemPrompts.first,
      );
    }
  }
  
  /// Load saved custom prompts from local storage
  Future<void> loadSavedPrompts() async {
    try {
      isLoading.value = true;
      
      // Load from local storage using GetStorage directly
      final storage = GetStorage();
      final savedSystemPrompts = storage.read<List<dynamic>>('system_prompts');
      final savedUserPrompts = storage.read<List<dynamic>>('user_prompts');
      
      if (savedSystemPrompts != null) {
        for (var promptData in savedSystemPrompts) {
          final data = Map<String, dynamic>.from(promptData);
          if (!(data['is_default'] ?? false)) {
            systemPrompts.add(PromptModel.fromJson(data));
          }
        }
      }
      
      if (savedUserPrompts != null) {
        for (var promptData in savedUserPrompts) {
          final data = Map<String, dynamic>.from(promptData);
          userPrompts.add(PromptModel.fromJson(data));
        }
      }
      
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Failed to load saved prompts: $e';
      isLoading.value = false;
    }
  }
  
  /// Fetch system prompts from backend (if endpoint becomes available)
  Future<void> fetchBackendPrompts() async {
    try {
      isLoading.value = true;
      
      // For now, we'll use the default prompts since backend doesn't expose an endpoint
      // When backend adds endpoint, implement like this:
      /*
      final response = await _apiService.dio.get(
        '${_apiService.baseUrl}/api/v1/prompts/system',
        options: dio.Options(
          headers: {'Authorization': 'Bearer ${await _storageService.getAuthToken()}'},
        ),
      );
      
      if (response.statusCode == 200) {
        final prompts = response.data['prompts'] as List;
        for (var promptData in prompts) {
          systemPrompts.add(PromptModel.fromJson(promptData));
        }
      }
      */
      
      // Simulate fetching with a delay
      await Future.delayed(Duration(seconds: 1));
      
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Failed to fetch backend prompts: $e';
      isLoading.value = false;
    }
  }
  
  /// Create a new prompt
  Future<bool> createPrompt({
    required String name,
    required String content,
    required PromptType type,
    required AIProvider provider,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate prompt compatibility
      final isValid = await validatePromptCompatibility(content, type, provider);
      if (!isValid) {
        errorMessage.value = 'Prompt is not compatible with backend format';
        return false;
      }
      
      final newPrompt = PromptModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        content: content,
        type: type,
        provider: provider,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
        metadata: metadata,
      );
      
      if (type == PromptType.system) {
        systemPrompts.add(newPrompt);
        await _savePromptsToStorage();
      } else {
        userPrompts.add(newPrompt);
        await _savePromptsToStorage();
      }
      
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to create prompt: $e';
      return false;
    }
  }
  
  /// Update an existing prompt
  Future<bool> updatePrompt({
    required String id,
    required String name,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Find the prompt
      PromptModel? prompt;
      int index = -1;
      
      index = systemPrompts.indexWhere((p) => p.id == id);
      if (index != -1) {
        prompt = systemPrompts[index];
      } else {
        index = userPrompts.indexWhere((p) => p.id == id);
        if (index != -1) {
          prompt = userPrompts[index];
        }
      }
      
      if (prompt == null || prompt.isDefault) {
        errorMessage.value = 'Cannot update default or non-existent prompt';
        return false;
      }
      
      // Validate updated content
      final isValid = await validatePromptCompatibility(content, prompt.type, prompt.provider);
      if (!isValid) {
        errorMessage.value = 'Updated prompt is not compatible with backend format';
        return false;
      }
      
      final updatedPrompt = prompt.copyWith(
        name: name,
        content: content,
        updatedAt: DateTime.now(),
        metadata: metadata,
      );
      
      if (prompt.type == PromptType.system) {
        systemPrompts[systemPrompts.indexWhere((p) => p.id == id)] = updatedPrompt;
      } else {
        userPrompts[userPrompts.indexWhere((p) => p.id == id)] = updatedPrompt;
      }
      
      await _savePromptsToStorage();
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to update prompt: $e';
      return false;
    }
  }
  
  /// Delete a prompt
  Future<bool> deletePrompt(String id) async {
    try {
      // Check if it's a default prompt
      final isDefault = systemPrompts.any((p) => p.id == id && p.isDefault);
      if (isDefault) {
        errorMessage.value = 'Cannot delete default prompts';
        return false;
      }
      
      // Remove from lists
      systemPrompts.removeWhere((p) => p.id == id && !p.isDefault);
      userPrompts.removeWhere((p) => p.id == id);
      
      // Update selection if needed
      if (selectedSystemPrompt.value?.id == id) {
        selectedSystemPrompt.value = systemPrompts.firstWhere(
          (p) => p.isDefault,
          orElse: () => systemPrompts.first,
        );
      }
      if (selectedUserPrompt.value?.id == id) {
        selectedUserPrompt.value = null;
      }
      
      await _savePromptsToStorage();
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to delete prompt: $e';
      return false;
    }
  }
  
  /// Validate prompt compatibility with backend
  Future<bool> validatePromptCompatibility(
    String content,
    PromptType type,
    AIProvider provider,
  ) async {
    try {
      // Check for required format markers based on backend structure
      if (type == PromptType.system) {
        // System prompts should contain certain keywords/structure
        final requiredKeywords = [
          'financial',
          'widget',
          'visualization',
          'html',
        ];
        
        final contentLower = content.toLowerCase();
        final hasRequiredStructure = requiredKeywords.any((keyword) => 
          contentLower.contains(keyword)
        );
        
        if (!hasRequiredStructure) {
          errorMessage.value = 'System prompt must include financial widget generation instructions';
          return false;
        }
        
        // Check for output format section
        if (!content.contains('```html') && !content.contains('OUTPUT') && !content.contains('Format')) {
          errorMessage.value = 'System prompt must specify output format for HTML generation';
          return false;
        }
      } else {
        // User prompts should be simpler
        if (content.length < 10) {
          errorMessage.value = 'User prompt is too short';
          return false;
        }
        
        if (content.length > 5000) {
          errorMessage.value = 'User prompt is too long (max 5000 characters)';
          return false;
        }
      }
      
      // Additional provider-specific validation
      switch (provider) {
        case AIProvider.claude:
          // Claude specific validation
          if (type == PromptType.system && !content.contains('assistant')) {
            print('Warning: Claude system prompts typically mention "assistant"');
          }
          break;
        case AIProvider.openai:
          // OpenAI specific validation
          if (content.length > 4000) {
            errorMessage.value = 'OpenAI prompts should be under 4000 characters';
            return false;
          }
          break;
        case AIProvider.gemini:
          // Gemini specific validation
          break;
        case AIProvider.perplexity:
          // Perplexity specific validation
          break;
      }
      
      return true;
    } catch (e) {
      errorMessage.value = 'Validation error: $e';
      return false;
    }
  }
  
  /// Save prompts to local storage
  Future<void> _savePromptsToStorage() async {
    try {
      final storage = GetStorage();
      
      // Save system prompts (excluding defaults)
      final customSystemPrompts = systemPrompts
          .where((p) => !p.isDefault)
          .map((p) => p.toJson())
          .toList();
      await storage.write('system_prompts', customSystemPrompts);
      
      // Save user prompts
      final userPromptsList = userPrompts.map((p) => p.toJson()).toList();
      await storage.write('user_prompts', userPromptsList);
    } catch (e) {
      print('Failed to save prompts to storage: $e');
    }
  }
  
  /// Get formatted prompt for widget generation
  String getFormattedPrompt({
    String? userInput,
    Map<String, dynamic>? theme,
  }) {
    final systemPrompt = selectedSystemPrompt.value?.content ?? '';
    final userPrompt = selectedUserPrompt.value?.content ?? userInput ?? '';
    
    // Apply theme variables if provided
    String formattedSystem = systemPrompt;
    if (theme != null) {
      formattedSystem = formattedSystem
          .replaceAll('{theme_name}', theme['name'] ?? 'default')
          .replaceAll('{primary_color}', theme['primary_color'] ?? '#007AFF')
          .replaceAll('{background_color}', theme['background_color'] ?? '#FFFFFF')
          .replaceAll('{text_color}', theme['text_color'] ?? '#000000')
          .replaceAll('{font_family}', theme['font_family'] ?? 'SF Pro Display');
    }
    
    // Combine prompts based on backend format
    if (formattedSystem.contains('\$system_prompt\$')) {
      // Backend custom format
      return formattedSystem.replaceAll('\$system_prompt\$', userPrompt);
    } else if (formattedSystem.contains('##user_prompt##')) {
      // Alternative backend format
      return formattedSystem.replaceAll('##user_prompt##', userPrompt);
    } else {
      // Default combination
      return '$formattedSystem\n\nUser Request: $userPrompt';
    }
  }
  
  /// Clear all custom prompts
  Future<void> clearCustomPrompts() async {
    final storage = GetStorage();
    systemPrompts.removeWhere((p) => !p.isDefault);
    userPrompts.clear();
    await storage.remove('system_prompts');
    await storage.remove('user_prompts');
  }
  
  /// Export prompts to JSON
  Map<String, dynamic> exportPrompts() {
    return {
      'system_prompts': systemPrompts
          .where((p) => !p.isDefault)
          .map((p) => p.toJson())
          .toList(),
      'user_prompts': userPrompts.map((p) => p.toJson()).toList(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }
  
  /// Import prompts from JSON
  Future<bool> importPrompts(Map<String, dynamic> data) async {
    try {
      if (data['system_prompts'] != null) {
        for (var promptData in data['system_prompts']) {
          final prompt = PromptModel.fromJson(promptData);
          if (!systemPrompts.any((p) => p.id == prompt.id)) {
            systemPrompts.add(prompt);
          }
        }
      }
      
      if (data['user_prompts'] != null) {
        for (var promptData in data['user_prompts']) {
          final prompt = PromptModel.fromJson(promptData);
          if (!userPrompts.any((p) => p.id == prompt.id)) {
            userPrompts.add(prompt);
          }
        }
      }
      
      await _savePromptsToStorage();
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to import prompts: $e';
      return false;
    }
  }
}