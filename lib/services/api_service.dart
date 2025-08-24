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
      final response = await _dio.post(
        otpSend,
        data: {'email': email},
      );
      return {
        'success': response.statusCode == 200,
        'data': response.data,
      };
    } catch (e) {
      print('Error sending OTP: $e');
      return {
        'success': false,
        'message': 'Failed to send OTP',
      };
    }
  }
  
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final response = await _dio.post(
        otpVerify,
        data: {
          'email': email,
          'otp': otp,
        },
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final token = response.data['data']['token'];
        if (token != null) {
          await _storage.write('auth_token', token);
          await _storage.write('user_data', response.data['data']);
        }
        return {
          'success': true,
          'data': response.data['data'],
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Verification failed',
      };
    } catch (e) {
      print('Error verifying OTP: $e');
      return {
        'success': false,
        'message': 'Failed to verify OTP',
      };
    }
  }
  
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        otpSend,
        data: {'email': email},
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
      final response = await _dio.get('/api/v1/users/widgets');
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
      final response = await _dio.get('/api/v1/users/saved-widgets');
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
      final response = await _dio.post(
        '$saveWidget/$widgetId/save',
        data: {'visibility': visibility},
      );
      
      if (response.statusCode == 409) {
        throw Exception('Widget already saved');
      }
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error saving widget: $e');
      if (e.toString().contains('409')) {
        throw Exception('Widget already saved');
      }
      return false;
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
  
  // Prompt & Analysis APIs
  Future<Map<String, dynamic>> createWidgetFromPrompt(String prompt) async {
    try {
      // Extended timeout for analysis operations
      final response = await _dio.post(
        promptsResult,
        data: {'prompt': prompt},
        options: Options(
          receiveTimeout: const Duration(seconds: 300),
          sendTimeout: const Duration(seconds: 300),
        ),
      );
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        return {
          'success': true,
          'widget': response.data['data'],
        };
      }
      
      return {
        'success': false,
        'message': 'Failed to generate widget',
      };
    } catch (e) {
      print('Error creating widget from prompt: $e');
      return {
        'success': false,
        'message': 'Failed to generate widget',
      };
    }
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
  
  // Social APIs
  Future<bool> followUser(String userId) async {
    try {
      final response = await _dio.post('/api/v1/users/profile/follow/$userId');
      return response.statusCode == 200;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }
  
  Future<bool> unfollowUser(String userId) async {
    try {
      final response = await _dio.post('/api/v1/users/profile/unfollow/$userId');
      return response.statusCode == 200;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }
  
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
}