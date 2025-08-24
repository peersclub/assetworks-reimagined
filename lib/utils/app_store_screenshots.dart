import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// App Store Screenshot configurations
class AppStoreScreenshots {
  // iPhone 6.7" (iPhone 15 Pro Max, 14 Pro Max)
  static const Size iPhone67 = Size(1290, 2796);
  
  // iPhone 6.5" (iPhone 15 Plus, 14 Plus, 13 Pro Max, 12 Pro Max)
  static const Size iPhone65 = Size(1242, 2688);
  
  // iPhone 5.5" (iPhone 8 Plus, 7 Plus, 6s Plus)
  static const Size iPhone55 = Size(1242, 2208);
  
  // iPad Pro 12.9" (6th gen)
  static const Size iPadPro129 = Size(2048, 2732);
  
  // iPad Pro 11" (4th gen)
  static const Size iPadPro11 = Size(1668, 2388);

  static List<ScreenshotConfig> getRequiredScreenshots() {
    return [
      ScreenshotConfig(
        name: 'Dashboard',
        description: 'Main dashboard with portfolio overview',
        features: ['Real-time data', 'Interactive charts', 'Portfolio insights'],
        primaryColor: CupertinoColors.systemIndigo,
      ),
      ScreenshotConfig(
        name: 'Dynamic Island',
        description: 'Live Activities in Dynamic Island',
        features: ['Real-time updates', 'Quick actions', 'Portfolio status'],
        primaryColor: CupertinoColors.systemPurple,
      ),
      ScreenshotConfig(
        name: 'Home Widgets',
        description: 'Beautiful iOS widgets for your home screen',
        features: ['Multiple sizes', 'Interactive', 'Live data'],
        primaryColor: CupertinoColors.systemBlue,
      ),
      ScreenshotConfig(
        name: 'Dark Mode',
        description: 'Stunning dark mode design',
        features: ['OLED optimized', 'Eye comfort', 'Automatic switching'],
        primaryColor: CupertinoColors.black,
      ),
      ScreenshotConfig(
        name: 'Charts',
        description: 'Advanced portfolio analytics',
        features: ['Interactive charts', 'Historical data', 'Performance metrics'],
        primaryColor: CupertinoColors.systemGreen,
      ),
    ];
  }
}

class ScreenshotConfig {
  final String name;
  final String description;
  final List<String> features;
  final Color primaryColor;

  ScreenshotConfig({
    required this.name,
    required this.description,
    required this.features,
    required this.primaryColor,
  });
}

// Screenshot preview widget
class ScreenshotPreview extends StatelessWidget {
  final ScreenshotConfig config;
  final Size deviceSize;
  final Widget child;

  const ScreenshotPreview({
    Key? key,
    required this.config,
    required this.deviceSize,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: deviceSize.width,
      height: deviceSize.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.primaryColor.withOpacity(0.8),
            config.primaryColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: PatternPainter(color: CupertinoColors.white.withOpacity(0.05)),
            ),
          ),
          
          // Main content
          Positioned(
            top: 120,
            left: 40,
            right: 40,
            bottom: 120,
            child: Column(
              children: [
                // Title
                Text(
                  config.name,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  config.description,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.white,
                    letterSpacing: 0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Device mockup
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withOpacity(0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: child,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Features
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: config.features.map((feature) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CupertinoColors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Status bar mockup
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '9:41',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.wifi,
                        color: CupertinoColors.white,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.battery_100,
                        color: CupertinoColors.white,
                        size: 25,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pattern painter for background
class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 60.0;
    const radius = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}