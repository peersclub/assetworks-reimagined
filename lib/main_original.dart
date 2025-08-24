import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/bindings/initial_binding.dart';
import 'presentation/pages/splash/splash_screen.dart';
import 'presentation/pages/auth/login_screen.dart';
import 'presentation/pages/auth/login_with_biometric_screen.dart';
import 'presentation/pages/auth/register_screen.dart';
import 'presentation/pages/auth/forgot_password_screen.dart';
import 'presentation/pages/auth/otp_login_screen.dart';
import 'presentation/pages/auth/otp_screen.dart';
// Register and forgot password screens removed - using OTP only
import 'presentation/pages/auth/onboarding_screen.dart';
import 'presentation/pages/main_screen.dart';
import 'presentation/pages/settings/settings_screen.dart';
import 'presentation/pages/widgets/create_widget_screen.dart';
import 'presentation/pages/widgets/widget_discovery_screen.dart';
import 'presentation/pages/widgets/widget_view_screen.dart';
import 'presentation/pages/widgets/prompt_history_screen.dart';
import 'presentation/pages/widgets/widget_templates_screen.dart';
import 'presentation/pages/widgets/template_customize_screen.dart';
import 'presentation/pages/widgets/widget_remix_screen.dart';
import 'presentation/pages/widgets/remix_approach_screen.dart';
import 'presentation/pages/widgets/widget_share_screen.dart';
import 'presentation/pages/profile/user_profile_screen.dart';
import 'presentation/pages/profile/enhanced_profile_screen.dart';
import 'presentation/pages/profile/followers_screen.dart';
import 'presentation/pages/playground/code_playground_screen.dart';

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
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  runApp(const AssetWorksApp());
}

class AssetWorksApp extends StatelessWidget {
  const AssetWorksApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Initialize theme controller
    Get.put(ThemeController());
    
    return GetMaterialApp(
      title: 'AssetWorks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeController.to.theme,
      initialBinding: InitialBinding(),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/', page: () => const MainScreen()),
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const LoginWithBiometricScreen()),
        GetPage(name: '/otp-login', page: () => const OtpLoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),
        GetPage(name: '/otp-verify', page: () => const OtpScreen()),
        GetPage(name: '/landing-screen', page: () => const OtpLoginScreen()),
        // Register and forgot password routes removed - using OTP only
        GetPage(name: '/home', page: () => const MainScreen()),
        GetPage(name: '/main', page: () => const MainScreen()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(name: '/create-widget', page: () => const CreateWidgetScreen()),
        GetPage(name: '/widget-discovery', page: () => const WidgetDiscoveryScreen()),
        GetPage(name: '/widget-view', page: () => const WidgetViewScreen()),
        GetPage(name: '/prompt-history', page: () => const PromptHistoryScreen()),
        GetPage(name: '/widget-templates', page: () => const WidgetTemplatesScreen()),
        GetPage(name: '/template-customize', page: () => const TemplateCustomizeScreen()),
        GetPage(name: '/widget-remix', page: () => const WidgetRemixScreen()),
        GetPage(name: '/remix-approach', page: () => const RemixApproachScreen()),
        GetPage(name: '/widget-share', page: () => const WidgetShareScreen()),
        GetPage(name: '/user-profile', page: () => const UserProfileScreen()),
        GetPage(name: '/profile', page: () => const EnhancedProfileScreen()),
        GetPage(name: '/followers', page: () => const FollowersScreen()),
        GetPage(name: '/following', page: () => const FollowersScreen()),
        GetPage(name: '/code-playground', page: () => const CodePlaygroundScreen()),
      ],
    );
  }
}