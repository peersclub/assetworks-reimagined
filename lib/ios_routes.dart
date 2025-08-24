import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'presentation/pages/ios/ios_main_screen.dart';
import 'presentation/pages/ios/auth/ios_login_screen.dart';
// import 'presentation/pages/ios/auth/ios_register_screen.dart';
// import 'presentation/pages/ios/auth/ios_otp_screen.dart';
import 'presentation/pages/ios/dashboard/ios_dashboard_screen.dart';
// import 'presentation/pages/ios/discovery/ios_discovery_screen.dart';
// import 'presentation/pages/ios/create/ios_create_widget_screen.dart';
// import 'presentation/pages/ios/profile/ios_profile_screen.dart';
// import 'presentation/pages/ios/settings/ios_settings_screen.dart';
// import 'presentation/pages/ios/notifications/ios_notifications_screen.dart';
// import 'presentation/pages/ios/widget_details/ios_widget_details_screen.dart';
import 'presentation/pages/splash/ios_splash_screen.dart';

// GoRouter for iOS navigation
final GoRouter iOSRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const iOSSplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const iOSLoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const CupertinoPageScaffold(child: Center(child: Text('Register Screen'))), // const iOSRegisterScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const CupertinoPageScaffold(child: Center(child: Text('OTP Screen'))), // const iOSOTPScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const iOSMainScreen(),
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (context, state) => const iOSDashboardScreen(),
        ),
        GoRoute(
          path: 'discovery',
          builder: (context, state) => const CupertinoPageScaffold(child: Center(child: Text('Discovery'))), // const iOSDiscoveryScreen(),
        ),
        GoRoute(
          path: 'create',
          builder: (context, state) => const CupertinoPageScaffold(child: Center(child: Text('Create Widget'))), // const iOSCreateWidgetScreen(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const CupertinoPageScaffold(child: Center(child: Text('Profile'))), // const iOSProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const CupertinoPageScaffold(child: Center(child: Text('Settings'))), // const iOSSettingsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const CupertinoPageScaffold(child: Center(child: Text('Notifications'))), // const iOSNotificationsScreen(),
    ),
    GoRoute(
      path: '/widget/:id',
      builder: (context, state) {
        final widgetId = state.pathParameters['id']!;
        return CupertinoPageScaffold(child: Center(child: Text('Widget: $widgetId'))); // iOSWidgetDetailsScreen(widgetId: widgetId);
      },
    ),
  ],
);

// GetX Routes for iOS (Alternative approach)
final List<GetPage> iOSAppRoutes = [
  GetPage(
    name: '/splash',
    page: () => const iOSSplashScreen(),
    transition: Transition.fade,
  ),
  GetPage(
    name: '/login',
    page: () => const iOSLoginScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/register',
    page: () => const iOSRegisterScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/otp',
    page: () => const iOSOTPScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/main',
    page: () => const iOSMainScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/dashboard',
    page: () => const iOSDashboardScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/discovery',
    page: () => const iOSDiscoveryScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/create',
    page: () => const iOSCreateWidgetScreen(),
    transition: Transition.cupertinoDialog,
  ),
  GetPage(
    name: '/profile',
    page: () => const iOSProfileScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/settings',
    page: () => const iOSSettingsScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/notifications',
    page: () => const iOSNotificationsScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: '/widget_details',
    page: () => const iOSWidgetDetailsScreen(widgetId: ''),
    transition: Transition.cupertino,
  ),
];

// Route names
class iOSRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String discovery = '/discovery';
  static const String create = '/create';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String widgetDetails = '/widget_details';
  
  // Helper methods
  static String getWidgetDetails(String id) => '/widget/$id';
}