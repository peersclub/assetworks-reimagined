import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Simple navigation after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        // Direct navigation to MainScreen without any checks
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemIndigo,
                    CupertinoColors.systemPurple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemIndigo.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.chart_bar_alt_fill,
                color: CupertinoColors.white,
                size: 60,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // App Name
            const Text(
              'AssetWorks',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Tagline
            Text(
              'AI-Powered Investment Insights',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            
            const SizedBox(height: 80),
            
            // Loading indicator
            const CupertinoActivityIndicator(radius: 15),
          ],
        ),
      ),
    );
  }
}