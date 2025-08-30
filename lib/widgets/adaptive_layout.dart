import 'package:flutter/cupertino.dart';
import '../core/utils/responsive_utils.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget master;
  final Widget? detail;
  final double masterWidth;
  final bool showDivider;
  
  const AdaptiveLayout({
    Key? key,
    required this.master,
    this.detail,
    this.masterWidth = 320,
    this.showDivider = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final shouldShowSplit = ResponsiveUtils.shouldShowSplitView(context);
    
    if (shouldShowSplit && detail != null) {
      return Row(
        children: [
          // Master view (sidebar)
          Container(
            width: masterWidth,
            child: master,
          ),
          
          // Divider
          if (showDivider)
            Container(
              width: 1,
              color: CupertinoColors.separator,
            ),
          
          // Detail view (main content)
          Expanded(
            child: detail!,
          ),
        ],
      );
    }
    
    // For phones or portrait tablets, show only master
    return master;
  }
}

class AdaptiveNavigationLayout extends StatefulWidget {
  final List<AdaptiveNavigationItem> items;
  final List<Widget> pages;
  final int initialIndex;
  
  const AdaptiveNavigationLayout({
    Key? key,
    required this.items,
    required this.pages,
    this.initialIndex = 0,
  }) : super(key: key);
  
  @override
  State<AdaptiveNavigationLayout> createState() => _AdaptiveNavigationLayoutState();
}

class _AdaptiveNavigationLayoutState extends State<AdaptiveNavigationLayout> {
  late int _selectedIndex;
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }
  
  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);
    
    if (isTablet && isLandscape) {
      // iPad landscape: Show sidebar navigation
      return CupertinoPageScaffold(
        child: Row(
          children: [
            // Sidebar
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGroupedBackground,
                border: Border(
                  right: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // App title
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'AssetWorks',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(height: 1),
                    // Navigation items
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final isSelected = _selectedIndex == index;
                          
                          return CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? CupertinoColors.systemBlue.withOpacity(0.1)
                                    : null,
                                border: isSelected
                                    ? Border(
                                        left: BorderSide(
                                          color: CupertinoColors.systemBlue,
                                          width: 3,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    color: isSelected
                                        ? CupertinoColors.systemBlue
                                        : CupertinoColors.label,
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected
                                          ? CupertinoColors.systemBlue
                                          : CupertinoColors.label,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if (item.badge != null) ...[
                                    Spacer(),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemRed,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        item.badge!,
                                        style: TextStyle(
                                          color: CupertinoColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content area
            Expanded(
              child: widget.pages[_selectedIndex],
            ),
          ],
        ),
      );
    } else {
      // Phone or portrait tablet: Show tab bar
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: widget.items.map((item) => BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          )).toList(),
        ),
        tabBuilder: (context, index) {
          return widget.pages[index];
        },
      );
    }
  }
}

class AdaptiveNavigationItem {
  final IconData icon;
  final String label;
  final String? badge;
  
  const AdaptiveNavigationItem({
    required this.icon,
    required this.label,
    this.badge,
  });
}