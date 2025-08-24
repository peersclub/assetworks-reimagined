import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/theme/ios18_theme.dart';
import '../../../../core/services/dynamic_island_service.dart';

class iOSOnboardingScreen extends StatefulWidget {
  const iOSOnboardingScreen({super.key});

  @override
  State<iOSOnboardingScreen> createState() => _iOSOnboardingScreenState();
}

class _iOSOnboardingScreenState extends State<iOSOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to AssetWorks',
      subtitle: 'Track your portfolio with iOS 18 widgets',
      description: 'Get real-time updates right from your home screen with our advanced widget system.',
      icon: CupertinoIcons.graph_square_fill,
      gradient: [
        iOS18Theme.systemBlue,
        iOS18Theme.systemIndigo,
      ],
      features: [
        'Live stock prices',
        'Portfolio tracking',
        'Custom alerts',
      ],
    ),
    OnboardingPage(
      title: 'Dynamic Island',
      subtitle: 'Always stay connected',
      description: 'Monitor your investments with Live Activities in the Dynamic Island.',
      icon: CupertinoIcons.phone,
      gradient: [
        iOS18Theme.systemPurple,
        iOS18Theme.systemPink,
      ],
      features: [
        'Live price updates',
        'Activity tracking',
        'Quick actions',
      ],
    ),
    OnboardingPage(
      title: 'Home Screen Widgets',
      subtitle: 'Information at a glance',
      description: 'Add beautiful widgets to your home screen for instant access to your portfolio.',
      icon: CupertinoIcons.square_grid_2x2_fill,
      gradient: [
        iOS18Theme.systemTeal,
        iOS18Theme.systemGreen,
      ],
      features: [
        'Multiple sizes',
        'Interactive widgets',
        'Dark mode support',
      ],
    ),
    OnboardingPage(
      title: 'Smart Notifications',
      subtitle: 'Never miss an opportunity',
      description: 'Get intelligent alerts based on your preferences and market conditions.',
      icon: CupertinoIcons.bell_fill,
      gradient: [
        iOS18Theme.systemOrange,
        iOS18Theme.systemRed,
      ],
      features: [
        'Price alerts',
        'News updates',
        'Custom triggers',
      ],
    ),
    OnboardingPage(
      title: 'Ready to Start?',
      subtitle: 'Your portfolio awaits',
      description: 'Sign up now and take control of your investments with AssetWorks.',
      icon: CupertinoIcons.rocket_fill,
      gradient: [
        iOS18Theme.systemIndigo,
        iOS18Theme.systemBlue,
      ],
      features: [
        'Free to start',
        'Premium features',
        'No credit card required',
      ],
      isLast: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.mediumImpact();
    _completeOnboarding();
  }

  void _completeOnboarding() {
    HapticFeedback.heavyImpact();
    DynamicIslandService.showSuccess('Welcome to AssetWorks!');
    Navigator.of(context).pushReplacementNamed('/ios-register');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          // Page content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                if (_currentPage < _pages.length - 1)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _skipOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: CupertinoColors.white.withOpacity(0.8),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      _animationController.reset();
                      _animationController.forward();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),
                
                // Bottom section
                _buildBottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _pages[_currentPage].gradient,
            ),
          ),
          child: Stack(
            children: [
              // Floating shapes
              Positioned(
                top: 100 + _floatingAnimation.value,
                left: -50,
                child: _buildFloatingShape(150, 0.3),
              ),
              Positioned(
                top: 300 - _floatingAnimation.value,
                right: -80,
                child: _buildFloatingShape(200, 0.2),
              ),
              Positioned(
                bottom: 200 + _floatingAnimation.value,
                left: 50,
                child: _buildFloatingShape(100, 0.25),
              ),
              Positioned(
                bottom: 100 - _floatingAnimation.value,
                right: 30,
                child: _buildFloatingShape(120, 0.15),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingShape(double size, double opacity) {
    return Transform.rotate(
      angle: _floatingAnimation.value * 0.01,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CupertinoColors.white.withOpacity(opacity),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with animation
                  AnimatedBuilder(
                    animation: _floatingController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatingAnimation.value * 0.5),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: CupertinoColors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 60,
                            color: CupertinoColors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Title
                  Text(
                    page.title,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    page.subtitle,
                    style: TextStyle(
                      color: CupertinoColors.white.withOpacity(0.9),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    page.description,
                    style: TextStyle(
                      color: CupertinoColors.white.withOpacity(0.8),
                      fontSize: 17,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Features
                  ...page.features.map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          color: CupertinoColors.white.withOpacity(0.9),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          feature,
                          style: TextStyle(
                            color: CupertinoColors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => _buildPageIndicator(index),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Action buttons
          if (_pages[_currentPage].isLast) ...[
            _buildGetStartedButton(),
            const SizedBox(height: 12),
            _buildSignInButton(),
          ] else
            _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? CupertinoColors.white
            : CupertinoColors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: CupertinoButton(
        color: CupertinoColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(28),
        onPressed: _nextPage,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              CupertinoIcons.arrow_right,
              color: CupertinoColors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: CupertinoButton(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(28),
        onPressed: _completeOnboarding,
        child: Text(
          'Get Started',
          style: TextStyle(
            color: _pages[_currentPage].gradient.first,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: CupertinoButton(
        color: CupertinoColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(28),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pushReplacementNamed('/ios-login');
        },
        child: const Text(
          'I already have an account',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final List<String> features;
  final bool isLast;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.features,
    this.isLast = false,
  });
}