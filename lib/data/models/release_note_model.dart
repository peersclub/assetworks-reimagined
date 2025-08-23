import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum ReleaseType {
  major,
  minor,
  patch,
  hotfix,
}

enum FeatureCategory {
  feature,
  improvement,
  bugfix,
  performance,
  ui,
  security,
}

class ReleaseNote {
  final String version;
  final String buildNumber;
  final DateTime releaseDate;
  final ReleaseType type;
  final String title;
  final String summary;
  final List<ReleaseFeature> features;
  final List<ReleaseFeature> improvements;
  final List<ReleaseFeature> bugFixes;
  final List<String> knownIssues;
  final bool isCurrent;
  
  ReleaseNote({
    required this.version,
    required this.buildNumber,
    required this.releaseDate,
    required this.type,
    required this.title,
    required this.summary,
    required this.features,
    required this.improvements,
    required this.bugFixes,
    this.knownIssues = const [],
    this.isCurrent = false,
  });
  
  String get fullVersion => 'v$version ($buildNumber)';
  
  Color get typeColor {
    switch (type) {
      case ReleaseType.major:
        return Colors.purple;
      case ReleaseType.minor:
        return Colors.blue;
      case ReleaseType.patch:
        return Colors.green;
      case ReleaseType.hotfix:
        return Colors.orange;
    }
  }
  
  IconData get typeIcon {
    switch (type) {
      case ReleaseType.major:
        return LucideIcons.rocket;
      case ReleaseType.minor:
        return LucideIcons.sparkles;
      case ReleaseType.patch:
        return LucideIcons.wrench;
      case ReleaseType.hotfix:
        return LucideIcons.flame;
    }
  }
  
  String get typeLabel {
    switch (type) {
      case ReleaseType.major:
        return 'Major Release';
      case ReleaseType.minor:
        return 'Feature Update';
      case ReleaseType.patch:
        return 'Improvements';
      case ReleaseType.hotfix:
        return 'Hotfix';
    }
  }
}

class ReleaseFeature {
  final String title;
  final String? description;
  final FeatureCategory category;
  final IconData icon;
  final bool isNew;
  final bool isBreaking;
  
  ReleaseFeature({
    required this.title,
    this.description,
    required this.category,
    required this.icon,
    this.isNew = false,
    this.isBreaking = false,
  });
  
  Color get categoryColor {
    switch (category) {
      case FeatureCategory.feature:
        return Colors.blue;
      case FeatureCategory.improvement:
        return Colors.green;
      case FeatureCategory.bugfix:
        return Colors.orange;
      case FeatureCategory.performance:
        return Colors.purple;
      case FeatureCategory.ui:
        return Colors.pink;
      case FeatureCategory.security:
        return Colors.red;
    }
  }
}