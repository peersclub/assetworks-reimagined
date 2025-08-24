import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'core/theme/ios_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/bindings/initial_binding.dart';
import 'presentation/pages/ios/ios_main_screen.dart';
import 'presentation/pages/splash/ios_splash_screen.dart';
import 'ios_routes.dart';

class AssetWorksiOSApp extends StatefulWidget {
  const AssetWorksiOSApp({Key? key}) : super(key: key);

  @override
  State<AssetWorksiOSApp> createState() => _AssetWorksiOSAppState();
}

class _AssetWorksiOSAppState extends State<AssetWorksiOSApp> with WidgetsBindingObserver {
  final ThemeController _themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupSystemUI();
    _setupDynamicIsland();
    _setupHomeWidget();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      _setupSystemUI();
    });
  }

  void _setupSystemUI() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: brightness,
        statusBarIconBrightness: brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        systemNavigationBarColor: CupertinoColors.systemBackground.resolveFrom(context),
        systemNavigationBarIconBrightness: brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
      ),
    );

    // iOS 18 Edge-to-edge display
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
  }

  void _setupDynamicIsland() {
    // Dynamic Island setup will be implemented in a separate service
    // This is where we'll initialize the Dynamic Island controller
  }

  void _setupHomeWidget() {
    // Home Widget setup will be implemented in a separate service
    // This is where we'll initialize the home widget controller
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = _themeController.isDarkMode;
      
      return PlatformProvider(
        settings: PlatformSettingsData(
          iosUsesMaterialWidgets: false,
          iosUseZeroPaddingForAppbarPlatformIcon: true,
        ),
        builder: (context) => PlatformApp.router(
          title: 'AssetWorks',
          debugShowCheckedModeBanner: false,
          
          // iOS specific settings
          cupertino: (_, __) => CupertinoAppData(
            theme: isDarkMode ? iOS18Theme.darkTheme : iOS18Theme.lightTheme,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              DefaultCupertinoLocalizations.delegate,
            ],
          ),
          
          // Material fallback (for web/android if needed)
          material: (_, __) => MaterialAppData(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          ),
          
          // Routing
          routeInformationParser: iOSRouter.routeInformationParser,
          routerDelegate: iOSRouter.routerDelegate,
          routeInformationProvider: iOSRouter.routeInformationProvider,
        ),
      );
    });
  }
}

/// iOS Platform App (Alternative approach using GetCupertinoApp)
class AssetWorksiOSAppAlternative extends StatelessWidget {
  const AssetWorksiOSAppAlternative({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    
    return Obx(() => GetCupertinoApp(
      title: 'AssetWorks',
      theme: themeController.isDarkMode 
          ? iOS18Theme.darkTheme 
          : iOS18Theme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      getPages: iOSAppRoutes,
      home: const iOSSplashScreen(),
      defaultTransition: Transition.cupertino,
      transitionDuration: iOS18Theme.normalTransition,
      
      // iOS specific settings
      scrollBehavior: const CupertinoScrollBehavior(),
      
      builder: (context, child) {
        // Apply iOS 18 specific modifications
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Prevent text scaling issues
          ),
          child: child!,
        );
      },
      
      // Localization
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      
      // Observers for analytics, etc.
      navigatorObservers: [
        // Add your observers here
      ],
    ));
  }
}