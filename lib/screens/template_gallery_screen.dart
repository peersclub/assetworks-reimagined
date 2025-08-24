import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../screens/widget_creation_screen.dart';

class TemplateGalleryScreen extends StatefulWidget {
  const TemplateGalleryScreen({Key? key}) : super(key: key);

  @override
  State<TemplateGalleryScreen> createState() => _TemplateGalleryScreenState();
}

class _TemplateGalleryScreenState extends State<TemplateGalleryScreen> {
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Investment',
    'Finance',
    'Analytics',
    'Portfolio',
    'Crypto',
    'Stocks',
    'Real Estate',
  ];
  
  final List<TemplateItem> _templates = [
    // Investment Templates
    TemplateItem(
      category: 'Investment',
      title: 'Portfolio Tracker Pro',
      description: 'Complete portfolio management with real-time tracking',
      icon: CupertinoIcons.chart_pie_fill,
      color: CupertinoColors.systemIndigo,
      features: ['Real-time prices', 'P&L tracking', 'Asset allocation', 'Performance charts'],
      popularity: 4.8,
      uses: 12500,
    ),
    TemplateItem(
      category: 'Investment',
      title: 'Stock Watchlist',
      description: 'Monitor your favorite stocks with price alerts',
      icon: CupertinoIcons.graph_square_fill,
      color: CupertinoColors.systemGreen,
      features: ['Price alerts', 'Technical indicators', 'News feed', 'Volume analysis'],
      popularity: 4.6,
      uses: 8900,
    ),
    TemplateItem(
      category: 'Crypto',
      title: 'Crypto Dashboard',
      description: 'Track cryptocurrency portfolios and market trends',
      icon: CupertinoIcons.bitcoin,
      color: CupertinoColors.systemOrange,
      features: ['Live prices', '24h changes', 'Market cap', 'Trading volume'],
      popularity: 4.9,
      uses: 15600,
    ),
    TemplateItem(
      category: 'Real Estate',
      title: 'Property Manager',
      description: 'Manage real estate investments and rental income',
      icon: CupertinoIcons.building_2_fill,
      color: CupertinoColors.systemBrown,
      features: ['Property values', 'Rental income', 'ROI calculator', 'Expense tracking'],
      popularity: 4.5,
      uses: 6700,
    ),
    TemplateItem(
      category: 'Finance',
      title: 'Budget Planner',
      description: 'Personal finance and budget management',
      icon: CupertinoIcons.money_dollar_circle_fill,
      color: CupertinoColors.systemTeal,
      features: ['Expense tracking', 'Savings goals', 'Bill reminders', 'Reports'],
      popularity: 4.7,
      uses: 19200,
    ),
    TemplateItem(
      category: 'Analytics',
      title: 'Market Analytics',
      description: 'Advanced market analysis and insights',
      icon: CupertinoIcons.chart_bar_alt_fill,
      color: CupertinoColors.systemPurple,
      features: ['Market trends', 'Sector analysis', 'Heat maps', 'Predictions'],
      popularity: 4.4,
      uses: 7800,
    ),
    TemplateItem(
      category: 'Portfolio',
      title: 'Retirement Planner',
      description: 'Plan and track retirement savings',
      icon: CupertinoIcons.briefcase_fill,
      color: CupertinoColors.systemBlue,
      features: ['401k tracking', 'IRA management', 'Projections', 'Tax planning'],
      popularity: 4.6,
      uses: 5400,
    ),
    TemplateItem(
      category: 'Stocks',
      title: 'Options Tracker',
      description: 'Options trading and strategy management',
      icon: CupertinoIcons.arrow_up_arrow_down_circle_fill,
      color: CupertinoColors.systemRed,
      features: ['Options chains', 'Greeks', 'Strategy builder', 'P&L analysis'],
      popularity: 4.3,
      uses: 3200,
    ),
  ];
  
  List<TemplateItem> get filteredTemplates {
    if (_selectedCategory == 'All') {
      return _templates;
    }
    return _templates.where((t) => t.category == _selectedCategory).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Template Gallery'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.add),
          onPressed: () {
            Get.to(() => const WidgetCreationScreen(),
              transition: Transition.cupertino,
            );
          },
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Professional Templates',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start with expertly crafted templates for your investment needs',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Category Filter
            SliverToBoxAdapter(
              child: Container(
                height: 44,
                margin: EdgeInsets.only(bottom: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    
                    return Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        color: isSelected
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(20),
                        onPressed: () {
                          setState(() => _selectedCategory = category);
                        },
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? CupertinoColors.white
                                : CupertinoColors.label,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Templates Grid
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final template = filteredTemplates[index];
                    return _TemplateCard(
                      template: template,
                      onTap: () => _useTemplate(template),
                    );
                  },
                  childCount: filteredTemplates.length,
                ),
              ),
            ),
            
            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
  
  void _useTemplate(TemplateItem template) {
    HapticFeedback.lightImpact();
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(template.title),
        message: Text('What would you like to do with this template?'),
        actions: [
          CupertinoActionSheetAction(
            child: Text('Use Template'),
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => const WidgetCreationScreen(),
                arguments: {'template': template.title},
                transition: Transition.cupertino,
              );
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Preview'),
            onPressed: () {
              Navigator.pop(context);
              // Show preview
            },
          ),
          CupertinoActionSheetAction(
            child: Text('View Details'),
            onPressed: () {
              Navigator.pop(context);
              _showTemplateDetails(template);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
  
  void _showTemplateDetails(TemplateItem template) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(template.title),
        content: Column(
          children: [
            const SizedBox(height: 12),
            Text(template.description),
            const SizedBox(height: 16),
            ...template.features.map((feature) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    size: 16,
                    color: CupertinoColors.activeGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature, style: TextStyle(fontSize: 14))),
                ],
              ),
            )),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Use Template'),
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => const WidgetCreationScreen(),
                arguments: {'template': template.title},
                transition: Transition.cupertino,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final TemplateItem template;
  final VoidCallback onTap;
  
  const _TemplateCard({
    required this.template,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    template.color.withOpacity(0.8),
                    template.color.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
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
                      template.icon,
                      size: 32,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: CupertinoColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            template.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Features
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: template.features.take(3).map((feature) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.label,
                        ),
                      ),
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            size: 16,
                            color: CupertinoColors.systemYellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            template.popularity.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      
                      // Uses
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.person_2_fill,
                            size: 16,
                            color: CupertinoColors.systemBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatCount(template.uses)} uses',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Use button
                      CupertinoButton(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: template.color,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: onTap,
                        child: Text(
                          'Use',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

class TemplateItem {
  final String category;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;
  final double popularity;
  final int uses;
  
  TemplateItem({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
    required this.popularity,
    required this.uses,
  });
}