import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/dynamic_island_service.dart';
import '../models/dashboard_widget.dart';
import '../screens/widget_preview_screen.dart';
import '../screens/investment_widget_creator_screen.dart';
import 'dashboard_screen.dart';
import 'dashboard_v2_screen.dart';
import 'dashboard_v3_screen.dart';
import '../presentation/pages/dashboard/dashboard_screen.dart' as PresentationDashboard;
import '../presentation/pages/dashboard/optimized_dashboard_screen.dart';

class DashboardV4TestScreen extends StatefulWidget {
  const DashboardV4TestScreen({Key? key}) : super(key: key);

  @override
  State<DashboardV4TestScreen> createState() => _DashboardV4TestScreenState();
}

class _DashboardV4TestScreenState extends State<DashboardV4TestScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = Get.find<ApiService>();
  int _selectedDashboardIndex = 0;
  
  final List<String> _dashboardNames = [
    'Classic Dashboard',
    'Dashboard V2 (Feed)',
    'Dashboard V3 (Trending)',
    'Presentation Dashboard',
    'Optimized Dashboard',
    'Combined View',
  ];
  
  final List<IconData> _dashboardIcons = [
    CupertinoIcons.square_grid_2x2,
    CupertinoIcons.rectangle_stack,
    CupertinoIcons.chart_bar_alt_fill,
    CupertinoIcons.rectangle_3_offgrid,
    CupertinoIcons.speedometer,
    CupertinoIcons.square_split_2x2,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _dashboardNames.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedDashboardIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildDashboardVersion(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen(); // Classic Dashboard
      case 1:
        return const DashboardV2Screen(); // V2 Feed Style
      case 2:
        return const DashboardV3Screen(); // V3 Trending Style
      case 3:
        return const PresentationDashboard.DashboardScreen(); // Presentation version
      case 4:
        return const OptimizedDashboardScreen(); // Optimized version
      case 5:
        return _buildCombinedView(); // Combined view of all
      default:
        return const DashboardScreen();
    }
  }

  Widget _buildCombinedView() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard V4 Test - Combined View',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All dashboard versions in one scrollable view',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Mini previews of each dashboard
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= _dashboardNames.length - 1) return null;
              
              return Container(
                height: 400,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey5,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_dashboardIcons[index], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _dashboardNames[index],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text(
                              'Open',
                              style: TextStyle(
                                color: CupertinoTheme.of(context).primaryColor,
                                fontSize: 12,
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                _tabController.animateTo(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(11),
                          bottomRight: Radius.circular(11),
                        ),
                        child: AbsorbPointer(
                          child: Transform.scale(
                            scale: 0.8,
                            child: _buildDashboardVersion(index),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: _dashboardNames.length - 1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text('Dashboard V4 Test'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.info_circle),
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: Text('Dashboard V4 Test'),
                    content: Text(
                      'This is a test screen that combines all dashboard versions. '
                      'Swipe between tabs or tap to switch between different dashboard implementations.',
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: Text('Got it'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.square_grid_3x2),
              onPressed: () {
                _showDashboardSelector();
              },
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: CupertinoTheme.of(context).barBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.systemGrey5,
                  width: 0.5,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: List.generate(_dashboardNames.length, (index) {
                  final isSelected = _selectedDashboardIndex == index;
                  return GestureDetector(
                    onTap: () {
                      _tabController.animateTo(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _dashboardIcons[index],
                            size: 16,
                            color: isSelected
                                ? CupertinoColors.white
                                : CupertinoColors.label,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _dashboardNames[index],
                            style: TextStyle(
                              color: isSelected
                                  ? CupertinoColors.white
                                  : CupertinoColors.label,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Dashboard content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                _dashboardNames.length,
                (index) => _buildDashboardVersion(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDashboardSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Select Dashboard Version'),
        message: Text('Choose which dashboard to view'),
        actions: List.generate(_dashboardNames.length, (index) {
          return CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_dashboardIcons[index], size: 20),
                const SizedBox(width: 8),
                Text(_dashboardNames[index]),
                if (_selectedDashboardIndex == index) ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    size: 16,
                    color: CupertinoColors.activeGreen,
                  ),
                ],
              ],
            ),
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(index);
            },
          );
        }),
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}