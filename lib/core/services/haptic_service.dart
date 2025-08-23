import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class HapticService {
  static bool _isEnabled = true;
  
  // Enable/disable haptics globally
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  static bool get isEnabled => _isEnabled;
  
  // Light impact - for selections, toggles
  static void lightImpact() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
  }
  
  // Medium impact - for button presses
  static void mediumImpact() {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact();
  }
  
  // Heavy impact - for important actions, errors
  static void heavyImpact() {
    if (!_isEnabled) return;
    HapticFeedback.heavyImpact();
  }
  
  // Selection click - for picker selections
  static void selectionClick() {
    if (!_isEnabled) return;
    HapticFeedback.selectionClick();
  }
  
  // Vibrate - for notifications, alerts
  static void vibrate({int duration = 100}) {
    if (!_isEnabled) return;
    HapticFeedback.vibrate();
  }
  
  // Success pattern - quick double tap
  static Future<void> success() async {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
  }
  
  // Error pattern - triple heavy tap
  static Future<void> error() async {
    if (!_isEnabled) return;
    for (int i = 0; i < 3; i++) {
      HapticFeedback.heavyImpact();
      if (i < 2) await Future.delayed(const Duration(milliseconds: 150));
    }
  }
  
  // Warning pattern - double medium tap
  static Future<void> warning() async {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
  }
  
  // Notification pattern - unique pattern for notifications
  static Future<void> notification() async {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    HapticFeedback.lightImpact();
  }
  
  // Long press feedback
  static void longPress() {
    if (!_isEnabled) return;
    HapticFeedback.heavyImpact();
  }
  
  // Scroll feedback - for pull to refresh
  static void scrollFeedback() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
  }
  
  // Tab change feedback
  static void tabChange() {
    if (!_isEnabled) return;
    HapticFeedback.selectionClick();
  }
}

// Extension for easy haptic feedback on widgets
extension HapticExtension on Widget {
  Widget withHaptic({
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    HapticType type = HapticType.light,
  }) {
    return GestureDetector(
      onTap: () {
        switch (type) {
          case HapticType.light:
            HapticService.lightImpact();
            break;
          case HapticType.medium:
            HapticService.mediumImpact();
            break;
          case HapticType.heavy:
            HapticService.heavyImpact();
            break;
          case HapticType.selection:
            HapticService.selectionClick();
            break;
        }
        onTap?.call();
      },
      onLongPress: onLongPress != null ? () {
        HapticService.longPress();
        onLongPress();
      } : null,
      child: this,
    );
  }
}

enum HapticType {
  light,
  medium,
  heavy,
  selection,
}