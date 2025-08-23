import 'package:flutter/material.dart';

class WidgetTemplate {
  final String id;
  final String title;
  final String description;
  final String? prompt;
  final String type; // dashboard, chart, table, form, calculator, etc.
  final IconData icon;
  final List<String> tags;
  final String category;
  final int usageCount;
  final String previewImage;
  final bool isPremium;
  
  WidgetTemplate({
    required this.id,
    required this.title,
    required this.description,
    this.prompt,
    this.type = 'dashboard',
    IconData? icon,
    List<String>? tags,
    required this.category,
    this.usageCount = 0,
    this.previewImage = '',
    this.isPremium = false,
  }) : icon = icon ?? Icons.dashboard,
       tags = tags ?? [];
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'prompt': prompt,
      'type': type,
      'icon': icon.codePoint,
      'tags': tags,
      'category': category,
      'usageCount': usageCount,
    };
  }
  
  factory WidgetTemplate.fromJson(Map<String, dynamic> json) {
    return WidgetTemplate(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      prompt: json['prompt'] ?? '',
      type: json['type'] ?? 'custom',
      icon: IconData(json['icon'] ?? 0xe3b0, fontFamily: 'MaterialIcons'),
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] ?? 'General',
      usageCount: json['usageCount'] ?? 0,
    );
  }
}