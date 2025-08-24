import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart';
import 'discovery_screen.dart';
import 'create_widget_screen.dart';
import 'profile_screen.dart';
import '../services/dynamic_island_service.dart';

class MainTabNavigation extends StatefulWidget {
  const MainTabNavigation({Key? key}) : super(key: key);

  @override
  State<MainTabNavigation> createState() => _MainTabNavigationState();
}

class _MainTabNavigationState extends State<MainTabNavigation> 
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  
  final List<Widget> _pages = [
    const DashboardScreen(),
    const DiscoveryScreen(),
    const CreateWidgetScreen(),
    const ProfileScreen(),
  ];
  
  final List<_TabItem> _tabItems = [
    _TabItem(
      icon: CupertinoIcons.home,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Home',
    ),
    _TabItem(
      icon: CupertinoIcons.compass,
      activeIcon: CupertinoIcons.compass_fill,
      label: 'Discover',
    ),
    _TabItem(
      icon: CupertinoIcons.add_circled,
      activeIcon: CupertinoIcons.add_circled_solid,
      label: 'Create',
      isSpecial: true,
    ),
    _TabItem(
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      label: 'Profile',
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }
  
  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    
    HapticFeedback.lightImpact();
    
    // Special handling for create button
    if (index == 2) {
      _fabAnimationController.forward().then((_) {
        _fabAnimationController.reverse();
      });
      
      // Show create modal
      _showCreateModal();
      return;
    }
    
    setState(() {
      _currentIndex = index;
    });
    
    // Update Dynamic Island
    DynamicIslandService().updateStatus(
      _tabItems[index].label,
      icon: _tabItems[index].activeIcon,
    );
  }
  
  void _showCreateModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey3,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Create Widget',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text(
                      'Create',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed('/create-widget');
                    },
                  ),
                ],
              ),
            ),
            
            // Content
            const Expanded(
              child: CreateWidgetScreen(),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex == 2 ? 0 : _currentIndex,
        onTap: _onTabSelected,
        backgroundColor: isDark 
            ? CupertinoColors.black.withOpacity(0.95)
            : CupertinoColors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        items: _tabItems.map((item) {
          final index = _tabItems.indexOf(item);
          final isActive = index == _currentIndex;
          
          if (item.isSpecial) {
            return BottomNavigationBarItem(
              icon: AnimatedBuilder(
                animation: _fabScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _fabScaleAnimation.value,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            CupertinoColors.systemIndigo,
                            CupertinoColors.systemPurple,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemIndigo.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.white,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
              label: '',
            );
          }
          
          return BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                size: 24,
              ),
            ),
            label: item.label,
          );
        }).toList(),
      ),
      tabBuilder: (context, index) {
        // Map the tab index to the correct page
        Widget page;
        switch (index) {
          case 0:
            page = const DashboardScreen();
            break;
          case 1:
            page = const DiscoveryScreen();
            break;
          case 2:
            page = const CreateWidgetScreen();
            break;
          case 3:
            page = const ProfileScreen();
            break;
          default:
            page = const DashboardScreen();
        }
        
        return CupertinoTabView(
          builder: (context) => page,
        );
      },
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSpecial;
  
  _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isSpecial = false,
  });
}