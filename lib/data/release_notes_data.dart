import 'package:lucide_icons/lucide_icons.dart';
import 'models/release_note_model.dart';

class ReleaseNotesData {
  static List<ReleaseNote> getAllReleases() {
    return [
      // Version 1.0.0 Build 4 - Current Production Release
      ReleaseNote(
        version: '1.0.0',
        buildNumber: '4',
        releaseDate: DateTime(2025, 8, 23),
        type: ReleaseType.major,
        title: 'Production Ready Release',
        summary: 'Complete app optimization with world-class performance, comprehensive error handling, and exceptional user experience.',
        isCurrent: true,
        features: [
          ReleaseFeature(
            title: 'Haptic Feedback System',
            description: 'Feel every interaction with sophisticated haptic patterns throughout the app',
            category: FeatureCategory.feature,
            icon: LucideIcons.vibrate,
            isNew: true,
          ),
          ReleaseFeature(
            title: 'Interactive Widget Cards',
            description: 'Long-press any widget card for instant HTML preview with stats',
            category: FeatureCategory.feature,
            icon: LucideIcons.layers,
            isNew: true,
          ),
          ReleaseFeature(
            title: 'Smart Caching System',
            description: 'Multi-tier caching with memory and disk storage for instant loading',
            category: FeatureCategory.feature,
            icon: LucideIcons.database,
            isNew: true,
          ),
          ReleaseFeature(
            title: 'Comprehensive Error Handling',
            description: 'Beautiful error states with automatic retry mechanisms',
            category: FeatureCategory.feature,
            icon: LucideIcons.shieldCheck,
            isNew: true,
          ),
          ReleaseFeature(
            title: 'Empty State Designs',
            description: 'Context-aware empty states with actionable CTAs',
            category: FeatureCategory.ui,
            icon: LucideIcons.layout,
            isNew: true,
          ),
        ],
        improvements: [
          ReleaseFeature(
            title: '5x Faster Dashboard Loading',
            description: 'Dashboard loads in <500ms with intelligent caching',
            category: FeatureCategory.performance,
            icon: LucideIcons.zap,
          ),
          ReleaseFeature(
            title: 'Parallel API Loading',
            description: 'All data loads simultaneously for better performance',
            category: FeatureCategory.performance,
            icon: LucideIcons.gitBranch,
          ),
          ReleaseFeature(
            title: 'Shimmer Loading Effects',
            description: 'Smooth loading animations replace blank screens',
            category: FeatureCategory.ui,
            icon: LucideIcons.loader,
          ),
          ReleaseFeature(
            title: 'Optimistic UI Updates',
            description: 'Instant feedback before server confirmation',
            category: FeatureCategory.improvement,
            icon: LucideIcons.refreshCw,
          ),
          ReleaseFeature(
            title: 'Professional Login UI',
            description: 'Font Awesome icons for Google and Apple sign-in',
            category: FeatureCategory.ui,
            icon: LucideIcons.userCheck,
          ),
        ],
        bugFixes: [
          ReleaseFeature(
            title: 'Fixed Widget Card User IDs',
            description: 'Usernames now display correctly instead of IDs',
            category: FeatureCategory.bugfix,
            icon: LucideIcons.bug,
          ),
          ReleaseFeature(
            title: 'Resolved Overflow Errors',
            description: 'No more yellow/black striped warnings',
            category: FeatureCategory.bugfix,
            icon: LucideIcons.alertTriangle,
          ),
          ReleaseFeature(
            title: 'Fixed History Navigation',
            description: 'History button now navigates to correct screen',
            category: FeatureCategory.bugfix,
            icon: LucideIcons.navigation,
          ),
          ReleaseFeature(
            title: 'Real Notifications',
            description: 'Notifications now fetch from live API',
            category: FeatureCategory.bugfix,
            icon: LucideIcons.bell,
          ),
          ReleaseFeature(
            title: 'Correct App Logo',
            description: 'AssetWorks logo displays properly on splash',
            category: FeatureCategory.bugfix,
            icon: LucideIcons.image,
          ),
        ],
        knownIssues: [],
      ),
      
      // Version 0.9.0 Build 3
      ReleaseNote(
        version: '0.9.0',
        buildNumber: '3',
        releaseDate: DateTime(2025, 8, 20),
        type: ReleaseType.minor,
        title: 'Beta Release',
        summary: 'Initial TestFlight release with core functionality and Face ID support.',
        features: [
          ReleaseFeature(
            title: 'Face ID/Touch ID Authentication',
            description: 'Secure biometric login support',
            category: FeatureCategory.feature,
            icon: LucideIcons.scan,
          ),
          ReleaseFeature(
            title: 'Widget Creation',
            description: 'AI-powered widget generation',
            category: FeatureCategory.feature,
            icon: LucideIcons.sparkles,
          ),
          ReleaseFeature(
            title: 'Dashboard',
            description: 'Personal investment dashboard',
            category: FeatureCategory.feature,
            icon: LucideIcons.layoutDashboard,
          ),
        ],
        improvements: [
          ReleaseFeature(
            title: 'Dark Mode Support',
            description: 'System-wide dark theme',
            category: FeatureCategory.ui,
            icon: LucideIcons.moon,
          ),
          ReleaseFeature(
            title: 'Profile Management',
            description: 'Edit profile and preferences',
            category: FeatureCategory.feature,
            icon: LucideIcons.user,
          ),
        ],
        bugFixes: [
          ReleaseFeature(
            title: 'Initial Stability',
            description: 'Core app stability improvements',
            category: FeatureCategory.bugfix,
            icon: LucideIcons.checkCircle,
          ),
        ],
      ),
      
      // Version 0.8.0 Build 2
      ReleaseNote(
        version: '0.8.0',
        buildNumber: '2',
        releaseDate: DateTime(2025, 8, 15),
        type: ReleaseType.minor,
        title: 'Alpha Release',
        summary: 'Internal testing release with basic functionality.',
        features: [
          ReleaseFeature(
            title: 'Basic Authentication',
            description: 'Email and OTP login',
            category: FeatureCategory.feature,
            icon: LucideIcons.logIn,
          ),
          ReleaseFeature(
            title: 'Widget Discovery',
            description: 'Browse trending widgets',
            category: FeatureCategory.feature,
            icon: LucideIcons.search,
          ),
        ],
        improvements: [],
        bugFixes: [],
      ),
    ];
  }
  
  static ReleaseNote getCurrentRelease() {
    return getAllReleases().firstWhere(
      (release) => release.isCurrent,
      orElse: () => getAllReleases().first,
    );
  }
  
  static ReleaseNote? getReleaseByVersion(String version) {
    try {
      return getAllReleases().firstWhere(
        (release) => release.version == version,
      );
    } catch (e) {
      return null;
    }
  }
  
  static List<ReleaseNote> getRecentReleases({int limit = 3}) {
    final releases = getAllReleases();
    return releases.take(limit).toList();
  }
}