class ApiConstants {
  // Base URLs
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.assetworks.com/v1',
  );
  
  static const String webSocketUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'wss://ws.assetworks.com',
  );
  
  // API Version
  static const String apiVersion = 'v1';
  static const String appVersion = '1.0.0';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // API Endpoints
  static const String auth = '/auth';
  static const String users = '/users';
  static const String dashboard = '/dashboard';
  static const String widgets = '/widgets';
  static const String analysis = '/analysis';
  static const String notifications = '/notifications';
  static const String market = '/market';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
  static const String upload = '/upload';
  
  // WebSocket events
  static const String wsConnect = 'connect';
  static const String wsDisconnect = 'disconnect';
  static const String wsNotification = 'notification';
  static const String wsMarketUpdate = 'market_update';
  static const String wsWidgetUpdate = 'widget_update';
  static const String wsAnalysisComplete = 'analysis_complete';
  
  // Storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user';
  static const String keyDeviceId = 'device_id';
  static const String keyTheme = 'theme';
  static const String keyLanguage = 'language';
  static const String keyNotificationSettings = 'notification_settings';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyBiometricEnabled = 'biometric_enabled';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File upload limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedFileTypes = [
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'csv',
    'jpg', 'jpeg', 'png', 'gif', 'webp'
  ];
  
  // Cache durations
  static const Duration cacheValidDuration = Duration(minutes: 5);
  static const Duration longCacheValidDuration = Duration(hours: 1);
  
  // Rate limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxUploadRequestsPerHour = 100;
}