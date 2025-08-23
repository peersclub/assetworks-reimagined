import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/network/api_client.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../core/utils/biometric_auth.dart';
import 'otp_controller.dart';

class AuthController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = Get.find<StorageService>();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final BiometricAuth _biometricAuth = BiometricAuth();
  
  // Observable states
  final isLoading = false.obs;
  final isAuthenticated = false.obs;
  final user = Rxn<UserModel>();
  final error = ''.obs;
  final isBiometricEnabled = false.obs;
  final biometricType = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
    _checkBiometricCapability();
  }
  
  // ============== Initialization ==============
  
  Future<void> _checkAuthStatus() async {
    final token = await _storageService.getAuthToken();
    if (token != null) {
      final userData = _storageService.getUser();
      if (userData != null) {
        user.value = UserModel.fromJson(userData);
        isAuthenticated.value = true;
      }
    }
  }
  
  // ============== Authentication Methods ==============
  
  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // Call logout API
      await _apiClient.signOut();
      
      // Clear local data
      await _storageService.clearAuth();
      user.value = null;
      isAuthenticated.value = false;
      
      Get.offAllNamed('/landing-screen');
      
      Get.snackbar(
        'Logged Out',
        'You have been successfully logged out',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      // Even if API fails, clear local session
      await _storageService.clearAuth();
      user.value = null;
      isAuthenticated.value = false;
      Get.offAllNamed('/landing-screen');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Update user after successful OTP login
  void setUser(UserModel userModel) {
    user.value = userModel;
    isAuthenticated.value = true;
    _storageService.saveUser(userModel.toJson());
  }
  
  void clearError() {
    error.value = '';
  }
  
  // ============== Biometric Authentication ==============
  
  Future<void> _checkBiometricCapability() async {
    try {
      final isAvailable = await BiometricAuth.isBiometricAvailable();
      if (isAvailable) {
        final types = await _localAuth.getAvailableBiometrics();
        if (types.contains(BiometricType.face)) {
          biometricType.value = 'Face ID';
        } else if (types.contains(BiometricType.fingerprint)) {
          biometricType.value = 'Touch ID';
        }
        
        // Check if user has enabled biometric
        final biometricEnabled = _storageService.getBiometricEnabled();
        isBiometricEnabled.value = biometricEnabled ?? false;
      }
    } catch (e) {
      print('Error checking biometric capability: $e');
    }
  }
  
  Future<bool> authenticateWithBiometric() async {
    try {
      final authenticated = await BiometricAuth.authenticate(
        reason: 'Authenticate to access AssetWorks',
      );
      
      if (authenticated) {
        // Check if we have stored credentials
        final storedEmail = await _storageService.getStoredEmail();
        final storedPassword = await _storageService.getStoredPassword();
        
        if (storedEmail != null && storedPassword != null) {
          // Login with stored credentials
          await loginWithCredentials(storedEmail, storedPassword);
          return true;
        } else {
          // Get stored token and user data for quick login
          final token = await _storageService.getAuthToken();
          if (token != null) {
            final userData = _storageService.getUser();
            if (userData != null) {
              user.value = UserModel.fromJson(userData);
              isAuthenticated.value = true;
              return true;
            }
          }
        }
      }
      return false;
    } catch (e) {
      print('Biometric authentication error: $e');
      Get.snackbar(
        'Authentication Failed',
        'Could not authenticate with biometric',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
  
  Future<void> enableBiometric(String email, String password) async {
    try {
      final authenticated = await BiometricAuth.authenticate(
        reason: 'Enable biometric login for AssetWorks',
      );
      
      if (authenticated) {
        // Store credentials securely
        await _storageService.saveCredentials(email, password);
        await _storageService.setBiometricEnabled(true);
        isBiometricEnabled.value = true;
        
        Get.snackbar(
          'Success',
          '${biometricType.value} login enabled',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error enabling biometric: $e');
      Get.snackbar(
        'Error',
        'Failed to enable biometric login',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> disableBiometric() async {
    try {
      await _storageService.clearCredentials();
      await _storageService.setBiometricEnabled(false);
      isBiometricEnabled.value = false;
      
      Get.snackbar(
        'Success',
        'Biometric login disabled',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error disabling biometric: $e');
    }
  }
  
  Future<void> loginWithCredentials(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Use OTP controller for login
      final otpController = Get.find<OtpController>();
      // For now, we'll use stored credentials approach
      
      // Save auth data for demo
      await _storageService.saveAuthToken('demo-token');
      await _storageService.saveUser({'email': email, 'id': '1'});
      
      user.value = UserModel(id: '1', email: email);
      isAuthenticated.value = true;
      
      // Navigate to main screen
      Get.offAllNamed('/main');
      return;
      
      // Real API call would be:
      // final response = await _apiClient.signInWithEmail(email, password);
      
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data']['user'];
        final token = response.data['data']['token'];
        
        // Save auth data
        await _storageService.saveAuthToken(token);
        await _storageService.saveUser(userData);
        
        user.value = UserModel.fromJson(userData);
        isAuthenticated.value = true;
        
        // Navigate to main screen
        Get.offAllNamed('/main');
      } else {
        error.value = 'Invalid credentials';
      }
    } catch (e) {
      print('Login error: $e');
      error.value = 'Login failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}