import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class StorageService extends GetxService {
  late GetStorage _box;
  late FlutterSecureStorage _secureStorage;
  
  @override
  void onInit() {
    super.onInit();
    _box = GetStorage();
    _secureStorage = const FlutterSecureStorage();
  }
  
  // ============== Auth Storage ==============
  
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: ApiConstants.keyAuthToken, value: token);
  }
  
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: ApiConstants.keyAuthToken);
  }
  
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: ApiConstants.keyRefreshToken, value: token);
  }
  
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: ApiConstants.keyRefreshToken);
  }
  
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _box.write(ApiConstants.keyUser, jsonEncode(user));
  }
  
  Map<String, dynamic>? getUser() {
    final userString = _box.read(ApiConstants.keyUser);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }
  
  Future<void> clearAuth() async {
    await _secureStorage.delete(key: ApiConstants.keyAuthToken);
    await _secureStorage.delete(key: ApiConstants.keyRefreshToken);
    await _box.remove(ApiConstants.keyUser);
  }
  
  bool get isAuthenticated {
    return getUser() != null;
  }
  
  // ============== Device Storage ==============
  
  Future<void> saveDeviceId(String deviceId) async {
    await _box.write(ApiConstants.keyDeviceId, deviceId);
  }
  
  Future<String> getDeviceId() async {
    String? deviceId = _box.read(ApiConstants.keyDeviceId);
    if (deviceId == null) {
      // Generate new device ID
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await saveDeviceId(deviceId);
    }
    return deviceId;
  }
  
  // ============== Settings Storage ==============
  
  Future<void> saveTheme(String theme) async {
    await _box.write(ApiConstants.keyTheme, theme);
  }
  
  String getTheme() {
    return _box.read(ApiConstants.keyTheme) ?? 'system';
  }
  
  Future<void> saveLanguage(String language) async {
    await _box.write(ApiConstants.keyLanguage, language);
  }
  
  String getLanguage() {
    return _box.read(ApiConstants.keyLanguage) ?? 'en';
  }
  
  Future<void> saveBiometricEnabled(bool enabled) async {
    await _box.write(ApiConstants.keyBiometricEnabled, enabled);
  }
  
  bool getBiometricEnabled() {
    return _box.read(ApiConstants.keyBiometricEnabled) ?? false;
  }
  
  Future<void> setBiometricEnabled(bool enabled) async {
    await saveBiometricEnabled(enabled);
  }
  
  Future<bool?> getBiometricEnabledAsync() async {
    return getBiometricEnabled();
  }
  
  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    await _box.write(ApiConstants.keyNotificationSettings, jsonEncode(settings));
  }
  
  Map<String, dynamic> getNotificationSettings() {
    final settingsString = _box.read(ApiConstants.keyNotificationSettings);
    if (settingsString != null) {
      return jsonDecode(settingsString);
    }
    return {
      'push': true,
      'email': true,
      'sms': false,
      'marketing': false,
      'updates': true,
      'analysis': true,
      'social': true,
    };
  }
  
  // ============== App State Storage ==============
  
  Future<void> setFirstLaunch(bool isFirst) async {
    await _box.write(ApiConstants.keyFirstLaunch, isFirst);
  }
  
  bool isFirstLaunch() {
    return _box.read(ApiConstants.keyFirstLaunch) ?? true;
  }
  
  // ============== Onboarding Storage ==============
  
  Future<void> saveOnboardingComplete(bool completed) async {
    await _box.write('onboarding_completed', completed);
  }
  
  bool isOnboardingComplete() {
    return _box.read('onboarding_completed') ?? false;
  }
  
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await _box.write('user_preferences', jsonEncode(preferences));
  }
  
  Map<String, dynamic> getUserPreferences() {
    final prefsString = _box.read('user_preferences');
    if (prefsString != null) {
      return jsonDecode(prefsString);
    }
    return {};
  }
  
  // ============== Cache Storage ==============
  
  Future<void> saveCache(String key, dynamic data, {Duration? validFor}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'validFor': validFor?.inMilliseconds ?? ApiConstants.cacheValidDuration.inMilliseconds,
    };
    await _box.write('cache_$key', jsonEncode(cacheData));
  }
  
  dynamic getCache(String key) {
    final cacheString = _box.read('cache_$key');
    if (cacheString != null) {
      final cacheData = jsonDecode(cacheString);
      final timestamp = cacheData['timestamp'];
      final validFor = cacheData['validFor'];
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (now - timestamp < validFor) {
        return cacheData['data'];
      } else {
        // Cache expired, remove it
        _box.remove('cache_$key');
      }
    }
    return null;
  }
  
  Future<void> clearCache() async {
    final keys = _box.getKeys().where((key) => key.toString().startsWith('cache_'));
    for (final key in keys) {
      await _box.remove(key);
    }
  }
  
  // ============== Recent Searches ==============
  
  Future<void> saveRecentSearch(String query) async {
    List<String> searches = getRecentSearches();
    searches.remove(query); // Remove if exists
    searches.insert(0, query); // Add to beginning
    if (searches.length > 10) {
      searches = searches.sublist(0, 10); // Keep only 10 recent
    }
    await _box.write('recent_searches', searches);
  }
  
  List<String> getRecentSearches() {
    return List<String>.from(_box.read('recent_searches') ?? []);
  }
  
  Future<void> clearRecentSearches() async {
    await _box.remove('recent_searches');
  }
  
  // ============== Saved Filters ==============
  
  Future<void> saveFilter(String name, Map<String, dynamic> filter) async {
    Map<String, dynamic> filters = getSavedFilters();
    filters[name] = filter;
    await _box.write('saved_filters', jsonEncode(filters));
  }
  
  Map<String, dynamic> getSavedFilters() {
    final filtersString = _box.read('saved_filters');
    if (filtersString != null) {
      return jsonDecode(filtersString);
    }
    return {};
  }
  
  Future<void> removeFilter(String name) async {
    Map<String, dynamic> filters = getSavedFilters();
    filters.remove(name);
    await _box.write('saved_filters', jsonEncode(filters));
  }
  
  // ============== Draft Storage ==============
  
  Future<void> saveDraft(String key, Map<String, dynamic> draft) async {
    await _box.write('draft_$key', jsonEncode(draft));
  }
  
  Map<String, dynamic>? getDraft(String key) {
    final draftString = _box.read('draft_$key');
    if (draftString != null) {
      return jsonDecode(draftString);
    }
    return null;
  }
  
  Future<void> removeDraft(String key) async {
    await _box.remove('draft_$key');
  }
  
  // ============== General Storage ==============
  
  Future<void> save(String key, dynamic value) async {
    await _box.write(key, value);
  }
  
  T? get<T>(String key) {
    return _box.read<T>(key);
  }
  
  Future<void> remove(String key) async {
    await _box.remove(key);
  }
  
  Future<void> clearAll() async {
    await _box.erase();
    await _secureStorage.deleteAll();
  }
  
  // ============== Biometric Credentials ==============
  
  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: 'biometric_email', value: email);
    await _secureStorage.write(key: 'biometric_password', value: password);
  }
  
  Future<String?> getStoredEmail() async {
    return await _secureStorage.read(key: 'biometric_email');
  }
  
  Future<String?> getStoredPassword() async {
    return await _secureStorage.read(key: 'biometric_password');
  }
  
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: 'biometric_email');
    await _secureStorage.delete(key: 'biometric_password');
  }
}