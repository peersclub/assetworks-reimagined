import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';
import '../models/dashboard_widget.dart';
import '../models/user_profile.dart';
import '../models/notification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService extends getx.GetxService {
  late final Dio _dio;
  final _storage = GetStorage();
  
  // Base URL from environment or default
  String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.assetworks.ai';
  
  // API Endpoints
  static const String onboardData = '/api/v1/data/onboard-data';
  static const String otpSend = '/api/v1/auth/otp/send';
  static const String otpVerify = '/api/v1/auth/otp/verify';
  static const String usernameExists = '/api/v1/skip/users/username_exists';
  static const String profilePicture = '/api/v1/skip/users/profile_picture';
  static const String finishProfileSetup = '/api/v1/skip/users/onboard';
  static const String dashboard = '/api/v1/personalization/widgets';
  static const String fullDashboard = '/api/v1/personalization/dashboard/widgets';
  static const String popularAnalysis = '/api/v1/personalization/analysis';
  static const String history = '/api/v1/personal/prompts';
  static const String profile = '/api/v1/users/profile';
  static const String trendingWidgets = '/api/v1/widgets/trending';
  static const String notifications = '/api/v1/users/notifications';
  static const String cautionEndpoint = '/api/v1/personal/users/caution';
  static const String deleteWidgets = '/api/v1/personal/widgets/clear';
  static const String saveWidget = '/api/v1/widgets';
  static const String followers = '/api/v1/personal/users/followers';
  static const String followings = '/api/v1/personal/users/followings';
  static const String updateProfile = '/api/v1/users/profile/update';
  static const String promptsResult = '/api/v1/prompts/result';
  static const String guestWidgets = '/api/v1/guest/widgets';
  static const String guestAnalysis = '/api/v1/guest/analysis';
  static const String deleteAccount = '/api/v1/users/delete-account';
  static const String signout = '/api/v1/users/signout';
  
  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }
  
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptor for authentication
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
            _storage.remove('auth_token');
            _storage.remove('user_data');
            getx.Get.offAllNamed('/login');
          }
          handler.next(error);
        },
      ),
    );
  }
  
  // Authentication APIs
  Future<Map<String, dynamic>> sendOTP(String email) async {
    try {
      print('Sending OTP to email: $email');
      print('API URL: $baseUrl$otpSend');
      
      final response = await _dio.post(
        otpSend,
        data: {'identifier': email},  // API expects 'identifier' not 'email'
      );
      
      print('OTP Response Status: ${response.statusCode}');
      print('OTP Response Data: ${response.data}');
      
      return {
        'success': response.statusCode == 200,
        'data': response.data,
        'message': response.data?['message'] ?? 'OTP sent successfully',
      };
    } on DioException catch (e) {
      print('DioException sending OTP: ${e.type}');
      print('Error message: ${e.message}');
      print('Error response: ${e.response?.data}');
      
      String errorMessage = 'Failed to send OTP';
      
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error. Please check your internet.';
      } else if (e.response != null) {
        // Handle both string and JSON error responses
        var responseData = e.response?.data;
        if (responseData is String) {
          errorMessage = responseData;
        } else if (responseData is Map) {
          errorMessage = responseData['message'] ?? 'Server error occurred';
        }
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('Unexpected error sending OTP: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }
  
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      print('Verifying OTP for email: $email');
      print('OTP Code: $otp');
      print('Verify URL: $baseUrl$otpVerify');
      
      final response = await _dio.post(
        otpVerify,
        data: {
          'identifier': email,  // API expects 'identifier' not 'email'
          'otp': otp,
        },
      );
      
      print('Verify Response Status: ${response.statusCode}');
      print('Verify Response Data: ${response.data}');
      
      // The API returns user and token directly, not wrapped in 'data'
      if (response.statusCode == 200) {
        final token = response.data['token'];
        final user = response.data['user'];
        
        if (token != null) {
          await _storage.write('auth_token', token);
          await _storage.write('user_data', response.data);
          
          return {
            'success': true,
            'data': {
              'token': token,
              'user': user,
              'expires_in': response.data['expires_in'],
            },
          };
        }
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Verification failed',
      };
    } on DioException catch (e) {
      print('DioException verifying OTP: ${e.type}');
      print('Error response status: ${e.response?.statusCode}');
      print('Error response data: ${e.response?.data}');
      
      String errorMessage = 'Failed to verify OTP';
      
      if (e.response?.statusCode == 403) {
        errorMessage = 'Invalid or expired OTP. Please try again.';
      } else if (e.response != null) {
        var responseData = e.response?.data;
        if (responseData is String) {
          errorMessage = responseData;
        } else if (responseData is Map) {
          errorMessage = responseData['message'] ?? 'Verification failed';
        }
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('Unexpected error verifying OTP: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }
  
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        otpSend,
        data: {'identifier': email},  // API expects 'identifier' not 'email'
      );
      return {
        'success': response.statusCode == 200,
        'data': response.data,
      };
    } catch (e) {
      print('Error in forgot password: $e');
      return {
        'success': false,
        'message': 'Failed to send reset code',
      };
    }
  }
  
  // Profile APIs
  Future<Map<String, dynamic>> checkUsernameExists(String username) async {
    try {
      final response = await _dio.get(
        usernameExists,
        queryParameters: {'username': username},
      );
      return {
        'success': true,
        'exists': response.data['data']['exists'] ?? false,
      };
    } catch (e) {
      print('Error checking username: $e');
      return {
        'success': false,
        'exists': false,
      };
    }
  }
  
  Future<Map<String, dynamic>> uploadProfilePicture(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post(
        profilePicture,
        data: formData,
      );
      
      return {
        'success': response.statusCode == 200,
        'url': response.data['data']['url'],
      };
    } catch (e) {
      print('Error uploading profile picture: $e');
      return {
        'success': false,
        'message': 'Failed to upload profile picture',
      };
    }
  }
  
  Future<Map<String, dynamic>> finishOnboarding({
    required String username,
    String? fullName,
    String? profilePictureUrl,
  }) async {
    try {
      final response = await _dio.post(
        finishProfileSetup,
        data: {
          'username': username,
          'full_name': fullName,
          'profile_picture_url': profilePictureUrl,
        },
      );
      
      return {
        'success': response.statusCode == 200,
        'data': response.data,
      };
    } catch (e) {
      print('Error finishing onboarding: $e');
      return {
        'success': false,
        'message': 'Failed to complete profile setup',
      };
    }
  }
  
  // User widgets and saved widgets
  Future<List<DashboardWidget>> getUserWidgets() async {
    try {
      final response = await _dio.get('/api/v1/personal/widgets');
      if (response.statusCode == 200) {
        final List widgets = response.data['data'] ?? [];
        return widgets.map((w) => DashboardWidget.fromJson(w)).toList();
      }
      return [];
    } catch (e) {
      print('Get user widgets error: $e');
      return [];
    }
  }
  
  Future<List<DashboardWidget>> getSavedWidgets() async {
    try {
      final response = await _dio.get('/api/v1/personal/saved-widgets');
      if (response.statusCode == 200) {
        final List widgets = response.data['data'] ?? [];
        return widgets.map((w) => DashboardWidget.fromJson(w)).toList();
      }
      return [];
    } catch (e) {
      print('Get saved widgets error: $e');
      return [];
    }
  }
  
  // Get followers and following
  Future<List<Map<String, dynamic>>> getFollowers() async {
    try {
      final response = await _dio.get(followers);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Get followers error: $e');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getFollowing() async {
    try {
      final response = await _dio.get(followings);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Get following error: $e');
      return [];
    }
  }
  
  Future<UserProfile?> getUserProfile() async {
    try {
      final response = await _dio.get(profile);
      if (response.statusCode == 200 && response.data['data'] != null) {
        return UserProfile.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
  
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.put(
        updateProfile,
        data: profileData,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
  
  // Update Profile Picture
  Future<bool> updateProfilePicture(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile.jpg',
        ),
      });
      
      final response = await _dio.post(
        profilePicture,
        data: formData,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Update profile picture error: $e');
      return false;
    }
  }
  
  // Dashboard APIs
  Future<List<DashboardWidget>> fetchDashboardWidgets({
    int page = 1,
    int limit = 10,
    Map<String, String>? filters,
  }) async {
    try {
      final response = await _dio.get(
        fullDashboard,
        queryParameters: {
          ...?filters,
        },
        options: Options(
          headers: {
            'X-Requested-Page': page.toString(),
            'X-Requested-Limit': limit.toString(),
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> widgetData = response.data['data'];
        return widgetData
            .map((json) => DashboardWidget.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching dashboard widgets: $e');
      return [];
    }
  }
  
  Future<List<DashboardWidget>> fetchTrendingWidgets({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        trendingWidgets,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> widgetData = response.data['data'];
        return widgetData
            .map((json) => DashboardWidget.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching trending widgets: $e');
      return [];
    }
  }
  
  // Widget Actions APIs
  Future<bool> saveWidgetToProfile(String widgetId, {String visibility = 'public'}) async {
    try {
      // Check current save status first
      final isSaved = await isWidgetSaved(widgetId);
      
      if (isSaved) {
        // If already saved, unsave it
        final response = await _dio.delete(
          '/api/v1/personal/saved-widgets/$widgetId',
        );
        return response.statusCode == 200;
      } else {
        // If not saved, save it
        final response = await _dio.post(
          '/api/v1/personal/saved-widgets',
          data: {
            'widget_id': widgetId,
            'visibility': visibility,
          },
        );
        return response.statusCode == 200 || response.statusCode == 201;
      }
    } on DioException catch (e) {
      print('Error saving widget: $e');
      print('Response: ${e.response?.data}');
      
      // If 409 conflict, widget is already saved
      if (e.response?.statusCode == 409) {
        // Try to unsave instead
        try {
          final response = await _dio.delete(
            '/api/v1/personal/saved-widgets/$widgetId',
          );
          return response.statusCode == 200;
        } catch (e) {
          print('Error unsaving widget: $e');
          return false;
        }
      }
      return false;
    } catch (e) {
      print('Unexpected error saving widget: $e');
      return false;
    }
  }
  
  Future<bool> isWidgetSaved(String widgetId) async {
    try {
      final savedWidgets = await fetchSavedWidgets();
      return savedWidgets.any((w) => w.id == widgetId);
    } catch (e) {
      return false;
    }
  }
  
  Future<List<DashboardWidget>> fetchSavedWidgets({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/api/v1/personal/saved-widgets',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> widgetData = response.data['data'];
        return widgetData.map((json) => DashboardWidget.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching saved widgets: $e');
      return [];
    }
  }
  
  Future<bool> likeWidget(String widgetId) async {
    try {
      final response = await _dio.post('/api/v1/widgets/$widgetId/like');
      return response.statusCode == 200;
    } catch (e) {
      print('Error liking widget: $e');
      return false;
    }
  }
  
  Future<bool> dislikeWidget(String widgetId) async {
    try {
      final response = await _dio.post('/api/v1/widgets/$widgetId/dislike');
      return response.statusCode == 200;
    } catch (e) {
      print('Error disliking widget: $e');
      return false;
    }
  }
  
  Future<bool> followUser(String userId) async {
    try {
      final response = await _dio.post('/api/v1/social/follow',
        data: {'user_id': userId}
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }
  
  Future<bool> unfollowUser(String userId) async {
    try {
      final response = await _dio.post('/api/v1/social/unfollow',
        data: {'user_id': userId}
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }
  
  Future<bool> addWidgetToDashboard(String widgetId) async {
    try {
      final response = await _dio.post('/api/v1/dashboard/add',
        data: {'widget_id': widgetId}
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding widget to dashboard: $e');
      return false;
    }
  }
  
  Future<bool> removeWidgetFromDashboard(String widgetId) async {
    try {
      final response = await _dio.delete('/api/v1/dashboard/remove/$widgetId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error removing widget from dashboard: $e');
      return false;
    }
  }
  
  Future<UserProfile> fetchUserProfile(String userId) async {
    try {
      final response = await _dio.get('/api/v1/users/$userId');
      return UserProfile.fromJson(response.data['user'] ?? response.data);
    } catch (e) {
      print('Error fetching user profile: $e');
      // Return basic profile with available data
      return UserProfile(
        id: userId,
        username: 'User',
        followers_count: 0,
        following_count: 0,
      );
    }
  }
  
  Future<bool> followWidget(String widgetId) async {
    try {
      final response = await _dio.post('/api/v1/widgets/$widgetId/follow');
      return response.statusCode == 200;
    } catch (e) {
      print('Error following widget: $e');
      return false;
    }
  }
  
  Future<bool> unfollowWidget(String widgetId) async {
    try {
      final response = await _dio.post('/api/v1/widgets/$widgetId/unfollow');
      return response.statusCode == 200;
    } catch (e) {
      print('Error unfollowing widget: $e');
      return false;
    }
  }
  
  Future<bool> reportWidget(String widgetId, String reason) async {
    try {
      final response = await _dio.post(
        '/api/v1/widgets/$widgetId/report',
        data: {'reason': reason},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error reporting widget: $e');
      return false;
    }
  }
  
  Future<bool> deleteUserWidgets(List<String> widgetIds) async {
    try {
      final response = await _dio.delete(
        deleteWidgets,
        queryParameters: {'widget_ids': widgetIds.join(',')},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting widgets: $e');
      return false;
    }
  }
  
  // Registration APIs
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/v1/auth/register', data: data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'user': response.data['user'] ?? {},
          'user_id': response.data['user']?['id'] ?? response.data['user_id'],
          'token': response.data['token'],
          'requires_verification': response.data['requires_verification'] ?? false,
          'message': response.data['message'] ?? 'Registration successful',
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'An error occurred during registration',
      };
    }
  }
  
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final response = await _dio.get(
        '/api/v1/auth/check-username',
        queryParameters: {'username': username},
      );
      
      return response.data['available'] ?? false;
    } catch (e) {
      print('Username check error: $e');
      return false;
    }
  }
  
  Future<bool> uploadProfilePictureFile(File image, {String? userId}) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        if (userId != null) 'user_id': userId,
      });
      
      final response = await _dio.post(
        '/api/v1/user/profile/picture',
        data: formData,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Profile picture upload error: $e');
      return false;
    }
  }
  
  // Settings APIs
  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final response = await _dio.get('/api/v1/user/settings');
      
      if (response.statusCode == 200) {
        return response.data['settings'] ?? response.data ?? {};
      }
      return {};
    } catch (e) {
      print('Error fetching user settings: $e');
      return {};
    }
  }
  
  Future<bool> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _dio.put(
        '/api/v1/user/settings',
        data: settings,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user settings: $e');
      return false;
    }
  }
  
  
  // Activity & History APIs
  Future<List<Map<String, dynamic>>> fetchUserActivity({
    int page = 1,
    int limit = 20,
    String? filter,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/user/activity',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (filter != null) 'filter': filter,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data['activities'] ?? response.data['data'] ?? [];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Error fetching user activity: $e');
      return [];
    }
  }
  
  Future<bool> trackActivity({
    required String action,
    required String widgetId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/user/activity',
        data: {
          'action': action,
          'widget_id': widgetId,
          'timestamp': DateTime.now().toIso8601String(),
          if (metadata != null) 'metadata': metadata,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error tracking activity: $e');
      return false;
    }
  }
  
  // AI Chat API
  Future<String?> sendAIMessage(String message, {String? context}) async {
    try {
      final response = await _dio.post(
        '/api/v1/ai/chat',
        data: {
          'message': message,
          'context': context ?? 'general',
        },
        options: Options(
          receiveTimeout: Duration(seconds: 30),
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data['response'] ?? response.data['message'];
      }
      return null;
    } catch (e) {
      print('Error sending AI message: $e');
      // Return null to trigger fallback
      return null;
    }
  }
  
  // Prompt & Analysis APIs
  Future<Map<String, dynamic>> createWidgetFromPrompt(String prompt) async {
    try {
      print('Creating widget from prompt: $prompt');
      print('Using endpoint: $baseUrl$promptsResult');
      
      // Get auth token
      final token = _storage.read('auth_token');
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication required. Please login first.',
        };
      }
      
      // Extended timeout for AI generation
      final response = await _dio.post(
        promptsResult,
        data: {
          'prompt': prompt,
          'user_session_id': null, // Optional session ID
          'ai_provider': 'claude', // Default to Claude
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 120), // 2 minutes for AI generation
          sendTimeout: const Duration(seconds: 60),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        return {
          'success': true,
          'widget': response.data['data'],
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to generate widget',
      };
    } catch (e) {
      print('Error creating widget from prompt: $e');
      
      return {
        'success': false,
        'message': 'Failed to generate widget. Please ensure backend is running.',
      };
    }
  }
  
  // Generate mock widget for testing when API is unavailable
  Map<String, dynamic> _generateMockWidget(String prompt) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return {
      'success': true,
      'widget': {
        'id': 'mock_$timestamp',
        'title': 'Generated Widget',
        'description': 'Widget generated from: $prompt',
        'code': '''
<div style="padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 12px; color: white;">
  <h2>Mock Widget</h2>
  <p>This is a mock widget generated because the API is unavailable.</p>
  <p>Your prompt: $prompt</p>
  <div style="margin-top: 20px; padding: 15px; background: rgba(255,255,255,0.1); border-radius: 8px;">
    <strong>Status:</strong> API Offline - Using Local Generation
  </div>
</div>
        ''',
        'image_url': null,
        'creator': 'AI System',
        'category': 'Custom',
        'tags': ['mock', 'test'],
        'created_at': DateTime.now().toIso8601String(),
      }
    };
  }
  
  Future<List<Map<String, dynamic>>> fetchPromptHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        history,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error fetching prompt history: $e');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> fetchPopularAnalysis({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        popularAnalysis,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error fetching popular analysis: $e');
      return [];
    }
  }
  
  // Social APIs (removed duplicates - defined above)
  
  Future<List<Map<String, dynamic>>> fetchFollowers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        followers,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error fetching followers: $e');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> fetchFollowings({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        followings,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error fetching followings: $e');
      return [];
    }
  }
  
  // Notification APIs
  Future<List<NotificationModel>> fetchNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        notifications,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> notificationData = response.data['data'];
        return notificationData
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
  
  // Guest APIs
  Future<List<DashboardWidget>> fetchGuestWidgets({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        guestWidgets,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> widgetData = response.data['data'];
        return widgetData
            .map((json) => DashboardWidget.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching guest widgets: $e');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> fetchGuestAnalysis({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        guestAnalysis,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print('Error fetching guest analysis: $e');
      return [];
    }
  }
  
  // Account Management APIs
  Future<bool> deleteUserAccount() async {
    try {
      final response = await _dio.delete(deleteAccount);
      if (response.statusCode == 200) {
        await _storage.remove('auth_token');
      await _storage.remove('user_data');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }
  
  Future<bool> signOut() async {
    try {
      final response = await _dio.post(signout);
      await _storage.remove('auth_token');
      await _storage.remove('user_data');
      return response.statusCode == 200;
    } catch (e) {
      print('Error signing out: $e');
      await _storage.remove('auth_token');
      await _storage.remove('user_data');
      return true;
    }
  }
  
  Future<bool> logout() async {
    return signOut();
  }
  
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    // This app uses OTP-based authentication
    // For compatibility, we'll treat password as OTP
    return await verifyOTP(email, password);
  }
  
  // Onboarding Data API
  Future<Map<String, dynamic>?> fetchOnboardingData() async {
    try {
      final response = await _dio.get(onboardData);
      if (response.statusCode == 200 && response.data['data'] != null) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching onboarding data: $e');
      return null;
    }
  }
  
  // Caution Data API
  Future<Map<String, dynamic>?> fetchCautionData() async {
    try {
      final response = await _dio.get(cautionEndpoint);
      if (response.statusCode == 200 && response.data['data'] != null) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching caution data: $e');
      return null;
    }
  }
  
  // Get trending widgets
  Future<List<DashboardWidget>> getTrendingWidgets() async {
    try {
      final response = await _dio.get(trendingWidgets);
      
      if (response.statusCode == 200) {
        final List widgets = response.data['data'] ?? [];
        return widgets.map((w) => DashboardWidget.fromJson(w)).toList();
      }
      return [];
    } catch (e) {
      print('Get trending widgets error: $e');
      return [];
    }
  }
  
  // Search widgets
  Future<List<DashboardWidget>> searchWidgets({
    required String query,
    String? filter,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/widgets/search',
        queryParameters: {
          'q': query,
          if (filter != null) 'filter': filter,
        },
      );
      
      if (response.statusCode == 200) {
        final List widgets = response.data['data'] ?? [];
        return widgets.map((w) => DashboardWidget.fromJson(w)).toList();
      }
      return [];
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }
  
  // Notification methods
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _dio.get(notifications);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Get notifications error: $e');
      return [];
    }
  }
  
  Future<bool> markNotificationsAsRead() async {
    try {
      final response = await _dio.put('$notifications/read');
      return response.statusCode == 200;
    } catch (e) {
      print('Mark notifications as read error: $e');
      return false;
    }
  }
  
  Future<bool> clearNotifications() async {
    try {
      final response = await _dio.delete(notifications);
      return response.statusCode == 200;
    } catch (e) {
      print('Clear notifications error: $e');
      return false;
    }
  }
  
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _dio.delete('$notifications/$notificationId');
      return response.statusCode == 200;
    } catch (e) {
      print('Delete notification error: $e');
      return false;
    }
  }
  
  // Prompt history methods
  Future<List<Map<String, dynamic>>> getPromptHistory() async {
    try {
      final response = await _dio.get(history);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Get prompt history error: $e');
      return [];
    }
  }
  
  Future<bool> deletePromptHistory(String promptId) async {
    try {
      final response = await _dio.delete('$history/$promptId');
      return response.statusCode == 200;
    } catch (e) {
      print('Delete prompt error: $e');
      return false;
    }
  }
  
  Future<bool> clearPromptHistory() async {
    try {
      final response = await _dio.delete(history);
      return response.statusCode == 200;
    } catch (e) {
      print('Clear prompt history error: $e');
      return false;
    }
  }
  
  // Widget Generation & Remix APIs
  Future<Map<String, dynamic>> generateWidget(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/api/v1/widgets/generate',
        data: data,
      );
      return response.data ?? {'success': false};
    } catch (e) {
      print('Error generating widget: $e');
      return {'success': false, 'message': 'Failed to generate widget'};
    }
  }
  
  Future<Map<String, dynamic>> remixWidget(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/api/v1/widgets/remix',
        data: data,
      );
      return response.data ?? {'success': false};
    } catch (e) {
      print('Error remixing widget: $e');
      return {'success': false, 'message': 'Failed to remix widget'};
    }
  }
  
  Future<Map<String, dynamic>> modifyWidget(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/api/v1/widgets/modify',
        data: data,
      );
      return response.data ?? {'success': false};
    } catch (e) {
      print('Error modifying widget: $e');
      return {'success': false, 'message': 'Failed to modify widget'};
    }
  }
  
  // Onboarding APIs
  Future<Map<String, dynamic>> saveOnboardingData(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/api/v1/user/onboarding',
        data: data,
      );
      return response.data ?? {'success': true};
    } catch (e) {
      print('Error saving onboarding data: $e');
      return {'success': false, 'message': 'Failed to save preferences'};
    }
  }
  
  Future<Map<String, dynamic>> getOnboardingStatus() async {
    try {
      final response = await _dio.get('/api/v1/user/onboarding/status');
      return response.data ?? {};
    } catch (e) {
      print('Error getting onboarding status: $e');
      return {'completed': false};
    }
  }
  
  Future<bool> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final response = await _dio.put(
        '/api/v1/user/preferences',
        data: preferences,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating preferences: $e');
      return false;
    }
  }
}