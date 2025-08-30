import 'package:get/get.dart';

// Controllers
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/dashboard_controller.dart';
import '../../presentation/controllers/widget_controller.dart';
import '../../presentation/controllers/template_controller.dart';
import '../../presentation/controllers/ai_widget_controller.dart';
import '../../controllers/theme_controller.dart';

// Services
import '../../services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../services/ai_provider_service.dart';

/// Global dependency injection bindings
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Core Services (Eager Loading)
    Get.put(StorageService(), permanent: true);
    Get.put(ApiService(), permanent: true);
    Get.put(ThemeController(), permanent: true);
    
    // Feature Services (Lazy Loading)
    Get.lazyPut(() => AIProviderService());
    
    // Controllers (Lazy Loading)
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => WidgetController());
    Get.lazyPut(() => TemplateController());
    Get.lazyPut(() => AIWidgetController());
  }
  
  /// Initialize critical services before app starts
  static Future<void> init() async {
    // Put any async initialization here
    Get.put(StorageService(), permanent: true);
    await Get.find<StorageService>().init();
    
    Get.put(ApiService(), permanent: true);
    Get.put(ThemeController(), permanent: true);
  }
}