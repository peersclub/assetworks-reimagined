import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../core/services/storage_service.dart';
import '../services/dynamic_island_service.dart';
import '../screens/main_screen.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> 
    with TickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Step 1: Asset Classes
  final List<Map<String, dynamic>> _assetClasses = [
    {'id': 'stocks', 'name': 'Stocks', 'icon': CupertinoIcons.graph_square_fill, 'selected': false},
    {'id': 'crypto', 'name': 'Cryptocurrency', 'icon': CupertinoIcons.bitcoin, 'selected': false},
    {'id': 'forex', 'name': 'Forex', 'icon': CupertinoIcons.money_dollar_circle_fill, 'selected': false},
    {'id': 'commodities', 'name': 'Commodities', 'icon': CupertinoIcons.cube_box_fill, 'selected': false},
    {'id': 'bonds', 'name': 'Bonds', 'icon': CupertinoIcons.doc_text_fill, 'selected': false},
    {'id': 'realestate', 'name': 'Real Estate', 'icon': CupertinoIcons.house_fill, 'selected': false},
    {'id': 'etfs', 'name': 'ETFs', 'icon': CupertinoIcons.layers_fill, 'selected': false},
    {'id': 'options', 'name': 'Options', 'icon': CupertinoIcons.option, 'selected': false},
  ];
  
  // Step 2: Investment Experience
  String _experienceLevel = '';
  final List<Map<String, dynamic>> _experienceLevels = [
    {
      'id': 'beginner',
      'title': 'Beginner',
      'description': 'New to investing',
      'icon': CupertinoIcons.star,
    },
    {
      'id': 'intermediate',
      'title': 'Intermediate',
      'description': '1-3 years experience',
      'icon': CupertinoIcons.star_lefthalf_fill,
    },
    {
      'id': 'advanced',
      'title': 'Advanced',
      'description': '3-5 years experience',
      'icon': CupertinoIcons.star_fill,
    },
    {
      'id': 'expert',
      'title': 'Expert',
      'description': '5+ years experience',
      'icon': CupertinoIcons.star_circle_fill,
    },
  ];
  
  // Step 3: Investment Goals
  final List<String> _selectedGoals = [];
  final List<Map<String, dynamic>> _investmentGoals = [
    {'id': 'wealth_building', 'name': 'Build Long-term Wealth', 'icon': CupertinoIcons.chart_bar_alt_fill},
    {'id': 'retirement', 'name': 'Retirement Planning', 'icon': CupertinoIcons.sunset_fill},
    {'id': 'passive_income', 'name': 'Generate Passive Income', 'icon': CupertinoIcons.money_dollar_circle},
    {'id': 'capital_preservation', 'name': 'Capital Preservation', 'icon': CupertinoIcons.shield_fill},
    {'id': 'aggressive_growth', 'name': 'Aggressive Growth', 'icon': CupertinoIcons.rocket_fill},
    {'id': 'education_fund', 'name': 'Education Fund', 'icon': CupertinoIcons.book_fill},
    {'id': 'short_term', 'name': 'Short-term Gains', 'icon': CupertinoIcons.timer_fill},
    {'id': 'diversification', 'name': 'Portfolio Diversification', 'icon': CupertinoIcons.square_grid_3x2_fill},
  ];
  
  // Step 4: Risk Tolerance
  double _riskTolerance = 50.0;
  
  // Step 5: Notification Preferences
  final Map<String, bool> _notifications = {
    'price_alerts': true,
    'portfolio_updates': true,
    'market_news': false,
    'educational_content': false,
    'community_updates': false,
  };
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 4) {
        setState(() => _currentStep++);
        _fadeController.forward(from: 0);
        _slideController.forward(from: 0);
        HapticFeedback.lightImpact();
      } else {
        _completeOnboarding();
      }
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _fadeController.forward(from: 0);
      _slideController.forward(from: 0);
      HapticFeedback.lightImpact();
    }
  }
  
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_assetClasses.where((c) => c['selected']).isEmpty) {
          _showError('Please select at least one asset class');
          return false;
        }
        break;
      case 1:
        if (_experienceLevel.isEmpty) {
          _showError('Please select your experience level');
          return false;
        }
        break;
      case 2:
        if (_selectedGoals.isEmpty) {
          _showError('Please select at least one investment goal');
          return false;
        }
        break;
    }
    return true;
  }
  
  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    
    try {
      // Prepare onboarding data
      final onboardingData = {
        'asset_classes': _assetClasses
            .where((c) => c['selected'])
            .map((c) => c['id'])
            .toList(),
        'experience_level': _experienceLevel,
        'investment_goals': _selectedGoals,
        'risk_tolerance': _riskTolerance.round(),
        'notifications': _notifications,
        'onboarding_completed': true,
        'onboarding_date': DateTime.now().toIso8601String(),
      };
      
      // Save to API
      final response = await _apiService.saveOnboardingData(onboardingData);
      
      if (response['success'] == true) {
        // Save locally
        await _storageService.saveOnboardingComplete(true);
        await _storageService.saveUserPreferences(onboardingData);
        
        DynamicIslandService().updateStatus(
          'Welcome to AssetWorks!',
          icon: CupertinoIcons.checkmark_circle_fill,
        );
        
        // Navigate to main app
        Get.offAll(() => const MainScreen());
      } else {
        _showError('Failed to save preferences. Please try again.');
      }
    } catch (e) {
      print('Onboarding error: $e');
      _showError('An error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _showError(String message) {
    HapticFeedback.heavyImpact();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Attention'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground.withOpacity(0.94),
        border: null,
        middle: const Text('Welcome to AssetWorks'),
        leading: _currentStep > 0
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.back),
                onPressed: _previousStep,
              )
            : null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            'Skip',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
          onPressed: () => _completeOnboarding(),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),
            
            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_currentStep == 0) _buildAssetClassesStep(),
                        if (_currentStep == 1) _buildExperienceStep(),
                        if (_currentStep == 2) _buildGoalsStep(),
                        if (_currentStep == 3) _buildRiskToleranceStep(),
                        if (_currentStep == 4) _buildNotificationsStep(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: CupertinoButton(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(25),
                onPressed: _isLoading ? null : _nextStep,
                child: _isLoading
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : Text(_currentStep < 4 ? 'Continue' : 'Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildAssetClassesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          CupertinoIcons.square_grid_2x2_fill,
          size: 60,
          color: CupertinoColors.activeBlue,
        ),
        const SizedBox(height: 20),
        Text(
          'Which asset classes interest you?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all that apply. You can change this later.',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 30),
        
        // Asset Class Grid
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _assetClasses.map((assetClass) {
            final isSelected = assetClass['selected'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  assetClass['selected'] = !assetClass['selected'];
                });
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey4,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      assetClass['icon'],
                      size: 20,
                      color: isSelected
                          ? CupertinoColors.white
                          : CupertinoColors.label,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      assetClass['name'],
                      style: TextStyle(
                        color: isSelected
                            ? CupertinoColors.white
                            : CupertinoColors.label,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildExperienceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          CupertinoIcons.chart_bar_fill,
          size: 60,
          color: CupertinoColors.activeBlue,
        ),
        const SizedBox(height: 20),
        Text(
          'What\'s your investment experience?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us personalize your experience.',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 30),
        
        // Experience Level Cards
        ...List.generate(_experienceLevels.length, (index) {
          final level = _experienceLevels[index];
          final isSelected = _experienceLevel == level['id'];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                setState(() => _experienceLevel = level['id']);
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CupertinoColors.activeBlue.withOpacity(0.1)
                      : CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      level['icon'],
                      size: 30,
                      color: isSelected
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: CupertinoColors.activeBlue,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildGoalsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          CupertinoIcons.flag_fill,
          size: 60,
          color: CupertinoColors.activeBlue,
        ),
        const SizedBox(height: 20),
        Text(
          'What are your investment goals?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all that apply to your investment strategy.',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 30),
        
        // Goals Grid
        ...List.generate(_investmentGoals.length, (index) {
          final goal = _investmentGoals[index];
          final isSelected = _selectedGoals.contains(goal['id']);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedGoals.remove(goal['id']);
                  } else {
                    _selectedGoals.add(goal['id']);
                  }
                });
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CupertinoColors.activeBlue.withOpacity(0.1)
                      : CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      goal['icon'],
                      size: 24,
                      color: isSelected
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        goal['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.label,
                        ),
                      ),
                    ),
                    Icon(
                      isSelected
                          ? CupertinoIcons.checkmark_square_fill
                          : CupertinoIcons.square,
                      color: isSelected
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGrey3,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildRiskToleranceStep() {
    String getRiskLabel() {
      if (_riskTolerance < 20) return 'Very Conservative';
      if (_riskTolerance < 40) return 'Conservative';
      if (_riskTolerance < 60) return 'Moderate';
      if (_riskTolerance < 80) return 'Aggressive';
      return 'Very Aggressive';
    }
    
    Color getRiskColor() {
      if (_riskTolerance < 20) return CupertinoColors.systemGreen;
      if (_riskTolerance < 40) return CupertinoColors.systemTeal;
      if (_riskTolerance < 60) return CupertinoColors.systemYellow;
      if (_riskTolerance < 80) return CupertinoColors.systemOrange;
      return CupertinoColors.systemRed;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          CupertinoIcons.speedometer,
          size: 60,
          color: CupertinoColors.activeBlue,
        ),
        const SizedBox(height: 20),
        Text(
          'Risk tolerance',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How much risk are you comfortable with?',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 40),
        
        // Risk Visualization
        Center(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getRiskColor().withOpacity(0.2),
              border: Border.all(
                color: getRiskColor(),
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_riskTolerance.round()}%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: getRiskColor(),
                  ),
                ),
                Text(
                  getRiskLabel(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: getRiskColor(),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Slider
        Column(
          children: [
            CupertinoSlider(
              value: _riskTolerance,
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: getRiskColor(),
              onChanged: (value) {
                setState(() => _riskTolerance = value);
                HapticFeedback.selectionClick();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Low Risk',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  Text(
                    'High Risk',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 30),
        
        // Risk Description
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: getRiskColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getRiskLabel(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: getRiskColor(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _riskTolerance < 20
                    ? 'You prefer stable, low-risk investments with predictable returns.'
                    : _riskTolerance < 40
                        ? 'You seek a balance between stability and modest growth.'
                        : _riskTolerance < 60
                            ? 'You\'re comfortable with moderate fluctuations for potential growth.'
                            : _riskTolerance < 80
                                ? 'You\'re willing to accept significant volatility for higher returns.'
                                : 'You seek maximum returns and can handle extreme volatility.',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildNotificationsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          CupertinoIcons.bell_fill,
          size: 60,
          color: CupertinoColors.activeBlue,
        ),
        const SizedBox(height: 20),
        Text(
          'Stay informed',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose what updates you\'d like to receive.',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 30),
        
        // Notification Options
        _buildNotificationOption(
          'Price Alerts',
          'Get notified about significant price movements',
          CupertinoIcons.graph_square_fill,
          'price_alerts',
        ),
        _buildNotificationOption(
          'Portfolio Updates',
          'Daily summary of your portfolio performance',
          CupertinoIcons.chart_pie_fill,
          'portfolio_updates',
        ),
        _buildNotificationOption(
          'Market News',
          'Breaking news and market analysis',
          CupertinoIcons.news_solid,
          'market_news',
        ),
        _buildNotificationOption(
          'Educational Content',
          'Tips and tutorials to improve your investing',
          CupertinoIcons.book_fill,
          'educational_content',
        ),
        _buildNotificationOption(
          'Community Updates',
          'Popular widgets and community highlights',
          CupertinoIcons.person_3_fill,
          'community_updates',
        ),
      ],
    );
  }
  
  Widget _buildNotificationOption(
    String title,
    String description,
    IconData icon,
    String key,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: CupertinoColors.activeBlue,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: _notifications[key] ?? false,
              onChanged: (value) {
                setState(() => _notifications[key] = value);
                HapticFeedback.selectionClick();
              },
            ),
          ],
        ),
      ),
    );
  }
}