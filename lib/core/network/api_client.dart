import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../utils/storage_helper.dart';

class ApiClient {
  late Dio _dio;
  late Dio _analysisClient; // Separate client for AI operations with longer timeout
  static final ApiClient _instance = ApiClient._internal();
  
  factory ApiClient() => _instance;
  
  ApiClient._internal() {
    _initializeDio();
  }
  
  void _initializeDio() {
    // Regular API client
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // AI Analysis client with extended timeout
    _analysisClient = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConfig.analysisConnectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConfig.analysisReceiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptors
    _dio.interceptors.add(_createInterceptor());
    _analysisClient.interceptors.add(_createInterceptor());
    
    // Add logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
      _analysisClient.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: false, // Don't log large AI responses
        error: true,
      ));
    }
  }
  
  InterceptorsWrapper _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = StorageHelper.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Add platform header
        options.headers['X-PLATFORM'] = getx.GetPlatform.isAndroid 
            ? 'android' 
            : getx.GetPlatform.isIOS 
                ? 'iOS' 
                : 'web';
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Check for security alerts
        if (response.data != null && response.data is Map) {
          if (response.data['security_alert'] == true) {
            _handleSecurityAlert();
          }
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Unauthorized - clear token and redirect to login
          await StorageHelper.removeToken();
          await StorageHelper.removeUser();
          getx.Get.offAllNamed('/landing-screen');
        } else if (error.response?.statusCode == 502) {
          // Bad Gateway - retry with exponential backoff
          if (error.requestOptions.extra['retry_count'] == null) {
            error.requestOptions.extra['retry_count'] = 0;
          }
          
          if (error.requestOptions.extra['retry_count'] < 3) {
            error.requestOptions.extra['retry_count']++;
            await Future.delayed(Duration(
              seconds: error.requestOptions.extra['retry_count'] * 2,
            ));
            
            try {
              final response = await _dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
        }
        
        handler.next(error);
      },
    );
  }
  
  void _handleSecurityAlert() {
    getx.Get.snackbar(
      'Security Alert',
      'Your account may be compromised. Please change your password immediately.',
      snackPosition: getx.SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }
  
  // Authentication APIs
  Future<Response> sendOtp(String identifier) async {
    return await _dio.post(
      ApiConfig.otpSend,
      data: {'identifier': identifier},
    );
  }
  
  Future<Response> verifyOtp({
    required String identifier,
    required String otp,
    String? firebaseToken,
  }) async {
    return await _dio.post(
      ApiConfig.otpVerify,
      data: {
        'identifier': identifier,
        'otp': otp,
        if (firebaseToken != null) 'firebase_token': firebaseToken,
      },
    );
  }
  
  Future<Response> signOut() async {
    return await _dio.post(ApiConfig.signout);
  }
  
  Future<Response> deleteAccount() async {
    return await _dio.delete(ApiConfig.deleteAccount);
  }
  
  // Template Operations
  Future<Response> getWidgetTemplates() async {
    return await _dio.get(ApiConfig.widgetTemplates);
  }
  
  Future<Response> trackTemplateUsage(String templateId) async {
    return await _dio.post(
      '${ApiConfig.widgetTemplates}/$templateId/usage',
    );
  }
  
  // AI Widget Generation - Main endpoint
  Future<Response> generateWidget({
    required String prompt,
    bool updateData = false,
    String? userSessionId,
    Map<String, dynamic>? remixData,
  }) async {
    return await _analysisClient.post(
      ApiConfig.promptsResult,
      data: {
        'prompt': prompt,
        'update_data': updateData,
        if (userSessionId != null) 'user_session_id': userSessionId,
        if (remixData != null) ...remixData,
      },
    );
  }
  
  // Get widget by ID
  Future<Response> getWidgetById(String widgetId) async {
    return await _dio.get('/api/v1/widgets/$widgetId');
  }
  
  // Get related widgets by prompt intention
  Future<Response> getPromptIntention(String prompt) async {
    return await _dio.post(
      ApiConfig.promptIntention,
      data: {'prompt': prompt},
    );
  }
  
  // Dashboard APIs
  Future<Response> getDashboardWidgets({
    int page = 1,
    int limit = 10,
  }) async {
    return await _dio.get(
      ApiConfig.fullDashboard,
      options: Options(
        headers: ApiConfig.getHeaders(
          page: page,
          limit: limit,
        ),
      ),
    );
  }
  
  // Trending Widgets
  Future<Response> getTrendingWidgets() async {
    return await _dio.get(ApiConfig.trendingWidgets);
  }
  
  // Popular Analysis
  Future<Response> getPopularAnalysis() async {
    return await _dio.get(ApiConfig.popularAnalysis);
  }
  
  // Saved Widgets
  Future<Response> getSavedWidgets() async {
    return await _dio.get(ApiConfig.savedWidgets);
  }
  
  // Widget Actions
  Future<Response> likeWidget(String widgetId) async {
    return await _dio.post(ApiConfig.likeWidget(widgetId));
  }
  
  Future<Response> dislikeWidget(String widgetId) async {
    return await _dio.post(ApiConfig.dislikeWidget(widgetId));
  }
  
  Future<Response> reportWidget(String widgetId, String reason) async {
    return await _dio.post(
      ApiConfig.reportWidget(widgetId),
      data: {'reason': reason},
    );
  }
  
  Future<Response> saveWidgetToProfile({
    required String widgetId,
    String visibility = 'public',
  }) async {
    return await _dio.post(
      ApiConfig.saveWidgetById(widgetId),
      data: {'visibility': visibility},
    );
  }
  
  Future<Response> deleteWidgets(List<String> widgetIds) async {
    return await _dio.delete(
      ApiConfig.deleteWidgets,
      queryParameters: {'widget_ids': widgetIds.join(',')},
    );
  }
  
  // Prompt History
  Future<Response> getPromptHistory({
    int page = 1,
    int limit = 10,
  }) async {
    return await _dio.get(
      ApiConfig.history,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
  }
  
  // User Profile
  Future<Response> getUserProfile() async {
    return await _dio.get(ApiConfig.profile);
  }
  
  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _dio.put(
      ApiConfig.updateProfile,
      data: data,
    );
  }
  
  Future<Response> uploadProfilePicture(FormData formData) async {
    return await _dio.post(
      ApiConfig.profilePicture,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }
  
  // Social Features
  Future<Response> getFollowers() async {
    return await _dio.get(ApiConfig.followers);
  }
  
  Future<Response> getFollowings() async {
    return await _dio.get(ApiConfig.followings);
  }
  
  Future<Response> followUser(String userId) async {
    return await _dio.post(ApiConfig.followUser(userId));
  }
  
  Future<Response> unfollowUser(String userId) async {
    return await _dio.post(ApiConfig.unfollowUser(userId));
  }
  
  // Notifications
  Future<Response> getNotifications() async {
    return await _dio.get(ApiConfig.notifications);
  }
  
  // Guest Access
  Future<Response> getGuestWidgets() async {
    return await _dio.get(ApiConfig.guestWidgets);
  }
  
  Future<Response> getGuestAnalysis() async {
    return await _dio.get(ApiConfig.guestAnalysis);
  }
  
  // Username Check
  Future<Response> checkUsernameExists(String username) async {
    return await _dio.post(
      ApiConfig.usernameExists,
      data: {'username': username},
    );
  }
  
  // Profile Setup
  Future<Response> completeProfileSetup(Map<String, dynamic> data) async {
    return await _dio.post(
      ApiConfig.finishProfileSetup,
      data: data,
    );
  }
  
  // Get onboard data
  Future<Response> getOnboardData() async {
    return await _dio.get(ApiConfig.onboardData);
  }
  
  // Update base URL (for switching environments)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    _analysisClient.options.baseUrl = newBaseUrl;
  }
  
  Dio get dio => _dio;
  Dio get analysisClient => _analysisClient;
}