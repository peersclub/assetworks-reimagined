import 'package:get/get.dart';

// Screens
import '../modules/splash/views/splash_view.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/otp_verification_view.dart';
import '../modules/main/views/main_view.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/widgets/views/create_widget_view.dart';
import '../modules/widgets/views/widget_preview_view.dart';
import '../modules/widgets/views/widget_remix_view.dart';
import '../modules/templates/views/template_list_view.dart';
import '../modules/explore/views/explore_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/notifications/views/notifications_view.dart';

// Bindings
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/widgets/bindings/widget_binding.dart';
import '../modules/templates/bindings/template_binding.dart';
import '../modules/explore/bindings/explore_binding.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/notifications/bindings/notifications_binding.dart';

/// Application Routes
abstract class AppRoutes {
  // Route Names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String createWidget = '/create-widget';
  static const String widgetPreview = '/widget-preview';
  static const String widgetRemix = '/widget-remix';
  static const String templates = '/templates';
  static const String explore = '/explore';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  
  // Route Pages
  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: otpVerification,
      page: () => const OtpVerificationView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: main,
      page: () => const MainView(),
      binding: MainBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: createWidget,
      page: () => const CreateWidgetView(),
      binding: WidgetBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: widgetPreview,
      page: () => const WidgetPreviewView(),
      binding: WidgetBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: widgetRemix,
      page: () => const WidgetRemixView(),
      binding: WidgetBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: templates,
      page: () => const TemplateListView(),
      binding: TemplateBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: explore,
      page: () => const ExploreView(),
      binding: ExploreBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.cupertino,
    ),
  ];
}