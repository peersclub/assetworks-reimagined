import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';

class AuthController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Observable states
  final isLoading = false.obs;
  final isAuthenticated = false.obs;
  final user = Rxn<UserModel>();
  final error = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
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
}