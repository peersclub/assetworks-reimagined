import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../core/theme/ios_theme.dart';
import '../../../controllers/settings_controller.dart';

class iOSSettingsScreen extends StatefulWidget {
  const iOSSettingsScreen({Key? key}) : super(key: key);

  @override
  State<iOSSettingsScreen> createState() => _iOSSettingsScreenState();
}

class _iOSSettingsScreenState extends State<iOSSettingsScreen> {
  final SettingsController _controller = Get.find<SettingsController>();
  final ScrollController _scrollController = ScrollController();
  
  // Settings state
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoRefresh = true;
  bool _faceIdEnabled = true;
  bool _analyticsEnabled = false;
  double _refreshInterval = 5.0;
  String _selectedCurrency = 'USD';
  String _selectedLanguage = 'English';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load saved settings
    setState(() {
      _notificationsEnabled = _controller.notificationsEnabled.value;
      _darkModeEnabled = _controller.darkModeEnabled.value;
      _autoRefresh = _controller.autoRefresh.value;
      _faceIdEnabled = _controller.faceIdEnabled.value;
      _analyticsEnabled = _controller.analyticsEnabled.value;
      _refreshInterval = _controller.refreshInterval.value.toDouble();
      _selectedCurrency = _controller.currency.value;
      _selectedLanguage = _controller.language.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = 
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.systemBackground.resolveFrom(context).withOpacity(0.94),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.arrow_left,
            color: iOS18Theme.label.resolveFrom(context),
          ),
        ),
        middle: const Text('Settings'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Profile section
              _buildProfileSection(),
              
              // Account settings
              _buildSectionHeader('ACCOUNT'),
              _buildSettingsGroup([
                _buildNavigationItem(
                  icon: CupertinoIcons.person_circle,
                  title: 'Edit Profile',
                  onTap: () => Get.toNamed('/profile/edit'),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.envelope,
                  title: 'Email',
                  value: 'john.doe@example.com',
                  onTap: () => _showEmailSettings(),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.phone,
                  title: 'Phone',
                  value: '+1 234 567 8900',
                  onTap: () => _showPhoneSettings(),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.lock,
                  title: 'Change Password',
                  onTap: () => Get.toNamed('/settings/password'),
                ),
              ]),
              
              // App settings
              _buildSectionHeader('APP SETTINGS'),
              _buildSettingsGroup([
                _buildSwitchItem(
                  icon: CupertinoIcons.bell,
                  title: 'Notifications',
                  subtitle: 'Push notifications for updates',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    _controller.setNotifications(value);
                    if (value) {
                      Get.toNamed('/settings/notifications');
                    }
                  },
                ),
                _buildSwitchItem(
                  icon: CupertinoIcons.moon,
                  title: 'Dark Mode',
                  subtitle: 'Use dark theme',
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() => _darkModeEnabled = value);
                    _controller.setDarkMode(value);
                    iOS18Theme.lightImpact();
                  },
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.globe,
                  title: 'Language',
                  value: _selectedLanguage,
                  onTap: () => _showLanguagePicker(),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.money_dollar_circle,
                  title: 'Currency',
                  value: _selectedCurrency,
                  onTap: () => _showCurrencyPicker(),
                ),
              ]),
              
              // Widget settings
              _buildSectionHeader('WIDGET SETTINGS'),
              _buildSettingsGroup([
                _buildSwitchItem(
                  icon: CupertinoIcons.refresh,
                  title: 'Auto Refresh',
                  subtitle: 'Automatically update widget data',
                  value: _autoRefresh,
                  onChanged: (value) {
                    setState(() => _autoRefresh = value);
                    _controller.setAutoRefresh(value);
                  },
                ),
                if (_autoRefresh)
                  _buildSliderItem(
                    icon: CupertinoIcons.timer,
                    title: 'Refresh Interval',
                    subtitle: '${_refreshInterval.toInt()} minutes',
                    value: _refreshInterval,
                    min: 1,
                    max: 60,
                    onChanged: (value) {
                      setState(() => _refreshInterval = value);
                      _controller.setRefreshInterval(value.toInt());
                    },
                  ),
                _buildNavigationItem(
                  icon: CupertinoIcons.chart_bar,
                  title: 'Default Chart Type',
                  value: 'Line',
                  onTap: () => _showChartTypePicker(),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.paintbrush,
                  title: 'Widget Themes',
                  onTap: () => Get.toNamed('/settings/themes'),
                ),
              ]),
              
              // Security settings
              _buildSectionHeader('SECURITY'),
              _buildSettingsGroup([
                _buildSwitchItem(
                  icon: CupertinoIcons.faceid,
                  title: 'Face ID',
                  subtitle: 'Use Face ID to unlock app',
                  value: _faceIdEnabled,
                  onChanged: (value) {
                    setState(() => _faceIdEnabled = value);
                    _controller.setFaceId(value);
                    if (value) {
                      _authenticateBiometric();
                    }
                  },
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.shield,
                  title: 'Two-Factor Authentication',
                  value: 'Enabled',
                  onTap: () => Get.toNamed('/settings/2fa'),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.eye_slash,
                  title: 'Privacy',
                  onTap: () => Get.toNamed('/settings/privacy'),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.list_bullet,
                  title: 'Login Activity',
                  onTap: () => Get.toNamed('/settings/activity'),
                ),
              ]),
              
              // Data & Storage
              _buildSectionHeader('DATA & STORAGE'),
              _buildSettingsGroup([
                _buildNavigationItem(
                  icon: CupertinoIcons.cloud_download,
                  title: 'Export Data',
                  onTap: () => _showExportOptions(),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.trash,
                  title: 'Clear Cache',
                  value: '124 MB',
                  onTap: () => _showClearCacheDialog(),
                ),
                _buildSwitchItem(
                  icon: CupertinoIcons.chart_line,
                  title: 'Analytics',
                  subtitle: 'Share usage data to improve app',
                  value: _analyticsEnabled,
                  onChanged: (value) {
                    setState(() => _analyticsEnabled = value);
                    _controller.setAnalytics(value);
                  },
                ),
              ]),
              
              // Support
              _buildSectionHeader('SUPPORT'),
              _buildSettingsGroup([
                _buildNavigationItem(
                  icon: CupertinoIcons.question_circle,
                  title: 'Help Center',
                  onTap: () => Get.toNamed('/help'),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.chat_bubble_2,
                  title: 'Contact Support',
                  onTap: () => Get.toNamed('/support'),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.star,
                  title: 'Rate App',
                  onTap: () => _rateApp(),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.share,
                  title: 'Share App',
                  onTap: () => _shareApp(),
                ),
              ]),
              
              // Legal
              _buildSectionHeader('LEGAL'),
              _buildSettingsGroup([
                _buildNavigationItem(
                  icon: CupertinoIcons.doc_text,
                  title: 'Terms of Service',
                  onTap: () => Get.toNamed('/terms'),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.lock_shield,
                  title: 'Privacy Policy',
                  onTap: () => Get.toNamed('/privacy'),
                ),
                _buildNavigationItem(
                  icon: CupertinoIcons.info_circle,
                  title: 'About',
                  onTap: () => Get.toNamed('/about'),
                ),
              ]),
              
              // App info
              _buildAppInfo(),
              
              // Sign out button
              _buildSignOutButton(),
              
              const SizedBox(height: iOS18Theme.spacing32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return GestureDetector(
      onTap: () {
        iOS18Theme.lightImpact();
        Get.toNamed('/profile');
      },
      child: Container(
        margin: const EdgeInsets.all(iOS18Theme.spacing16),
        padding: const EdgeInsets.all(iOS18Theme.spacing16),
        decoration: BoxDecoration(
          color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iOS18Theme.systemGray5.resolveFrom(context),
              ),
              child: Icon(
                CupertinoIcons.person_fill,
                size: 30,
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
              ),
            ),
            const SizedBox(width: iOS18Theme.spacing16),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: iOS18Theme.headline.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'john.doe@example.com',
                    style: iOS18Theme.footnote.copyWith(
                      color: iOS18Theme.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: iOS18Theme.spacing4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: iOS18Theme.spacing8,
                      vertical: iOS18Theme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: iOS18Theme.systemGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
                    ),
                    child: Text(
                      'Premium',
                      style: iOS18Theme.caption2.copyWith(
                        color: iOS18Theme.systemGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 20,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(
        left: iOS18Theme.spacing16,
        right: iOS18Theme.spacing16,
        top: iOS18Theme.spacing20,
        bottom: iOS18Theme.spacing8,
      ),
      child: Text(
        title,
        style: iOS18Theme.caption1.copyWith(
          color: iOS18Theme.secondaryLabel.resolveFrom(context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(iOS18Theme.largeRadius),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          
          return Column(
            children: [
              item,
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: Container(
                    height: 0.5,
                    color: iOS18Theme.separator.resolveFrom(context),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        iOS18Theme.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(iOS18Theme.spacing12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iOS18Theme.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iOS18Theme.systemBlue,
              ),
            ),
            const SizedBox(width: iOS18Theme.spacing12),
            Expanded(
              child: Text(
                title,
                style: iOS18Theme.body.copyWith(
                  color: iOS18Theme.label.resolveFrom(context),
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value,
                style: iOS18Theme.body.copyWith(
                  color: iOS18Theme.secondaryLabel.resolveFrom(context),
                ),
              ),
              const SizedBox(width: iOS18Theme.spacing8),
            ],
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(iOS18Theme.spacing12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iOS18Theme.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iOS18Theme.systemBlue,
            ),
          ),
          const SizedBox(width: iOS18Theme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: iOS18Theme.body.copyWith(
                    color: iOS18Theme.label.resolveFrom(context),
                  ),
                ),
                Text(
                  subtitle,
                  style: iOS18Theme.caption1.copyWith(
                    color: iOS18Theme.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: iOS18Theme.systemGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(iOS18Theme.spacing12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iOS18Theme.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(iOS18Theme.smallRadius),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iOS18Theme.systemBlue,
                ),
              ),
              const SizedBox(width: iOS18Theme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: iOS18Theme.body.copyWith(
                        color: iOS18Theme.label.resolveFrom(context),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: iOS18Theme.caption1.copyWith(
                        color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: iOS18Theme.spacing8),
          CupertinoSlider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      margin: const EdgeInsets.all(iOS18Theme.spacing16),
      child: Column(
        children: [
          Text(
            'AssetWorks',
            style: iOS18Theme.headline.copyWith(
              color: iOS18Theme.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: iOS18Theme.spacing4),
          Text(
            'Version 1.0.0 (Build 100)',
            style: iOS18Theme.caption1.copyWith(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
      child: CupertinoButton(
        color: iOS18Theme.systemRed,
        borderRadius: BorderRadius.circular(iOS18Theme.mediumRadius),
        onPressed: () {
          iOS18Theme.mediumImpact();
          _showSignOutDialog();
        },
        child: const Text(
          'Sign Out',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Sign Out'),
            onPressed: () {
              Navigator.pop(context);
              _controller.signOut();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  void _showEmailSettings() {
    // Show email settings modal
  }

  void _showPhoneSettings() {
    // Show phone settings modal
  }

  void _showLanguagePicker() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'];
    _showPicker(
      title: 'Select Language',
      options: languages,
      selected: _selectedLanguage,
      onSelect: (value) {
        setState(() => _selectedLanguage = value);
        _controller.setLanguage(value);
      },
    );
  }

  void _showCurrencyPicker() {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'AUD', 'CAD'];
    _showPicker(
      title: 'Select Currency',
      options: currencies,
      selected: _selectedCurrency,
      onSelect: (value) {
        setState(() => _selectedCurrency = value);
        _controller.setCurrency(value);
      },
    );
  }

  void _showChartTypePicker() {
    final types = ['Line', 'Candle', 'Bar', 'Area'];
    _showPicker(
      title: 'Default Chart Type',
      options: types,
      selected: 'Line',
      onSelect: (value) {
        // Handle chart type selection
      },
    );
  }

  void _showPicker({
    required String title,
    required List<String> options,
    required String selected,
    required Function(String) onSelect,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 320,
        color: iOS18Theme.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: iOS18Theme.spacing16),
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    title,
                    style: iOS18Theme.headline.copyWith(
                      color: iOS18Theme.label.resolveFrom(context),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  onSelect(options[index]);
                },
                children: options.map((option) {
                  return Center(
                    child: Text(
                      option,
                      style: iOS18Theme.body.copyWith(
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

  void _authenticateBiometric() async {
    // Implement biometric authentication
  }

  void _showExportOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Export Data'),
        message: const Text('Choose export format'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Export as CSV
            },
            child: const Text('Export as CSV'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Export as JSON
            },
            child: const Text('Export as JSON'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Export as PDF
            },
            child: const Text('Export as PDF'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will delete 124 MB of cached data. You may need to re-download some content.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear'),
            onPressed: () {
              Navigator.pop(context);
              _controller.clearCache();
              iOS18Theme.successImpact();
            },
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    // Open app store for rating
  }

  void _shareApp() {
    // Share app link
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}