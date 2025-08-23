import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../data/models/user_model.dart';
import '../../data/models/widget_response_model.dart';
import '../../core/utils/storage_helper.dart';

class ProfileController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  
  // Observable states
  final isLoading = false.obs;
  final currentUser = Rxn<UserModel>();
  final userWidgets = <WidgetResponseModel>[].obs;
  final likedWidgets = <WidgetResponseModel>[].obs;
  final activities = <Map<String, dynamic>>[].obs;
  final followers = <UserModel>[].obs;
  final following = <UserModel>[].obs;
  final isFollowing = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCurrentUserProfile();
  }
  
  Future<void> loadCurrentUserProfile() async {
    try {
      isLoading.value = true;
      
      final response = await _apiClient.getUserProfile();
      
      if (response.statusCode == 200 && response.data != null) {
        print('Profile API Response: ${response.data}');
        
        // The API returns the user data directly, not wrapped in 'data'
        final userData = response.data is Map && response.data.containsKey('data') 
            ? response.data['data'] 
            : response.data;
            
        if (userData != null) {
          currentUser.value = UserModel.fromJson(userData);
          await loadUserWidgets(currentUser.value!.id);
          await loadUserActivities(currentUser.value!.id);
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadUserProfile(String userId) async {
    try {
      isLoading.value = true;
      
      // Note: Backend doesn't have get user by ID endpoint
      // This feature is not supported
      Get.snackbar(
        'Not Available',
        'User profile lookup is not available',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadUserWidgets(String userId) async {
    try {
      // Load user's created widgets
      final response = await _apiClient.getDashboardWidgets();
      
      if (response.statusCode == 200 && response.data != null) {
        print('Widgets API Response: ${response.data}');
        
        // Check if data is wrapped or direct
        final widgetsData = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;
            
        if (widgetsData is List) {
          userWidgets.value = widgetsData
              .map((w) => WidgetResponseModel.fromJson(w))
              .toList();
        } else {
          userWidgets.value = [];
        }
      }
    } catch (e) {
      print('Error loading user widgets: $e');
      userWidgets.value = [];
    }
  }
  
  Future<void> loadUserActivities(String userId) async {
    // User activities endpoint not available in backend
    // Keep empty until API is available
    activities.value = [];
  }
  
  Future<void> checkFollowStatus(String userId) async {
    try {
      // Check if current user follows this user
      final response = await _apiClient.getFollowings();
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        isFollowing.value = data.any((u) => u['id'] == userId);
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }
  
  Future<void> followUser(String userId) async {
    try {
      await _apiClient.followUser(userId);
      isFollowing.value = true;
      
      // Update follower count
      if (currentUser.value != null) {
        currentUser.value = currentUser.value!.copyWith(
          followersCount: currentUser.value!.followersCount + 1,
        );
      }
      
      Get.snackbar(
        'Following',
        'You are now following this user',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error following user: $e');
      Get.snackbar(
        'Error',
        'Failed to follow user',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> unfollowUser(String userId) async {
    try {
      await _apiClient.unfollowUser(userId);
      isFollowing.value = false;
      
      // Update follower count
      if (currentUser.value != null) {
        currentUser.value = currentUser.value!.copyWith(
          followersCount: currentUser.value!.followersCount - 1,
        );
      }
      
      Get.snackbar(
        'Unfollowed',
        'You have unfollowed this user',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error unfollowing user: $e');
      Get.snackbar(
        'Error',
        'Failed to unfollow user',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> loadFollowers(String userId) async {
    try {
      isLoading.value = true;
      
      final response = await _apiClient.getFollowers();
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        followers.value = data
            .map((u) => UserModel.fromJson(u))
            .toList();
      }
    } catch (e) {
      print('Error loading followers: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadFollowing(String userId) async {
    try {
      isLoading.value = true;
      
      final response = await _apiClient.getFollowings();
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        following.value = data
            .map((u) => UserModel.fromJson(u))
            .toList();
      }
    } catch (e) {
      print('Error loading following: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      
      final response = await _apiClient.updateProfile(data);
      
      if (response.statusCode == 200 && response.data != null) {
        currentUser.value = UserModel.fromJson(response.data['data']);
        
        // Update stored user
        await StorageHelper.saveUser(response.data['data']);
        
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}