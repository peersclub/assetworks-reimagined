# AssetWorks Development Context

## Current Build Status (September 4, 2025)

### ✅ Successfully Running
- **Platform**: iPhone 16 Pro Simulator (iOS 18.6)
- **Flutter Version**: 3.32.8 (Dart 3.8.1)
- **Build Number**: 17 (Version 1.0.0+6)
- **Bundle ID**: ai.assetworks.mobile
- **Development Team**: 97U2KB248P

### 📱 App State
- **Current Screen**: Main navigation with explore, trending, create screens
- **Authentication**: Not logged in (401 errors on API calls)
- **Base API**: https://api.assetworks.ai
- **Hot Reload**: Active and ready (press 'r' in terminal)

## 🔧 Development Setup

### Active Sessions
1. **Xcode**: Runner.xcworkspace open
2. **Flutter**: Running in debug mode with DevTools
3. **Simulator**: iPhone 16 Pro booted and active

### Keep These Running
```bash
# Terminal 1 - Flutter hot reload (KEEP OPEN)
cd /Users/Victor/assetworks-reimagined/assetworks-reimagined
flutter run

# Terminal 2 - For git and file operations
cd /Users/Victor/assetworks-reimagined/assetworks-reimagined
```

## 📝 Before Making Changes

### 1. Version Control
```bash
# Create a feature branch
git checkout -b feature/your-upgrade-name

# Commit current state
git add -A
git commit -m "checkpoint: before starting [upgrade name]"
```

### 2. Document Your Changes
Create a file for each upgrade session:
- `UPGRADES/2025-09-04-upgrade-name.md`
- Track what you're changing and why
- Note any dependencies affected

### 3. Test Points
Mark these as test checkpoints:
- [ ] App launches without crashes
- [ ] Navigation works
- [ ] API calls handle errors gracefully
- [ ] UI renders correctly on different screen sizes

## 🎯 Upgrade Strategy

### For UI Changes
1. Use Flutter hot reload (press 'r')
2. Changes apply instantly without losing state
3. Hot restart (press 'R') only when needed

### For Logic Changes
1. Make changes in appropriate service/controller files
2. Hot reload usually works
3. Full restart only for initialization changes

### For Native iOS Changes
1. Stop Flutter (press 'q')
2. Make changes in Xcode
3. Run `flutter run` again

## 🚀 Quick Commands

### Check Current State
```bash
# See what files changed
git status

# See running processes
ps aux | grep flutter

# Check simulator status
xcrun simctl list | grep Booted
```

### Save Progress
```bash
# Quick save point
git add -A && git commit -m "WIP: [what you're working on]"

# Create a restoration point
git tag checkpoint-$(date +%Y%m%d-%H%M%S)
```

### Restore if Needed
```bash
# Undo last changes (not committed)
git checkout -- .

# Go back to last commit
git reset --hard HEAD

# Return to checkpoint
git checkout checkpoint-[timestamp]
```

## 📊 Current Technical Debt

### Known Issues
1. **Missing Assets**: Need to create assets/images, assets/icons, assets/animations directories
2. **Authentication**: No auth token, all API calls return 401
3. **Pod Warnings**: Some pods have outdated deployment targets

### Areas for Improvement
- [ ] Update pod deployment targets to iOS 12.0+
- [ ] Implement proper error handling for 401s
- [ ] Add asset directories
- [ ] Configure authentication flow

## 🔄 Maintaining Context

### Between Sessions
1. **Read this file first** when returning to development
2. **Check git log** to see recent changes
3. **Run flutter doctor** to ensure environment is ready
4. **Open previous terminal tabs** to maintain command history

### During Development
1. **Keep Flutter running** - don't quit unless necessary
2. **Use hot reload** - preserves app state
3. **Commit frequently** - small, focused commits
4. **Document as you go** - update this file with important changes

## 📌 Important Files to Track

### Core Configuration
- `/lib/main.dart` - App entry point
- `/ios/Runner/Info.plist` - iOS configuration
- `/pubspec.yaml` - Dependencies

### Key Features
- `/lib/services/api_service.dart` - API integration
- `/lib/services/ai_provider_service.dart` - AI providers
- `/lib/screens/main_screen.dart` - Main navigation

### iOS Specific
- `/ios/Runner.xcworkspace` - Xcode project
- `/ios/Podfile` - CocoaPods dependencies

## 💡 Development Tips

1. **Use GetX Navigation**: App uses GetX for state and routing
2. **Follow Clean Architecture**: Maintain separation of concerns
3. **Test on Multiple Devices**: Use different simulators
4. **Monitor Console**: Watch Flutter output for errors
5. **Backup Before Major Changes**: Create git tags

---

*Last Updated: September 4, 2025, 07:02 GMT*
*App Running: YES ✅*
*Hot Reload: ACTIVE 🔥*