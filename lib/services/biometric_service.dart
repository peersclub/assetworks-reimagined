import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get_storage/get_storage.dart';

class BiometricService extends GetxService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final GetStorage _storage = GetStorage();
  
  // Observable states
  final RxBool isBiometricEnabled = false.obs;
  final RxBool isAvailable = false.obs;
  final RxList<BiometricType> availableBiometrics = <BiometricType>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initBiometrics();
  }
  
  Future<void> _initBiometrics() async {
    try {
      // Check if biometrics are available
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      isAvailable.value = canCheck && isDeviceSupported;
      
      if (isAvailable.value) {
        // Get available biometric types
        final biometrics = await _localAuth.getAvailableBiometrics();
        availableBiometrics.value = biometrics;
        
        // Check if user has enabled biometric auth
        isBiometricEnabled.value = _storage.read('biometric_enabled') ?? false;
      }
    } catch (e) {
      print('Error initializing biometrics: $e');
    }
  }
  
  // Enable biometric authentication
  Future<bool> enableBiometric() async {
    try {
      if (!isAvailable.value) {
        Get.snackbar(
          'Not Available',
          'Biometric authentication is not available on this device',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      // Authenticate to enable
      final authenticated = await authenticate(
        reason: 'Enable biometric authentication for AssetWorks',
      );
      
      if (authenticated) {
        await _storage.write('biometric_enabled', true);
        isBiometricEnabled.value = true;
        
        // Store encrypted credentials if user is logged in
        final token = _storage.read('auth_token');
        if (token != null) {
          await _storeCredentials(token);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error enabling biometric: $e');
      return false;
    }
  }
  
  // Disable biometric authentication
  Future<void> disableBiometric() async {
    await _storage.write('biometric_enabled', false);
    await _storage.remove('biometric_credentials');
    isBiometricEnabled.value = false;
  }
  
  // Authenticate with biometrics
  Future<bool> authenticate({
    required String reason,
    bool stickyAuth = true,
  }) async {
    try {
      if (!isAvailable.value) return false;
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: false, // Allow PIN/pattern as fallback
          useErrorDialogs: true,
        ),
      );
      
      return authenticated;
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }
  
  // Quick login with biometrics
  Future<Map<String, dynamic>?> biometricLogin() async {
    try {
      if (!isBiometricEnabled.value) {
        return null;
      }
      
      final authenticated = await authenticate(
        reason: 'Login to AssetWorks',
      );
      
      if (authenticated) {
        // Retrieve stored credentials
        final credentials = await _getStoredCredentials();
        if (credentials != null) {
          return {
            'success': true,
            'token': credentials['token'],
            'email': credentials['email'],
          };
        }
      }
      
      return null;
    } catch (e) {
      print('Biometric login error: $e');
      return null;
    }
  }
  
  // Store encrypted credentials
  Future<void> _storeCredentials(String token) async {
    try {
      final email = _storage.read('user_email') ?? '';
      
      // In production, use proper encryption
      final credentials = {
        'token': token,
        'email': email,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _storage.write('biometric_credentials', credentials);
    } catch (e) {
      print('Error storing credentials: $e');
    }
  }
  
  // Get stored credentials
  Future<Map<String, dynamic>?> _getStoredCredentials() async {
    try {
      final credentials = _storage.read('biometric_credentials');
      if (credentials != null) {
        // Check if credentials are not expired (24 hours)
        final timestamp = DateTime.parse(credentials['timestamp']);
        if (DateTime.now().difference(timestamp).inHours < 24) {
          return credentials;
        } else {
          // Credentials expired, remove them
          await _storage.remove('biometric_credentials');
        }
      }
      return null;
    } catch (e) {
      print('Error getting credentials: $e');
      return null;
    }
  }
  
  // Update stored credentials when user logs in normally
  Future<void> updateCredentials(String token, String email) async {
    if (isBiometricEnabled.value) {
      await _storage.write('user_email', email);
      await _storeCredentials(token);
    }
  }
  
  // Check biometric type
  String getBiometricType() {
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Touch ID';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    }
    return 'Biometric';
  }
  
  // Check if should show biometric prompt on app launch
  bool shouldShowBiometricPrompt() {
    if (!isBiometricEnabled.value) return false;
    
    final credentials = _storage.read('biometric_credentials');
    return credentials != null;
  }
}