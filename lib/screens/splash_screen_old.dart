import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../core/theme/ios_theme.dart';
import '../services/dynamic_island_service.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _shimmerController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _shimmerAnimation;
  bool _hasNavigated = false;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5),
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(_shimmerController);
    
    // Start animations
    _logoController.forward();
    
    // Navigate after delay
    _navigateToNext();
    
    // Update Dynamic Island
    DynamicIslandService().updateStatus(
      'Launching AssetWorks',
      icon: CupertinoIcons.rocket_fill,
    );
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }
  
  Future<void> _navigateToNext() async {
    // Prevent multiple navigations
    if (_hasNavigated) return;
    _hasNavigated = true;
    
    await Future.delayed(const Duration(seconds: 2));
    
    // Double check mounted state
    if (!mounted) return;
    
    // Skip all authentication and onboarding, go directly to main screen
    print('Navigating directly to main screen (skipping auth)...');
    try {
      // Use Get.off instead of Get.offAllNamed to avoid route issues
      Get.off(() => const MainScreen());
    } catch (e) {
      print('Navigation error: $e');
      // If that fails, try the route name
      try {
        Get.offAllNamed('/main');
      } catch (e2) {
        print('Route navigation also failed: $e2');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Haptic feedback on load
    HapticFeedback.lightImpact();
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.systemIndigo.withOpacity(0.1),
                  CupertinoColors.systemPurple.withOpacity(0.05),
                ],
              ),
            ),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animation
                AnimatedBuilder(
                  animation: Listenable.merge([_logoController, _shimmerController]),
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Logo container
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: CupertinoColors.systemIndigo.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Stack(
                                  children: [
                                    // Logo icon
                                    const Center(
                                      child: Icon(
                                        CupertinoIcons.cube_box_fill,
                                        size: 60,
                                        color: CupertinoColors.systemIndigo,
                                      ),
                                    ),
                                    
                                    // Shimmer effect
                                    Positioned.fill(
                                      child: ShaderMask(
                                        shaderCallback: (rect) {
                                          return LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: const [
                                              CupertinoColors.white,
                                              CupertinoColors.white,
                                              CupertinoColors.systemIndigo,
                                              CupertinoColors.white,
                                              CupertinoColors.white,
                                            ],
                                            stops: [
                                              0.0,
                                              _shimmerAnimation.value - 0.3,
                                              _shimmerAnimation.value,
                                              _shimmerAnimation.value + 0.3,
                                              1.0,
                                            ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                                          ).createShader(rect);
                                        },
                                        blendMode: BlendMode.srcATop,
                                        child: Container(
                                          color: CupertinoColors.white.withOpacity(0.1),
                                        ),
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
                  },
                ),
                
                const SizedBox(height: 30),
                
                // App name
                AnimatedBuilder(
                  animation: _logoOpacity,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoOpacity,
                      child: Column(
                        children: [
                          Text(
                            'AssetWorks',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: CupertinoTheme.of(context).textTheme.textStyle.color,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reimagined for iOS 18',
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Loading indicator
                const CupertinoActivityIndicator(
                  radius: 15,
                ),
              ],
            ),
          ),
          
          // Version info at bottom
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _logoOpacity,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _logoOpacity,
                  child: Text(
                    'Version 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}