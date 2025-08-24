import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/ios18_theme.dart';
import '../../../../core/services/dynamic_island_service.dart';

class iOSHelpSupportScreen extends StatefulWidget {
  const iOSHelpSupportScreen({super.key});

  @override
  State<iOSHelpSupportScreen> createState() => _iOSHelpSupportScreenState();
}

class _iOSHelpSupportScreenState extends State<iOSHelpSupportScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  String _selectedCategory = 'all';
  final Set<String> _expandedFAQs = {};
  bool _isSearching = false;
  
  final List<HelpCategory> _categories = [
    HelpCategory(
      id: 'getting-started',
      title: 'Getting Started',
      icon: CupertinoIcons.rocket_fill,
      color: iOS18Theme.systemBlue,
      articles: 12,
    ),
    HelpCategory(
      id: 'widgets',
      title: 'Widgets & Home Screen',
      icon: CupertinoIcons.square_grid_2x2_fill,
      color: iOS18Theme.systemPurple,
      articles: 8,
    ),
    HelpCategory(
      id: 'portfolio',
      title: 'Portfolio Management',
      icon: CupertinoIcons.chart_pie_fill,
      color: iOS18Theme.systemGreen,
      articles: 15,
    ),
    HelpCategory(
      id: 'notifications',
      title: 'Alerts & Notifications',
      icon: CupertinoIcons.bell_fill,
      color: iOS18Theme.systemOrange,
      articles: 6,
    ),
    HelpCategory(
      id: 'account',
      title: 'Account & Security',
      icon: CupertinoIcons.person_crop_circle_fill,
      color: iOS18Theme.systemRed,
      articles: 10,
    ),
    HelpCategory(
      id: 'troubleshooting',
      title: 'Troubleshooting',
      icon: CupertinoIcons.wrench_fill,
      color: iOS18Theme.systemIndigo,
      articles: 20,
    ),
  ];
  
  final List<FAQ> _faqs = [
    FAQ(
      question: 'How do I add a widget to my home screen?',
      answer: 'To add a widget, long press on your home screen, tap the + button in the top corner, search for AssetWorks, and select the widget size you prefer. Then tap "Add Widget" and position it on your screen.',
      category: 'widgets',
    ),
    FAQ(
      question: 'How often does the data update?',
      answer: 'Market data updates in real-time during trading hours. Widgets refresh every 5 minutes by default, but you can adjust this in Settings > Widget Preferences.',
      category: 'portfolio',
    ),
    FAQ(
      question: 'Is my financial data secure?',
      answer: 'Yes! We use bank-level 256-bit encryption for all data. Your credentials are never stored on our servers, and all connections use secure HTTPS protocols.',
      category: 'account',
    ),
    FAQ(
      question: 'How do I set up price alerts?',
      answer: 'Go to any asset detail page and tap the bell icon. Set your target price and choose your notification preferences. You can manage all alerts in Settings > Notifications.',
      category: 'notifications',
    ),
    FAQ(
      question: 'Can I use the app offline?',
      answer: 'Yes, the app works offline with cached data. Your portfolios and recent data are available offline, but real-time updates require an internet connection.',
      category: 'getting-started',
    ),
    FAQ(
      question: 'Why is my widget not updating?',
      answer: 'Check your Background App Refresh settings in iOS Settings > General > Background App Refresh. Make sure it\'s enabled for AssetWorks.',
      category: 'troubleshooting',
    ),
  ];
  
  final List<ContactOption> _contactOptions = [
    ContactOption(
      title: 'Live Chat',
      subtitle: 'Chat with our support team',
      icon: CupertinoIcons.chat_bubble_2_fill,
      color: iOS18Theme.systemGreen,
      available: true,
      waitTime: '< 2 min',
    ),
    ContactOption(
      title: 'Email Support',
      subtitle: 'support@assetworks.com',
      icon: CupertinoIcons.mail_fill,
      color: iOS18Theme.systemBlue,
      available: true,
      waitTime: '< 24 hours',
    ),
    ContactOption(
      title: 'Phone Support',
      subtitle: '1-800-ASSETS',
      icon: CupertinoIcons.phone_fill,
      color: iOS18Theme.systemOrange,
      available: true,
      waitTime: '< 5 min',
    ),
    ContactOption(
      title: 'Community Forum',
      subtitle: 'Get help from other users',
      icon: CupertinoIcons.person_3_fill,
      color: iOS18Theme.systemPurple,
      available: true,
      waitTime: null,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleFAQ(String question) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_expandedFAQs.contains(question)) {
        _expandedFAQs.remove(question);
      } else {
        _expandedFAQs.add(question);
      }
    });
  }
  
  void _startChat() {
    HapticFeedback.mediumImpact();
    DynamicIslandService.showSuccess('Starting chat...');
    // Navigate to chat screen
  }
  
  void _callSupport() {
    HapticFeedback.heavyImpact();
    DynamicIslandService.showAlert('Calling support...');
    // Initiate phone call
  }
  
  void _sendEmail() {
    HapticFeedback.lightImpact();
    // Open email client
  }
  
  List<FAQ> get _filteredFAQs {
    if (_selectedCategory == 'all') {
      return _faqs;
    }
    return _faqs.where((faq) => faq.category == _selectedCategory).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context).withOpacity(0.8),
        border: null,
        middle: const Text('Help & Support'),
        previousPageTitle: 'Settings',
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),
            
            // Quick actions
            SliverToBoxAdapter(
              child: _buildQuickActions(),
            ),
            
            // Help categories
            SliverToBoxAdapter(
              child: _buildCategories(),
            ),
            
            // Popular FAQs
            SliverToBoxAdapter(
              child: _buildFAQSection(),
            ),
            
            // Contact options
            SliverToBoxAdapter(
              child: _buildContactOptions(),
            ),
            
            // Additional resources
            SliverToBoxAdapter(
              child: _buildResources(),
            ),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoTextField(
        controller: _searchController,
        placeholder: 'Search for help...',
        placeholderStyle: TextStyle(
          color: iOS18Theme.tertiaryLabel.resolveFrom(context),
        ),
        style: TextStyle(
          color: iOS18Theme.label.resolveFrom(context),
        ),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Icon(
            CupertinoIcons.search,
            color: iOS18Theme.secondaryLabel.resolveFrom(context),
          ),
        ),
        suffix: _searchController.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    CupertinoIcons.clear_circled_solid,
                    color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                    size: 18,
                  ),
                ),
              )
            : null,
        padding: const EdgeInsets.all(12),
        decoration: null,
        onChanged: (value) {
          setState(() {
            _isSearching = value.isNotEmpty;
          });
        },
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickActionCard(
            'Video Tutorials',
            CupertinoIcons.play_rectangle_fill,
            iOS18Theme.systemRed,
            () => DynamicIslandService.showAlert('Opening tutorials...'),
          ),
          _buildQuickActionCard(
            'User Guide',
            CupertinoIcons.book_fill,
            iOS18Theme.systemBlue,
            () => DynamicIslandService.showAlert('Opening guide...'),
          ),
          _buildQuickActionCard(
            'What\'s New',
            CupertinoIcons.sparkles,
            iOS18Theme.systemPurple,
            () => Navigator.of(context).pushNamed('/ios-release-notes'),
          ),
          _buildQuickActionCard(
            'Tips & Tricks',
            CupertinoIcons.lightbulb_fill,
            iOS18Theme.systemYellow,
            () => DynamicIslandService.showAlert('Loading tips...'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(_slideAnimation.value, 0),
              child: Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.8),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: CupertinoColors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 24, bottom: 12),
          child: Text(
            'Browse by Category',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategoryCard(HelpCategory category) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionFeedback();
        setState(() {
          _selectedCategory = category.id;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          border: _selectedCategory == category.id
              ? Border.all(color: category.color, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.title,
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              '${category.articles} articles',
              style: TextStyle(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 24, bottom: 12),
          child: Text(
            'Frequently Asked Questions',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _filteredFAQs.map((faq) => _buildFAQItem(faq)).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFAQItem(FAQ faq) {
    final isExpanded = _expandedFAQs.contains(faq.question);
    
    return Column(
      children: [
        GestureDetector(
          onTap: () => _toggleFAQ(faq.question),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    faq.question,
                    style: TextStyle(
                      color: iOS18Theme.label.resolveFrom(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isExpanded ? 0.25 : 0,
                  child: Icon(
                    CupertinoIcons.chevron_right,
                    color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              faq.answer,
              style: TextStyle(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (faq != _filteredFAQs.last)
          Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: iOS18Theme.separator.resolveFrom(context),
          ),
      ],
    );
  }
  
  Widget _buildContactOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 24, bottom: 12),
          child: Text(
            'Contact Support',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...(_contactOptions.map((option) => _buildContactCard(option))),
      ],
    );
  }
  
  Widget _buildContactCard(ContactOption option) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (option.title == 'Live Chat') {
                  _startChat();
                } else if (option.title == 'Phone Support') {
                  _callSupport();
                } else if (option.title == 'Email Support') {
                  _sendEmail();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: option.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        option.icon,
                        color: option.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: TextStyle(
                              color: iOS18Theme.label.resolveFrom(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option.subtitle,
                            style: TextStyle(
                              color: iOS18Theme.secondaryLabel.resolveFrom(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (option.waitTime != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: iOS18Theme.systemGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          option.waitTime!,
                          style: TextStyle(
                            color: iOS18Theme.systemGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildResources() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 24, bottom: 12),
          child: Text(
            'Additional Resources',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildResourceItem(
                'Developer API',
                'api.assetworks.com',
                CupertinoIcons.chevron_left_slash_chevron_right,
              ),
              const SizedBox(height: 12),
              _buildResourceItem(
                'Status Page',
                'status.assetworks.com',
                CupertinoIcons.checkmark_shield_fill,
              ),
              const SizedBox(height: 12),
              _buildResourceItem(
                'Blog & News',
                'blog.assetworks.com',
                CupertinoIcons.news_solid,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildResourceItem(String title, String url, IconData icon) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        DynamicIslandService.showAlert('Opening $url...');
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: iOS18Theme.systemBlue,
            size: 20,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  url,
                  style: TextStyle(
                    color: iOS18Theme.systemBlue,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.arrow_up_right,
            color: iOS18Theme.tertiaryLabel.resolveFrom(context),
            size: 16,
          ),
        ],
      ),
    );
  }
}

class HelpCategory {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final int articles;
  
  HelpCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.articles,
  });
}

class FAQ {
  final String question;
  final String answer;
  final String category;
  
  FAQ({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class ContactOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool available;
  final String? waitTime;
  
  ContactOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.available,
    this.waitTime,
  });
}