import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/dynamic_island_service.dart';

class WidgetViewScreen extends StatelessWidget {
  const WidgetViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? widget = Get.arguments;
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget?['title'] ?? 'Widget Details'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.share),
          onPressed: () {
            HapticFeedback.lightImpact();
            _showShareSheet(context);
          },
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Widget Preview
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: (widget?['color'] ?? CupertinoColors.systemBlue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (widget?['color'] ?? CupertinoColors.systemBlue).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget?['icon'] ?? CupertinoIcons.cube_box,
                      size: 60,
                      color: widget?['color'] ?? CupertinoColors.systemBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget?['title'] ?? 'Widget',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget?['description'] ?? 'No description',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Creator Info
              if (widget?['creator'] != null) ...[
                const Text(
                  'Created by',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.person_fill,
                        size: 20,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget!['creator'],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              
              // Actions
              CupertinoButton.filled(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _installWidget(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.add_circled),
                    SizedBox(width: 8),
                    Text('Add to Home Screen'),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              CupertinoButton(
                color: CupertinoColors.systemGrey5,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.toNamed('/widget-remix', arguments: widget);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.wand_stars,
                      color: CupertinoColors.label,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Remix Widget',
                      style: TextStyle(color: CupertinoColors.label),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    icon: CupertinoIcons.heart_fill,
                    value: widget?['likes']?.toString() ?? '0',
                    label: 'Likes',
                    color: CupertinoColors.systemRed,
                  ),
                  _buildStat(
                    icon: CupertinoIcons.eye_fill,
                    value: '1.2k',
                    label: 'Views',
                    color: CupertinoColors.systemBlue,
                  ),
                  _buildStat(
                    icon: CupertinoIcons.arrow_down_circle_fill,
                    value: '89',
                    label: 'Installs',
                    color: CupertinoColors.systemGreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
  
  void _installWidget(BuildContext context) {
    DynamicIslandService().updateStatus(
      'Installing Widget...',
      icon: CupertinoIcons.cloud_download,
    );
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Widget Added'),
        content: const Text('The widget has been added to your home screen.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              DynamicIslandService().updateStatus(
                'Widget Installed!',
                icon: CupertinoIcons.checkmark_circle_fill,
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showShareSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Share via Messages'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Copy Link'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Share to Social'),
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