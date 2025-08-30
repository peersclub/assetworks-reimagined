import 'package:flutter/services.dart';
import 'dart:async';

class CustomHapticPatternsService {
  static const platform = MethodChannel('com.assetworks.haptics');
  static final CustomHapticPatternsService _instance = CustomHapticPatternsService._internal();
  
  factory CustomHapticPatternsService() => _instance;
  CustomHapticPatternsService._internal();
  
  // Success pattern - double tap with increasing intensity
  Future<void> playSuccessPattern() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
  
  // Error pattern - three quick taps
  Future<void> playErrorPattern() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
  
  // Warning pattern - two medium taps
  Future<void> playWarningPattern() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.mediumImpact();
  }
  
  // Notification pattern - light ascending
  Future<void> playNotificationPattern() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }
  
  // Long press pattern - gradual increase
  Future<void> playLongPressPattern() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.mediumImpact();
  }
  
  // Scroll tick pattern
  Future<void> playScrollTickPattern() async {
    await HapticFeedback.lightImpact();
  }
  
  // Custom rhythm pattern
  Future<void> playRhythmPattern(List<HapticNote> notes) async {
    for (final note in notes) {
      switch (note.intensity) {
        case HapticIntensity.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticIntensity.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticIntensity.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticIntensity.selection:
          await HapticFeedback.lightImpact();
          break;
      }
      
      if (note.duration != null) {
        await Future.delayed(note.duration!);
      }
    }
  }
  
  // Heartbeat pattern
  Future<void> playHeartbeatPattern() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 600));
  }
  
  // Countdown pattern
  Future<void> playCountdownPattern(int count) async {
    for (int i = count; i > 0; i--) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    await HapticFeedback.heavyImpact();
  }
  
  // Progress pattern
  Future<void> playProgressPattern(double progress) async {
    if (progress == 0.0) {
      await HapticFeedback.lightImpact();
    } else if (progress == 0.25) {
      await HapticFeedback.lightImpact();
    } else if (progress == 0.5) {
      await HapticFeedback.lightImpact();
    } else if (progress == 0.75) {
      await HapticFeedback.mediumImpact();
    } else if (progress == 1.0) {
      await playSuccessPattern();
    }
  }
  
  // Swipe pattern
  Future<void> playSwipePattern() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }
  
  // Bounce pattern
  Future<void> playBouncePattern() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }
  
  // Toggle pattern
  Future<void> playTogglePattern(bool isOn) async {
    if (isOn) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    } else {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    }
  }
  
  // Morse code pattern
  Future<void> playMorseCodePattern(String text) async {
    final morse = _textToMorse(text.toUpperCase());
    
    for (final char in morse.split('')) {
      if (char == '.') {
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 100));
      } else if (char == '-') {
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 300));
      } else if (char == ' ') {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }
  
  String _textToMorse(String text) {
    const morseCode = {
      'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
      'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
      'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
      'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
      'Y': '-.--', 'Z': '--..', '0': '-----', '1': '.----', '2': '..---',
      '3': '...--', '4': '....-', '5': '.....', '6': '-....', '7': '--...',
      '8': '---..', '9': '----.', ' ': '   ',
    };
    
    return text.split('').map((char) => morseCode[char] ?? '').join(' ');
  }
  
  // Custom pattern builder
  HapticPatternBuilder createPattern() {
    return HapticPatternBuilder();
  }
}

// Haptic pattern builder
class HapticPatternBuilder {
  final List<HapticNote> _notes = [];
  
  HapticPatternBuilder addLight({Duration? delay}) {
    _notes.add(HapticNote(
      intensity: HapticIntensity.light,
      duration: delay,
    ));
    return this;
  }
  
  HapticPatternBuilder addMedium({Duration? delay}) {
    _notes.add(HapticNote(
      intensity: HapticIntensity.medium,
      duration: delay,
    ));
    return this;
  }
  
  HapticPatternBuilder addHeavy({Duration? delay}) {
    _notes.add(HapticNote(
      intensity: HapticIntensity.heavy,
      duration: delay,
    ));
    return this;
  }
  
  HapticPatternBuilder addSelection({Duration? delay}) {
    _notes.add(HapticNote(
      intensity: HapticIntensity.selection,
      duration: delay,
    ));
    return this;
  }
  
  HapticPatternBuilder addDelay(Duration delay) {
    if (_notes.isNotEmpty) {
      _notes.last.duration = delay;
    }
    return this;
  }
  
  HapticPatternBuilder repeat(int times) {
    final currentNotes = List<HapticNote>.from(_notes);
    for (int i = 1; i < times; i++) {
      _notes.addAll(currentNotes);
    }
    return this;
  }
  
  Future<void> play() async {
    await CustomHapticPatternsService().playRhythmPattern(_notes);
  }
  
  List<HapticNote> build() {
    return List.from(_notes);
  }
}

// Haptic note model
class HapticNote {
  final HapticIntensity intensity;
  Duration? duration;
  
  HapticNote({
    required this.intensity,
    this.duration,
  });
}

// Haptic intensity enum
enum HapticIntensity {
  light,
  medium,
  heavy,
  selection,
}

// Haptic feedback wrapper with patterns
class HapticFeedbackWrapper {
  static final _haptics = CustomHapticPatternsService();
  
  // Basic haptic feedback
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }
  
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }
  
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }
  
  static Future<void> selection() async {
    await HapticFeedback.lightImpact();
  }
  
  // Pattern feedback
  static Future<void> success() async {
    await _haptics.playSuccessPattern();
  }
  
  static Future<void> error() async {
    await _haptics.playErrorPattern();
  }
  
  static Future<void> warning() async {
    await _haptics.playWarningPattern();
  }
  
  static Future<void> notification() async {
    await _haptics.playNotificationPattern();
  }
  
  static Future<void> longPress() async {
    await _haptics.playLongPressPattern();
  }
  
  static Future<void> scrollTick() async {
    await _haptics.playScrollTickPattern();
  }
  
  static Future<void> heartbeat() async {
    await _haptics.playHeartbeatPattern();
  }
  
  static Future<void> swipe() async {
    await _haptics.playSwipePattern();
  }
  
  static Future<void> bounce() async {
    await _haptics.playBouncePattern();
  }
  
  static Future<void> toggle(bool isOn) async {
    await _haptics.playTogglePattern(isOn);
  }
  
  static Future<void> progress(double value) async {
    await _haptics.playProgressPattern(value);
  }
  
  static Future<void> countdown(int count) async {
    await _haptics.playCountdownPattern(count);
  }
  
  static Future<void> morse(String text) async {
    await _haptics.playMorseCodePattern(text);
  }
}