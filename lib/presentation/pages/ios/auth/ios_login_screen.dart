import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../controllers/auth_controller.dart';

class iOSLoginScreen extends StatefulWidget {
  const iOSLoginScreen({Key? key}) : super(key: key);

  @override
  State<iOSLoginScreen> createState() => _iOSLoginScreenState();
}

class _iOSLoginScreenState extends State<iOSLoginScreen> 
    with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSavedCredentials();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

  void _loadSavedCredentials() {
    // Load saved email if remember me was checked
    final savedEmail = _authController.getSavedEmail();
    if (savedEmail != null) {
      _emailController.text = savedEmail;
    }
  }

  Future<void> _handleLogin() async {
    // Validate input
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please enter your email and password');
      return;
    }

    iOS18Theme.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final success = await _authController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (success) {
        iOS18Theme.successImpact();
        Get.offAllNamed('/main');
      } else {
        _showErrorDialog('Invalid email or password');
      }
    } catch (e) {
      _showErrorDialog('Login failed. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleBiometricLogin() async {
    iOS18Theme.lightImpact();
    
    final success = await _authController.biometricLogin();
    if (success) {
      iOS18Theme.successImpact();
      Get.offAllNamed('/main');
    } else {
      _showErrorDialog('Biometric authentication failed');
    }
  }

  void _showErrorDialog(String message) {
    iOS18Theme.notificationError();
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
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.systemBackground.resolveFrom(context),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing24),
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      CupertinoIcons.arrow_left,
                      color: iOS18Theme.label.resolveFrom(context),
                    ),
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: iOS18Theme.spacing32),
                        
                        // Logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: iOS18Theme.systemBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.person_circle_fill,
                            size: 60,
                            color: iOS18Theme.systemBlue,
                          ),
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing32),
                        
                        // Title
                        Text(
                          'Welcome Back',
                          style: iOS18Theme.largeTitle.copyWith(
                            color: iOS18Theme.label.resolveFrom(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing8),
                        
                        Text(
                          'Sign in to continue',
                          style: iOS18Theme.subheadline.copyWith(
                            color: iOS18Theme.secondaryLabel.resolveFrom(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing32),
                        
                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          placeholder: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: CupertinoIcons.mail,
                          onSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing16),
                        
                        // Password field
                        _buildTextField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          placeholder: 'Password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          prefixIcon: CupertinoIcons.lock,
                          suffixIcon: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              iOS18Theme.lightImpact();
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            child: Icon(
                              _obscurePassword
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              size: 22,
                              color: iOS18Theme.secondaryLabel.resolveFrom(context),
                            ),
                          ),
                          onSubmitted: (_) => _handleLogin(),
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing16),
                        
                        // Remember me & Forgot password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CupertinoSwitch(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    iOS18Theme.lightImpact();
                                    setState(() => _rememberMe = value);
                                  },
                                  activeColor: iOS18Theme.systemBlue,
                                ),
                                const SizedBox(width: iOS18Theme.spacing8),
                                Text(
                                  'Remember me',
                                  style: iOS18Theme.footnote.copyWith(
                                    color: iOS18Theme.label.resolveFrom(context),
                                  ),
                                ),
                              ],
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                iOS18Theme.lightImpact();
                                Get.toNamed('/forgot-password');
                              },
                              child: Text(
                                'Forgot password?',
                                style: iOS18Theme.footnote.copyWith(
                                  color: iOS18Theme.systemBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing32),
                        
                        // Login button
                        CupertinoButton.filled(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const CupertinoActivityIndicator(
                                  color: CupertinoColors.white,
                                )
                              : const Text('Sign In'),
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing16),
                        
                        // Biometric login
                        CupertinoButton(
                          onPressed: _handleBiometricLogin,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.faceid,
                                color: iOS18Theme.label.resolveFrom(context),
                              ),
                              const SizedBox(width: iOS18Theme.spacing8),
                              Text(
                                'Sign in with Face ID',
                                style: iOS18Theme.body.copyWith(
                                  color: iOS18Theme.label.resolveFrom(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing16),
                        
                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: iOS18Theme.separator.resolveFrom(context),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: iOS18Theme.spacing16,
                              ),
                              child: Text(
                                'OR',
                                style: iOS18Theme.caption1.copyWith(
                                  color: iOS18Theme.tertiaryLabel.resolveFrom(context),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: iOS18Theme.separator.resolveFrom(context),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing16),
                        
                        // Social login buttons
                        _buildSocialButton(
                          icon: CupertinoIcons.person_2,
                          title: 'Continue with Apple',
                          onPressed: () {
                            iOS18Theme.lightImpact();
                            _authController.signInWithApple();
                          },
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing12),
                        
                        _buildSocialButton(
                          icon: CupertinoIcons.globe,
                          title: 'Continue with Google',
                          onPressed: () {
                            iOS18Theme.lightImpact();
                            _authController.signInWithGoogle();
                          },
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing32),
                        
                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: iOS18Theme.footnote.copyWith(
                                color: iOS18Theme.secondaryLabel.resolveFrom(context),
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                iOS18Theme.lightImpact();
                                Get.toNamed('/register');
                              },
                              child: Text(
                                'Sign Up',
                                style: iOS18Theme.footnote.copyWith(
                                  color: iOS18Theme.systemBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    IconData? prefixIcon,
    Widget? suffixIcon,
    void Function(String)? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
      ),
      child: Row(
        children: [
          if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.only(left: iOS18Theme.spacing12),
              child: Icon(
                prefixIcon,
                size: 22,
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
            ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              focusNode: focusNode,
              placeholder: placeholder,
              placeholderStyle: iOS18Theme.body.copyWith(
                color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              ),
              style: iOS18Theme.body.copyWith(
                color: iOS18Theme.label.resolveFrom(context),
              ),
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              decoration: const BoxDecoration(),
              padding: const EdgeInsets.symmetric(
                horizontal: iOS18Theme.spacing12,
                vertical: iOS18Theme.spacing16,
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: iOS18Theme.spacing16,
          vertical: iOS18Theme.spacing12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: iOS18Theme.separator.resolveFrom(context),
          ),
          borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: iOS18Theme.label.resolveFrom(context),
            ),
            const SizedBox(width: iOS18Theme.spacing8),
            Text(
              title,
              style: iOS18Theme.body.copyWith(
                color: iOS18Theme.label.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }
}