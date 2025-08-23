import 'package:get/get.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/otp_controller.dart';
import '../../presentation/controllers/widget_controller.dart';
import '../../presentation/controllers/profile_controller.dart';
import '../services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize services first
    Get.put<StorageService>(StorageService(), permanent: true);
    
    // Initialize all controllers
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<OtpController>(() => OtpController(), fenix: true);
    Get.lazyPut<WidgetController>(() => WidgetController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}