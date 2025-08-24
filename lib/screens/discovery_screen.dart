import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../presentation/widgets/ios/ios_widget_card.dart';
import '../presentation/widgets/ios/ios_search_bar.dart';
import '../presentation/widgets/ios/ios_segmented_control.dart';
import '../services/performance_optimization_service.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  int _selectedSegment = 0;
  String _searchQuery = '';
  
  final List<String> _categories = ['All', 'Popular', 'New', 'Featured'];
  
  final List<Map<String, dynamic>> _discoveryItems = [
    {
      'title': 'Stock Tracker',
      'creator': 'John Doe',
      'likes': 234,
      'icon': CupertinoIcons.chart_bar_alt_fill,
      'color': CupertinoColors.systemGreen,
    },
    {
      'title': 'Fitness Goals',
      'creator': 'Jane Smith',
      'likes': 189,
      'icon': CupertinoIcons.heart_fill,
      'color': CupertinoColors.systemRed,
    },
    {
      'title': 'Task Manager',
      'creator': 'Alex Johnson',
      'likes': 567,
      'icon': CupertinoIcons.checkmark_square_fill,
      'color': CupertinoColors.systemBlue,
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Discover'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.line_horizontal_3_decrease),
              onPressed: () {
                HapticFeedback.lightImpact();
                _showFilterSheet();
              },
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  IOSSearchBar(
                    placeholder: 'Search widgets...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  IOSSegmentedControl(
                    options: _categories,
                    selectedIndex: _selectedSegment,
                    onChanged: (index) {
                      if (index != null) {
                        setState(() {
                          _selectedSegment = index;
                        });
                        HapticFeedback.lightImpact();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _discoveryItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoTheme.of(context).barBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Get.toNamed('/widget-view', arguments: item);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: item['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item['icon'],
                                  color: item['color'],
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'by ${item['creator']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  const Icon(
                                    CupertinoIcons.heart_fill,
                                    color: CupertinoColors.systemRed,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item['likes']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _discoveryItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFilterSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Filter Options'),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Most Popular'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Most Recent'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Highest Rated'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}