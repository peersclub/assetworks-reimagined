import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';
import '../data/models/ai_provider_model.dart';
import '../core/network/api_client.dart';

class AIProviderService extends getx.GetxService {
  late final Dio _dio;
  final _storage = GetStorage();
  
  // Base URL from storage or default
  String get baseUrl => _storage.read('api_base_url') ?? 'https://api.assetworks.ai';
  
  // AI Provider Endpoints
  static const String claudeEndpoint = '/admin/api/v1/claude/assistant';
  static const String openaiEndpoint = '/admin/api/v1/openai/assistant';
  static const String geminiEndpoint = '/admin/api/v1/gemini/assistant';
  static const String perplexityEndpoint = '/admin/api/v1/perplexity/assistant';
  
  // Analysis endpoints with provider support
  static const String promptIntention = '/api/v1/prompts/intention';
  static const String promptResult = '/api/v1/prompts/result';
  
  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    _loadProviderPreferences();
  }
  
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add authentication interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _handleAuthError();
          }
          handler.next(error);
        },
      ),
    );
  }
  
  void _handleAuthError() {
    _storage.remove('auth_token');
    _storage.remove('user_data');
    getx.Get.offAllNamed('/login');
  }
  
  // Load user's provider preferences
  void _loadProviderPreferences() {
    final savedProvider = _storage.read('preferred_ai_provider');
    if (savedProvider != null) {
      try {
        _currentProvider = AIProvider.values.firstWhere(
          (e) => e.toString().split('.').last == savedProvider,
        );
      } catch (e) {
        _currentProvider = AIProvider.openai;
      }
    }
  }
  
  // Current selected provider
  AIProvider _currentProvider = AIProvider.openai;
  AIProvider get currentProvider => _currentProvider;
  
  // Set current provider
  void setCurrentProvider(AIProvider provider) {
    _currentProvider = provider;
    _storage.write('preferred_ai_provider', provider.toString().split('.').last);
  }
  
  // Get endpoint for current provider
  String _getProviderEndpoint(AIProvider provider) {
    switch (provider) {
      case AIProvider.claude:
        return claudeEndpoint;
      case AIProvider.openai:
        return openaiEndpoint;
      case AIProvider.gemini:
        return geminiEndpoint;
      case AIProvider.perplexity:
        return perplexityEndpoint;
    }
  }
  
  // Generate widget with selected AI provider
  Future<AIProviderResponse> generateWidget({
    required String prompt,
    required AIProvider provider,
    Map<String, dynamic>? additionalParams,
    List<File>? attachments,
  }) async {
    try {
      final startTime = DateTime.now();
      
      // Prepare form data if attachments exist
      FormData? formData;
      if (attachments != null && attachments.isNotEmpty) {
        formData = FormData.fromMap({
          'prompt': prompt,
          'provider': provider.toString().split('.').last,
          if (additionalParams != null) ...additionalParams,
          'files': attachments.map((file) => 
            MultipartFile.fromFileSync(
              file.path,
              filename: file.path.split('/').last,
            )
          ).toList(),
        });
      }
      
      final response = await _dio.post(
        _getProviderEndpoint(provider),
        data: formData ?? {
          'prompt': prompt,
          'provider': provider.toString().split('.').last,
          if (additionalParams != null) ...additionalParams,
        },
      );
      
      final processingTime = DateTime.now().difference(startTime);
      
      // Parse response based on provider
      final result = _parseProviderResponse(response.data, provider);
      
      return AIProviderResponse(
        result: result['content'] ?? '',
        provider: provider,
        requestId: result['requestId'],
        tokensUsed: result['tokensUsed'],
        creditsUsed: result['creditsUsed'],
        processingTime: processingTime,
        metadata: result['metadata'],
      );
    } catch (e) {
      print('Error generating with ${provider.name}: $e');
      throw Exception('Failed to generate with ${provider.name}: $e');
    }
  }
  
  // Parse provider-specific response
  Map<String, dynamic> _parseProviderResponse(
    Map<String, dynamic> data, 
    AIProvider provider
  ) {
    switch (provider) {
      case AIProvider.claude:
        return {
          'content': data['response'] ?? data['result'] ?? '',
          'requestId': data['requestId'],
          'tokensUsed': data['usage']?['total_tokens'],
          'creditsUsed': data['creditsUsed'],
          'metadata': {
            'model': data['model'] ?? 'claude-3-opus',
            'stopReason': data['stop_reason'],
          },
        };
      
      case AIProvider.openai:
        return {
          'content': data['response'] ?? data['choices']?[0]?['message']?['content'] ?? '',
          'requestId': data['id'],
          'tokensUsed': data['usage']?['total_tokens'],
          'creditsUsed': data['creditsUsed'],
          'metadata': {
            'model': data['model'] ?? 'gpt-4-turbo',
            'finishReason': data['choices']?[0]?['finish_reason'],
          },
        };
      
      case AIProvider.gemini:
        return {
          'content': data['response'] ?? data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '',
          'requestId': data['requestId'],
          'tokensUsed': data['usageMetadata']?['totalTokenCount'],
          'creditsUsed': data['creditsUsed'],
          'metadata': {
            'model': data['model'] ?? 'gemini-pro',
            'safetyRatings': data['candidates']?[0]?['safetyRatings'],
          },
        };
      
      case AIProvider.perplexity:
        return {
          'content': data['response'] ?? data['choices']?[0]?['message']?['content'] ?? '',
          'requestId': data['id'],
          'tokensUsed': data['usage']?['total_tokens'],
          'creditsUsed': data['creditsUsed'],
          'metadata': {
            'model': data['model'] ?? 'pplx-70b-online',
            'sources': data['sources'],
          },
        };
    }
  }
  
  // Analyze prompt intention with provider
  Future<Map<String, dynamic>> analyzeIntention({
    required String prompt,
    AIProvider? provider,
  }) async {
    try {
      final selectedProvider = provider ?? _currentProvider;
      
      final response = await _dio.post(
        promptIntention,
        data: {
          'prompt': prompt,
          'provider': selectedProvider.toString().split('.').last,
        },
      );
      
      return {
        'success': true,
        'intention': response.data['intention'],
        'provider': selectedProvider.name,
        'data': response.data,
      };
    } catch (e) {
      print('Error analyzing intention: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Get provider configurations
  Future<List<AIProviderConfig>> getProviderConfigurations() async {
    try {
      final response = await _dio.get('/api/v1/providers/config');
      
      final configs = (response.data['providers'] as List)
          .map((json) => AIProviderConfig.fromJson(json))
          .toList();
      
      return configs;
    } catch (e) {
      print('Error fetching provider configs: $e');
      // Return default configurations
      return AIProvider.values.map((provider) => 
        AIProviderConfig(
          provider: provider,
          isEnabled: true,
          isPremium: provider == AIProvider.claude || provider == AIProvider.perplexity,
        )
      ).toList();
    }
  }
  
  // Check user's credit balance for provider
  Future<Map<String, dynamic>> checkProviderCredits(AIProvider provider) async {
    try {
      final response = await _dio.get(
        '/api/v1/users/credits',
        queryParameters: {
          'provider': provider.toString().split('.').last,
        },
      );
      
      return {
        'available': response.data['credits'] ?? 0,
        'required': response.data['requiredCredits'] ?? 1,
        'canUse': response.data['canUse'] ?? false,
      };
    } catch (e) {
      print('Error checking credits: $e');
      return {
        'available': 0,
        'required': 1,
        'canUse': false,
      };
    }
  }
  
  // Stream response for long-running operations
  Stream<String> streamProviderResponse({
    required String prompt,
    required AIProvider provider,
    Map<String, dynamic>? additionalParams,
  }) async* {
    try {
      final response = await _dio.post(
        '${_getProviderEndpoint(provider)}/stream',
        data: {
          'prompt': prompt,
          'provider': provider.toString().split('.').last,
          'stream': true,
          if (additionalParams != null) ...additionalParams,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );
      
      await for (final chunk in response.data.stream) {
        final text = String.fromCharCodes(chunk);
        yield text;
      }
    } catch (e) {
      print('Error streaming from ${provider.name}: $e');
      throw Exception('Failed to stream from ${provider.name}: $e');
    }
  }
  
  // Get provider usage statistics
  Future<Map<String, dynamic>> getProviderStats() async {
    try {
      final response = await _dio.get('/api/v1/users/provider-stats');
      
      return {
        'success': true,
        'stats': response.data['stats'],
        'mostUsed': response.data['mostUsed'],
        'creditsUsed': response.data['creditsUsed'],
      };
    } catch (e) {
      print('Error fetching provider stats: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}