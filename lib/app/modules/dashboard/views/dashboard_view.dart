import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_tabs.dart';
import '../widgets/my_analysis_tab.dart';
import '../widgets/saved_analysis_tab.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            // Header Section
            const DashboardHeader(),
            
            // Tab Bar
            const DashboardTabs(),
            
            // Tab Content
            Expanded(
              child: Obx(() {
                return IndexedStack(
                  index: controller.currentTabIndex.value,
                  children: const [
                    MyAnalysisTab(),
                    SavedAnalysisTab(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}