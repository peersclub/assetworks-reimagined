import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart'; // Uncomment when package is added
import '../services/dynamic_island_service.dart';
import '../data/services/api_service.dart';
import '../core/services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  // final _localAuth = LocalAuthentication(); // Uncomment when package is added
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _canCheckBiometrics = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    
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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _checkBiometrics() async {
    // Mock biometric check - uncomment when local_auth is added
    setState(() {
      _canCheckBiometrics = true; // Mock as available
    });
    
    // Auto-prompt for Face ID if available
    if (_canCheckBiometrics) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _authenticateWithBiometrics();
      });
    }
  }
  
  Future<void> _authenticateWithBiometrics() async {
    // Mock biometric authentication for now
    HapticFeedback.mediumImpact();
    
    // Try to login with saved credentials
    final savedEmail = await _storageService.getSavedEmail();
    final savedToken = await _storageService.getAuthToken();
    
    if (savedToken != null) {
      DynamicIslandService().updateStatus(
        'Welcome back!',
        icon: CupertinoIcons.checkmark_circle_fill,
      );
      Get.offAllNamed('/main');
    } else {
      _showErrorDialog('Please login with your credentials first');
    }
  }
  
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please enter email and password');
      return;
    }
    
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    
    DynamicIslandService().updateStatus(
      'Signing in...',
      icon: CupertinoIcons.person_circle,
    );
    
    try {
      final response = await _apiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (response['success'] == true || response['token'] != null) {
        // Save credentials if remember me is checked
        if (_rememberMe) {
          await _storageService.saveEmail(_emailController.text.trim());
        }
        
        setState(() => _isLoading = false);
        HapticFeedback.heavyImpact();
        
        DynamicIslandService().updateStatus(
          'Welcome ${response['user']?['name'] ?? 'back'}!',
          icon: CupertinoIcons.checkmark_circle_fill,
        );
        
        Get.offAllNamed('/main');
      } else {
        setState(() => _isLoading = false);
        _showErrorDialog(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
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
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        
                        // Logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemIndigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            CupertinoIcons.cube_box_fill,
                            size: 50,
                            color: CupertinoColors.systemIndigo,
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Welcome text
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: CupertinoTheme.of(context).textTheme.textStyle.color,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Sign in to continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Email field
                        CupertinoTextField(
                          controller: _emailController,
                          placeholder: 'Email',
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: Icon(
                              CupertinoIcons.mail,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? CupertinoColors.systemGrey6.darkColor 
                                : CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Password field
                        CupertinoTextField(
                          controller: _passwordController,
                          placeholder: 'Password',
                          obscureText: !_isPasswordVisible,
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: Icon(
                              CupertinoIcons.lock,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          suffix: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Icon(
                              _isPasswordVisible 
                                  ? CupertinoIcons.eye_slash 
                                  : CupertinoIcons.eye,
                              color: CupertinoColors.systemGrey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? CupertinoColors.systemGrey6.darkColor 
                                : CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Remember me and forgot password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CupertinoSwitch(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() => _rememberMe = value);
                                  },
                                  activeColor: CupertinoColors.systemIndigo,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                                  ),
                                ),
                              ],
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: CupertinoColors.systemIndigo,
                                ),
                              ),
                              onPressed: () {
                                Get.toNamed('/forgot-password');
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: CupertinoButton(
                            color: CupertinoColors.systemIndigo,
                            borderRadius: BorderRadius.circular(12),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading 
                                ? const CupertinoActivityIndicator(
                                    color: CupertinoColors.white,
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        if (_canCheckBiometrics) ...[
                          const SizedBox(height: 20),
                          
                          // Face ID button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: CupertinoButton(
                              color: isDark 
                                  ? CupertinoColors.systemGrey6.darkColor 
                                  : CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(12),
                              onPressed: _authenticateWithBiometrics,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.lock_shield,
                                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sign in with Face ID',
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
                        ],
                        
                        const SizedBox(height: 20),
                        
                        // OTP Login
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                CupertinoIcons.phone,
                                size: 20,
                                color: CupertinoColors.systemIndigo,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Sign in with OTP',
                                style: TextStyle(
                                  color: CupertinoColors.systemIndigo,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Get.toNamed('/otp-login');
                          },
                        ),
                        
                        const Spacer(),
                        
                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: CupertinoColors.systemIndigo,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                Get.toNamed('/register');
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
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
}