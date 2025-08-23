import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../controllers/otp_controller.dart';
import 'otp_screen.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({Key? key}) : super(key: key);
  
  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _identifierController = TextEditingController();
  late OtpController _controller;
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _controller = Get.put(OtpController());
  }
  
  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.surfaceDark,
                  ]
                : [
                    AppColors.backgroundLight,
                    AppColors.primaryLight.withOpacity(0.05),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // AssetWorks Logo
                    SizedBox(
                      width: 180,
                      height: 100,
                      child: SvgPicture.asset(
                        'assets/assetworks_logo_full_black.svg',
                        colorFilter: ColorFilter.mode(
                          isDark ? Colors.white : AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Welcome Text
                    Text(
                      'Welcome to AssetWorks',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI-Powered Investment Intelligence',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.shield,
                            size: 24,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Secure login with One-Time Password',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Identifier Field
                    AppTextField(
                      label: 'Email or Phone Number',
                      hint: 'Enter your email or phone',
                      controller: _identifierController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(LucideIcons.user, size: 20),
                      onSubmitted: (_) => _handleSendOtp(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email or phone number';
                        }
                        // Simple validation - either email or phone
                        if (!value.contains('@') && value.length < 10) {
                          return 'Please enter a valid email or phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Send OTP Button
                    Obx(() => AppButton(
                      text: 'Send Verification Code',
                      icon: LucideIcons.mail,
                      onPressed: _handleSendOtp,
                      isLoading: _controller.isResending.value,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                    )),
                    const SizedBox(height: 32),
                    
                    // Guest Mode
                    TextButton(
                      onPressed: _handleGuestMode,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.userX,
                            size: 18,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Continue as Guest',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Features List
                    Column(
                      children: [
                        _buildFeatureItem(
                          icon: LucideIcons.sparkles,
                          title: 'AI-Powered Analysis',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem(
                          icon: LucideIcons.barChart3,
                          title: 'Real-time Market Data',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem(
                          icon: LucideIcons.shield,
                          title: 'Secure & Private',
                          isDark: isDark,
                        ),
                      ],
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
  
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
  
  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    final identifier = _identifierController.text.trim();
    
    // Send OTP
    await _controller.sendOtp(identifier);
    
    // Navigate to OTP verification screen
    Get.to(() => const OtpScreen(), arguments: {
      'identifier': identifier,
    });
  }
  
  void _handleGuestMode() {
    // Navigate to home in guest mode
    Get.offAllNamed('/home', arguments: {'guestMode': true});
  }
}