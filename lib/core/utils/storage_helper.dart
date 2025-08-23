import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class StorageHelper {
  static final _box = GetStorage();
  
  // Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';
  static const String biometricKey = 'biometric_enabled';
  static const String languageKey = 'app_language';
  static const String notificationsKey = 'notifications_enabled';
  
  // Auth methods
  static Future<void> saveToken(String token) async {
    await _box.write(tokenKey, token);
  }
  
  static String? getToken() {
    return _box.read(tokenKey);
  }
  
  static Future<void> removeToken() async {
    await _box.remove(tokenKey);
  }
  
  // User methods
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _box.write(userKey, jsonEncode(user));
  }
  
  static Map<String, dynamic>? getUser() {
    final userString = _box.read(userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }
  
  static Future<void> removeUser() async {
    await _box.remove(userKey);
  }
  
  // Generic methods
  static Future<void> save(String key, dynamic value) async {
    await _box.write(key, value);
  }
  
  static T? get<T>(String key) {
    return _box.read<T>(key);
  }
  
  static Future<void> remove(String key) async {
    await _box.remove(key);
  }
  
  static Future<void> clearAll() async {
    await _box.erase();
  }
  
  // List methods
  static Future<void> saveList(String key, List<dynamic> list) async {
    await _box.write(key, jsonEncode(list));
  }
  
  static List<dynamic>? getList(String key) {
    final listString = _box.read(key);
    if (listString != null) {
      return jsonDecode(listString);
    }
    return null;
  }
  
  // Bool methods
  static Future<void> setBool(String key, bool value) async {
    await _box.write(key, value);
  }
  
  static bool getBool(String key, {bool defaultValue = false}) {
    return _box.read(key) ?? defaultValue;
  }
  
  // Check if key exists
  static bool hasKey(String key) {
    return _box.hasData(key);
  }
  
  // Onboarding
  static bool get isOnboardingCompleted {
    return getBool(onboardingKey);
  }
  
  static Future<void> setOnboardingCompleted(bool value) async {
    await setBool(onboardingKey, value);
  }
  
  // Biometric
  static bool get isBiometricEnabled {
    return getBool(biometricKey);
  }
  
  static Future<void> setBiometricEnabled(bool value) async {
    await setBool(biometricKey, value);
  }
  
  // Notifications
  static bool get areNotificationsEnabled {
    return getBool(notificationsKey, defaultValue: true);
  }
  
  static Future<void> setNotificationsEnabled(bool value) async {
    await setBool(notificationsKey, value);
  }
}