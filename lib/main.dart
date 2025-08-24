import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// iOS 18 Theme and Services
import 'core/theme/ios_theme.dart';
import 'controllers/theme_controller.dart';
import 'services/dynamic_island_service.dart';
import 'core/services/home_widget_service.dart';
import 'services/accessibility_service.dart';
import 'services/performance_optimization_service.dart';
import 'services/keyboard_navigation_service.dart';
import 'services/dynamic_type_service.dart';

// AssetWorks API and Services
import 'services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/network/api_client.dart';

// iOS 18 Screens
import 'screens/splash_screen.dart';
import 'screens/otp_login_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/main_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/trending_screen.dart';
import 'screens/create_widget_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/widget_preview_screen.dart';
import 'screens/prompt_history_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await GetStorage.init();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Could not load .env file: $e');
    // Continue without env file - use defaults
  }
  
  // Initialize GetX services
  Get.lazyPut(() => StorageService());
  Get.lazyPut(() => ApiClient());
  Get.lazyPut(() => ApiService());
  
  // Initialize Theme Controller
  Get.put(ThemeController());
  
  // Register iOS 18 services with GetX
  Get.lazyPut(() => PerformanceOptimizationService());
  Get.lazyPut(() => AccessibilityService());
  Get.lazyPut(() => KeyboardNavigationService());
  Get.lazyPut(() => DynamicTypeService());
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Initialize iOS 18 services (delayed to avoid crashes)
  Future.delayed(Duration(seconds: 1), () {
    DynamicIslandService().initialize();
    HomeWidgetService().initialize();
    Get.find<PerformanceOptimizationService>().initialize();
  });
  
  // Set iOS system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const AssetWorksReimagined());
}

class AssetWorksReimagined extends StatelessWidget {
  const AssetWorksReimagined({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    
    return Obx(() => GetCupertinoApp(
      title: 'AssetWorks Reimagined',
      debugShowCheckedModeBanner: false,
      theme: themeController.currentTheme,
      // Theme changes dynamically based on user selection
      localizationsDelegates: const [
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
          transition: Transition.native,
        ),
        GetPage(
          name: '/login',
          page: () => const OtpLoginScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/otp-verify',
          page: () => const OTPVerificationScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/onboarding',
          page: () => const OnboardingScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/main',
          page: () => const MainScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/dashboard',
          page: () => const DashboardScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/trending',
          page: () => const TrendingScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/create-widget',
          page: () => const CreateWidgetScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/notifications',
          page: () => const NotificationsScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/search',
          page: () => const SearchScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/widget-preview',
          page: () => const WidgetPreviewScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/prompt-history',
          page: () => const PromptHistoryScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsScreen(),
          transition: Transition.cupertino,
        ),
      ],
      builder: (context, child) {
        // Wrap with accessibility and keyboard navigation
        return IOSKeyboardNavigator(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 2.0),
            ),
            child: child!,
          ),
        );
      },
    ));
  }
}

// GetX Cupertino App Extension
class GetCupertinoApp extends StatelessWidget {
  final String title;
  final CupertinoThemeData? theme;
  final List<GetPage>? getPages;
  final String? initialRoute;
  final bool debugShowCheckedModeBanner;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Widget Function(BuildContext, Widget?)? builder;

  const GetCupertinoApp({
    Key? key,
    required this.title,
    this.theme,
    this.getPages,
    this.initialRoute,
    this.debugShowCheckedModeBanner = true,
    this.localizationsDelegates,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: title,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CupertinoColors.systemIndigo.color,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ).copyWith(
        cupertinoOverrideTheme: theme,
        platform: TargetPlatform.iOS,
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CupertinoColors.systemIndigo.color,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ).copyWith(
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: CupertinoColors.systemIndigo,
        ),
        platform: TargetPlatform.iOS,
      ),
      themeMode: ThemeMode.system,
      getPages: getPages,
      initialRoute: initialRoute,
      localizationsDelegates: localizationsDelegates,
      builder: (context, child) {
        // Apply iOS-style navigation
        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: builder != null ? builder!(context, child) : child,
          localizationsDelegates: localizationsDelegates,
        );
      },
    );
  }
}