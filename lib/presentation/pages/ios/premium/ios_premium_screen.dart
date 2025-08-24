import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/ios18_theme.dart';
import '../../../../core/services/dynamic_island_service.dart';

class iOSPremiumScreen extends StatefulWidget {
  const iOSPremiumScreen({super.key});

  @override
  State<iOSPremiumScreen> createState() => _iOSPremiumScreenState();
}

class _iOSPremiumScreenState extends State<iOSPremiumScreen>
    with TickerProviderStateMixin {
  int _selectedPlanIndex = 1; // Default to yearly (best value)
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  bool _isProcessing = false;

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      id: 'monthly',
      name: 'Monthly',
      price: 9.99,
      period: 'month',
      features: [
        'Unlimited widgets',
        'Real-time data',
        'Basic alerts',
        'Standard support',
      ],
      savings: null,
      isBestValue: false,
    ),
    SubscriptionPlan(
      id: 'yearly',
      name: 'Yearly',
      price: 79.99,
      originalPrice: 119.88,
      period: 'year',
      features: [
        'Everything in Monthly',
        'Advanced analytics',
        'Custom alerts',
        'Priority support',
        'Export data',
      ],
      savings: '33% OFF',
      isBestValue: true,
    ),
    SubscriptionPlan(
      id: 'lifetime',
      name: 'Lifetime',
      price: 199.99,
      period: 'once',
      features: [
        'Everything in Yearly',
        'Early access features',
        'Premium templates',
        'VIP support',
        'All future updates',
      ],
      savings: 'BEST DEAL',
      isBestValue: false,
    ),
  ];

  final List<PremiumFeature> _features = [
    PremiumFeature(
      icon: CupertinoIcons.graph_square_fill,
      title: 'Advanced Analytics',
      description: 'Deep insights into your portfolio performance',
      color: iOS18Theme.systemBlue,
    ),
    PremiumFeature(
      icon: CupertinoIcons.bell_fill,
      title: 'Smart Alerts',
      description: 'AI-powered notifications for market opportunities',
      color: iOS18Theme.systemOrange,
    ),
    PremiumFeature(
      icon: CupertinoIcons.square_grid_2x2_fill,
      title: 'Unlimited Widgets',
      description: 'Create as many home screen widgets as you need',
      color: iOS18Theme.systemPurple,
    ),
    PremiumFeature(
      icon: CupertinoIcons.shield_fill,
      title: 'Priority Support',
      description: '24/7 dedicated support from our expert team',
      color: iOS18Theme.systemGreen,
    ),
    PremiumFeature(
      icon: CupertinoIcons.cloud_fill,
      title: 'Cloud Sync',
      description: 'Sync your data across all your devices',
      color: iOS18Theme.systemIndigo,
    ),
    PremiumFeature(
      icon: CupertinoIcons.lock_shield_fill,
      title: 'Enhanced Security',
      description: 'Bank-level encryption for your financial data',
      color: iOS18Theme.systemRed,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
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
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectPlan(int index) {
    HapticFeedback.selectionFeedback();
    setState(() {
      _selectedPlanIndex = index;
    });
  }

  Future<void> _subscribe() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isProcessing = true;
    });

    // Simulate subscription process
    await Future.delayed(const Duration(seconds: 2));
    
    DynamicIslandService.showSuccess('Welcome to Premium!');
    
    setState(() {
      _isProcessing = false;
    });
    
    Navigator.of(context).pop(true);
  }

  void _restorePurchases() {
    HapticFeedback.lightImpact();
    DynamicIslandService.showProgress('Restoring purchases...');
    // Implement restore purchases logic
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context).withOpacity(0.8),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(
            CupertinoIcons.xmark,
            color: iOS18Theme.label.resolveFrom(context),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _restorePurchases,
          child: Text(
            'Restore',
            style: TextStyle(
              color: iOS18Theme.systemBlue,
              fontSize: 17,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            
            // Features
            SliverToBoxAdapter(
              child: _buildFeatures(),
            ),
            
            // Plans
            SliverToBoxAdapter(
              child: _buildPlans(),
            ),
            
            // Subscribe button
            SliverToBoxAdapter(
              child: _buildSubscribeButton(),
            ),
            
            // Terms
            SliverToBoxAdapter(
              child: _buildTerms(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Premium badge with animation
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        iOS18Theme.systemYellow,
                        iOS18Theme.systemOrange,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iOS18Theme.systemOrange.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.star_fill,
                    color: CupertinoColors.white,
                    size: 50,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Unlock Premium',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'Get unlimited access to all features',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Container(
      height: 280,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _features.length,
        itemBuilder: (context, index) {
          final feature = _features[index];
          return _buildFeatureCard(feature);
        },
      ),
    );
  }

  Widget _buildFeatureCard(PremiumFeature feature) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: feature.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    feature.icon,
                    color: feature.color,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  feature.title,
                  style: TextStyle(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  feature.description,
                  style: TextStyle(
                    color: iOS18Theme.secondaryLabel.resolveFrom(context),
                    fontSize: 14,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlans() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Choose Your Plan',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_plans.length, (index) {
            return _buildPlanCard(_plans[index], index);
          }),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, int index) {
    final isSelected = _selectedPlanIndex == index;
    
    return GestureDetector(
      onTap: () => _selectPlan(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? iOS18Theme.systemBlue.withOpacity(0.1)
              : iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? iOS18Theme.systemBlue
                : iOS18Theme.separator.resolveFrom(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            if (plan.isBestValue)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iOS18Theme.systemOrange,
                        iOS18Theme.systemRed,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Selection indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? iOS18Theme.systemBlue
                            : iOS18Theme.tertiaryLabel.resolveFrom(context),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: iOS18Theme.systemBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Plan details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.name,
                              style: TextStyle(
                                color: iOS18Theme.label.resolveFrom(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (plan.savings != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: iOS18Theme.systemGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  plan.savings!,
                                  style: TextStyle(
                                    color: iOS18Theme.systemGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$${plan.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: iOS18Theme.label.resolveFrom(context),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              plan.period == 'once' ? ' one time' : '/${plan.period}',
                              style: TextStyle(
                                color: iOS18Theme.secondaryLabel.resolveFrom(context),
                                fontSize: 16,
                              ),
                            ),
                            if (plan.originalPrice != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '\$${plan.originalPrice!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    final selectedPlan = _plans[_selectedPlanIndex];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerAnimation.value, -0.3),
                end: Alignment(1.0 + _shimmerAnimation.value, 0.3),
                colors: [
                  iOS18Theme.systemBlue,
                  iOS18Theme.systemBlue.withOpacity(0.8),
                  iOS18Theme.systemBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(28),
              onPressed: _isProcessing ? null : _subscribe,
              child: _isProcessing
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                  : Text(
                      'Subscribe to ${selectedPlan.name}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTerms() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Cancel anytime in Settings',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Navigate to terms
                },
                child: Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: iOS18Theme.systemBlue,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                ' • ',
                style: TextStyle(
                  color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Navigate to privacy
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: iOS18Theme.systemBlue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String period;
  final List<String> features;
  final String? savings;
  final bool isBestValue;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.period,
    required this.features,
    this.savings,
    required this.isBestValue,
  });
}

class PremiumFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}