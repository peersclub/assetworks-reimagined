import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  
  final _storage = GetStorage();
  final _key = 'isDarkMode';
  
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;
  
  ThemeMode get theme => _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  
  @override
  void onInit() {
    super.onInit();
    _isDarkMode.value = _storage.read(_key) ?? false;
  }
  
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _storage.write(_key, _isDarkMode.value);
    Get.changeThemeMode(theme);
  }
  
  void setDarkMode(bool value) {
    _isDarkMode.value = value;
    _storage.write(_key, value);
    Get.changeThemeMode(theme);
  }
}