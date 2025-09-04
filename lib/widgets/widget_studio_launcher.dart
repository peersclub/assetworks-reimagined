import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/widget_studio_screen.dart';
import '../presentation/controllers/widget_studio_controller.dart';

class WidgetStudioLauncher {
  /// Launch Widget Studio with optional pre-filled context
  static void launch({
    String? prompt,
    String? templateName,
    CreationMode? mode,
  }) {
    // Navigate to Widget Studio
    Get.to(() => const WidgetStudioScreen());
    
    // If we have context, pre-fill it after navigation
    if (prompt != null || templateName != null || mode != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        final controller = Get.find<WidgetStudioController>();
        
        if (mode != null) {
          controller.setCreationMode(mode);
        }
        
        if (prompt != null) {
          controller.promptController.text = prompt;
          controller.updatePrompt(prompt);
        }
        
        if (templateName != null) {
          controller.selectTemplate(templateName);
        }
      });
    }
  }
  
  /// Launch with remix context from an existing widget
  static void remix({
    required String widgetTitle,
    String? widgetDescription,
  }) {
    launch(
      mode: CreationMode.prompt,
      prompt: 'Create a variation of "$widgetTitle" widget${widgetDescription != null ? ": $widgetDescription" : ""}',
    );
  }
  
  /// Launch with template suggestion
  static void launchWithTemplate(String category) {
    final templateMap = {
      'crypto': 'Crypto Price',
      'stocks': 'Stock Ticker',
      'finance': 'Portfolio',
      'budget': 'Budget Tracker',
      'forex': 'Exchange Rates',
      'goals': 'Investment Goal',
    };
    
    launch(
      mode: CreationMode.template,
      templateName: templateMap[category.toLowerCase()] ?? 'Stock Ticker',
    );
  }
}