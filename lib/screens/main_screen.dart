import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'dashboard_screen.dart';  // Use our modified dashboard instead
import '../presentation/pages/dashboard/dashboard_screen.dart' as ModifiedDashboard;
import 'dashboard_v2_screen.dart';
import 'explore_screen.dart';
import 'explore_screen_enhanced.dart';
import 'investment_widget_creator_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'ai_assistant_screen.dart';
import '../services/performance_optimization_service.dart';
import '../services/dynamic_island_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _notificationCount = 0;
  bool _useEnhancedExplore = false; // Toggle for Explore versions
  bool _showV2Hint = false; // Show hint when V2 is activated
  DateTime? _lastExploreTabTap; // Track double tap on Explore tab
  DateTime? _lastDashboardTabTap; // Track double tap on Dashboard tab
  
  List<Widget> get _screens => [
    const ModifiedDashboard.DashboardScreen(),  // Use our modified dashboard with tabs
    _useEnhancedExplore 
        ? const ExploreScreenEnhanced()  // V2: Enhanced explore with all features
        : const ExploreScreen(),  // V1: Original explore screen
    const InvestmentWidgetCreatorScreen(),  // Keep this for now, will use templates
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Services are already initialized in main.dart
    
    // Load notification count
    _loadNotificationCount();
    
    // Show double tap hint after a delay
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        _showDoubleTapHint();
      }
    });
  }
  
  void _showDoubleTapHint() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          children: [
            Icon(CupertinoIcons.info_circle, size: 20),
            SizedBox(width: 8),
            Text('Pro Tip'),
          ],
        ),
        content: Text(
          'Double-tap Dashboard or Explore tabs to switch between different versions and access more options.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('Got it!'),
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
          ),
        ],
      ),
    );
  }
  
  Future<void> _loadNotificationCount() async {
    // This would fetch unread notification count from API
    setState(() {
      _notificationCount = 3; // Example count
    });
  }

  void _showDashboardOptions() {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Dashboard Options'),
          actions: [
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.square_grid_2x2, size: 20),
                  SizedBox(width: 8),
                  Text('Classic Dashboard'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.rectangle_stack, size: 20),
                  SizedBox(width: 8),
                  Text('Twitter-Style Feed (V2)'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                Get.to(() => DashboardV2Screen(), 
                  transition: Transition.cupertino,
                );
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showExploreOptions() {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Explore Options'),
          message: Text('Choose your explore experience'),
          actions: [
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.compass, size: 20),
                  SizedBox(width: 8),
                  Text('Classic Explore'),
                  if (!_useEnhancedExplore) ...[
                    SizedBox(width: 8),
                    Icon(CupertinoIcons.checkmark_circle_fill, 
                      size: 16, 
                      color: CupertinoColors.activeGreen),
                  ],
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _useEnhancedExplore = false;
                  _currentIndex = 1; // Switch to Explore tab
                });
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.square_grid_3x2_fill, size: 20),
                  SizedBox(width: 8),
                  Text('Explore V2 (All Features)'),
                  if (_useEnhancedExplore) ...[
                    SizedBox(width: 8),
                    Icon(CupertinoIcons.checkmark_circle_fill, 
                      size: 16, 
                      color: CupertinoColors.activeGreen),
                  ],
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _useEnhancedExplore = true;
                  _currentIndex = 1; // Switch to Explore tab
                  _showV2Hint = true;
                });
                // Hide hint after 3 seconds
                Future.delayed(Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() => _showV2Hint = false);
                  }
                });
              },
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.square_grid_3x2, size: 20),
                  SizedBox(width: 8),
                  Text('All Features Menu'),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                Get.toNamed('/all-features');
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CupertinoTabScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          
          // Check for double tap on Dashboard tab (index 0)
          if (index == 0) {
            final now = DateTime.now();
            if (_lastDashboardTabTap != null && 
                now.difference(_lastDashboardTabTap!).inMilliseconds < 500) {
              // Double tap detected - show dashboard options
              _showDashboardOptions();
              _lastDashboardTabTap = null; // Reset
              return;
            }
            _lastDashboardTabTap = now;
          }
          
          // Check for double tap on Explore tab (index 1)
          if (index == 1) {
            final now = DateTime.now();
            if (_lastExploreTabTap != null && 
                now.difference(_lastExploreTabTap!).inMilliseconds < 500) {
              // Double tap detected - show explore options
              _showExploreOptions();
              _lastExploreTabTap = null; // Reset
              return;
            }
            _lastExploreTabTap = now;
          }
          
          setState(() {
            _currentIndex = index;
            // Clear notification badge when viewing notifications
            if (index == 3) {
              _notificationCount = 0;
            }
          });
        },
        activeColor: CupertinoColors.systemIndigo,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
            label: 'Dashboard ••',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  CupertinoIcons.compass,
                  color: _useEnhancedExplore && _currentIndex == 1
                      ? CupertinoColors.systemPurple
                      : null,
                ),
                if (_useEnhancedExplore)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemPurple,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CupertinoColors.systemBackground,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  CupertinoIcons.compass_fill,
                  color: _useEnhancedExplore
                      ? CupertinoColors.systemPurple
                      : CupertinoColors.systemIndigo,
                ),
                if (_useEnhancedExplore)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CupertinoColors.systemPurple,
                            CupertinoColors.systemIndigo,
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CupertinoColors.systemBackground,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: _useEnhancedExplore ? 'Explore V2 ••' : 'Explore ••',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: _currentIndex == 2
                    ? LinearGradient(
                        colors: [
                          CupertinoColors.systemIndigo,
                          CupertinoColors.systemPurple,
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.add,
                color: _currentIndex == 2
                    ? CupertinoColors.white
                    : CupertinoColors.systemGrey,
              ),
            ),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(CupertinoIcons.bell),
                if (_notificationCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(CupertinoIcons.bell_fill),
                if (_notificationCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Activity',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_fill),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) => _screens[index],
        );
      },
    ),
        // V2 Hint Overlay
        if (_showV2Hint)
          Positioned(
            bottom: 85,
            left: 60,
            right: 60,
            child: AnimatedOpacity(
              opacity: _showV2Hint ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemPurple,
                      CupertinoColors.systemIndigo,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemPurple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.sparkles,
                      color: CupertinoColors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Explore V2 Activated',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Floating AI Assistant Button
        Positioned(
          bottom: 100,
          right: 20,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              Get.to(() => const AIAssistantScreen(),
                transition: Transition.cupertino,
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                CupertinoIcons.sparkles,
                color: CupertinoColors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}