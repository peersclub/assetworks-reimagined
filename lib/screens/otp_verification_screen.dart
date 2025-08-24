import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/dynamic_island_service.dart';
import '../services/api_service.dart';
import '../services/biometric_service.dart';
import '../core/services/storage_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final BiometricService _biometricService = Get.find<BiometricService>();
  
  bool _isLoading = false;
  int _resendTimer = 30;
  String? _email;
  bool? _isSignup;
  
  @override
  void initState() {
    super.initState();
    
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    _email = args?['email'];
    _isSignup = args?['isSignup'] ?? false;
    
    _startResendTimer();
  }
  
  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  
  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        return true;
      }
      return false;
    });
  }
  
  String get _otpCode {
    return _otpControllers.map((c) => c.text).join();
  }
  
  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) {
      _showErrorDialog('Please enter the complete OTP');
      return;
    }
    
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    
    DynamicIslandService().updateStatus(
      'Verifying OTP...',
      icon: CupertinoIcons.lock_shield,
    );
    
    try {
      final response = await _apiService.verifyOTP(
        _email!,
        _otpCode,
      );
      
      setState(() => _isLoading = false);
      
      if (response['success'] == true) {
        HapticFeedback.heavyImpact();
        
        DynamicIslandService().updateStatus(
          'Verification Successful!',
          icon: CupertinoIcons.checkmark_circle_fill,
        );
        
        // Update biometric credentials if enabled
        if (response['data'] != null && response['data']['token'] != null) {
          await _biometricService.updateCredentials(
            response['data']['token'],
            _email ?? '',
          );
        }
        
        if (_isSignup == true) {
          // Navigate to profile setup
          Get.offNamed('/add-profile-details');
        } else {
          // Navigate to main screen
          Get.offAllNamed('/main');
        }
      } else {
        _showErrorDialog(response['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Verification failed. Please try again.');
    }
  }
  
  Future<void> _resendOTP() async {
    if (_resendTimer > 0) return;
    
    HapticFeedback.lightImpact();
    
    try {
      await _apiService.sendOTP(_email!);
      
      setState(() => _resendTimer = 30);
      _startResendTimer();
      
      _showSuccessDialog('OTP has been resent to your email');
    } catch (e) {
      _showErrorDialog('Failed to resend OTP');
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
  
  void _showSuccessDialog(String message) {
    HapticFeedback.mediumImpact();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Verify OTP'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemIndigo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.mail_solid,
                  size: 40,
                  color: CupertinoColors.systemIndigo,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Verification Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'We have sent a verification code to',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                _email ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemIndigo,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // OTP Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: CupertinoTextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _otpControllers[index].text.isNotEmpty
                              ? CupertinoColors.systemIndigo
                              : CupertinoColors.systemGrey4,
                          width: 1,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        
                        // Auto-verify when all digits are entered
                        if (_otpCode.length == 6) {
                          _verifyOTP();
                        }
                        
                        setState(() {});
                      },
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 32),
              
              // Resend code
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _resendTimer > 0 ? null : _resendOTP,
                child: Text(
                  _resendTimer > 0
                      ? 'Resend code in $_resendTimer seconds'
                      : 'Resend Code',
                  style: TextStyle(
                    color: _resendTimer > 0
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemIndigo,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CupertinoButton(
                  color: CupertinoColors.systemIndigo,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _isLoading ? null : _verifyOTP,
                  child: _isLoading
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}