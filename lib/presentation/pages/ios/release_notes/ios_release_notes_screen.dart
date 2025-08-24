import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/ios18_theme.dart';

class iOSReleaseNotesScreen extends StatefulWidget {
  const iOSReleaseNotesScreen({super.key});

  @override
  State<iOSReleaseNotesScreen> createState() => _iOSReleaseNotesScreenState();
}

class _iOSReleaseNotesScreenState extends State<iOSReleaseNotesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _expandController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  final Set<String> _expandedVersions = {};
  String _selectedFilter = 'all';
  
  final List<ReleaseNote> _releaseNotes = [
    ReleaseNote(
      version: '3.0.0',
      date: DateTime(2024, 12, 15),
      title: 'iOS 18 Redesign',
      isLatest: true,
      isMajor: true,
      features: [
        ReleaseFeature(
          title: 'Complete iOS 18 UI Overhaul',
          description: 'Brand new interface following iOS 18 design guidelines',
          icon: CupertinoIcons.paintbrush_fill,
          type: FeatureType.newFeature,
        ),
        ReleaseFeature(
          title: 'Dynamic Island Support',
          description: 'Live Activities and real-time updates in Dynamic Island',
          icon: CupertinoIcons.phone,
          type: FeatureType.newFeature,
        ),
        ReleaseFeature(
          title: 'Interactive Widgets',
          description: 'Home screen widgets with multiple sizes and interactions',
          icon: CupertinoIcons.square_grid_2x2_fill,
          type: FeatureType.newFeature,
        ),
      ],
      improvements: [
        'Enhanced performance with 60fps animations',
        'Reduced app size by 40%',
        'Improved battery efficiency',
      ],
      bugFixes: [
        'Fixed crash on portfolio refresh',
        'Resolved sync issues with cloud backup',
        'Fixed notification delivery delays',
      ],
    ),
    ReleaseNote(
      version: '2.5.2',
      date: DateTime(2024, 11, 28),
      title: 'Performance Update',
      features: [],
      improvements: [
        'Optimized chart rendering performance',
        'Faster app launch time',
        'Improved memory management',
      ],
      bugFixes: [
        'Fixed widget refresh issues',
        'Resolved Face ID authentication bug',
        'Fixed dark mode color inconsistencies',
      ],
    ),
    ReleaseNote(
      version: '2.5.0',
      date: DateTime(2024, 11, 10),
      title: 'Analytics Dashboard',
      isMajor: true,
      features: [
        ReleaseFeature(
          title: 'Advanced Analytics',
          description: 'Deep insights into portfolio performance',
          icon: CupertinoIcons.chart_bar_alt_fill,
          type: FeatureType.newFeature,
        ),
        ReleaseFeature(
          title: 'Custom Reports',
          description: 'Generate personalized investment reports',
          icon: CupertinoIcons.doc_chart_fill,
          type: FeatureType.newFeature,
        ),
      ],
      improvements: [
        'Enhanced data visualization',
        'New chart types and indicators',
      ],
      bugFixes: [],
    ),
    ReleaseNote(
      version: '2.4.1',
      date: DateTime(2024, 10, 25),
      title: 'Bug Fixes',
      features: [],
      improvements: [],
      bugFixes: [
        'Fixed login issues for some users',
        'Resolved data sync problems',
        'Fixed notification sound settings',
        'Corrected timezone display issues',
      ],
    ),
    ReleaseNote(
      version: '2.4.0',
      date: DateTime(2024, 10, 5),
      title: 'Social Features',
      features: [
        ReleaseFeature(
          title: 'Community Feed',
          description: 'Share and discover investment strategies',
          icon: CupertinoIcons.person_2_fill,
          type: FeatureType.newFeature,
        ),
      ],
      improvements: [
        'New social sharing options',
        'Follow other investors',
      ],
      bugFixes: [],
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _expandController.dispose();
    super.dispose();
  }
  
  void _toggleExpanded(String version) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_expandedVersions.contains(version)) {
        _expandedVersions.remove(version);
      } else {
        _expandedVersions.add(version);
      }
    });
  }
  
  List<ReleaseNote> get _filteredNotes {
    switch (_selectedFilter) {
      case 'major':
        return _releaseNotes.where((note) => note.isMajor).toList();
      case 'features':
        return _releaseNotes.where((note) => note.features.isNotEmpty).toList();
      case 'fixes':
        return _releaseNotes.where((note) => note.bugFixes.isNotEmpty).toList();
      default:
        return _releaseNotes;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context).withOpacity(0.8),
        border: null,
        middle: const Text('Release Notes'),
        previousPageTitle: 'Settings',
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with latest version
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            
            // Filter chips
            SliverToBoxAdapter(
              child: _buildFilterChips(),
            ),
            
            // Release notes list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final note = _filteredNotes[index];
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value * (index + 1) * 0.5),
                          child: _buildReleaseCard(note),
                        ),
                      );
                    },
                  );
                },
                childCount: _filteredNotes.length,
              ),
            ),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    final latestRelease = _releaseNotes.firstWhere((note) => note.isLatest, orElse: () => _releaseNotes.first);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iOS18Theme.systemBlue,
            iOS18Theme.systemIndigo,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: iOS18Theme.systemBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LATEST',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.sparkles,
                color: CupertinoColors.white.withOpacity(0.9),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Version ${latestRelease.version}',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            latestRelease.title,
            style: TextStyle(
              color: CupertinoColors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(latestRelease.date),
            style: TextStyle(
              color: CupertinoColors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChips() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Major', 'major'),
          const SizedBox(width: 8),
          _buildFilterChip('Features', 'features'),
          const SizedBox(width: 8),
          _buildFilterChip('Bug Fixes', 'fixes'),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionFeedback();
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? iOS18Theme.systemBlue
              : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? iOS18Theme.systemBlue
                : iOS18Theme.separator.resolveFrom(context),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? CupertinoColors.white
                  : iOS18Theme.label.resolveFrom(context),
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildReleaseCard(ReleaseNote note) {
    final isExpanded = _expandedVersions.contains(note.version);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
        border: note.isMajor
            ? Border.all(
                color: iOS18Theme.systemBlue.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Header
              GestureDetector(
                onTap: () => _toggleExpanded(note.version),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Version badge
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: note.isMajor
                              ? LinearGradient(
                                  colors: [
                                    iOS18Theme.systemBlue,
                                    iOS18Theme.systemIndigo,
                                  ],
                                )
                              : null,
                          color: note.isMajor
                              ? null
                              : iOS18Theme.tertiarySystemGroupedBackground.resolveFrom(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            note.version.split('.')[0],
                            style: TextStyle(
                              color: note.isMajor
                                  ? CupertinoColors.white
                                  : iOS18Theme.label.resolveFrom(context),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title and date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'v${note.version}',
                                  style: TextStyle(
                                    color: iOS18Theme.label.resolveFrom(context),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (note.isMajor) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: iOS18Theme.systemBlue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'MAJOR',
                                      style: TextStyle(
                                        color: iOS18Theme.systemBlue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note.title,
                              style: TextStyle(
                                color: iOS18Theme.secondaryLabel.resolveFrom(context),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(note.date),
                              style: TextStyle(
                                color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Chevron
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: isExpanded ? 0.25 : 0,
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Expanded content
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildExpandedContent(note),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildExpandedContent(ReleaseNote note) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Features
          if (note.features.isNotEmpty) ...[
            _buildSectionTitle('New Features', CupertinoIcons.star_fill, iOS18Theme.systemYellow),
            const SizedBox(height: 8),
            ...note.features.map((feature) => _buildFeatureItem(feature)),
            const SizedBox(height: 16),
          ],
          
          // Improvements
          if (note.improvements.isNotEmpty) ...[
            _buildSectionTitle('Improvements', CupertinoIcons.arrow_up_circle_fill, iOS18Theme.systemGreen),
            const SizedBox(height: 8),
            ...note.improvements.map((improvement) => _buildTextItem(improvement)),
            const SizedBox(height: 16),
          ],
          
          // Bug fixes
          if (note.bugFixes.isNotEmpty) ...[
            _buildSectionTitle('Bug Fixes', CupertinoIcons.wrench_fill, iOS18Theme.systemOrange),
            const SizedBox(height: 8),
            ...note.bugFixes.map((fix) => _buildTextItem(fix)),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: iOS18Theme.label.resolveFrom(context),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeatureItem(ReleaseFeature feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iOS18Theme.tertiarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getFeatureColor(feature.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature.icon,
              color: _getFeatureColor(feature.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (feature.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    feature.description,
                    style: TextStyle(
                      color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getFeatureColor(FeatureType type) {
    switch (type) {
      case FeatureType.newFeature:
        return iOS18Theme.systemBlue;
      case FeatureType.improvement:
        return iOS18Theme.systemGreen;
      case FeatureType.experimental:
        return iOS18Theme.systemPurple;
    }
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class ReleaseNote {
  final String version;
  final DateTime date;
  final String title;
  final bool isLatest;
  final bool isMajor;
  final List<ReleaseFeature> features;
  final List<String> improvements;
  final List<String> bugFixes;
  
  ReleaseNote({
    required this.version,
    required this.date,
    required this.title,
    this.isLatest = false,
    this.isMajor = false,
    required this.features,
    required this.improvements,
    required this.bugFixes,
  });
}

class ReleaseFeature {
  final String title;
  final String description;
  final IconData icon;
  final FeatureType type;
  
  ReleaseFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
  });
}

enum FeatureType {
  newFeature,
  improvement,
  experimental,
}