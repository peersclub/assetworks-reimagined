import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/ios18_theme.dart';
import '../../../../core/services/dynamic_island_service.dart';

class iOSNotificationSettingsScreen extends StatefulWidget {
  const iOSNotificationSettingsScreen({super.key});

  @override
  State<iOSNotificationSettingsScreen> createState() => _iOSNotificationSettingsScreenState();
}

class _iOSNotificationSettingsScreenState extends State<iOSNotificationSettingsScreen> {
  // Master switches
  bool _allowNotifications = true;
  bool _showPreviews = true;
  String _previewStyle = 'whenUnlocked';
  
  // Notification types
  bool _priceAlerts = true;
  bool _portfolioUpdates = true;
  bool _newsAlerts = true;
  bool _marketOpen = true;
  bool _marketClose = true;
  bool _weeklyReport = true;
  bool _monthlyReport = false;
  
  // Alert styles
  bool _soundEnabled = true;
  bool _badgeEnabled = true;
  bool _bannersEnabled = true;
  bool _lockScreenEnabled = true;
  bool _notificationCenterEnabled = true;
  
  // Critical alerts
  bool _criticalAlerts = false;
  
  // Quiet hours
  bool _quietHoursEnabled = false;
  DateTime _quietHoursStart = DateTime(2024, 1, 1, 22, 0);
  DateTime _quietHoursEnd = DateTime(2024, 1, 1, 7, 0);
  
  // Custom sounds
  String _selectedSound = 'default';
  final List<String> _availableSounds = [
    'Default',
    'Bell',
    'Chime',
    'Glass',
    'Horn',
    'Morse',
    'Note',
    'Popcorn',
    'Pulse',
    'Synth',
  ];
  
  void _toggleMasterSwitch(bool value) {
    HapticFeedback.mediumImpact();
    setState(() {
      _allowNotifications = value;
    });
    
    if (!value) {
      DynamicIslandService.showAlert('Notifications disabled');
    } else {
      DynamicIslandService.showSuccess('Notifications enabled');
    }
  }
  
