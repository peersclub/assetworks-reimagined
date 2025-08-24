import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/dynamic_island_service.dart';
import '../services/api_service.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({Key? key}) : super(key: key);

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> 
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final ApiService _apiService = Get.find<ApiService>();
  
  bool _isLoading = false;
  bool _acceptedTerms = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _sendOTP() async {
    if (_emailController.text.isEmpty) {
      _showErrorDialog('Please enter your email');
      return;
    }
    
    if (!_acceptedTerms) {
      _showErrorDialog('Please accept the terms and conditions');
      return;
    }
    
    if (!GetUtils.isEmail(_emailController.text.trim())) {
      _showErrorDialog('Please enter a valid email');
      return;
    }
    
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    
    DynamicIslandService().updateStatus(
      'Sending OTP...',
      icon: CupertinoIcons.mail,
    );
    
    try {
      // Call API to send OTP
      final response = await _apiService.sendOTP(_emailController.text.trim());
      
      setState(() => _isLoading = false);
      
      if (response['success'] == true) {
        HapticFeedback.mediumImpact();
        DynamicIslandService().updateStatus(
          'OTP Sent!',
          icon: CupertinoIcons.checkmark_circle_fill,
        );
        
        // Navigate to OTP verification screen
        Get.toNamed('/otp-verify', arguments: {
          'email': _emailController.text.trim(),
          'isSignup': false,
        });
      } else {
        _showErrorDialog(response['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('An error occurred. Please try again.');
    }
  }
  
  void _showErrorDialog(String message) {
    HapticFeedback.heavyImpact();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
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
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.0),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.systemIndigo,
                          CupertinoColors.systemPurple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      CupertinoIcons.cube_box_fill,
                      size: 40,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Title
                const Text(
                  'Welcome to AssetWorks',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  'Create amazing widgets with AI-powered generation',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Email field
                const Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _emailController,
                  placeholder: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Icon(
                      CupertinoIcons.mail,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  onSubmitted: (_) => _sendOTP(),
                ),
                
                const SizedBox(height: 24),
                
                // Terms checkbox
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() => _acceptedTerms = !_acceptedTerms);
                    HapticFeedback.lightImpact();
                  },
                  child: Row(
                    children: [
                      Icon(
                        _acceptedTerms 
                            ? CupertinoIcons.checkmark_square_fill
                            : CupertinoIcons.square,
                        color: _acceptedTerms 
                            ? CupertinoColors.systemIndigo
                            : CupertinoColors.systemGrey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: CupertinoTheme.of(context).textTheme.textStyle.color,
                              fontSize: 14,
                            ),
                            children: const [
                              TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: CupertinoColors.systemIndigo,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: CupertinoColors.systemIndigo,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    color: CupertinoColors.systemIndigo,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _isLoading ? null : _sendOTP,
                    child: _isLoading
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Or divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: CupertinoColors.systemGrey4,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: CupertinoColors.systemGrey4,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Guest mode button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Continue as guest
                      Get.offAllNamed('/main');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.person,
                          color: CupertinoTheme.of(context).textTheme.textStyle.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Continue as Guest',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: CupertinoTheme.of(context).textTheme.textStyle.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}