import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URL Configuration
  static String get baseUrl => 
      dotenv.env['API_BASE_URL'] ?? 'https://api.assetworks.ai';
  
  // Alternative URLs
  static const String stagingUrl = 'https://staging-api.assetworks.ai';
  static const String productionUrl = 'https://api.assetworks.ai';
  
  // Timeouts
  static const int connectTimeout = 90000; // 90 seconds
  static const int receiveTimeout = 90000; // 90 seconds
  static const int analysisConnectTimeout = 300000; // 300 seconds for AI operations
  static const int analysisReceiveTimeout = 300000; // 300 seconds for AI operations
  
  // Authentication Endpoints
  static const String otpSend = '/api/v1/auth/otp/send';
  static const String otpVerify = '/api/v1/auth/otp/verify';
  static const String signout = '/api/v1/users/signout';
  static const String deleteAccount = '/api/v1/users/delete-account';
  
  // User Management
  static const String usernameExists = '/api/v1/skip/users/username_exists';
  static const String finishProfileSetup = '/api/v1/skip/users/onboard';
  static const String profile = '/api/v1/users/profile';
  static const String updateProfile = '/api/v1/users/profile/update';
  static const String profilePicture = '/api/v1/skip/users/profile_picture';
  
  // Widget Operations
  static const String saveWidget = '/api/v1/widgets';
  static const String dashboard = '/api/v1/personalization/widgets';
  static const String fullDashboard = '/api/v1/personalization/dashboard/widgets';
  static const String trendingWidgets = '/api/v1/widgets/trending';
  static const String savedWidgets = '/api/v1/widgets/saved';
  static const String deleteWidgets = '/api/v1/personal/widgets/clear';
  static const String widgetTemplates = '/api/v1/widgets/templates';
  
  // Widget Actions (Dynamic endpoints)
  static String likeWidget(String widgetId) => '/api/v1/widgets/$widgetId/like';
  static String dislikeWidget(String widgetId) => '/api/v1/widgets/$widgetId/dislike';
  static String reportWidget(String widgetId) => '/api/v1/widgets/$widgetId/report';
  static String saveWidgetById(String widgetId) => '/api/v1/widgets/$widgetId/save';
  
  // AI & Analysis Endpoints
  static const String promptsResult = '/api/v1/prompts/result';
  static const String promptIntention = '/api/v1/prompts/intention';
  static const String popularAnalysis = '/api/v1/personalization/analysis';
  static const String history = '/api/v1/personal/prompts';
  
  // Social Features
  static const String followers = '/api/v1/personal/users/followers';
  static const String followings = '/api/v1/personal/users/followings';
  static String followUser(String userId) => '/api/v1/users/profile/follow/$userId';
  static String unfollowUser(String userId) => '/api/v1/users/profile/unfollow/$userId';
  
  // Notifications
  static const String notifications = '/api/v1/users/notifications';
  
  // Guest Endpoints (No Auth Required)
  static const String guestWidgets = '/api/v1/guest/widgets';
  static const String guestAnalysis = '/api/v1/guest/analysis';
  
  // Data & Onboarding
  static const String onboardData = '/api/v1/data/onboard-data';
  static const String cautionEndpoint = '/api/v1/personal/users/caution';
  
  // Headers
  static Map<String, String> getHeaders({
    String? token,
    int? page,
    int? limit,
    String? platform,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    if (page != null) {
      headers['X-Requested-Page'] = page.toString();
    }
    
    if (limit != null) {
      headers['X-Requested-Limit'] = limit.toString();
    }
    
    if (platform != null) {
      headers['X-PLATFORM'] = platform;
    }
    
    return headers;
  }
  
  // File Upload Config
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileExtensions = [
    'pdf', 'doc', 'docx', 
    'xls', 'xlsx', 'csv', 
    'txt', 'png', 'jpg', 'jpeg'
  ];
}