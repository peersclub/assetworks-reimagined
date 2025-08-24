import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../../data/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../core/utils/biometric_auth.dart';
import 'dart:io';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
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
      await _apiService.logout();
      
      // Clear local data
      await _storageService.clearAuth();
      user.value = null;
      isAuthenticated.value = false;
      
      Get.offAllNamed('/login');
      
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
      Get.offAllNamed('/login');
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
      final isAvailable = await BiometricAuth.isAvailable();
      print('Biometric available: $isAvailable');
      
      if (isAvailable) {
        final types = await _localAuth.getAvailableBiometrics();
        print('Available biometric types: $types');
        
        if (types.contains(BiometricType.face)) {
          biometricType.value = 'Face ID';
        } else if (types.contains(BiometricType.fingerprint)) {
          biometricType.value = 'Touch ID';
        } else if (types.isNotEmpty) {
          // Fallback to first available type
          biometricType.value = 'Biometric';
        }
        
        // For simulator testing, always show Face ID option
        if (biometricType.value.isEmpty) {
          biometricType.value = 'Face ID';
        }
        
        // Check if user has enabled biometric
        final biometricEnabled = _storageService.getBiometricEnabled();
        isBiometricEnabled.value = biometricEnabled ?? false;
        
        print('Biometric type set to: ${biometricType.value}');
        print('Biometric enabled: ${isBiometricEnabled.value}');
      } else {
        // For testing on simulator, always show Face ID
        biometricType.value = 'Face ID';
        print('Biometric not available, defaulting to Face ID for UI');
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
          return await loginWithCredentials(storedEmail, storedPassword);
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
  
  Future<bool> loginWithCredentials(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Call real API
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      
      // Extract user data from response
      final userData = response['user'];
      user.value = UserModel.fromJson(userData);
      isAuthenticated.value = true;
      
      // Navigate to main screen
      Get.offAllNamed('/main');
      
      Get.snackbar(
        'Welcome back!',
        'Successfully logged in',
        snackPosition: SnackPosition.TOP,
      );
      
      return true;
    } catch (e) {
      print('Login error: $e');
      error.value = e.toString();
      
      Get.snackbar(
        'Login Failed',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Call real API
      final response = await _apiService.signup(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      
      Get.snackbar(
        'Registration Successful',
        'Please check your email to verify your account',
        snackPosition: SnackPosition.TOP,
      );
      
      // Navigate to OTP verification
      Get.toNamed('/otp', arguments: {'email': email});
      
      return true;
    } catch (e) {
      print('Registration error: $e');
      error.value = e.toString();
      
      Get.snackbar(
        'Registration Failed',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> verifyOTP(String email, String otp) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Call real API
      final response = await _apiService.verifyOTP(
        email: email,
        otp: otp,
      );
      
      // Extract user data from response
      final userData = response['user'];
      user.value = UserModel.fromJson(userData);
      isAuthenticated.value = true;
      
      Get.snackbar(
        'Welcome!',
        'Account verified successfully',
        snackPosition: SnackPosition.TOP,
      );
      
      // Navigate to main screen or onboarding
      Get.offAllNamed('/onboarding');
      
      return true;
    } catch (e) {
      print('OTP verification error: $e');
      error.value = e.toString();
      
      Get.snackbar(
        'Verification Failed',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Call real API
      await _apiService.forgotPassword(email);
      
      Get.snackbar(
        'Password Reset',
        'Check your email for reset instructions',
        snackPosition: SnackPosition.TOP,
      );
      
      return true;
    } catch (e) {
      print('Forgot password error: $e');
      error.value = e.toString();
      
      Get.snackbar(
        'Reset Failed',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Call real API
      await _apiService.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      
      Get.snackbar(
        'Password Updated',
        'Your password has been reset successfully',
        snackPosition: SnackPosition.TOP,
      );
      
      // Navigate to login
      Get.offAllNamed('/login');
      
      return true;
    } catch (e) {
      print('Reset password error: $e');
      error.value = e.toString();
      
      Get.snackbar(
        'Reset Failed',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? phone,
    File? avatar,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Call real API
      final updatedUser = await _apiService.updateProfile(
        name: name,
        bio: bio,
        phone: phone,
        avatar: avatar,
      );
      
      user.value = updatedUser;
      
      Get.snackbar(
        'Profile Updated',
        'Your profile has been updated successfully',
        snackPosition: SnackPosition.TOP,
      );
      
      return true;
    } catch (e) {
      print('Update profile error: $e');
      error.value = e.toString();
      
      Get.snackbar(
        'Update Failed',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Call real API
      await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      Get.snackbar(
        'Password Changed',
        'Your password has been updated successfully',
        snackPosition: SnackPosition.TOP,
      );
      
      return true;
    } catch (e) {
      print('Change password error: $e');
      error.value = e.toString();
      
      Get.snackbar(
        'Change Failed',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}