import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../controllers/auth_controller.dart';

class iOSRegisterScreen extends StatefulWidget {
  const iOSRegisterScreen({Key? key}) : super(key: key);

  @override
  State<iOSRegisterScreen> createState() => _iOSRegisterScreenState();
}

class _iOSRegisterScreenState extends State<iOSRegisterScreen> 
    with TickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  
  // State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _subscribeToNewsletter = true;
  bool _isLoading = false;
  
  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = CupertinoColors.systemGrey;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _passwordController.addListener(_checkPasswordStrength);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: iOS18Theme.springCurve),
    ));
    
    _animationController.forward();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;
    
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.125;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.125;
    
    setState(() {
      _passwordStrength = strength;
      
      if (strength <= 0.25) {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = iOS18Theme.systemRed;
      } else if (strength <= 0.5) {
        _passwordStrengthText = 'Fair';
        _passwordStrengthColor = iOS18Theme.systemOrange;
      } else if (strength <= 0.75) {
        _passwordStrengthText = 'Good';
        _passwordStrengthColor = iOS18Theme.systemYellow;
      } else {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = iOS18Theme.systemGreen;
      }
    });
  }

  Future<void> _handleRegister() async {
    // Validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorDialog('Please fill in all required fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    if (!_agreedToTerms) {
      _showErrorDialog('Please agree to the Terms of Service');
      return;
    }

    iOS18Theme.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final success = await _authController.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        newsletter: _subscribeToNewsletter,
      );

      if (success) {
        iOS18Theme.successImpact();
        Get.toNamed('/otp');
      } else {
        _showErrorDialog('Registration failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
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
        middle: const Text('Create Account'),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: iOS18Theme.spacing24),
                  
                  // Welcome text
                  Text(
                    'Join AssetWorks',
                    style: iOS18Theme.largeTitle.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing8),
                  
                  Text(
                    'Start building your investment widgets',
                    style: iOS18Theme.subheadline.copyWith(
                      color: iOS18Theme.secondaryLabel.resolveFrom(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing32),
                  
                  // Profile photo selector
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        iOS18Theme.lightImpact();
                        _showPhotoOptions();
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: iOS18Theme.systemGray5.resolveFrom(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.camera_fill,
                          size: 40,
                          color: iOS18Theme.secondaryLabel.resolveFrom(context),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing32),
                  
                  // Name field
                  _buildTextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    placeholder: 'Full Name *',
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    prefixIcon: CupertinoIcons.person,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocus);
                    },
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing16),
                  
                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    placeholder: 'Email *',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: CupertinoIcons.mail,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_phoneFocus);
                    },
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing16),
                  
                  // Phone field (optional)
                  _buildTextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    placeholder: 'Phone (Optional)',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    prefixIcon: CupertinoIcons.phone,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing16),
                  
                  // Password field
                  _buildTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    placeholder: 'Password *',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
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
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                    },
                  ),
                  
                  // Password strength indicator
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: iOS18Theme.spacing8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: iOS18Theme.systemGray5.resolveFrom(context),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _passwordStrength,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _passwordStrengthColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: iOS18Theme.spacing8),
                        Text(
                          _passwordStrengthText,
                          style: iOS18Theme.caption1.copyWith(
                            color: _passwordStrengthColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: iOS18Theme.spacing16),
                  
                  // Confirm password field
                  _buildTextField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    placeholder: 'Confirm Password *',
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    prefixIcon: CupertinoIcons.lock_shield,
                    suffixIcon: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        iOS18Theme.lightImpact();
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                      child: Icon(
                        _obscureConfirmPassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        size: 22,
                        color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                    onSubmitted: (_) => _handleRegister(),
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing24),
                  
                  // Terms and conditions
                  GestureDetector(
                    onTap: () {
                      iOS18Theme.lightImpact();
                      setState(() => _agreedToTerms = !_agreedToTerms);
                    },
                    child: Row(
                      children: [
                        Icon(
                          _agreedToTerms
                              ? CupertinoIcons.checkmark_square_fill
                              : CupertinoIcons.square,
                          size: 24,
                          color: _agreedToTerms
                              ? iOS18Theme.systemBlue
                              : iOS18Theme.secondaryLabel.resolveFrom(context),
                        ),
                        const SizedBox(width: iOS18Theme.spacing8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: iOS18Theme.footnote.copyWith(
                                color: iOS18Theme.label.resolveFrom(context),
                              ),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: iOS18Theme.systemBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: iOS18Theme.systemBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing16),
                  
                  // Newsletter subscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Subscribe to newsletter',
                          style: iOS18Theme.footnote.copyWith(
                            color: iOS18Theme.label.resolveFrom(context),
                          ),
                        ),
                      ),
                      CupertinoSwitch(
                        value: _subscribeToNewsletter,
                        onChanged: (value) {
                          iOS18Theme.lightImpact();
                          setState(() => _subscribeToNewsletter = value);
                        },
                        activeColor: iOS18Theme.systemBlue,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing32),
                  
                  // Register button
                  CupertinoButton.filled(
                    onPressed: (_isLoading || !_agreedToTerms) ? null : _handleRegister,
                    child: _isLoading
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          )
                        : const Text('Create Account'),
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
                  
                  // Social signup buttons
                  _buildSocialButton(
                    icon: CupertinoIcons.person_2,
                    title: 'Sign up with Apple',
                    onPressed: () {
                      iOS18Theme.lightImpact();
                      _authController.signInWithApple();
                    },
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing12),
                  
                  _buildSocialButton(
                    icon: CupertinoIcons.globe,
                    title: 'Sign up with Google',
                    onPressed: () {
                      iOS18Theme.lightImpact();
                      _authController.signInWithGoogle();
                    },
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing32),
                  
                  // Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: iOS18Theme.footnote.copyWith(
                          color: iOS18Theme.secondaryLabel.resolveFrom(context),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          iOS18Theme.lightImpact();
                          Get.toNamed('/login');
                        },
                        child: Text(
                          'Sign In',
                          style: iOS18Theme.footnote.copyWith(
                            color: iOS18Theme.systemBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: iOS18Theme.spacing32),
                ],
              ),
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

  void _showPhotoOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Add Profile Photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Handle camera
              iOS18Theme.lightImpact();
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Handle gallery
              iOS18Theme.lightImpact();
            },
            child: const Text('Choose from Library'),
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }
}