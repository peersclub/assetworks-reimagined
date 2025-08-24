import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../services/api_service.dart';
import '../core/services/storage_service.dart';
import '../services/dynamic_island_service.dart';
import '../screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Settings State
  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _widgetUpdates = true;
  bool _newFollowers = true;
  bool _directMessages = true;
  bool _marketingEmails = false;
  bool _biometricEnabled = false;
  bool _analyticsEnabled = true;
  bool _crashReporting = true;
  bool _locationTracking = false;
  bool _autoPlayVideos = true;
  bool _reducedMotion = false;
  String _language = 'English';
  String _currency = 'USD';
  String _dataUsage = 'WiFi Only';
  
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  
  // Account info
  String _email = '';
  String _username = '';
  String _plan = 'Pro';
  String _storageUsed = '0 MB';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBiometricAvailability();
  }
  
  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported;
      });
      
      if (_isBiometricAvailable) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        print('Available biometrics: $availableBiometrics');
      }
    } catch (e) {
      print('Biometric check error: $e');
      setState(() => _isBiometricAvailable = false);
    }
  }
  
  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // Load settings from API
      final response = await _apiService.getUserSettings();
      
      // Load from local storage as fallback
      final localSettings = await _storageService.getSettings();
      
      setState(() {
        // API settings
        _darkMode = response['dark_mode'] ?? localSettings['dark_mode'] ?? false;
        _pushNotifications = response['push_notifications'] ?? localSettings['push_notifications'] ?? true;
        _emailNotifications = response['email_notifications'] ?? localSettings['email_notifications'] ?? true;
        _widgetUpdates = response['widget_updates'] ?? localSettings['widget_updates'] ?? true;
        _newFollowers = response['new_followers'] ?? localSettings['new_followers'] ?? true;
        _directMessages = response['direct_messages'] ?? localSettings['direct_messages'] ?? true;
        _marketingEmails = response['marketing_emails'] ?? localSettings['marketing_emails'] ?? false;
        _biometricEnabled = response['biometric_enabled'] ?? localSettings['biometric_enabled'] ?? false;
        _analyticsEnabled = response['analytics_enabled'] ?? localSettings['analytics_enabled'] ?? true;
        _crashReporting = response['crash_reporting'] ?? localSettings['crash_reporting'] ?? true;
        _locationTracking = response['location_tracking'] ?? localSettings['location_tracking'] ?? false;
        _autoPlayVideos = response['auto_play_videos'] ?? localSettings['auto_play_videos'] ?? true;
        _reducedMotion = response['reduced_motion'] ?? localSettings['reduced_motion'] ?? false;
        _language = response['language'] ?? localSettings['language'] ?? 'English';
        _currency = response['currency'] ?? localSettings['currency'] ?? 'USD';
        _dataUsage = response['data_usage'] ?? localSettings['data_usage'] ?? 'WiFi Only';
        
        // User info
        _email = response['email'] ?? _storageService.getUserEmail() ?? '';
        _username = response['username'] ?? _storageService.getUsername() ?? '';
        _plan = response['plan'] ?? 'Pro';
        _storageUsed = response['storage_used'] ?? '0 MB';
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading settings: $e');
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      // Update on API
      await _apiService.updateUserSettings({key: value});
      
      // Update local storage
      await _storageService.saveSetting(key, value);
      
      DynamicIslandService().updateStatus(
        'Settings updated',
        icon: CupertinoIcons.checkmark_circle_fill,
      );
    } catch (e) {
      print('Error updating setting: $e');
      _showError('Failed to update setting');
    }
  }
  
  Future<void> _toggleBiometric(bool value) async {
    if (value && _isBiometricAvailable) {
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Enable biometric authentication for AssetWorks',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        
        if (authenticated) {
          setState(() => _biometricEnabled = true);
          await _updateSetting('biometric_enabled', true);
        }
      } catch (e) {
        print('Biometric authentication error: $e');
        _showError('Failed to enable biometric authentication');
      }
    } else {
      setState(() => _biometricEnabled = false);
      await _updateSetting('biometric_enabled', false);
    }
  }
  
  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  Future<void> _clearCache() async {
    HapticFeedback.heavyImpact();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data and images. Continue?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear'),
            onPressed: () async {
              Navigator.pop(context);
              await _storageService.clearCache();
              DynamicIslandService().updateStatus(
                'Cache cleared',
                icon: CupertinoIcons.trash_fill,
              );
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteAccount() async {
    HapticFeedback.heavyImpact();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.pop(context);
              
              // Confirm with biometric if available
              if (_biometricEnabled && _isBiometricAvailable) {
                final authenticated = await _localAuth.authenticate(
                  localizedReason: 'Confirm account deletion',
                );
                
                if (!authenticated) return;
              }
              
              // Delete account via API
              final success = await _apiService.deleteUserAccount();
              if (success) {
                await _storageService.clearAll();
                Get.offAll(() => const LoginScreen());
              }
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  Future<void> _logout() async {
    HapticFeedback.mediumImpact();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Logout'),
            onPressed: () async {
              Navigator.pop(context);
              await _apiService.logout();
              await _storageService.clearUserData();
              Get.offAll(() => const LoginScreen());
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground.withOpacity(0.94),
        border: null,
        middle: const Text('Settings'),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: ListView(
                children: [
                  // Account Section
                  CupertinoListSection.insetGrouped(
                    header: const Text('ACCOUNT'),
                    children: [
                      CupertinoListTile.notched(
                        title: const Text('Username'),
                        additionalInfo: Text(_username),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Email'),
                        additionalInfo: Text(_email),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Subscription'),
                        additionalInfo: Text(_plan),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          // Navigate to subscription management
                        },
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Storage Used'),
                        additionalInfo: Text(_storageUsed),
                      ),
                    ],
                  ),
                  
                  // Appearance Section
                  CupertinoListSection.insetGrouped(
                    header: const Text('APPEARANCE'),
                    children: [
                      CupertinoListTile.notched(
                        title: const Text('Dark Mode'),
                        trailing: CupertinoSwitch(
                          value: _darkMode,
                          onChanged: (value) {
                            setState(() => _darkMode = value);
                            _updateSetting('dark_mode', value);
                            // Apply theme change
                            Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                          },
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Reduce Motion'),
                        trailing: CupertinoSwitch(
                          value: _reducedMotion,
                          onChanged: (value) {
                            setState(() => _reducedMotion = value);
                            _updateSetting('reduced_motion', value);
                          },
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Auto-Play Videos'),
                        trailing: CupertinoSwitch(
                          value: _autoPlayVideos,
                          onChanged: (value) {
                            setState(() => _autoPlayVideos = value);
                            _updateSetting('auto_play_videos', value);
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Notifications Section
                  CupertinoListSection.insetGrouped(
                    header: const Text('NOTIFICATIONS'),
                    children: [
                      CupertinoListTile.notched(
                        title: const Text('Push Notifications'),
                        trailing: CupertinoSwitch(
                          value: _pushNotifications,
                          onChanged: (value) {
                            setState(() => _pushNotifications = value);
                            _updateSetting('push_notifications', value);
                          },
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Email Notifications'),
                        trailing: CupertinoSwitch(
                          value: _emailNotifications,
                          onChanged: (value) {
                            setState(() => _emailNotifications = value);
                            _updateSetting('email_notifications', value);
                          },
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Widget Updates'),
                        trailing: CupertinoSwitch(
                          value: _widgetUpdates,
                          onChanged: (value) {
                            setState(() => _widgetUpdates = value);
                            _updateSetting('widget_updates', value);
                          },
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('New Followers'),
                        trailing: CupertinoSwitch(
                          value: _newFollowers,
                          onChanged: (value) {
                            setState(() => _newFollowers = value);
                            _updateSetting('new_followers', value);
                          },
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Direct Messages'),
                        trailing: CupertinoSwitch(
                          value: _directMessages,
                          onChanged: (value) {
                            setState(() => _directMessages = value);
                            _updateSetting('direct_messages', value);
                          },
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Marketing Emails'),
                        trailing: CupertinoSwitch(
                          value: _marketingEmails,
                          onChanged: (value) {
                            setState(() => _marketingEmails = value);
                            _updateSetting('marketing_emails', value);
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Privacy & Security Section
                  CupertinoListSection.insetGrouped(
                    header: const Text('PRIVACY & SECURITY'),
                    children: [
                      if (_isBiometricAvailable)
                        CupertinoListTile.notched(
                          title: const Text('Biometric Authentication'),
                          leading: Icon(
                            CupertinoIcons.lock_shield_fill,
                            color: _biometricEnabled 
                                ? CupertinoColors.systemGreen 
                                : CupertinoColors.systemGrey,
                          ),
                          trailing: CupertinoSwitch(
                            value: _biometricEnabled,
                            onChanged: _toggleBiometric,
                          ),
                        ),
                      CupertinoListTile.notched(
                        title: const Text('Analytics'),
                        trailing: CupertinoSwitch(
                          value: _analyticsEnabled,
                          onChanged: (value) {
                            setState(() => _analyticsEnabled = value);
                            _updateSetting('analytics_enabled', value);
                          },
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Crash Reporting'),
                        trailing: CupertinoSwitch(
                          value: _crashReporting,
                          onChanged: (value) {
                            setState(() => _crashReporting = value);
                            _updateSetting('crash_reporting', value);
                          },
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Location Tracking'),
                        trailing: CupertinoSwitch(
                          value: _locationTracking,
                          onChanged: (value) {
                            setState(() => _locationTracking = value);
                            _updateSetting('location_tracking', value);
                          },
                        ),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          // Open privacy policy
                        },
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Terms of Service'),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          // Open terms
                        },
                      ),
                    ],
                  ),
                  
                  // Preferences Section
                  CupertinoListSection.insetGrouped(
                    header: const Text('PREFERENCES'),
                    children: [
                      CupertinoListTile.notched(
                        title: const Text('Language'),
                        additionalInfo: Text(_language),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () => _showLanguagePicker(),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Currency'),
                        additionalInfo: Text(_currency),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () => _showCurrencyPicker(),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Data Usage'),
                        additionalInfo: Text(_dataUsage),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () => _showDataUsagePicker(),
                      ),
                    ],
                  ),
                  
                  // Support Section
                  CupertinoListSection.insetGrouped(
                    header: const Text('SUPPORT'),
                    children: [
                      CupertinoListTile.notched(
                        title: const Text('Help Center'),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          // Open help center
                        },
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Contact Support'),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          // Open support
                        },
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Report a Bug'),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          // Open bug report
                        },
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Feature Request'),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          // Open feature request
                        },
                      ),
                    ],
                  ),
                  
                  // About Section
                  CupertinoListSection.insetGrouped(
                    header: const Text('ABOUT'),
                    children: [
                      CupertinoListTile.notched(
                        title: const Text('Version'),
                        additionalInfo: const Text('1.0.0 (4)'),
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Licenses'),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          // Show licenses
                        },
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Rate Us'),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          // Open App Store
                        },
                      ),
                    ],
                  ),
                  
                  // Danger Zone
                  CupertinoListSection.insetGrouped(
                    header: const Text('DANGER ZONE'),
                    children: [
                      CupertinoListTile.notched(
                        title: const Text('Clear Cache'),
                        leading: const Icon(
                          CupertinoIcons.trash,
                          color: CupertinoColors.systemOrange,
                        ),
                        onTap: _clearCache,
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Logout'),
                        leading: const Icon(
                          CupertinoIcons.square_arrow_left,
                          color: CupertinoColors.systemOrange,
                        ),
                        onTap: _logout,
                      ),
                      CupertinoListTile.notched(
                        title: const Text('Delete Account'),
                        leading: const Icon(
                          CupertinoIcons.delete_solid,
                          color: CupertinoColors.systemRed,
                        ),
                        onTap: _deleteAccount,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }
  
  void _showLanguagePicker() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'];
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: CupertinoPicker(
          itemExtent: 32,
          onSelectedItemChanged: (index) {
            setState(() => _language = languages[index]);
            _updateSetting('language', languages[index]);
          },
          children: languages.map((lang) => Text(lang)).toList(),
        ),
      ),
    );
  }
  
  void _showCurrencyPicker() {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR'];
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: CupertinoPicker(
          itemExtent: 32,
          onSelectedItemChanged: (index) {
            setState(() => _currency = currencies[index]);
            _updateSetting('currency', currencies[index]);
          },
          children: currencies.map((curr) => Text(curr)).toList(),
        ),
      ),
    );
  }
  
  void _showDataUsagePicker() {
    final options = ['WiFi Only', 'WiFi + Cellular', 'Unlimited'];
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: CupertinoPicker(
          itemExtent: 32,
          onSelectedItemChanged: (index) {
            setState(() => _dataUsage = options[index]);
            _updateSetting('data_usage', options[index]);
          },
          children: options.map((opt) => Text(opt)).toList(),
        ),
      ),
    );
  }
}