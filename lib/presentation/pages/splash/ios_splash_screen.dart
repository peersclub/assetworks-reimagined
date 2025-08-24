import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/ios_theme.dart';
import '../../controllers/auth_controller.dart';

class iOSSplashScreen extends StatefulWidget {
  const iOSSplashScreen({Key? key}) : super(key: key);

  @override
  State<iOSSplashScreen> createState() => _iOSSplashScreenState();
}

class _iOSSplashScreenState extends State<iOSSplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: iOS18Theme.springCurve),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // Haptic feedback on launch
    iOS18Theme.mediumImpact();

    // Minimum splash duration for smooth experience
    await Future.delayed(const Duration(seconds: 2));

    // Check authentication status
    final isAuthenticated = await _authController.checkAuthStatus();

    if (mounted) {
      if (isAuthenticated) {
        Get.offAllNamed('/main');
      } else {
        Get.offAllNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode 
          ? CupertinoColors.black 
          : CupertinoColors.white,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
          statusBarIconBrightness: 
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with iOS 18 style shadow
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? iOS18Theme.systemGray6 
                                : CupertinoColors.white,
                            borderRadius: BorderRadius.circular(
                              iOS18Theme.extraLargeRadius,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.systemGrey.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(iOS18Theme.spacing24),
                            child: Image.asset(
                              'assets/images/assetworks_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing32),
                        
                        // App name with iOS typography
                        Text(
                          'AssetWorks',
                          style: iOS18Theme.largeTitle.copyWith(
                            color: isDarkMode 
                                ? CupertinoColors.white 
                                : CupertinoColors.black,
                          ),
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing8),
                        
                        Text(
                          'Investment Intelligence',
                          style: iOS18Theme.subheadline.copyWith(
                            color: isDarkMode 
                                ? iOS18Theme.secondaryLabel 
                                : iOS18Theme.secondaryLabel,
                          ),
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing32 * 2),
                        
                        // iOS style loading indicator
                        const CupertinoActivityIndicator(
                          radius: 15,
                        ),
                        
                        const SizedBox(height: iOS18Theme.spacing16),
                        
                        Text(
                          'Loading your dashboard...',
                          style: iOS18Theme.footnote.copyWith(
                            color: iOS18Theme.tertiaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Alternative splash with Lottie animation
class iOSSplashScreenAnimated extends StatefulWidget {
  const iOSSplashScreenAnimated({Key? key}) : super(key: key);

  @override
  State<iOSSplashScreenAnimated> createState() => _iOSSplashScreenAnimatedState();
}

class _iOSSplashScreenAnimatedState extends State<iOSSplashScreenAnimated> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Get.offAllNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode 
          ? CupertinoColors.black 
          : CupertinoColors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation placeholder
            Container(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/animations/splash.json',
                repeat: true,
                animate: true,
              ),
            ),
            
            const SizedBox(height: iOS18Theme.spacing32),
            
            Text(
              'AssetWorks',
              style: iOS18Theme.largeTitle.copyWith(
                color: isDarkMode 
                    ? CupertinoColors.white 
                    : CupertinoColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}