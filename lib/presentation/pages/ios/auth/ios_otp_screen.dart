import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../../core/theme/ios_theme.dart';
import '../../../controllers/auth_controller.dart';

class iOSOTPScreen extends StatefulWidget {
  const iOSOTPScreen({Key? key}) : super(key: key);

  @override
  State<iOSOTPScreen> createState() => _iOSOTPScreenState();
}

class _iOSOTPScreenState extends State<iOSOTPScreen> 
    with TickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  
  // OTP Controllers
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  // State
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;
  
  // Animations
  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _shakeAnimation;
  
  String get _phoneNumber => Get.arguments?['phone'] ?? '+1 234 567 8900';
  String get _email => Get.arguments?['email'] ?? 'user@example.com';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startResendTimer();
    
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNodes[0].requestFocus();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: iOS18Theme.springCurve,
    ));
    
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0),
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _animationController.forward();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _canResend = false;
    
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        // Last field filled, verify OTP
        _verifyOTP();
      }
    }
  }

  void _onOtpKeyDown(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_otpControllers[index].text.isEmpty && index > 0) {
          // Move to previous field
          _otpFocusNodes[index - 1].requestFocus();
        }
      }
    }
  }

  String get _otpCode {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) {
      _showError('Please enter all 6 digits');
      return;
    }

    iOS18Theme.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final success = await _authController.verifyOTP(_otpCode);
      
      if (success) {
        iOS18Theme.successImpact();
        _showSuccessAnimation();
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed('/main');
      } else {
        _shakeError();
        _showError('Invalid code. Please try again.');
      }
    } catch (e) {
      _shakeError();
      _showError('Verification failed. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _shakeError() {
    iOS18Theme.notificationError();
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  void _showError(String message) {
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

  void _showSuccessAnimation() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: iOS18Theme.systemGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.check_mark,
            color: CupertinoColors.white,
            size: 60,
          ),
        ),
      ),
    );
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    iOS18Theme.lightImpact();
    
    try {
      await _authController.resendOTP();
      _startResendTimer();
      
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Code Sent'),
          content: Text('A new verification code has been sent to $_email'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError('Failed to resend code. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.systemBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.systemBackground.resolveFrom(context).withOpacity(0.94),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.arrow_left,
            color: iOS18Theme.label.resolveFrom(context),
          ),
        ),
        middle: const Text('Verification'),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing24),
            child: Column(
              children: [
                const SizedBox(height: iOS18Theme.spacing32),
                
                // Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: iOS18Theme.systemBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.shield_lefthalf_fill,
                      size: 50,
                      color: iOS18Theme.systemBlue,
                    ),
                  ),
                ),
                
                const SizedBox(height: iOS18Theme.spacing32),
                
                // Title
                Text(
                  'Enter Verification Code',
                  style: iOS18Theme.title1.copyWith(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: iOS18Theme.spacing12),
                
                // Description
                Text(
                  'We sent a 6-digit code to',
                  style: iOS18Theme.body.copyWith(
                    color: iOS18Theme.secondaryLabel.resolveFrom(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: iOS18Theme.spacing4),
                
                Text(
                  _email,
                  style: iOS18Theme.body.copyWith(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: iOS18Theme.spacing32),
                
                // OTP Input Fields
                SlideTransition(
                  position: _shakeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        height: 60,
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (event) => _onOtpKeyDown(event, index),
                          child: CupertinoTextField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: iOS18Theme.title2.copyWith(
                              color: iOS18Theme.label.resolveFrom(context),
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: BoxDecoration(
                              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
                              borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
                              border: Border.all(
                                color: _otpFocusNodes[index].hasFocus
                                    ? iOS18Theme.systemBlue
                                    : iOS18Theme.separator.resolveFrom(context),
                                width: _otpFocusNodes[index].hasFocus ? 2 : 1,
                              ),
                            ),
                            onChanged: (value) => _onOtpChanged(value, index),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                const SizedBox(height: iOS18Theme.spacing32),
                
                // Resend code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: iOS18Theme.footnote.copyWith(
                        color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _canResend ? _resendOTP : null,
                      child: Text(
                        _canResend
                            ? 'Resend'
                            : 'Resend in ${_resendCountdown}s',
                        style: iOS18Theme.footnote.copyWith(
                          color: _canResend
                              ? iOS18Theme.systemBlue
                              : iOS18Theme.tertiaryLabel.resolveFrom(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: iOS18Theme.spacing32),
                
                // Verify button
                CupertinoButton.filled(
                  onPressed: _isLoading ? null : _verifyOTP,
                  child: _isLoading
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        )
                      : const Text('Verify'),
                ),
                
                const SizedBox(height: iOS18Theme.spacing16),
                
                // Alternative verification
                CupertinoButton(
                  onPressed: () {
                    iOS18Theme.lightImpact();
                    _showAlternativeVerification();
                  },
                  child: Text(
                    'Try another verification method',
                    style: iOS18Theme.footnote.copyWith(
                      color: iOS18Theme.systemBlue,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Security note
                Container(
                  padding: const EdgeInsets.all(iOS18Theme.spacing12),
                  decoration: BoxDecoration(
                    color: iOS18Theme.systemGray6.resolveFrom(context),
                    borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.lock_shield,
                        size: 20,
                        color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      ),
                      const SizedBox(width: iOS18Theme.spacing8),
                      Expanded(
                        child: Text(
                          'Your security is our priority. This code expires in 10 minutes.',
                          style: iOS18Theme.caption1.copyWith(
                            color: iOS18Theme.secondaryLabel.resolveFrom(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: iOS18Theme.spacing32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAlternativeVerification() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Alternative Verification'),
        message: const Text('Choose another way to verify your account'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Handle SMS
              iOS18Theme.lightImpact();
            },
            child: const Text('Send SMS to phone'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Handle phone call
              iOS18Theme.lightImpact();
            },
            child: const Text('Call me with code'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Handle email
              iOS18Theme.lightImpact();
            },
            child: const Text('Send to backup email'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}