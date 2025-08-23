import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/storage_helper.dart';
import '../../data/models/user_model.dart';

class OtpController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  // Observable states
  final isVerifying = false.obs;
  final isResending = false.obs;
  
  Future<void> sendOtp(String identifier) async {
    try {
      isResending.value = true;
      
      final response = await _apiClient.sendOtp(identifier);
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Code Sent',
          'Verification code has been sent to $identifier',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isResending.value = false;
    }
  }
  
  Future<void> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    try {
      isVerifying.value = true;
      
      // Debug logging
      print('Verifying OTP for identifier: $identifier');
      print('OTP Code: $otp');
      
      // Get Firebase token if available
      String? firebaseToken;
      // TODO: Get Firebase token from Firebase Messaging
      
      final response = await _apiClient.verifyOtp(
        identifier: identifier,
        otp: otp,
        firebaseToken: firebaseToken,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      // Check if response indicates success even with 200 status
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        // Check for error in response body even with 200 status
        if (data['error'] == true || data['success'] == false) {
          throw Exception(data['message'] ?? 'Verification failed');
        }
        
        // Handle both direct data and nested data structure
        final actualData = data['data'] ?? data;
        
        // Save token - check multiple possible field names
        final token = actualData['token'] ?? actualData['access_token'] ?? actualData['accessToken'];
        if (token != null) {
          await StorageHelper.saveToken(token);
        }
        
        // Save user data - check if user data exists
        final userData = actualData['user'] ?? actualData['data'];
        if (userData != null) {
          try {
            final user = UserModel.fromJson(userData);
            await StorageHelper.saveUser(user.toJson());
          } catch (e) {
            print('Error parsing user data: $e');
            // Create minimal user if parsing fails
            final minimalUser = UserModel(
              id: userData['id'] ?? userData['_id'] ?? '',
              username: userData['username'] ?? identifier.split('@')[0],
              email: identifier.contains('@') ? identifier : '',
              widgetCount: 0,
              followersCount: 0,
              followingCount: 0,
              isVerified: false,
              isPremium: false,
              joinedAt: DateTime.now(),
            );
            await StorageHelper.saveUser(minimalUser.toJson());
          }
        }
        
        // Check onboarding status - handle different field names
        final onboardStatus = actualData['onboard'] ?? actualData['onboarding'] ?? actualData['onboard_status'];
        final isNewUser = actualData['is_new_user'] ?? actualData['isNewUser'] ?? false;
        
        Get.snackbar(
          'Success',
          'Verification successful!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Small delay to ensure token is saved
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Navigate based on onboarding status or if new user
        if (onboardStatus == 'pending' || isNewUser == true) {
          // For now, always go to home since profile-setup might not exist
          Get.offAllNamed('/home');
        } else {
          // User is fully onboarded
          Get.offAllNamed('/home');
        }
        
        // Return early to prevent any further error handling
        return;
      } else {
        throw Exception(response.data['message'] ?? 'Invalid verification code');
      }
    } catch (e) {
      print('Verification error: $e');
      
      // Only show error if we haven't already shown success
      if (!Get.isSnackbarOpen) {
        String errorMessage = 'Invalid or expired code. Please try again.';
        
        // Extract more specific error message if available
        if (e.toString().contains('DioException')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('Invalid')) {
          errorMessage = 'Invalid verification code. Please check and try again.';
        } else if (e.toString().contains('expired')) {
          errorMessage = 'Code has expired. Please request a new one.';
        } else if (e.toString().contains('message:')) {
          // Extract message from exception
          final match = RegExp(r'message: (.+)').firstMatch(e.toString());
          if (match != null) {
            errorMessage = match.group(1) ?? errorMessage;
          }
        }
        
        Get.snackbar(
          'Verification Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isVerifying.value = false;
    }
  }
  
  Future<void> resendOtp(String identifier) async {
    await sendOtp(identifier);
  }
}