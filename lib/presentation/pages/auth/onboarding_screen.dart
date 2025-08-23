import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<Map<String, dynamic>> _pages = [
    {
      'icon': LucideIcons.barChart3,
      'title': 'AI-Powered Analytics',
      'description': 'Get intelligent insights and predictions for your investments using advanced AI algorithms',
      'color': const Color(0xFF4CAF50),
    },
    {
      'icon': LucideIcons.sparkles,
      'title': 'Create Custom Widgets',
      'description': 'Build personalized dashboards and widgets tailored to your specific investment needs',
      'color': const Color(0xFF2196F3),
    },
    {
      'icon': LucideIcons.shield,
      'title': 'Secure & Reliable',
      'description': 'Your data is protected with enterprise-grade security and encryption',
      'color': const Color(0xFF9C27B0),
    },
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'],
                            size: 60,
                            color: page['color'],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title'],
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                      ? AppColors.primary 
                      : (isDark ? AppColors.neutral700 : AppColors.neutral300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: _currentPage == _pages.length - 1
                  ? Column(
                      children: [
                        AppButton(
                          text: 'Get Started',
                          onPressed: _getStarted,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'I already have an account',
                          type: AppButtonType.outline,
                          onPressed: () => Get.offNamed('/login'),
                          isFullWidth: true,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: AppButton(
                              text: 'Back',
                              type: AppButtonType.outline,
                              onPressed: _previousPage,
                            ),
                          ),
                        if (_currentPage > 0) const SizedBox(width: 12),
                        Expanded(
                          flex: _currentPage == 0 ? 1 : 2,
                          child: AppButton(
                            text: 'Next',
                            onPressed: _nextPage,
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
  
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _skip() {
    Get.offNamed('/login');
  }
  
  void _getStarted() {
    Get.offNamed('/register');
  }
}