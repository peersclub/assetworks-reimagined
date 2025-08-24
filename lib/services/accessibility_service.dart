import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'dart:io';

class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  // Check if VoiceOver is enabled
  bool get isVoiceOverEnabled {
    if (Platform.isIOS) {
      return SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation;
    }
    return false;
  }

  // Check if reduce motion is enabled
  bool get isReduceMotionEnabled {
    return SemanticsBinding.instance.accessibilityFeatures.reduceMotion;
  }

  // Check if bold text is enabled
  bool get isBoldTextEnabled {
    return SemanticsBinding.instance.accessibilityFeatures.boldText;
  }

  // Check if high contrast is enabled
  bool get isHighContrastEnabled {
    return SemanticsBinding.instance.accessibilityFeatures.highContrast;
  }

  // Check if inverted colors is enabled
  bool get isInvertColorsEnabled {
    return SemanticsBinding.instance.accessibilityFeatures.invertColors;
  }

  // Check if disable animations is enabled
  bool get isDisableAnimationsEnabled {
    return SemanticsBinding.instance.accessibilityFeatures.disableAnimations;
  }

  // Get text scale factor
  double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  // Announce message for screen readers
  void announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  // Announce with priority
  void announceWithPriority(String message, {bool assertive = false}) {
    if (assertive) {
      SemanticsService.announce(message, TextDirection.ltr, 
        assertiveness: Assertiveness.assertive);
    } else {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  // Create semantic wrapper for widgets
  Widget semanticWrapper({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? link,
    bool? header,
    bool? focused,
    bool? selected,
    bool? enabled,
    bool? checked,
    bool? image,
    bool? liveRegion,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onScrollDown,
    VoidCallback? onScrollUp,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
    int? sortKey,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button ?? false,
      link: link ?? false,
      header: header ?? false,
      focused: focused ?? false,
      selected: selected ?? false,
      enabled: enabled ?? true,
      checked: checked,
      image: image ?? false,
      liveRegion: liveRegion ?? false,
      onTap: onTap,
      onLongPress: onLongPress,
      onScrollDown: onScrollDown,
      onScrollUp: onScrollUp,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      sortKey: sortKey != null ? OrdinalSortKey(sortKey.toDouble()) : null,
      child: child,
    );
  }

  // Create accessible button
  Widget accessibleButton({
    required Widget child,
    required String label,
    required VoidCallback onPressed,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: child,
      ),
    );
  }

  // Create accessible form field
  Widget accessibleFormField({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    String? error,
    bool enabled = true,
    bool obscured = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      enabled: enabled,
      obscured: obscured,
      textField: true,
      child: child,
    );
  }

  // Create accessible image
  Widget accessibleImage({
    required Widget image,
    required String description,
    bool decorative = false,
  }) {
    if (decorative) {
      return ExcludeSemantics(child: image);
    }
    return Semantics(
      image: true,
      label: description,
      child: image,
    );
  }

  // Create accessible list item
  Widget accessibleListItem({
    required Widget child,
    required String label,
    String? hint,
    int? index,
    int? total,
    VoidCallback? onTap,
    bool selected = false,
  }) {
    String semanticLabel = label;
    if (index != null && total != null) {
      semanticLabel = '$label. Item $index of $total';
    }
    
    return Semantics(
      label: semanticLabel,
      hint: hint,
      selected: selected,
      onTap: onTap,
      child: child,
    );
  }

  // Create accessible progress indicator
  Widget accessibleProgressIndicator({
    required Widget child,
    required String label,
    double? value,
    String? semanticValue,
  }) {
    return Semantics(
      label: label,
      value: semanticValue ?? (value != null ? '${(value * 100).toInt()}%' : 'In progress'),
      child: child,
    );
  }

  // Create accessible tab
  Widget accessibleTab({
    required Widget child,
    required String label,
    bool selected = false,
    int? index,
    int? total,
  }) {
    String semanticLabel = label;
    if (index != null && total != null) {
      semanticLabel = '$label. Tab $index of $total';
    }
    
    return Semantics(
      label: semanticLabel,
      selected: selected,
      button: true,
      child: child,
    );
  }

  // Create accessible dialog
  Widget accessibleDialog({
    required Widget child,
    required String title,
    String? description,
  }) {
    return Semantics(
      label: title,
      hint: description,
      scopesRoute: true,
      namesRoute: true,
      child: child,
    );
  }

  // Create accessible navigation bar
  Widget accessibleNavigationBar({
    required Widget child,
    required String label,
    List<String>? actions,
  }) {
    return Semantics(
      label: label,
      header: true,
      child: child,
    );
  }

  // Create live region for dynamic content
  Widget liveRegion({
    required Widget child,
    required String label,
    bool assertive = false,
  }) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: child,
    );
  }

  // Check if we should use reduced animations
  Duration getAnimationDuration(Duration defaultDuration) {
    if (isReduceMotionEnabled || isDisableAnimationsEnabled) {
      return Duration.zero;
    }
    return defaultDuration;
  }

  // Get appropriate curve for animations
  Curve getAnimationCurve(Curve defaultCurve) {
    if (isReduceMotionEnabled || isDisableAnimationsEnabled) {
      return Curves.linear;
    }
    return defaultCurve;
  }

  // Helper to create accessible routes
  Route<T> createAccessibleRoute<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    if (isReduceMotionEnabled) {
      // Use fade transition for reduced motion
      return PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => builder(context),
        transitionDuration: const Duration(milliseconds: 150),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        settings: settings,
      );
    }
    
    // Use default iOS transition
    return CupertinoPageRoute<T>(
      builder: builder,
      settings: settings,
    );
  }

  // Create semantic container for grouped content
  Widget semanticContainer({
    required Widget child,
    required String label,
    bool? container,
    bool? explicitChildNodes,
  }) {
    return Semantics(
      label: label,
      container: container ?? true,
      explicitChildNodes: explicitChildNodes ?? false,
      child: child,
    );
  }

  // Create accessible switch
  Widget accessibleSwitch({
    required Widget child,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value ? 'On' : 'Off',
      toggled: value,
      onTap: () => onChanged(!value),
      child: child,
    );
  }

  // Create accessible slider
  Widget accessibleSlider({
    required Widget child,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    String? semanticValue,
  }) {
    return Semantics(
      label: label,
      value: semanticValue ?? '${(value * 100).toInt()}%',
      increasedValue: '${((value + 0.1).clamp(min, max) * 100).toInt()}%',
      decreasedValue: '${((value - 0.1).clamp(min, max) * 100).toInt()}%',
      onIncrease: () => onChanged((value + 0.1).clamp(min, max)),
      onDecrease: () => onChanged((value - 0.1).clamp(min, max)),
      child: child,
    );
  }
}

// Accessibility-aware text widget
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;
  
  const AccessibleText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final accessibility = AccessibilityService();
    final scaleFactor = accessibility.getTextScaleFactor(context);
    
    TextStyle? adjustedStyle = style;
    if (accessibility.isBoldTextEnabled && style != null) {
      adjustedStyle = style!.copyWith(
        fontWeight: FontWeight.bold,
      );
    }
    
    return Semantics(
      label: semanticsLabel ?? text,
      excludeSemantics: semanticsLabel != null,
      child: Text(
        text,
        style: adjustedStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        textScaleFactor: scaleFactor.clamp(0.8, 2.0),
      ),
    );
  }
}

// Accessibility-aware icon widget
class AccessibleIcon extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final double? size;
  final Color? color;
  
  const AccessibleIcon(
    this.icon, {
    Key? key,
    required this.semanticLabel,
    this.size,
    this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Icon(
        icon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      ),
    );
  }
}