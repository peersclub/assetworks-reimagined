import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/dashboard_widget.dart';
import '../widgets/widget_card_final.dart';
import '../widgets/widget_card_shimmer.dart';
import '../core/utils/responsive_utils.dart';

class ExploreScreenEnhanced extends StatefulWidget {
  const ExploreScreenEnhanced({Key? key}) : super(key: key);

  @override
  State<ExploreScreenEnhanced> createState() => _ExploreScreenEnhancedState();
}

class _ExploreScreenEnhancedState extends State<ExploreScreenEnhanced> 
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Navigation Bar
          CupertinoSliverNavigationBar(
            largeTitle: Text('Explore'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.search),
                  onPressed: () => Get.toNamed('/enhanced-search'),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.bell_circle),
                  onPressed: () => Get.toNamed('/notifications'),
                ),
              ],
            ),
          ),
          
          // Quick Actions Grid
          SliverToBoxAdapter(
            child: _buildQuickActions(),
          ),
          
          // Widget Creation Section
          SliverToBoxAdapter(
            child: _buildSection(
              'Create & Customize',
              'Build your perfect widgets',
              [
                _FeatureCard(
                  title: 'AI Widget Creator',
                  subtitle: 'Create widgets with AI assistance',
                  icon: CupertinoIcons.wand_stars,
                  gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  route: '/ai-widget-creator',
                ),
                _FeatureCard(
                  title: 'Investment Widgets',
                  subtitle: 'Financial tracking tools',
                  icon: CupertinoIcons.graph_circle_fill,
                  gradient: [Color(0xFF10B981), Color(0xFF059669)],
                  route: '/investment-widget-creator',
                ),
                _FeatureCard(
                  title: 'Widget Remix',
                  subtitle: 'Customize existing widgets',
                  icon: CupertinoIcons.shuffle,
                  gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  route: '/widget-remix',
                ),
                _FeatureCard(
                  title: 'Template Gallery',
                  subtitle: 'Browse ready-made templates',
                  icon: CupertinoIcons.rectangle_grid_3x2_fill,
                  gradient: [Color(0xFFEC4899), Color(0xFFDB2777)],
                  route: '/template-gallery',
                ),
              ],
            ),
          ),
          
          // Discovery Section
          SliverToBoxAdapter(
            child: _buildSection(
              'Discover & Browse',
              'Find inspiration from the community',
              [
                _FeatureCard(
                  title: 'Trending Widgets',
                  subtitle: 'See what\'s popular now',
                  icon: CupertinoIcons.flame_fill,
                  gradient: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  route: '/trending',
                ),
                _FeatureCard(
                  title: 'Discovery Feed',
                  subtitle: 'Explore community creations',
                  icon: CupertinoIcons.compass_fill,
                  gradient: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  route: '/discovery',
                ),
              ],
            ),
          ),
          
          // Analytics & AI Section
          SliverToBoxAdapter(
            child: _buildSection(
              'Analytics & AI',
              'Advanced tools and insights',
              [
                _FeatureCard(
                  title: 'AI Assistant',
                  subtitle: 'Chat with your AI companion',
                  icon: CupertinoIcons.chat_bubble_2_fill,
                  gradient: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  route: '/ai-assistant',
                ),
                _FeatureCard(
                  title: 'Pro Analytics',
                  subtitle: 'Advanced data visualization',
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  gradient: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                  route: '/pro-analytics',
                ),
                _FeatureCard(
                  title: 'Dashboard V2',
                  subtitle: 'Enhanced dashboard experience',
                  icon: CupertinoIcons.rectangle_stack_fill,
                  gradient: [Color(0xFFA855F7), Color(0xFF9333EA)],
                  route: '/dashboard-v2',
                ),
              ],
            ),
          ),
          
          // Profile & History Section
          SliverToBoxAdapter(
            child: _buildSection(
              'Your Activity',
              'Track your progress and history',
              [
                _FeatureCard(
                  title: 'User Profile',
                  subtitle: 'Extended profile settings',
                  icon: CupertinoIcons.person_circle_fill,
                  gradient: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  route: '/user-profile',
                ),
                _FeatureCard(
                  title: 'Activity History',
                  subtitle: 'View your past actions',
                  icon: CupertinoIcons.clock_fill,
                  gradient: [Color(0xFF64748B), Color(0xFF475569)],
                  route: '/history',
                ),
                _FeatureCard(
                  title: 'Prompt History',
                  subtitle: 'Review your AI prompts',
                  icon: CupertinoIcons.text_bubble_fill,
                  gradient: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  route: '/prompt-history',
                ),
              ],
            ),
          ),
          
          // iOS 18 Features Section
          SliverToBoxAdapter(
            child: _buildSection(
              'iOS 18 Features',
              'Exclusive system integrations',
              [
                _FeatureCard(
                  title: 'Dynamic Island',
                  subtitle: 'Live activities & notifications',
                  icon: CupertinoIcons.rectangle_compress_vertical,
                  gradient: [Color(0xFF000000), Color(0xFF374151)],
                  route: '/settings',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showFeatureInfo('Dynamic Island', 
                      'Dynamic Island integration is active. Configure in Settings.');
                  },
                ),
                _FeatureCard(
                  title: 'Apple Watch',
                  subtitle: 'Companion app features',
                  icon: CupertinoIcons.device_phone_portrait,
                  gradient: [Color(0xFF059669), Color(0xFF047857)],
                  route: '/settings',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showFeatureInfo('Apple Watch', 
                      'Apple Watch sync is enabled. Widgets will appear on your watch.');
                  },
                ),
                _FeatureCard(
                  title: 'Siri Shortcuts',
                  subtitle: 'Voice command integration',
                  icon: CupertinoIcons.mic_fill,
                  gradient: [Color(0xFF9333EA), Color(0xFF7E22CE)],
                  route: '/settings',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showFeatureInfo('Siri Shortcuts', 
                      'Say "Hey Siri, show my widgets" to access your dashboard.');
                  },
                ),
              ],
            ),
          ),
          
          // All Features Button
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20),
              child: CupertinoButton(
                color: CupertinoColors.systemIndigo,
                borderRadius: BorderRadius.circular(16),
                padding: EdgeInsets.symmetric(vertical: 16),
                onPressed: () => Get.toNamed('/all-features'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.square_grid_3x2_fill),
                    SizedBox(width: 8),
                    Text(
                      'View All Features',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Padding
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final quickActions = [
      {'icon': CupertinoIcons.add_circled_solid, 'label': 'Create', 'route': '/create-widget'},
      {'icon': CupertinoIcons.search, 'label': 'Search', 'route': '/enhanced-search'},
      {'icon': CupertinoIcons.flame_fill, 'label': 'Trending', 'route': '/trending'},
      {'icon': CupertinoIcons.person_fill, 'label': 'Profile', 'route': '/profile'},
    ];
    
    final padding = ResponsiveUtils.getAdaptivePadding(context);

    return Container(
      padding: EdgeInsets.all(padding),
      margin: ResponsiveUtils.getAdaptiveMargins(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: quickActions.map((action) {
          return Expanded(
            child: _QuickActionButton(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              onTap: () => Get.toNamed(action['route'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<_FeatureCard> cards) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final padding = ResponsiveUtils.getAdaptivePadding(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
      margin: ResponsiveUtils.getAdaptiveMargins(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 22),
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getAdaptiveFontSize(context, 14),
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          if (isTablet)
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: ResponsiveUtils.getGridColumns(context,
                phoneColumns: 1,
                tabletPortraitColumns: 2,
                tabletLandscapeColumns: 3,
              ),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: ResponsiveUtils.isLandscape(context) ? 4.0 : 3.5,
              children: cards.map((card) => _buildFeatureCard(card)).toList(),
            )
          else
            ...cards.map((card) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _buildFeatureCard(card),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureCard card) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: card.onTap ?? () => Get.toNamed(card.route),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: card.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: card.gradient.first.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                card.icon,
                color: CupertinoColors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    card.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureInfo(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('Got it'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: CupertinoColors.activeBlue,
                size: 28,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String route;
  final VoidCallback? onTap;

  _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.route,
    this.onTap,
  });
}