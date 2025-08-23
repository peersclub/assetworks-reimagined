import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/otp_controller.dart';

class LoginWithBiometricScreen extends StatefulWidget {
  const LoginWithBiometricScreen({Key? key}) : super(key: key);
  
  @override
  State<LoginWithBiometricScreen> createState() => _LoginWithBiometricScreenState();
}

class _LoginWithBiometricScreenState extends State<LoginWithBiometricScreen> with WidgetsBindingObserver {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();
  final OtpController _otpController = Get.put(OtpController());
  
  bool _isPasswordLogin = false;
  bool _rememberMe = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricLogin();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isPasswordLogin) {
      _checkBiometricLogin();
    }
  }
  
  Future<void> _checkBiometricLogin() async {
    // Check if biometric is enabled and available
    if (_authController.isBiometricEnabled.value) {
      await Future.delayed(const Duration(milliseconds: 500));
      _handleBiometricLogin();
    }
  }
  
  Future<void> _handleBiometricLogin() async {
    final success = await _authController.authenticateWithBiometric();
    if (success) {
      Get.offAllNamed('/main');
    }
  }
  
  Future<void> _handleEmailPasswordLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    await _authController.loginWithCredentials(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (_authController.isAuthenticated.value) {
      // Ask to enable biometric if not enabled and remember me is checked
      if (_rememberMe && 
          !_authController.isBiometricEnabled.value && 
          _authController.biometricType.value.isNotEmpty) {
        _showEnableBiometricDialog();
      } else {
        Get.offAllNamed('/main');
      }
    }
  }
  
  Future<void> _handleOtpLogin() async {
    Get.toNamed('/otp-login');
  }
  
  Future<void> _handleSocialLogin(String provider) async {
    if (provider == 'google') {
      // Google sign in - use OTP controller's method
      Get.snackbar(
        'Google Sign In',
        'Redirecting to Google...',
        snackPosition: SnackPosition.BOTTOM,
      );
      // await _otpController.handleGoogleSignIn();
    } else if (provider == 'apple') {
      // Apple sign in
      Get.snackbar(
        'Coming Soon',
        'Apple Sign In will be available soon',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  void _showEnableBiometricDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Enable ${_authController.biometricType.value}?'),
        content: Text(
          'Would you like to use ${_authController.biometricType.value} to sign in faster next time?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/main');
            },
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _authController.enableBiometric(
                _emailController.text.trim(),
                _passwordController.text,
              );
              Get.offAllNamed('/main');
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
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
              child: Obx(() {
                // Show biometric login UI if enabled and not using password
                if (_authController.isBiometricEnabled.value && !_isPasswordLogin) {
                  return _buildBiometricLoginUI(context, isDark);
                }
                
                // Show password login form
                return _buildPasswordLoginForm(context, isDark);
              }),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBiometricLoginUI(BuildContext context, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // AssetWorks Logo
        SizedBox(
          width: 150,
          height: 80,
          child: SvgPicture.asset(
            'assets/assetworks_logo_black.svg',
            colorFilter: ColorFilter.mode(
              isDark ? Colors.white : AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(height: 48),
        
        // Biometric Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            _authController.biometricType.value == 'Face ID' 
                ? Icons.face 
                : Icons.fingerprint,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use ${_authController.biometricType.value} to sign in',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 48),
        
        // Authenticate Button
        AppButton(
          text: 'Authenticate with ${_authController.biometricType.value}',
          onPressed: _handleBiometricLogin,
          isFullWidth: true,
          size: AppButtonSize.large,
          icon: _authController.biometricType.value == 'Face ID' 
              ? Icons.face 
              : Icons.fingerprint,
        ),
        const SizedBox(height: 16),
        
        // Use Password Instead
        TextButton(
          onPressed: () {
            setState(() {
              _isPasswordLogin = true;
            });
          },
          child: const Text('Use Password Instead'),
        ),
      ],
    );
  }
  
  Widget _buildPasswordLoginForm(BuildContext context, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AssetWorks Logo
          SizedBox(
            width: 150,
            height: 80,
            child: SvgPicture.asset(
              'assets/assetworks_logo_black.svg',
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Welcome Text
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue to AssetWorks',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),
          
          // Email Field
          AppTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(LucideIcons.mail, size: 20),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Password Field
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            obscureText: true,
            showPasswordToggle: true,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(LucideIcons.lock, size: 20),
            onSubmitted: (_) => _handleEmailPasswordLogin(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Remember Me and Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text('Remember Me'),
                ],
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed('/forgot-password');
                },
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Login Button
          Obx(() => AppButton(
            text: 'Sign In',
            onPressed: _handleEmailPasswordLogin,
            isLoading: _authController.isLoading.value,
            isFullWidth: true,
            size: AppButtonSize.large,
          )),
          
          // Show Face ID button if available but not enabled
          if (_authController.biometricType.value.isNotEmpty && 
              _authController.isBiometricEnabled.value)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppButton(
                text: 'Use ${_authController.biometricType.value}',
                onPressed: () {
                  setState(() {
                    _isPasswordLogin = false;
                  });
                  _handleBiometricLogin();
                },
                isFullWidth: true,
                size: AppButtonSize.large,
                type: AppButtonType.secondary,
                icon: _authController.biometricType.value == 'Face ID' 
                    ? Icons.face 
                    : Icons.fingerprint,
              ),
            ),
          
          const SizedBox(height: 24),
          
          // OTP Login
          AppButton(
            text: 'Sign In with OTP',
            onPressed: _handleOtpLogin,
            isFullWidth: true,
            size: AppButtonSize.large,
            type: AppButtonType.secondary,
            icon: LucideIcons.smartphone,
          ),
          const SizedBox(height: 12),
          
          // Debug Quick Login (only in debug mode)
          AppButton(
            text: 'Quick Test Login',
            onPressed: () async {
              // Use demo credentials for testing
              _emailController.text = 'demo@assetworks.ai';
              _passwordController.text = 'demo123';
              await _handleEmailPasswordLogin();
            },
            isFullWidth: true,
            size: AppButtonSize.large,
            type: AppButtonType.outline,
            icon: LucideIcons.testTube,
          ),
          const SizedBox(height: 24),
          
          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Social Login Buttons
          Column(
            children: [
              // Google Sign In
              OutlinedButton(
                onPressed: () => _handleSocialLogin('google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.google,
                      size: 20,
                      color: Color(0xFF4285F4),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Apple Sign In
              OutlinedButton(
                onPressed: () => _handleSocialLogin('apple'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  side: BorderSide(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.apple,
                      size: 20,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Apple',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Sign Up Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed('/register');
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          
          // Error Message
          Obx(() {
            if (_authController.error.value.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _authController.error.value,
                  style: TextStyle(color: Colors.red[700]),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  
  const _SocialLoginButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: isDark ? AppColors.neutral800 : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.neutral700 : AppColors.neutral200,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
      ),
    );
  }
}