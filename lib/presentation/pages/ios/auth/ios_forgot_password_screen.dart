import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/ios18_theme.dart';
import '../../../../core/services/dynamic_island_service.dart';

class iOSForgotPasswordScreen extends StatefulWidget {
  const iOSForgotPasswordScreen({super.key});

  @override
  State<iOSForgotPasswordScreen> createState() => _iOSForgotPasswordScreenState();
}

class _iOSForgotPasswordScreenState extends State<iOSForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      HapticFeedback.heavyImpact();
      return;
    }
    
    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      HapticFeedback.heavyImpact();
      return;
    }
    
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    DynamicIslandService.showProgress('Sending reset link...');
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
    
    DynamicIslandService.showSuccess('Reset link sent!');
    HapticFeedback.notificationFeedback(HapticFeedbackType.success);
    
    // Reset animation for success state
    _animationController.reset();
    _animationController.forward();
  }
  
  void _resendLink() {
    HapticFeedback.lightImpact();
    setState(() {
      _emailSent = false;
      _emailController.clear();
    });
    _animationController.reset();
    _animationController.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context).withOpacity(0.0),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(
            CupertinoIcons.back,
            color: iOS18Theme.label.resolveFrom(context),
          ),
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: _emailSent ? _buildSuccessView() : _buildFormView(),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildFormView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Spacer(flex: 1),
          
          // Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iOS18Theme.systemBlue.withOpacity(0.2),
                    iOS18Theme.systemIndigo.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.lock_circle,
                size: 60,
                color: iOS18Theme.systemBlue,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Title
          Text(
            'Forgot Password?',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 17,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          // Email field
          Container(
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _errorMessage != null
                    ? iOS18Theme.systemRed.withOpacity(0.5)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: CupertinoTextField(
                  controller: _emailController,
                  placeholder: 'Email address',
                  placeholderStyle: TextStyle(
                    color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                  ),
                  style: TextStyle(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontSize: 17,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context).withOpacity(0.5),
                  ),
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(
                      CupertinoIcons.mail,
                      color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      size: 20,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendResetLink(),
                  enabled: !_isLoading,
                ),
              ),
            ),
          ),
          
          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: iOS18Theme.systemRed,
                  fontSize: 14,
                ),
              ),
            ),
          
          const SizedBox(height: 32),
          
          // Send button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CupertinoButton(
              color: iOS18Theme.systemBlue,
              borderRadius: BorderRadius.circular(28),
              onPressed: _isLoading ? null : _sendResetLink,
              child: _isLoading
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                  : const Text(
                      'Send Reset Link',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Back to login
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.arrow_left,
                  color: iOS18Theme.systemBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Login',
                  style: TextStyle(
                    color: iOS18Theme.systemBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(flex: 2),
        ],
      ),
    );
  }
  
  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Spacer(flex: 1),
          
          // Success icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iOS18Theme.systemGreen.withOpacity(0.2),
                    iOS18Theme.systemTeal.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.checkmark_circle_fill,
                size: 60,
                color: iOS18Theme.systemGreen,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Title
          Text(
            'Check Your Email',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Email address
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: iOS18Theme.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _emailController.text,
              style: TextStyle(
                color: iOS18Theme.systemBlue,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions.',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 17,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          // Open email app button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CupertinoButton(
              color: iOS18Theme.systemBlue,
              borderRadius: BorderRadius.circular(28),
              onPressed: () {
                HapticFeedback.mediumImpact();
                // Open email app
                Navigator.of(context).pushReplacementNamed('/ios-login');
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.mail,
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Open Email App',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Didn't receive email
          Column(
            children: [
              Text(
                'Didn\'t receive the email?',
                style: TextStyle(
                  color: iOS18Theme.secondaryLabel.resolveFrom(context),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _resendLink,
                child: Text(
                  'Resend Link',
                  style: TextStyle(
                    color: iOS18Theme.systemBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}