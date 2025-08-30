import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardTabs extends GetView<DashboardController> {
  const DashboardTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark 
            ? CupertinoColors.darkBackgroundGray 
            : CupertinoColors.systemGroupedBackground,
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? CupertinoColors.systemGrey5.darkColor 
                : CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      child: Obx(() => Row(
        children: [
          _TabButton(
            title: 'My Analysis',
            isSelected: controller.currentTabIndex.value == 0,
            onTap: () => controller.switchTab(0),
          ),
          _TabButton(
            title: 'Saved Analysis',
            isSelected: controller.currentTabIndex.value == 1,
            onTap: () => controller.switchTab(1),
          ),
        ],
      )),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: CupertinoColors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected 
                      ? CupertinoColors.activeBlue 
                      : CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 100,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? CupertinoColors.activeBlue 
                      : CupertinoColors.transparent,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}