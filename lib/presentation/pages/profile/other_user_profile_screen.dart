import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../widgets/widget_card.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;
  final String? username;
  
  const OtherUserProfileScreen({
    Key? key,
    required this.userId,
    this.username,
  }) : super(key: key);
  
  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  
  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'Sarah Smith',
    'username': '@sarahsmith',
    'bio': 'Financial Analyst | Market Expert | Crypto Enthusiast',
    'followers': 5432,
    'following': 234,
    'posts': 156,
    'joinedDate': 'March 2023',
    'isPremium': true,
    'isVerified': true,
  };
  
  // Mock posts
  final List<Map<String, dynamic>> _userPosts = [
    {
      'id': '1',
      'title': 'Tech Stock Analysis Q4 2024',
      'description': 'Deep dive into the best performing tech stocks',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'likes': 234,
      'comments': 45,
      'shares': 12,
      'tags': ['Tech', 'Stocks', 'Analysis'],
      'isSaved': false,
    },
    {
      'id': '2',
      'title': 'Cryptocurrency Market Update',
      'description': 'Latest trends in the crypto market',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'likes': 567,
      'comments': 89,
      'shares': 34,
      'tags': ['Crypto', 'Bitcoin', 'Market'],
      'isSaved': true,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(45),
                                border: Border.all(
                                  color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _userData['name'][0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (_userData['isVerified'])
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.info,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    LucideIcons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Name and username
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _userData['name'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            if (_userData['isPremium']) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.crown,
                                      size: 10,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'PRO',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData['username'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Bio
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            _userData['bio'],
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem('Posts', _userData['posts'].toString()),
                            Container(
                              width: 1,
                              height: 30,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                            ),
                            _buildStatItem('Followers', _formatCount(_userData['followers'])),
                            Container(
                              width: 1,
                              height: 30,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                            ),
                            _buildStatItem('Following', _formatCount(_userData['following'])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.moreVertical, size: 20),
                  onSelected: (value) {
                    switch (value) {
                      case 'share':
                        // Handle share
                        break;
                      case 'report':
                        // Handle report
                        break;
                      case 'block':
                        // Handle block
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(LucideIcons.share2, size: 18),
                          SizedBox(width: 12),
                          Text('Share Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(LucideIcons.flag, size: 18),
                          SizedBox(width: 12),
                          Text('Report User'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(LucideIcons.userX, size: 18),
                          SizedBox(width: 12),
                          Text('Block User'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: Container(
                  color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                  child: Column(
                    children: [
                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: _isFollowing ? 'Following' : 'Follow',
                                icon: _isFollowing ? LucideIcons.userCheck : LucideIcons.userPlus,
                                type: _isFollowing ? AppButtonType.outline : AppButtonType.primary,
                                onPressed: () {
                                  setState(() {
                                    _isFollowing = !_isFollowing;
                                  });
                                },
                                size: AppButtonSize.medium,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppButton(
                                text: 'Message',
                                icon: LucideIcons.messageCircle,
                                type: AppButtonType.outline,
                                onPressed: () {},
                                size: AppButtonSize.medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tabs
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Posts'),
                          Tab(text: 'Widgets'),
                          Tab(text: 'About'),
                        ],
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Posts Tab
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                final post = _userPosts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: WidgetCard(
                    title: post['title'],
                    author: _userData['name'],
                    authorId: widget.userId,
                    date: post['date'],
                    likes: post['likes'],
                    comments: post['comments'],
                    shares: post['shares'],
                    description: post['description'],
                    tags: List<String>.from(post['tags']),
                    isSaved: post['isSaved'],
                    onTap: () {},
                    onAuthorTap: null, // Don't navigate to same profile
                    onLike: () {},
                    onComment: () {},
                    onShare: () {},
                    onSave: () {
                      setState(() {
                        post['isSaved'] = !post['isSaved'];
                      });
                    },
                  ),
                );
              },
            ),
            
            // Widgets Tab
            Center(
              child: Text(
                'No widgets yet',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            
            // About Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('Member Since', _userData['joinedDate']),
                  _buildInfoSection('Total Posts', _userData['posts'].toString()),
                  _buildInfoSection('Total Followers', _formatCount(_userData['followers'])),
                  _buildInfoSection('Total Following', _formatCount(_userData['following'])),
                  if (_userData['isPremium'])
                    _buildInfoSection('Membership', 'Premium Member', isPremium: true),
                  if (_userData['isVerified'])
                    _buildInfoSection('Verification', 'Verified Account', isVerified: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoSection(String label, String value, {bool isPremium = false, bool isVerified = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          Row(
            children: [
              if (isPremium)
                Icon(
                  LucideIcons.crown,
                  size: 16,
                  color: AppColors.warning,
                ),
              if (isVerified)
                Icon(
                  LucideIcons.checkCircle,
                  size: 16,
                  color: AppColors.info,
                ),
              if (isPremium || isVerified) const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}