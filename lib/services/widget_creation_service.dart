import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../data/models/widget_model.dart';
import '../core/services/storage_service.dart';
import '../services/api_service.dart';

class WidgetIntention {
  final String prompt;
  final String widgetType;
  final Map<String, dynamic> parameters;
  final String style;
  final List<String> features;
  
  WidgetIntention({
    required this.prompt,
    required this.widgetType,
    required this.parameters,
    required this.style,
    required this.features,
  });
  
  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'widget_type': widgetType,
    'parameters': parameters,
    'style': style,
    'features': features,
  };
}

class WidgetCreationService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Backend API endpoints
  static const String _intentionEndpoint = '/api/v1/widgets/generate';
  static const String _resultEndpoint = '/api/v1/prompts/result';
  static const String _attachmentEndpoint = '/api/v1/prompts/attachments';
  
  // Cache for templates
  final Map<String, WidgetModel> _templateCache = {};
  
  @override
  void onInit() {
    super.onInit();
    _loadTemplateCache();
  }
  
  /// Analyzes a user prompt to generate widget intention
  Future<WidgetIntention> analyzePrompt(String prompt) async {
    try {
      // Since the backend doesn't have a separate intention endpoint,
      // we'll create a local intention based on the prompt
      return WidgetIntention(
        prompt: prompt,
        widgetType: _detectWidgetType(prompt),
        parameters: {
          'theme': 'dark',
          'style': 'modern',
        },
        style: 'glassmorphism',
        features: _extractFeatures(prompt),
      );
    } catch (e) {
      throw Exception('Failed to analyze prompt: $e');
    }
  }
  
  /// Generates a widget based on the intention
  Future<WidgetModel> generateWidget(WidgetIntention intention) async {
    try {
      // Call API with extended timeout for real generation
      final response = await _apiService.createWidgetFromPrompt(intention.prompt);
      
      if (response['success'] == true && response['widget'] != null) {
        // Parse the generated widget
        return _parseWidget({'data': response['widget']});
      } else {
        throw Exception(response['message'] ?? 'Failed to generate widget');
      }
    } catch (e) {
      // More detailed error handling
      if (e.toString().contains('404')) {
        throw Exception('API endpoint not available. Please check backend configuration.');
      } else if (e.toString().contains('401')) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Widget generation is taking longer than expected. Please try again.');
      } else if (e.toString().contains('Authentication required')) {
        throw Exception('Please login to generate widgets.');
      }
      throw Exception('${e.toString().replaceAll('Exception:', '').trim()}');
    }
  }
  
  /// Uploads attachments for widget creation
  Future<List<String>> uploadAttachments(List<String> filePaths) async {
    try {
      final uploadedUrls = <String>[];
      
      for (final path in filePaths) {
        final formData = dio.FormData.fromMap({
          'file': await dio.MultipartFile.fromFile(path),
          'user_id': _storageService.getUser()?['id'] ?? 'anonymous',
        });
        
        final response = await _makeApiCall(
          endpoint: _attachmentEndpoint,
          body: formData,
          isMultipart: true,
        );
        
        if (response['url'] != null) {
          uploadedUrls.add(response['url']);
        }
      }
      
      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload attachments: $e');
    }
  }
  
  /// Saves a generated widget
  Future<void> saveWidget(WidgetModel widget) async {
    try {
      // Save to local storage
      // Save widget to local storage
      await _storageService.save('widget_${widget.id}', widget.toJson());
      
      // Sync with backend if user is authenticated
      if (_storageService.isAuthenticated) {
        await _syncWidgetToBackend(widget);
      }
    } catch (e) {
      throw Exception('Failed to save widget: $e');
    }
  }
  
  /// Loads a template by name
  Future<WidgetModel?> loadTemplate(String templateName) async {
    try {
      // Check cache first
      if (_templateCache.containsKey(templateName)) {
        return _templateCache[templateName];
      }
      
      // Generate from template prompt
      final templatePrompt = _getTemplatePrompt(templateName);
      final intention = await analyzePrompt(templatePrompt);
      final widget = await generateWidget(intention);
      
      // Cache the template
      _templateCache[templateName] = widget;
      
      return widget;
    } catch (e) {
      print('Failed to load template: $e');
      return null;
    }
  }
  
  /// Makes an API call to the backend
  Future<Map<String, dynamic>> _makeApiCall({
    required String endpoint,
    required dynamic body,
    bool isMultipart = false,
  }) async {
    try {
      final client = dio.Dio();
      
      // Set up headers
      final token = await _storageService.getAuthToken();
      final headers = {
        'Authorization': 'Bearer $token',
        if (!isMultipart) 'Content-Type': 'application/json',
      };
      
      // Make the request
      final response = await client.post(
        '${_apiService.baseUrl}$endpoint',
        data: body,
        options: dio.Options(headers: headers),
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is dio.DioException) {
        throw Exception('Network error: ${e.message}');
      }
      throw e;
    }
  }
  
  /// Parses intention from API response
  WidgetIntention _parseIntention(Map<String, dynamic> response) {
    final data = response['data'] ?? {};
    
    return WidgetIntention(
      prompt: data['prompt'] ?? '',
      widgetType: data['widget_type'] ?? 'custom',
      parameters: data['parameters'] ?? {},
      style: data['style'] ?? 'modern',
      features: List<String>.from(data['features'] ?? []),
    );
  }
  
  /// Parses widget from API response
  WidgetModel _parseWidget(Map<String, dynamic> response) {
    final data = response['data'] ?? {};
    
    return WidgetModel(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? 'Generated Widget',
      description: data['description'] ?? '',
      thumbnail: data['thumbnail'] ?? data['image_url'],
      authorId: data['author_id'] ?? 'ai_system',
      authorName: data['author_name'] ?? data['creator'] ?? 'AI',
      authorAvatar: data['author_avatar'] ?? data['creator_avatar'],
      config: data['config'] ?? {},
      tags: List<String>.from(data['tags'] ?? []),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      shares: data['shares'] ?? 0,
      views: data['views'] ?? 0,
      isLiked: data['is_liked'] ?? false,
      isSaved: data['is_saved'] ?? false,
      isPublic: data['is_public'] ?? true,
      isFeatured: data['is_featured'] ?? false,
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: data['updated_at'] != null ? DateTime.tryParse(data['updated_at']) : null,
      category: data['category'] ?? 'Custom',
      rating: data['rating']?.toDouble(),
      sourceUrl: data['source_url'] ?? data['widget_url'],
      metadata: data['metadata'] ?? {'code': data['code'] ?? ''},
    );
  }
  
  /// Syncs widget to backend
  Future<void> _syncWidgetToBackend(WidgetModel widget) async {
    try {
      final client = dio.Dio();
      await client.post(
        '${_apiService.baseUrl}/widgets/sync',
        data: {
          'widget': widget.toJson(),
          'user_id': _storageService.getUser()?['id'],
        },
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer ${await _storageService.getAuthToken()}',
          },
        ),
      );
    } catch (e) {
      // Silently fail for now, widget is saved locally
      print('Failed to sync widget to backend: $e');
    }
  }
  
  /// Gets template prompt based on template name
  String _getTemplatePrompt(String templateName) {
    final templatePrompts = {
      'Stock Ticker': 'Create a real-time stock ticker widget showing price, change percentage, and a mini chart for a specific stock symbol',
      'Portfolio': 'Create a portfolio overview widget displaying total value, daily change, and top holdings with performance indicators',
      'Crypto Price': 'Create a cryptocurrency price tracker widget with real-time updates, 24h change, and market cap information',
      'Budget Tracker': 'Create a budget tracking widget showing monthly spending, remaining budget, and spending categories',
      'Exchange Rates': 'Create a currency exchange rate widget with live rates and conversion calculator',
      'Investment Goal': 'Create an investment goal tracker widget showing progress, target amount, and projected timeline',
    };
    
    return templatePrompts[templateName] ?? 
           'Create a $templateName widget with modern design and real-time data';
  }
  
  /// Loads template cache on init
  void _loadTemplateCache() {
    // Pre-cache common templates in background
    Future.delayed(const Duration(seconds: 2), () {
      final commonTemplates = ['Stock Ticker', 'Portfolio', 'Crypto Price'];
      for (final template in commonTemplates) {
        loadTemplate(template);
      }
    });
  }
  
  /// Detects widget type from prompt
  String _detectWidgetType(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    if (lowerPrompt.contains('stock') || lowerPrompt.contains('ticker')) {
      return 'stock_ticker';
    } else if (lowerPrompt.contains('crypto') || lowerPrompt.contains('bitcoin')) {
      return 'crypto_price';
    } else if (lowerPrompt.contains('portfolio')) {
      return 'portfolio';
    } else if (lowerPrompt.contains('budget') || lowerPrompt.contains('expense')) {
      return 'budget_tracker';
    } else if (lowerPrompt.contains('chart') || lowerPrompt.contains('graph')) {
      return 'chart';
    } else if (lowerPrompt.contains('coin') || lowerPrompt.contains('alt')) {
      return 'altcoin';
    }
    return 'custom';
  }
  
  /// Extracts features from prompt
  List<String> _extractFeatures(String prompt) {
    final features = <String>[];
    final lowerPrompt = prompt.toLowerCase();
    
    if (lowerPrompt.contains('real-time') || lowerPrompt.contains('live')) {
      features.add('real-time');
    }
    if (lowerPrompt.contains('interactive') || lowerPrompt.contains('click')) {
      features.add('interactive');
    }
    if (lowerPrompt.contains('dark')) {
      features.add('dark-mode');
    }
    if (lowerPrompt.contains('animate') || lowerPrompt.contains('animation')) {
      features.add('animations');
    }
    if (lowerPrompt.contains('detail') || lowerPrompt.contains('analysis')) {
      features.add('detailed-analysis');
    }
    
    return features.isEmpty ? ['standard'] : features;
  }
  
  /// Validates widget code
  bool validateWidgetCode(String code) {
    // Basic validation checks
    if (code.trim().isEmpty) return false;
    if (!code.contains('Widget') && !code.contains('widget')) return false;
    if (code.length < 50) return false; // Too short to be valid widget code
    
    // Check for basic Flutter/React structure
    final hasStructure = code.contains('return') || 
                        code.contains('render') ||
                        code.contains('build');
    
    return hasStructure;
  }
  
  /// Generates widget preview URL
  String generatePreviewUrl(WidgetModel widget) {
    // Generate a preview URL for the widget
    final baseUrl = 'https://preview.assetworks.ai';
    final widgetId = widget.id;
    return '$baseUrl/widget/$widgetId';
  }
}