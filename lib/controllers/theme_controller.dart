import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:get/get.dart';
import '../core/services/storage_service.dart';
import '../core/theme/ios_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  
  final StorageService _storage = Get.find<StorageService>();
  
  // Observable theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;
  
  // Current theme data
  CupertinoThemeData get currentTheme {
    switch (_themeMode.value) {
      case ThemeMode.dark:
        return iOS18Theme.darkTheme;
      case ThemeMode.light:
        return iOS18Theme.lightTheme;
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.window.platformBrightness;
        return brightness == Brightness.dark 
            ? iOS18Theme.darkTheme 
            : iOS18Theme.lightTheme;
    }
  }
  
  // Check if dark mode is active
  bool get isDarkMode {
    switch (_themeMode.value) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.window.platformBrightness;
        return brightness == Brightness.dark;
    }
  }
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }
  
  // Load saved theme preference
  void _loadThemeMode() {
    final savedTheme = _storage.getTheme();
    switch (savedTheme) {
      case 'dark':
        _themeMode.value = ThemeMode.dark;
        break;
      case 'light':
        _themeMode.value = ThemeMode.light;
        break;
      default:
        _themeMode.value = ThemeMode.system;
    }
  }
  
  // Set theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    
    // Save preference
    String themeString;
    switch (mode) {
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    
    _storage.saveTheme(themeString);
    
    // Force rebuild to apply theme changes
    Get.forceAppUpdate();
  }
  
  // Toggle between light and dark
  void toggleTheme() {
    if (isDarkMode) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
  
  // Set to system theme
  void useSystemTheme() {
    setThemeMode(ThemeMode.system);
  }
}