import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../core/services/storage_service.dart';
import '../services/dynamic_island_service.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/main_screen.dart';
import '../screens/user_onboarding_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> 
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // State
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _subscribedToNewsletter = false;
  File? _selectedImage;
  int _currentStep = 0;
  
  // Validation
  bool _isEmailValid = false;
  bool _isUsernameAvailable = true;
  bool _isPasswordStrong = false;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    // Add listeners for validation
    _emailController.addListener(_validateEmail);
    _usernameController.addListener(_checkUsernameAvailability);
    _passwordController.addListener(_validatePassword);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
      _emailError = email.isNotEmpty && !_isEmailValid 
          ? 'Please enter a valid email' 
          : null;
    });
  }
  
  Future<void> _checkUsernameAvailability() async {
    final username = _usernameController.text.trim();
    
    if (username.length < 3) {
      setState(() {
        _usernameError = 'Username must be at least 3 characters';
        _isUsernameAvailable = false;
      });
      return;
    }
    
    try {
      final available = await _apiService.checkUsernameAvailability(username);
      setState(() {
        _isUsernameAvailable = available;
        _usernameError = available ? null : 'Username is already taken';
      });
    } catch (e) {
      print('Error checking username: $e');
    }
  }
  
  void _validatePassword() {
    final password = _passwordController.text;
    
    // Check password strength
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final isLongEnough = password.length >= 8;
    
    setState(() {
      _isPasswordStrong = isLongEnough && hasUpperCase && hasLowerCase && 
                          (hasDigits || hasSpecialCharacters);
      
      if (password.isNotEmpty && !_isPasswordStrong) {
        _passwordError = 'Password must be at least 8 characters with uppercase, lowercase, and numbers';
      } else {
        _passwordError = null;
      }
    });
  }
  
  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Profile Photo'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Take Photo'),
            onPressed: () async {
              Navigator.pop(context);
              final pickedFile = await _imagePicker.pickImage(
                source: ImageSource.camera,
                maxWidth: 512,
                maxHeight: 512,
              );
              if (pickedFile != null) {
                setState(() => _selectedImage = File(pickedFile.path));
              }
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Choose from Gallery'),
            onPressed: () async {
              Navigator.pop(context);
              final pickedFile = await _imagePicker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 512,
                maxHeight: 512,
              );
              if (pickedFile != null) {
                setState(() => _selectedImage = File(pickedFile.path));
              }
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
  
  Future<void> _register() async {
    // Validate all fields
    if (!_validateFields()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Prepare registration data
      final registrationData = {
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'referral_code': _referralCodeController.text.trim(),
        'newsletter': _subscribedToNewsletter,
      };
      
      // Register user
      final response = await _apiService.register(registrationData);
      
      if (response['success'] == true) {
        // Upload profile picture if selected
        if (_selectedImage != null && response['user_id'] != null) {
          await _apiService.uploadProfilePictureFile(
            _selectedImage!,
            userId: response['user_id'],
          );
        }
        
        // Save user data
        await _storageService.saveUser(response['user'] ?? {});
        
        DynamicIslandService().updateStatus(
          'Registration successful!',
          icon: CupertinoIcons.checkmark_circle_fill,
        );
        
        // Navigate based on verification requirement
        if (response['requires_verification'] == true) {
          Get.to(() => const OTPVerificationScreen());
        } else {
          // Check if user needs onboarding
          final needsOnboarding = response['needs_onboarding'] ?? true;
          if (needsOnboarding) {
            Get.offAll(() => const UserOnboardingScreen());
          } else {
            Get.offAll(() => const MainScreen());
          }
        }
      } else {
        _showError(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      _showError('An error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  bool _validateFields() {
    if (_currentStep == 0) {
      // Validate basic info
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your name');
        return false;
      }
      if (!_isUsernameAvailable) {
        _showError('Please choose a different username');
        return false;
      }
    } else if (_currentStep == 1) {
      // Validate contact info
      if (!_isEmailValid) {
        _showError('Please enter a valid email');
        return false;
      }
      if (_phoneController.text.trim().length < 10) {
        _showError('Please enter a valid phone number');
        return false;
      }
    } else if (_currentStep == 2) {
      // Validate password
      if (!_isPasswordStrong) {
        _showError('Please create a stronger password');
        return false;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('Passwords do not match');
        return false;
      }
      if (!_agreedToTerms) {
        _showError('Please agree to the terms and conditions');
        return false;
      }
    }
    
    return true;
  }
  
  void _showError(String message) {
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
  
  void _nextStep() {
    if (_validateFields()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
        _animationController.forward(from: 0);
      } else {
        _register();
      }
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _animationController.forward(from: 0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground.withOpacity(0.94),
        border: null,
        middle: const Text('Create Account'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => _currentStep > 0 ? _previousStep() : Get.back(),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Main Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress Indicator
                    _buildProgressIndicator(),
                    
                    const SizedBox(height: 30),
                    
                    // Step Content
                    if (_currentStep == 0) _buildBasicInfoStep(),
                    if (_currentStep == 1) _buildContactInfoStep(),
                    if (_currentStep == 2) _buildSecurityStep(),
                    
                    const SizedBox(height: 30),
                    
                    // Action Button
                    CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      borderRadius: BorderRadius.circular(25),
                      onPressed: _isLoading ? null : _nextStep,
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : Text(_currentStep < 2 ? 'Continue' : 'Create Account'),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Login Link
                    if (_currentStep == 0)
                      Center(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: CupertinoColors.activeBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        final isCompleted = index < _currentStep;
        
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  index == 0 ? 'Basic Info' :
                  index == 1 ? 'Contact' : 'Security',
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive
                        ? CupertinoColors.label
                        : CupertinoColors.systemGrey,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile Photo
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.systemIndigo,
                        CupertinoColors.systemPurple,
                      ],
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipOval(
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          CupertinoIcons.person_fill,
                          size: 60,
                          color: CupertinoColors.white,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CupertinoColors.white,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      CupertinoIcons.camera_fill,
                      size: 20,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Full Name
        CupertinoTextField(
          controller: _nameController,
          placeholder: 'Full Name',
          prefix: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(
              CupertinoIcons.person_fill,
              color: CupertinoColors.systemGrey,
            ),
          ),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          textInputAction: TextInputAction.next,
        ),
        
        const SizedBox(height: 16),
        
        // Username
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              controller: _usernameController,
              placeholder: 'Username',
              prefix: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(
                  CupertinoIcons.at,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              suffix: _usernameController.text.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        _isUsernameAvailable
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.xmark_circle_fill,
                        color: _isUsernameAvailable
                            ? CupertinoColors.systemGreen
                            : CupertinoColors.systemRed,
                        size: 20,
                      ),
                    )
                  : null,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              textInputAction: TextInputAction.next,
            ),
            if (_usernameError != null)
              Padding(
                padding: EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  _usernameError!,
                  style: TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildContactInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              controller: _emailController,
              placeholder: 'Email',
              keyboardType: TextInputType.emailAddress,
              prefix: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(
                  CupertinoIcons.mail_solid,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              suffix: _emailController.text.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        _isEmailValid
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.xmark_circle_fill,
                        color: _isEmailValid
                            ? CupertinoColors.systemGreen
                            : CupertinoColors.systemRed,
                        size: 20,
                      ),
                    )
                  : null,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              textInputAction: TextInputAction.next,
            ),
            if (_emailError != null)
              Padding(
                padding: EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  _emailError!,
                  style: TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Phone
        CupertinoTextField(
          controller: _phoneController,
          placeholder: 'Phone Number',
          keyboardType: TextInputType.phone,
          prefix: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(
              CupertinoIcons.phone_fill,
              color: CupertinoColors.systemGrey,
            ),
          ),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          textInputAction: TextInputAction.next,
        ),
        
        const SizedBox(height: 16),
        
        // Referral Code (Optional)
        CupertinoTextField(
          controller: _referralCodeController,
          placeholder: 'Referral Code (Optional)',
          prefix: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(
              CupertinoIcons.gift_fill,
              color: CupertinoColors.systemGrey,
            ),
          ),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Newsletter Subscription
        GestureDetector(
          onTap: () {
            setState(() => _subscribedToNewsletter = !_subscribedToNewsletter);
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.mail,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscribe to Newsletter',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Get updates on new features and tips',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: _subscribedToNewsletter,
                  onChanged: (value) {
                    setState(() => _subscribedToNewsletter = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSecurityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Password
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              controller: _passwordController,
              placeholder: 'Password',
              obscureText: _obscurePassword,
              prefix: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(
                  CupertinoIcons.lock_fill,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              suffix: CupertinoButton(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  _obscurePassword
                      ? CupertinoIcons.eye_slash_fill
                      : CupertinoIcons.eye_fill,
                  color: CupertinoColors.systemGrey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              textInputAction: TextInputAction.next,
            ),
            if (_passwordError != null)
              Padding(
                padding: EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  _passwordError!,
                  style: TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 12,
                  ),
                ),
              ),
            
            // Password Strength Indicator
            if (_passwordController.text.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _isPasswordStrong
                              ? CupertinoColors.systemGreen
                              : _passwordController.text.length > 6
                                  ? CupertinoColors.systemOrange
                                  : CupertinoColors.systemRed,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isPasswordStrong ? 'Strong' :
                      _passwordController.text.length > 6 ? 'Medium' : 'Weak',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isPasswordStrong
                            ? CupertinoColors.systemGreen
                            : _passwordController.text.length > 6
                                ? CupertinoColors.systemOrange
                                : CupertinoColors.systemRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Confirm Password
        CupertinoTextField(
          controller: _confirmPasswordController,
          placeholder: 'Confirm Password',
          obscureText: _obscureConfirmPassword,
          prefix: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(
              CupertinoIcons.lock_fill,
              color: CupertinoColors.systemGrey,
            ),
          ),
          suffix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_confirmPasswordController.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    _passwordController.text == _confirmPasswordController.text
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.xmark_circle_fill,
                    color: _passwordController.text == _confirmPasswordController.text
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemRed,
                    size: 20,
                  ),
                ),
              CupertinoButton(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  _obscureConfirmPassword
                      ? CupertinoIcons.eye_slash_fill
                      : CupertinoIcons.eye_fill,
                  color: CupertinoColors.systemGrey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
            ],
          ),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Terms and Conditions
        GestureDetector(
          onTap: () {
            setState(() => _agreedToTerms = !_agreedToTerms);
          },
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _agreedToTerms
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _agreedToTerms
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey3,
                    width: 2,
                  ),
                ),
                child: _agreedToTerms
                    ? Icon(
                        CupertinoIcons.checkmark,
                        size: 16,
                        color: CupertinoColors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: CupertinoColors.activeBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: CupertinoColors.activeBlue,
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
      ],
    );
  }
}