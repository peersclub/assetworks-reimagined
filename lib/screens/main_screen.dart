import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart';
import 'trending_screen.dart';
import 'create_widget_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
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
    const TrendingScreen(),
    const CreateWidgetScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize performance monitoring
    Get.find<PerformanceOptimizationService>().initialize();
    
    // Initialize Dynamic Island
    DynamicIslandService().initialize();
    
    // Load notification count
    _loadNotificationCount();
  }
  
  Future<void> _loadNotificationCount() async {
    // This would fetch unread notification count from API
    setState(() {
      _notificationCount = 3; // Example count
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
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
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.flame),
            activeIcon: Icon(CupertinoIcons.flame_fill),
            label: 'Trending',
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
    );
  }
}