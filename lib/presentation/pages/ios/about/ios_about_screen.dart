import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/ios18_theme.dart';
import '../../../../core/services/dynamic_island_service.dart';

class iOSAboutScreen extends StatefulWidget {
  const iOSAboutScreen({super.key});

  @override
  State<iOSAboutScreen> createState() => _iOSAboutScreenState();
}

class _iOSAboutScreenState extends State<iOSAboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _logoRotation;
  late Animation<double> _pulseAnimation;
  
  final String _appVersion = '3.0.0';
  final String _buildNumber = '2024.12.15';
  final String _copyright = '© 2024 AssetWorks, Inc.';
  
  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _logoRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _openWebsite() {
    HapticFeedback.lightImpact();
    DynamicIslandService.showAlert('Opening website...');
  }
  
  void _rateApp() {
    HapticFeedback.mediumImpact();
    DynamicIslandService.showSuccess('Opening App Store...');
  }
  
  void _shareApp() {
    HapticFeedback.lightImpact();
    // Show share sheet
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context).withOpacity(0.8),
        border: null,
        middle: const Text('About'),
        previousPageTitle: 'Settings',
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Logo and app info
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            
            // Mission statement
            SliverToBoxAdapter(
              child: _buildMission(),
            ),
            
            // Team section
            SliverToBoxAdapter(
              child: _buildTeam(),
            ),
            
            // Statistics
            SliverToBoxAdapter(
              child: _buildStatistics(),
            ),
            
            // Technologies
            SliverToBoxAdapter(
              child: _buildTechnologies(),
            ),
            
            // Actions
            SliverToBoxAdapter(
              child: _buildActions(),
            ),
            
            // Legal links
            SliverToBoxAdapter(
              child: _buildLegalLinks(),
            ),
            
            // Credits
            SliverToBoxAdapter(
              child: _buildCredits(),
            ),
            
            // Footer
            SliverToBoxAdapter(
              child: _buildFooter(),
            ),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Animated logo
          AnimatedBuilder(
            animation: Listenable.merge([_logoController, _pulseController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        iOS18Theme.systemBlue,
                        iOS18Theme.systemIndigo,
                      ],
                      transform: GradientRotation(_logoRotation.value),
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: iOS18Theme.systemBlue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'AW',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'AssetWorks',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Version $_appVersion',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 16,
            ),
          ),
          
          Text(
            'Build $_buildNumber',
            style: TextStyle(
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMission() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iOS18Theme.systemIndigo.withOpacity(0.1),
            iOS18Theme.systemBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iOS18Theme.systemBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.quote_bubble_fill,
            color: iOS18Theme.systemBlue,
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            'Our Mission',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'To democratize financial investing by providing powerful, intuitive tools that help everyone make informed investment decisions and build wealth for their future.',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTeam() {
    final team = [
      TeamMember('Sarah Chen', 'CEO & Founder', iOS18Theme.systemBlue),
      TeamMember('Michael Roberts', 'CTO', iOS18Theme.systemIndigo),
      TeamMember('Emma Wilson', 'Head of Design', iOS18Theme.systemPurple),
      TeamMember('David Kim', 'Lead Engineer', iOS18Theme.systemOrange),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
          child: Text(
            'The Team',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: team.length,
            itemBuilder: (context, index) {
              final member = team[index];
              return _buildTeamCard(member);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildTeamCard(TeamMember member) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: member.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.name.split(' ').map((n) => n[0]).join(),
                style: TextStyle(
                  color: member.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            member.name,
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            member.role,
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatistics() {
    return Container(
      margin: const EdgeInsets.only(top: 32, left: 24, right: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'By the Numbers',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('1M+', 'Users', iOS18Theme.systemBlue),
              _buildStat('50K+', 'Widgets', iOS18Theme.systemGreen),
              _buildStat('4.8', 'Rating', iOS18Theme.systemYellow),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('150+', 'Countries', iOS18Theme.systemPurple),
              _buildStat('99.9%', 'Uptime', iOS18Theme.systemOrange),
              _buildStat('24/7', 'Support', iOS18Theme.systemRed),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: iOS18Theme.secondaryLabel.resolveFrom(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTechnologies() {
    final technologies = [
      Technology('Flutter', 'Cross-platform framework'),
      Technology('iOS 18', 'Latest Apple technologies'),
      Technology('Swift', 'Native iOS integration'),
      Technology('WidgetKit', 'Home screen widgets'),
      Technology('CloudKit', 'Data synchronization'),
      Technology('Core ML', 'Machine learning'),
    ];
    
    return Container(
      margin: const EdgeInsets.only(top: 24, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Built With',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...technologies.map((tech) => _buildTechItem(tech)),
        ],
      ),
    );
  }
  
  Widget _buildTechItem(Technology tech) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: iOS18Theme.systemBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tech.name,
                  style: TextStyle(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  tech.description,
                  style: TextStyle(
                    color: iOS18Theme.secondaryLabel.resolveFrom(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions() {
    return Container(
      margin: const EdgeInsets.only(top: 32, left: 24, right: 24),
      child: Column(
        children: [
          _buildActionButton(
            'Rate AssetWorks',
            'Help us improve with your feedback',
            CupertinoIcons.star_fill,
            iOS18Theme.systemYellow,
            _rateApp,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Share with Friends',
            'Spread the word about AssetWorks',
            CupertinoIcons.share,
            iOS18Theme.systemBlue,
            _shareApp,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Visit Our Website',
            'www.assetworks.com',
            CupertinoIcons.globe,
            iOS18Theme.systemIndigo,
            _openWebsite,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: iOS18Theme.label.resolveFrom(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegalLinks() {
    return Container(
      margin: const EdgeInsets.only(top: 32, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegalLink('Privacy', () {
            Navigator.of(context).pushNamed('/ios-privacy-policy');
          }),
          _buildLegalLink('Terms', () {
            Navigator.of(context).pushNamed('/ios-terms-service');
          }),
          _buildLegalLink('Licenses', () {
            HapticFeedback.lightImpact();
            // Show licenses
          }),
        ],
      ),
    );
  }
  
  Widget _buildLegalLink(String title, VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: iOS18Theme.systemBlue,
          fontSize: 15,
        ),
      ),
    );
  }
  
  Widget _buildCredits() {
    return Container(
      margin: const EdgeInsets.only(top: 32, left: 24, right: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Special Thanks',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'To our amazing community of users, beta testers, and contributors who help make AssetWorks better every day.',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.heart_fill,
                color: iOS18Theme.systemRed,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Made with love in San Francisco',
                style: TextStyle(
                  color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            _copyright,
            style: TextStyle(
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All rights reserved',
            style: TextStyle(
              color: iOS18Theme.quaternaryLabel.resolveFrom(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class TeamMember {
  final String name;
  final String role;
  final Color color;
  
  TeamMember(this.name, this.role, this.color);
}

class Technology {
  final String name;
  final String description;
  
  Technology(this.name, this.description);
}