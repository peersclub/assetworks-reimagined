import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// App Configuration
import 'app/config/app_config.dart';
import 'app/config/app_bindings.dart';
import 'app/config/app_routes.dart';
import 'app/config/app_theme.dart';

void main() async {
  await initializeApp();
  runApp(const AssetWorksApp());
}

/// Initialize all required services and configurations
Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await GetStorage.init();
  
  // Load environment variables
  await loadEnvironment();
  
  // Configure system UI
  configureSystemUI();
  
  // Initialize services
  await AppBindings.init();
  
  // Set device orientations
  await setDeviceOrientations();
}

/// Load environment variables
Future<void> loadEnvironment() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Environment file not found, using defaults: $e');
  }
}

/// Configure system UI overlays
void configureSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
}

/// Set supported device orientations
Future<void> setDeviceOrientations() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// Main Application Widget
class AssetWorksApp extends StatelessWidget {
  const AssetWorksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      initialBinding: AppBindings(),
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

/// Custom GetCupertinoApp implementation
class GetCupertinoApp extends GetMaterialApp {
  const GetCupertinoApp({
    super.key,
    super.title,
    super.theme,
    super.darkTheme,
    super.themeMode,
    super.initialRoute,
    super.getPages,
    super.initialBinding,
    super.debugShowCheckedModeBanner,
    super.defaultTransition,
    super.transitionDuration,
    super.locale,
    super.fallbackLocale,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: title ?? '',
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      theme: theme?.copyWith(
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: CupertinoColors.systemIndigo,
        ),
        platform: TargetPlatform.iOS,
      ),
      darkTheme: darkTheme?.copyWith(
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: CupertinoColors.systemIndigo,
        ),
        platform: TargetPlatform.iOS,
      ),
      themeMode: themeMode,
      getPages: getPages,
      initialRoute: initialRoute,
      initialBinding: initialBinding,
      defaultTransition: defaultTransition,
      transitionDuration: transitionDuration,
      locale: locale,
      fallbackLocale: fallbackLocale,
    );
  }
}