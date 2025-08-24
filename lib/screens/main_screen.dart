import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart';
import 'dashboard_v2_screen.dart';
import 'explore_screen.dart';
import 'widget_creator_screen.dart';
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
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ExploreScreen(),
    const WidgetCreatorScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Services are already initialized in main.dart
    
    // Load notification count
    _loadNotificationCount();
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
            icon: GestureDetector(
              onLongPress: _showDashboardOptions,
              child: Icon(CupertinoIcons.square_grid_2x2),
            ),
            activeIcon: GestureDetector(
              onLongPress: _showDashboardOptions,
              child: Icon(CupertinoIcons.square_grid_2x2_fill),
            ),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.compass),
            activeIcon: Icon(CupertinoIcons.compass_fill),
            label: 'Explore',
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