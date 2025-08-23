import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';
import '../models/user_model.dart';
import '../models/widget_model.dart';
import '../models/analysis_model.dart';
import '../models/notification_model.dart';

class ApiService extends getx.GetxService {
  late Dio _dio;
  final StorageService _storage = getx.Get.find<StorageService>();
  
  // Observable states
  final isLoading = false.obs;
  final error = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }
  
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Request interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _storage.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Add device info
        options.headers['X-Device-Id'] = await _storage.getDeviceId();
        options.headers['X-Platform'] = Platform.isIOS ? 'iOS' : 'Android';
        options.headers['X-App-Version'] = ApiConstants.appVersion;
        
        debugPrint('API Request: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('API Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('API Error: ${error.message}');
        _handleError(error);
        handler.next(error);
      },
    ));
  }
  
  // ============== Authentication APIs ==============
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      if (response.data['token'] != null) {
        await _storage.saveAuthToken(response.data['token']);
        await _storage.saveUser(response.data['user']);
      }
      
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('/auth/signup', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });
      
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      
      if (response.data['token'] != null) {
        await _storage.saveAuthToken(response.data['token']);
        await _storage.saveUser(response.data['user']);
      }
      
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
      await _storage.clearAuth();
    } catch (e) {
      // Clear local auth even if API fails
      await _storage.clearAuth();
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      if (response.data['token'] != null) {
        await _storage.saveAuthToken(response.data['token']);
      }
      
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post('/auth/reset-password', data: {
        'token': token,
        'password': newPassword,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============== User Profile APIs ==============
  
  Future<UserModel> getUserProfile({String? userId}) async {
    try {
      final endpoint = userId != null ? '/users/$userId' : '/users/me';
      final response = await _dio.get(endpoint);
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<UserModel> updateProfile({
    String? name,
    String? bio,
    String? phone,
    File? avatar,
  }) async {
    try {
      FormData formData = FormData();
      
      if (name != null) formData.fields.add(MapEntry('name', name));
      if (bio != null) formData.fields.add(MapEntry('bio', bio));
      if (phone != null) formData.fields.add(MapEntry('phone', phone));
      
      if (avatar != null) {
        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(avatar.path, filename: 'avatar.jpg'),
        ));
      }
      
      final response = await _dio.put('/users/me', data: formData);
      final user = UserModel.fromJson(response.data);
      await _storage.saveUser(response.data);
      return user;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post('/users/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<UserModel>> getFollowers({String? userId, int page = 1}) async {
    try {
      final endpoint = userId != null 
          ? '/users/$userId/followers' 
          : '/users/me/followers';
      final response = await _dio.get(endpoint, queryParameters: {
        'page': page,
        'limit': 20,
      });
      return (response.data['data'] as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<UserModel>> getFollowing({String? userId, int page = 1}) async {
    try {
      final endpoint = userId != null 
          ? '/users/$userId/following' 
          : '/users/me/following';
      final response = await _dio.get(endpoint, queryParameters: {
        'page': page,
        'limit': 20,
      });
      return (response.data['data'] as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> followUser(String userId) async {
    try {
      await _dio.post('/users/$userId/follow');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> unfollowUser(String userId) async {
    try {
      await _dio.delete('/users/$userId/follow');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============== Dashboard & Widgets APIs ==============
  
  Future<List<WidgetModel>> getDashboardWidgets({
    int page = 1,
    String? filter,
    String? sortBy,
  }) async {
    try {
      final response = await _dio.get('/dashboard/widgets', queryParameters: {
        'page': page,
        'limit': 20,
        'filter': filter,
        'sort': sortBy,
      });
      return (response.data['data'] as List)
          .map((json) => WidgetModel.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<WidgetModel> createWidget({
    required String title,
    required String description,
    required Map<String, dynamic> config,
    List<String>? tags,
    File? thumbnail,
  }) async {
    try {
      FormData formData = FormData();
      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('description', description));
      formData.fields.add(MapEntry('config', jsonEncode(config)));
      
      if (tags != null) {
        formData.fields.add(MapEntry('tags', jsonEncode(tags)));
      }
      
      if (thumbnail != null) {
        formData.files.add(MapEntry(
          'thumbnail',
          await MultipartFile.fromFile(thumbnail.path),
        ));
      }
      
      final response = await _dio.post('/widgets', data: formData);
      return WidgetModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<WidgetModel> updateWidget({
    required String widgetId,
    String? title,
    String? description,
    Map<String, dynamic>? config,
  }) async {
    try {
      final response = await _dio.put('/widgets/$widgetId', data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (config != null) 'config': config,
      });
      return WidgetModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> deleteWidget(String widgetId) async {
    try {
      await _dio.delete('/widgets/$widgetId');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> saveWidget(String widgetId) async {
    try {
      await _dio.post('/widgets/$widgetId/save');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> unsaveWidget(String widgetId) async {
    try {
      await _dio.delete('/widgets/$widgetId/save');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> likeWidget(String widgetId) async {
    try {
      await _dio.post('/widgets/$widgetId/like');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> unlikeWidget(String widgetId) async {
    try {
      await _dio.delete('/widgets/$widgetId/like');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> shareWidget(String widgetId) async {
    try {
      final response = await _dio.post('/widgets/$widgetId/share');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> reportWidget(String widgetId, String reason) async {
    try {
      await _dio.post('/widgets/$widgetId/report', data: {
        'reason': reason,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============== Analysis APIs ==============
  
  Future<List<AnalysisModel>> getPopularAnalysis({
    int page = 1,
    String? category,
  }) async {
    try {
      final response = await _dio.get('/analysis/popular', queryParameters: {
        'page': page,
        'limit': 20,
        'category': category,
      });
      return (response.data['data'] as List)
          .map((json) => AnalysisModel.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<AnalysisModel> createAnalysis({
    required String query,
    List<File>? attachments,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      FormData formData = FormData();
      formData.fields.add(MapEntry('query', query));
      
      if (parameters != null) {
        formData.fields.add(MapEntry('parameters', jsonEncode(parameters)));
      }
      
      if (attachments != null) {
        for (var file in attachments) {
          formData.files.add(MapEntry(
            'attachments',
            await MultipartFile.fromFile(file.path),
          ));
        }
      }
      
      final response = await _dio.post('/analysis', data: formData);
      return AnalysisModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getAnalysisResult(String analysisId) async {
    try {
      final response = await _dio.get('/analysis/$analysisId/result');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<Map<String, dynamic>>> getAnalysisHistory({int page = 1}) async {
    try {
      final response = await _dio.get('/analysis/history', queryParameters: {
        'page': page,
        'limit': 20,
      });
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============== Notifications APIs ==============
  
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    String? type,
    bool? unreadOnly,
  }) async {
    try {
      final response = await _dio.get('/notifications', queryParameters: {
        'page': page,
        'limit': 20,
        if (type != null) 'type': type,
        if (unreadOnly != null) 'unread': unreadOnly,
      });
      return (response.data['data'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/read');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> markAllNotificationsRead() async {
    try {
      await _dio.put('/notifications/read-all');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dio.delete('/notifications/$notificationId');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final response = await _dio.get('/notifications/settings');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      await _dio.put('/notifications/settings', data: settings);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> registerDeviceToken(String token) async {
    try {
      await _dio.post('/notifications/device', data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============== Market Data APIs ==============
  
  Future<Map<String, dynamic>> getMarketOverview() async {
    try {
      final response = await _dio.get('/market/overview');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<Map<String, dynamic>>> getTrendingStocks() async {
    try {
      final response = await _dio.get('/market/trending');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getStockDetails(String symbol) async {
    try {
      final response = await _dio.get('/market/stocks/$symbol');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<Map<String, dynamic>>> searchStocks(String query) async {
    try {
      final response = await _dio.get('/market/search', queryParameters: {
        'q': query,
      });
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============== File Upload APIs ==============
  
  Future<String> uploadFile(File file, {String? type}) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        if (type != null) 'type': type,
      });
      
      final response = await _dio.post('/upload', data: formData);
      return response.data['url'];
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<String>> uploadMultipleFiles(List<File> files) async {
    try {
      FormData formData = FormData();
      
      for (var file in files) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path),
        ));
      }
      
      final response = await _dio.post('/upload/multiple', data: formData);
      return List<String>.from(response.data['urls']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============== Search APIs ==============
  
  Future<Map<String, dynamic>> globalSearch({
    required String query,
    String? type,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get('/search', queryParameters: {
        'q': query,
        'type': type,
        'page': page,
        'limit': 20,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============== Settings APIs ==============
  
  Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final response = await _dio.get('/settings/app');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      await _dio.put('/settings/user', data: settings);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      final response = await _dio.get('/subscription/status');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> upgradeToPremium(String planId) async {
    try {
      final response = await _dio.post('/subscription/upgrade', data: {
        'plan_id': planId,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============== Error Handling ==============
  
  String _handleError(dynamic error) {
    String errorMessage = 'An error occurred';
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage = 'Connection timeout. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection';
          break;
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            errorMessage = 'Session expired. Please login again.';
            // Trigger logout
            getx.Get.offAllNamed('/login');
          } else if (error.response?.statusCode == 403) {
            errorMessage = 'Access denied';
          } else if (error.response?.statusCode == 404) {
            errorMessage = 'Resource not found';
          } else if (error.response?.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            errorMessage = error.response?.data['message'] ?? 'Something went wrong';
          }
          break;
        default:
          errorMessage = error.message ?? 'An error occurred';
      }
    }
    
    this.error.value = errorMessage;
    return errorMessage;
  }
}