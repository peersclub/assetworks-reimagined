import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/widget_response_model.dart';
import '../../core/utils/storage_helper.dart';

class WidgetController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  // Observable states
  final isCreating = false.obs;
  final isLoading = false.obs;
  final currentSessionId = Rxn<String>(); // For AI conversation continuity
  final generatedWidget = Rxn<WidgetResponseModel>();
  final dashboardWidgets = <WidgetResponseModel>[].obs;
  final trendingWidgets = <WidgetResponseModel>[].obs;
  final popularAnalysis = <Map<String, dynamic>>[].obs;
  final promptHistory = <Map<String, dynamic>>[].obs;
  
  // Remix state
  final remixedWidget = Rxn<WidgetResponseModel>();
  final remixCache = <String, WidgetResponseModel>{}.obs;
  
  // Pagination
  final currentPage = 1.obs;
  final hasMore = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDashboardWidgets();
    loadTrendingWidgets();
  }
  
  // Generate widget using AI
  Future<void> generateWidget({
    required String prompt,
    List<File>? attachments,
    bool updateData = false,
  }) async {
    try {
      isCreating.value = true;
      
      // Use existing session ID if continuing conversation
      final sessionId = currentSessionId.value;
      
      print('Generating widget with prompt: $prompt');
      print('Session ID: $sessionId');
      print('Update data: $updateData');
      
      final response = await _apiClient.generateWidget(
        prompt: prompt,
        updateData: updateData,
        userSessionId: sessionId,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        print('Widget generation response: ${response.data}');
        
        final data = response.data['data'] ?? response.data;
        
        // Store session ID for conversation continuity
        final sessionId = data['user_session_id'] ?? data['userSessionId'] ?? data['session_id'];
        if (sessionId != null) {
          currentSessionId.value = sessionId;
        }
        
        // Parse widget response - check multiple possible structures
        dynamic widgetData;
        
        // Check different possible response structures
        if (data['widget'] != null) {
          widgetData = data['widget'];
        } else if (data['result'] != null) {
          widgetData = data['result'];
        } else if (data['analysis'] != null) {
          widgetData = data['analysis'];
        } else if (data['id'] != null && data['full_version_url'] != null) {
          // Direct widget data
          widgetData = data;
        }
        
        if (widgetData != null) {
          // Create widget from response
          final widget = WidgetResponseModel(
            id: widgetData['id'] ?? widgetData['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            userId: widgetData['user_id'] ?? widgetData['userId'] ?? '',
            title: widgetData['title'] ?? 'Generated Widget',
            summary: widgetData['summary'] ?? '',
            tagline: widgetData['tagline'] ?? '',
            username: widgetData['username'] ?? 'You',
            category: widgetData['category'] ?? 'Custom',
            originalPrompt: prompt,
            fullVersionUrl: widgetData['full_version_url'] ?? widgetData['fullVersionUrl'] ?? '',
            previewVersionUrl: widgetData['preview_version_url'] ?? widgetData['previewVersionUrl'] ?? '',
            likes: widgetData['likes'] ?? 0,
            dislikes: widgetData['dislikes'] ?? 0,
            followers: widgetData['followers'] ?? 0,
            shares: widgetData['shares'] ?? 0,
            like: widgetData['like'] ?? false,
            dislike: widgetData['dislike'] ?? false,
            save: widgetData['save'] ?? false,
            follow: false,
            unfollow: false,
            shared: false,
            reported: false,
            createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            userSessionId: sessionId,
          );
          
          generatedWidget.value = widget;
          
          // Save to history
          await _saveToLocalHistory(widget);
          
          Get.snackbar(
            'Success',
            'Analysis is ready!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          
          // Navigate to widget view
          Get.toNamed('/widget-view', arguments: widget);
        } else {
          // No widget data found - show error
          throw Exception('No widget data received from server');
        }
      } else {
        print('Failed response - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to generate widget: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Widget generation error: $e');
      Get.snackbar(
        'Error',
        'Failed to generate widget: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isCreating.value = false;
    }
  }
  
  // Get related widgets based on prompt intention
  Future<List<WidgetResponseModel>> getRelatedWidgets(String prompt) async {
    try {
      final response = await _apiClient.getPromptIntention(prompt);
      
      if (response.statusCode == 200 && response.data != null) {
        final widgets = (response.data['data'] as List?)
            ?.map((w) => WidgetResponseModel.fromJson(w))
            .toList() ?? [];
        return widgets;
      }
      return [];
    } catch (e) {
      print('Error getting related widgets: $e');
      return [];
    }
  }
  
  // Load dashboard widgets
  Future<void> loadDashboardWidgets({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        dashboardWidgets.clear();
        hasMore.value = true;
      }
      
      if (!hasMore.value) return;
      
      isLoading.value = true;
      
      final response = await _apiClient.getDashboardWidgets(
        page: currentPage.value,
        limit: 10,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final widgets = (response.data['data'] as List?)
            ?.map((w) => WidgetResponseModel.fromJson(w))
            .toList() ?? [];
        
        if (widgets.isEmpty) {
          hasMore.value = false;
        } else {
          dashboardWidgets.addAll(widgets);
          currentPage.value++;
        }
      }
    } catch (e) {
      print('Error loading dashboard widgets: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load trending widgets
  Future<void> loadTrendingWidgets() async {
    try {
      final response = await _apiClient.getTrendingWidgets();
      
      if (response.statusCode == 200 && response.data != null) {
        final widgets = (response.data['data'] as List?)
            ?.map((w) => WidgetResponseModel.fromJson(w))
            .toList() ?? [];
        trendingWidgets.value = widgets;
      }
    } catch (e) {
      print('Error loading trending widgets: $e');
    }
  }
  
  // Load popular analysis
  Future<void> loadPopularAnalysis() async {
    try {
      final response = await _apiClient.getPopularAnalysis();
      
      if (response.statusCode == 200 && response.data != null) {
        popularAnalysis.value = List<Map<String, dynamic>>.from(
          response.data['data'] ?? [],
        );
      }
    } catch (e) {
      print('Error loading popular analysis: $e');
    }
  }
  
  // Load prompt history
  Future<void> loadPromptHistory() async {
    try {
      final response = await _apiClient.getPromptHistory(
        page: 1,
        limit: 20,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        promptHistory.value = List<Map<String, dynamic>>.from(
          response.data['data'] ?? [],
        );
      }
    } catch (e) {
      print('Error loading prompt history: $e');
    }
  }
  
  // Enhance prompt with AI
  Future<String?> enhancePrompt(String prompt) async {
    try {
      // For now, return an enhanced version of the prompt
      // In a real implementation, this would call an AI API
      final enhanced = '''$prompt

Key features to include:
- Real-time data visualization
- Interactive elements for user engagement
- Responsive design for all screen sizes
- Performance optimization for smooth updates
- Clear data presentation with proper formatting''';
      
      return enhanced;
    } catch (e) {
      print('Error enhancing prompt: $e');
      return null;
    }
  }
  
  // Widget actions
  Future<void> likeWidget(String widgetId) async {
    try {
      await _apiClient.likeWidget(widgetId);
      
      // Update local state
      final index = dashboardWidgets.indexWhere((w) => w.id == widgetId);
      if (index != -1) {
        dashboardWidgets[index] = dashboardWidgets[index].copyWith(
          like: true,
          dislike: false,
          likes: dashboardWidgets[index].likes + 1,
        );
      }
    } catch (e) {
      print('Error liking widget: $e');
    }
  }
  
  Future<void> dislikeWidget(String widgetId) async {
    try {
      await _apiClient.dislikeWidget(widgetId);
      
      // Update local state
      final index = dashboardWidgets.indexWhere((w) => w.id == widgetId);
      if (index != -1) {
        dashboardWidgets[index] = dashboardWidgets[index].copyWith(
          like: false,
          dislike: true,
          dislikes: dashboardWidgets[index].dislikes + 1,
        );
      }
    } catch (e) {
      print('Error disliking widget: $e');
    }
  }
  
  Future<void> saveWidget(String widgetId, {String visibility = 'public'}) async {
    try {
      await _apiClient.saveWidgetToProfile(
        widgetId: widgetId,
        visibility: visibility,
      );
      
      // Update local state
      final index = dashboardWidgets.indexWhere((w) => w.id == widgetId);
      if (index != -1) {
        dashboardWidgets[index] = dashboardWidgets[index].copyWith(
          save: true,
        );
      }
      
      Get.snackbar(
        'Success',
        'Widget saved to your profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save widget',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> reportWidget(String widgetId, String reason) async {
    try {
      await _apiClient.reportWidget(widgetId, reason);
      
      Get.snackbar(
        'Reported',
        'Widget has been reported',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to report widget',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> deleteWidgets(List<String> widgetIds) async {
    try {
      await _apiClient.deleteWidgets(widgetIds);
      
      // Remove from local state
      dashboardWidgets.removeWhere((w) => widgetIds.contains(w.id));
      
      Get.snackbar(
        'Success',
        'Widgets deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete widgets',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Export feature removed - no backend support
  // Widget export functionality is not available
  
  // Continue conversation with existing session
  Future<void> continueConversation(String prompt, String sessionId) async {
    currentSessionId.value = sessionId;
    await generateWidget(prompt: prompt);
  }
  
  // Start new conversation
  void startNewConversation() {
    currentSessionId.value = null;
    generatedWidget.value = null;
  }
  
  // Save to local history
  Future<void> _saveToLocalHistory(WidgetResponseModel widget) async {
    try {
      final history = await StorageHelper.getList('widget_history') ?? [];
      
      history.insert(0, {
        'id': widget.id,
        'title': widget.title,
        'prompt': widget.originalPrompt,
        'sessionId': currentSessionId.value,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      // Keep only last 50 items
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }
      
      await StorageHelper.saveList('widget_history', history);
    } catch (e) {
      print('Error saving to history: $e');
    }
  }
  
  // Clear session
  void clearSession() {
    currentSessionId.value = null;
    generatedWidget.value = null;
  }
  
  // Remix functionality
  Future<void> setRemixWidget(WidgetResponseModel widget) async {
    remixedWidget.value = widget;
    // Cache the widget details
    remixCache[widget.id] = widget;
    await StorageHelper.save('remix_widget', widget.toJson());
  }
  
  void clearRemixWidget() {
    remixedWidget.value = null;
    StorageHelper.remove('remix_widget');
  }
  
  Future<WidgetResponseModel?> getWidgetById(String widgetId) async {
    // Check cache first
    if (remixCache.containsKey(widgetId)) {
      return remixCache[widgetId];
    }
    
    try {
      final response = await _apiClient.getWidgetById(widgetId);
      if (response.statusCode == 200 && response.data != null) {
        final widget = WidgetResponseModel.fromJson(
          response.data['data'] ?? response.data,
        );
        remixCache[widgetId] = widget;
        return widget;
      }
    } catch (e) {
      print('Error fetching widget by ID: $e');
    }
    return null;
  }
  
  // Generate remixed widget
  Future<void> generateRemixedWidget({
    required String prompt,
    List<File>? attachments,
  }) async {
    try {
      isCreating.value = true;
      
      // Build the remix prompt with attribution
      String remixPrompt = prompt;
      Map<String, dynamic>? remixData;
      
      if (remixedWidget.value != null) {
        final original = remixedWidget.value!;
        remixData = {
          'is_remix': true,
          'remixed_from_id': original.id,
          'remixed_from_title': original.title,
          'remixed_from_username': original.username,
          'remixed_from_user_id': original.userId,
          'remixed_from_url': original.fullVersionUrl,
          'remixed_from_prompt': original.originalPrompt,
          'remixed_from_created_at': original.createdAt,
        };
        
        // Add context about the remix
        remixPrompt = '''This is a remix of "${original.title}" by @${original.username}.

Original prompt: ${original.originalPrompt}

New requirements:
$prompt''';
      }
      
      print('Generating remixed widget with prompt: $remixPrompt');
      
      final response = await _apiClient.generateWidget(
        prompt: remixPrompt,
        updateData: false,
        userSessionId: currentSessionId.value,
        remixData: remixData,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        
        // Store session ID for conversation continuity
        final sessionId = data['user_session_id'] ?? data['userSessionId'] ?? data['session_id'];
        if (sessionId != null) {
          currentSessionId.value = sessionId;
        }
        
        // Parse widget response
        dynamic widgetData;
        
        if (data['widget'] != null) {
          widgetData = data['widget'];
        } else if (data['result'] != null) {
          widgetData = data['result'];
        } else if (data['analysis'] != null) {
          widgetData = data['analysis'];
        } else if (data['id'] != null && data['full_version_url'] != null) {
          widgetData = data;
        }
        
        if (widgetData != null) {
          // Add remix data to the widget
          if (remixData != null) {
            widgetData.addAll(remixData);
          }
          
          // Create widget from response
          final widget = WidgetResponseModel.fromJson(widgetData);
          
          generatedWidget.value = widget;
          
          // Save to history
          await _saveToLocalHistory(widget);
          
          // Clear remix after successful generation
          clearRemixWidget();
          
          Get.snackbar(
            'Success',
            'Remixed widget created successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          
          // Navigate to widget view
          Get.offNamed('/widget-view', arguments: widget);
        } else {
          throw Exception('No widget data received from server');
        }
      } else {
        throw Exception('Failed to generate widget: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Remix widget generation error: $e');
      Get.snackbar(
        'Error',
        'Failed to create remix: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isCreating.value = false;
    }
  }
}