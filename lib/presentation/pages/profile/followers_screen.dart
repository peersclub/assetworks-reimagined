import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/user_model.dart';
import '../../controllers/profile_controller.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({Key? key}) : super(key: key);
  
  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  late ProfileController _controller;
  late UserModel user;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
    user = Get.arguments as UserModel;
    _controller.loadFollowers(user.id);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.username}\'s Followers'),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.neutral800 : AppColors.neutral200,
                ),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search followers...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 20),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Followers List
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final allFollowers = _controller.followers;
              
              // Apply search filter
              final followers = _searchQuery.isEmpty 
                  ? allFollowers 
                  : allFollowers.where((user) {
                      return user.username.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();
              
              if (followers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.users,
                        size: 64,
                        color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty 
                            ? 'No followers found'
                            : 'No followers yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: followers.length,
                itemBuilder: (context, index) {
                  final follower = followers[index];
                  return _buildUserItem(follower);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserItem(UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openUserProfile(user),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.neutral800 : AppColors.neutral200,
            ),
          ),
          child: Row(
            children: [
              // Profile Picture
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  image: user.profilePicture != null
                      ? DecorationImage(
                          image: NetworkImage(user.profilePicture!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user.profilePicture == null
                    ? Icon(
                        LucideIcons.user,
                        size: 24,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '@${user.username}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.badgeCheck,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    if (user.bio != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.bio!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.layout,
                          size: 12,
                          color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user.widgetCount} widgets',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          LucideIcons.users,
                          size: 12,
                          color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user.followersCount} followers',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Follow Button
              AppButton(
                text: 'Follow',
                size: AppButtonSize.small,
                onPressed: () => _followUser(user),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _openUserProfile(UserModel user) {
    Get.toNamed('/user-profile', arguments: user);
  }
  
  void _followUser(UserModel user) {
    _controller.followUser(user.id);
  }
}