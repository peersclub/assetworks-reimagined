import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../core/theme/ios_theme.dart';
import 'dashboard/ios_dashboard_screen.dart';
// import 'discovery/ios_discovery_screen.dart';
// import 'create/ios_create_widget_screen.dart';
// import 'profile/ios_profile_screen.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/notifications_controller.dart';

class iOSMainScreen extends StatefulWidget {
  const iOSMainScreen({Key? key}) : super(key: key);

  @override
  State<iOSMainScreen> createState() => _iOSMainScreenState();
}

class _iOSMainScreenState extends State<iOSMainScreen> {
  final CupertinoTabController _tabController = CupertinoTabController();
  final DashboardController _dashboardController = Get.find<DashboardController>();
  final NotificationsController _notificationsController = Get.find<NotificationsController>();
  
  // Track previous tab for haptic feedback
  int _previousTab = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupQuickActions();
  }

  void _initializeControllers() {
    // Initialize data on app start
    _dashboardController.loadDashboardWidgets();
    _notificationsController.loadNotifications();
  }

  void _setupQuickActions() {
    // Setup iOS Quick Actions (3D Touch / Long Press on app icon)
    // This will be implemented with quick_actions package
  }

  void _onTabTapped(int index) {
    if (index != _previousTab) {
      // Haptic feedback on tab change
      iOS18Theme.selectionClick();
      _previousTab = index;
      
      // Special handling for create tab (modal)
      if (index == 2) {
        _showCreateModal();
        // Reset to previous tab
        Future.delayed(Duration.zero, () {
          _tabController.index = _previousTab;
        });
      }
    }
  }

  void _showCreateModal() {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      barrierColor: CupertinoColors.black.withOpacity(0.6),
      bounce: true,
      isDismissible: true,
      enableDrag: true,
      topRadius: const Radius.circular(iOS18Theme.extraLargeRadius),
      builder: (context) => const CupertinoPageScaffold(child: Center(child: Text('Create Widget'))), // const iOSCreateWidgetScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        backgroundColor: isDarkMode
            ? iOS18Theme.secondarySystemBackground.darkColor.withOpacity(0.94)
            : iOS18Theme.secondarySystemBackground.color.withOpacity(0.94),
        border: Border(
          top: BorderSide(
            color: iOS18Theme.separator.resolveFrom(context),
            width: 0.0, // iOS 18 no border
          ),
        ),
        activeColor: iOS18Theme.systemBlue,
        inactiveColor: iOS18Theme.secondaryLabel.resolveFrom(context),
        iconSize: 28,
        height: 49, // iOS standard tab bar height
        onTap: _onTabTapped,
        items: [
          // Dashboard
          BottomNavigationBarItem(
            icon: _buildTabIcon(CupertinoIcons.square_grid_2x2, false),
            activeIcon: _buildTabIcon(CupertinoIcons.square_grid_2x2_fill, true),
            label: 'Dashboard',
          ),
          // Discovery
          BottomNavigationBarItem(
            icon: _buildTabIcon(CupertinoIcons.compass, false),
            activeIcon: _buildTabIcon(CupertinoIcons.compass_fill, true),
            label: 'Discover',
          ),
          // Create (Center button)
          BottomNavigationBarItem(
            icon: _buildCreateButton(false),
            activeIcon: _buildCreateButton(true),
            label: 'Create',
          ),
          // Notifications with badge
          BottomNavigationBarItem(
            icon: _buildNotificationIcon(false),
            activeIcon: _buildNotificationIcon(true),
            label: 'Activity',
          ),
          // Profile
          BottomNavigationBarItem(
            icon: _buildTabIcon(CupertinoIcons.person_circle, false),
            activeIcon: _buildTabIcon(CupertinoIcons.person_circle_fill, true),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => const iOSDashboardScreen(),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => const CupertinoPageScaffold(child: Center(child: Text('Discovery'))), // const iOSDiscoveryScreen(),
            );
          case 2:
            // This is handled by modal, return current view
            return CupertinoTabView(
              builder: (context) => const iOSDashboardScreen(),
            );
          case 3:
            return CupertinoTabView(
              builder: (context) => const CupertinoPageScaffold(child: Center(child: Text('Notifications'))), // const iOSNotificationsScreen(),
            );
          case 4:
            return CupertinoTabView(
              builder: (context) => const CupertinoPageScaffold(child: Center(child: Text('Profile'))), // const iOSProfileScreen(),
            );
          default:
            return CupertinoTabView(
              builder: (context) => const iOSDashboardScreen(),
            );
        }
      },
    );
  }

  Widget _buildTabIcon(IconData icon, bool isActive) {
    return Icon(
      icon,
      size: isActive ? 28 : 26,
    );
  }

  Widget _buildCreateButton(bool isActive) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  iOS18Theme.systemBlue,
                  iOS18Theme.systemBlue.withBlue(200),
                ]
              : [
                  iOS18Theme.systemBlue.withOpacity(0.9),
                  iOS18Theme.systemBlue.withOpacity(0.9),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: iOS18Theme.systemBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Icon(
        CupertinoIcons.plus,
        color: CupertinoColors.white,
        size: 24,
      ),
    );
  }

  Widget _buildNotificationIcon(bool isActive) {
    return Obx(() {
      final unreadCount = _notificationsController.unreadCount.value;
      
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            isActive 
                ? CupertinoIcons.bell_fill 
                : CupertinoIcons.bell,
            size: isActive ? 28 : 26,
          ),
          if (unreadCount > 0)
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iOS18Theme.systemRed,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CupertinoColors.white,
                    width: 2,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Notification Icon for Navigation Bar
class iOSNotificationIcon extends StatelessWidget {
  const iOSNotificationIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NotificationsController controller = Get.find<NotificationsController>();
    
    return Obx(() {
      final unreadCount = controller.unreadCount.value;
      
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          iOS18Theme.lightImpact();
          Get.toNamed('/notifications');
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              CupertinoIcons.bell,
              size: 22,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: iOS18Theme.systemRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}