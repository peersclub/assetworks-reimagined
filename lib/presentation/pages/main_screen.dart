import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import 'home/home_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'analyse/analyse_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomeScreen(),
    const DashboardScreen(),
    const AnalyseScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark ? AppColors.neutral500 : AppColors.neutral600,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home, size: 22),
              activeIcon: Icon(LucideIcons.home, size: 22),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.layoutDashboard, size: 22),
              activeIcon: Icon(LucideIcons.layoutDashboard, size: 22),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.sparkles, size: 22),
              activeIcon: Icon(LucideIcons.sparkles, size: 22),
              label: 'Analyse',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.bell, size: 22),
              activeIcon: Icon(LucideIcons.bell, size: 22),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user, size: 22),
              activeIcon: Icon(LucideIcons.user, size: 22),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}