  void _showPreviewStylePicker() {
    HapticFeedback.selectionFeedback();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: iOS18Theme.primaryBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: iOS18Theme.systemBlue),
                    ),
                  ),
                  Text(
                    'Show Previews',
                    style: TextStyle(
                      color: iOS18Theme.label.resolveFrom(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: iOS18Theme.systemBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _previewStyle = ['always', 'whenUnlocked', 'never'][index];
                  });
                },
                children: [
                  Center(child: Text('Always')),
                  Center(child: Text('When Unlocked')),
                  Center(child: Text('Never')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSoundPicker() {
    HapticFeedback.selectionFeedback();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: iOS18Theme.primaryBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: iOS18Theme.systemBlue),
                    ),
                  ),
                  Text(
                    'Notification Sound',
                    style: TextStyle(
                      color: iOS18Theme.label.resolveFrom(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: iOS18Theme.systemBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: _availableSounds.indexWhere(
                    (s) => s.toLowerCase() == _selectedSound.toLowerCase(),
                  ),
                ),
                onSelectedItemChanged: (index) {
                  HapticFeedback.selectionFeedback();
                  setState(() {
                    _selectedSound = _availableSounds[index].toLowerCase();
                  });
                  // Play preview sound
                  SystemSound.play(SystemSoundType.click);
                },
                children: _availableSounds.map((sound) {
                  return Center(
                    child: Text(
                      sound,
                      style: TextStyle(
                        color: iOS18Theme.label.resolveFrom(context),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showQuietHoursTimePicker(bool isStart) {
    HapticFeedback.selectionFeedback();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: iOS18Theme.primaryBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: iOS18Theme.systemBlue),
                    ),
                  ),
                  Text(
                    isStart ? 'Start Time' : 'End Time',
                    style: TextStyle(
                      color: iOS18Theme.label.resolveFrom(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: iOS18Theme.systemBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: isStart ? _quietHoursStart : _quietHoursEnd,
                onDateTimeChanged: (DateTime newTime) {
                  setState(() {
                    if (isStart) {
                      _quietHoursStart = newTime;
                    } else {
                      _quietHoursEnd = newTime;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context).withOpacity(0.8),
        border: null,
        middle: const Text('Notification Settings'),
        previousPageTitle: 'Settings',
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Master control
            SliverToBoxAdapter(
              child: _buildSection(
                null,
                [
                  _buildMasterSwitch(),
                ],
              ),
            ),
            
            // Preview style
            if (_allowNotifications)
              SliverToBoxAdapter(
                child: _buildSection(
                  'PREVIEW',
                  [
                    _buildPreviewStyle(),
                  ],
                ),
              ),
            
            // Alert types
            if (_allowNotifications)
              SliverToBoxAdapter(
                child: _buildSection(
                  'ALERTS',
                  [
                    _buildSwitch('Price Alerts', _priceAlerts, (value) {
                      setState(() => _priceAlerts = value);
                    }),
                    _buildSwitch('Portfolio Updates', _portfolioUpdates, (value) {
                      setState(() => _portfolioUpdates = value);
                    }),
                    _buildSwitch('News Alerts', _newsAlerts, (value) {
                      setState(() => _newsAlerts = value);
                    }),
                    _buildSwitch('Market Open', _marketOpen, (value) {
                      setState(() => _marketOpen = value);
                    }),
                    _buildSwitch('Market Close', _marketClose, (value) {
                      setState(() => _marketClose = value);
                    }),
                  ],
                ),
              ),
            
            // Reports
            if (_allowNotifications)
              SliverToBoxAdapter(
                child: _buildSection(
                  'REPORTS',
                  [
                    _buildSwitch('Weekly Summary', _weeklyReport, (value) {
                      setState(() => _weeklyReport = value);
                    }),
                    _buildSwitch('Monthly Report', _monthlyReport, (value) {
                      setState(() => _monthlyReport = value);
                    }),
                  ],
                ),
              ),
            
            // Alert style
            if (_allowNotifications)
              SliverToBoxAdapter(
                child: _buildSection(
                  'ALERT STYLE',
                  [
                    _buildSwitch('Sounds', _soundEnabled, (value) {
                      setState(() => _soundEnabled = value);
                    }),
                    if (_soundEnabled) _buildSoundSelector(),
                    _buildSwitch('Badges', _badgeEnabled, (value) {
                      setState(() => _badgeEnabled = value);
                    }),
                    _buildSwitch('Banners', _bannersEnabled, (value) {
                      setState(() => _bannersEnabled = value);
                    }),
                    _buildSwitch('Lock Screen', _lockScreenEnabled, (value) {
                      setState(() => _lockScreenEnabled = value);
                    }),
                    _buildSwitch('Notification Center', _notificationCenterEnabled, (value) {
                      setState(() => _notificationCenterEnabled = value);
                    }),
                  ],
                ),
              ),
            
            // Critical alerts
            if (_allowNotifications)
              SliverToBoxAdapter(
                child: _buildSection(
                  'CRITICAL ALERTS',
                  [
                    _buildCriticalAlerts(),
                  ],
                  footer: 'Critical alerts can break through Do Not Disturb and ringer switch settings.',
                ),
              ),
            
            // Quiet hours
            if (_allowNotifications)
              SliverToBoxAdapter(
                child: _buildSection(
                  'QUIET HOURS',
                  [
                    _buildSwitch('Enable Quiet Hours', _quietHoursEnabled, (value) {
                      setState(() => _quietHoursEnabled = value);
                    }),
                    if (_quietHoursEnabled) ...[
                      _buildTimeSelector('Start', _quietHoursStart, true),
                      _buildTimeSelector('End', _quietHoursEnd, false),
                    ],
                  ],
                  footer: _quietHoursEnabled
                      ? 'Notifications will be silenced during quiet hours except for critical alerts.'
                      : null,
                ),
              ),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String? title, List<Widget> children, {String? footer}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8, top: 24),
              child: Text(
                title,
                style: TextStyle(
                  color: iOS18Theme.secondaryLabel.resolveFrom(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: children),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Text(
                footer,
                style: TextStyle(
                  color: iOS18Theme.secondaryLabel.resolveFrom(context),
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMasterSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iOS18Theme.systemRed,
                  iOS18Theme.systemOrange,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.bell_fill,
              color: CupertinoColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allow Notifications',
                  style: TextStyle(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _allowNotifications ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: iOS18Theme.secondaryLabel.resolveFrom(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: _allowNotifications,
            onChanged: _toggleMasterSwitch,
            activeColor: iOS18Theme.systemGreen,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreviewStyle() {
    return GestureDetector(
      onTap: _showPreviewStylePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              'Show Previews',
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              _previewStyle == 'always'
                  ? 'Always'
                  : _previewStyle == 'whenUnlocked'
                      ? 'When Unlocked'
                      : 'Never',
              style: TextStyle(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_right,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: iOS18Theme.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 16,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeColor: iOS18Theme.systemGreen,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSoundSelector() {
    return GestureDetector(
      onTap: _showSoundPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: iOS18Theme.separator.resolveFrom(context),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 32),
            Text(
              'Sound',
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              _selectedSound.substring(0, 1).toUpperCase() + _selectedSound.substring(1),
              style: TextStyle(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_right,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCriticalAlerts() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: iOS18Theme.systemOrange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Critical Alerts',
                  style: TextStyle(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Large price movements only',
                  style: TextStyle(
                    color: iOS18Theme.secondaryLabel.resolveFrom(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: _criticalAlerts,
            onChanged: (value) {
              HapticFeedback.heavyImpact();
              setState(() => _criticalAlerts = value);
            },
            activeColor: iOS18Theme.systemOrange,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeSelector(String label, DateTime time, bool isStart) {
    return GestureDetector(
      onTap: () => _showQuietHoursTimePicker(isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: iOS18Theme.separator.resolveFrom(context),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 32),
            Text(
              label,
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_right,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}