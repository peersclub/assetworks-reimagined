import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';

class BiometricAuth {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Check if biometric is available
  static Future<bool> isAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('Biometric availability check error: $e');
      return false;
    }
  }
  
  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Get available biometrics error: $e');
      return [];
    }
  }
  
  // Check if Face ID is available
  static Future<bool> isFaceIdAvailable() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }
  
  // Check if Touch ID is available
  static Future<bool> isTouchIdAvailable() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }
  
  // Authenticate with biometric
  static Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final isAvailable = await BiometricAuth.isAvailable();
      if (!isAvailable) {
        Get.snackbar(
          'Not Available',
          'Biometric authentication is not available on this device',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      
      return authenticated;
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
      
      String errorMessage = 'Authentication failed';
      switch (e.code) {
        case 'NotAvailable':
          errorMessage = 'Biometric authentication is not available';
          break;
        case 'NotEnrolled':
          errorMessage = 'No biometric credentials are enrolled';
          break;
        case 'LockedOut':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        case 'PermanentlyLockedOut':
          errorMessage = 'Biometric authentication is locked. Please use passcode';
          break;
        case 'BiometricOnlyNotSupported':
          errorMessage = 'Biometric-only authentication is not supported';
          break;
        default:
          errorMessage = e.message ?? 'Authentication failed';
      }
      
      Get.snackbar(
        'Authentication Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      
      return false;
    } catch (e) {
      print('Unexpected biometric error: $e');
      return false;
    }
  }
  
  // Cancel authentication
  static Future<bool> cancelAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      print('Cancel authentication error: $e');
      return false;
    }
  }
}