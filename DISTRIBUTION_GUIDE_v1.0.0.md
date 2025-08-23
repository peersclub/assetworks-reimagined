# AssetWorks Mobile v1.0.0 - Distribution Guide

## 📱 iOS Distribution (TestFlight & App Store)

### Pre-Distribution Checklist
- [x] Version updated in pubspec.yaml: `1.0.0+4`
- [x] All code committed and pushed to GitHub
- [x] Release notes prepared
- [x] Testing documentation ready
- [ ] Screenshots prepared (if needed)
- [ ] App Store metadata ready

### Step 1: Clean Build
```bash
# Clean everything first
cd /Users/Victor/Projects/assetworks_mobile_new
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock

# Get dependencies
flutter pub get

# Install iOS pods
cd ios
pod install
cd ..
```

### Step 2: Build & Archive in Xcode

#### Option A: Using Xcode GUI (Recommended)
1. Open Xcode workspace:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Configure for Release:
   - Select "Runner" in project navigator
   - Select "Runner" target
   - Go to "Signing & Capabilities"
   - Ensure "Automatically manage signing" is checked
   - Team: "AssetWorks AI Inc."

3. Select Device:
   - In toolbar, select "Any iOS Device (arm64)"

4. Archive:
   - Menu: Product → Clean Build Folder (⇧⌘K)
   - Menu: Product → Archive
   - Wait for build to complete (3-5 minutes)

5. Upload to App Store Connect:
   - Organizer window opens automatically
   - Select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Select "Upload"
   - Use automatic signing
   - Click "Upload"

#### Option B: Using Command Line
```bash
# Build release IPA
flutter build ios --release --no-codesign

# Open Xcode to archive
open ios/Runner.xcworkspace
# Then follow steps 4-5 from Option A
```

### Step 3: Configure in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to TestFlight tab

#### For TestFlight Beta:
1. Wait for processing (10-15 minutes)
2. Once processed, select the build
3. Add Testing Notes:
   ```
   Version 1.0.0 - Production Release
   
   🚀 Major Performance Update!
   • 5x faster loading
   • Haptic feedback throughout
   • Long-press widgets for preview
   • Smart offline caching
   • Release notes in Settings
   
   Please test all features and report any issues.
   ```

4. Add Beta Testers:
   - Internal Testing: Add team members
   - External Testing: Submit for review

#### For App Store Release:
1. Go to "App Store" tab
2. Create new version "1.0.0"
3. Add release notes
4. Upload screenshots
5. Submit for review

### Step 4: TestFlight Distribution

1. **Internal Testing (Immediate)**:
   - Add up to 100 internal testers
   - Available immediately after processing
   - No review required

2. **External Testing (Requires Review)**:
   - Submit for Beta App Review
   - Add up to 10,000 testers
   - Usually approved within 24 hours

3. **Share Testing Link**:
   - Get public link from TestFlight
   - Share with testers along with `TESTFLIGHT_v1.0.0_TESTING.md`

## 🤖 Android Distribution (Google Play)

### Step 1: Build Release APK/AAB

```bash
# Clean build
flutter clean

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# OR Build APK (for direct distribution)
flutter build apk --release
```

### Step 2: Sign the App (if not configured)

If you haven't set up signing:

1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore ~/assetworks-release.keystore \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias assetworks
   ```

2. Configure in `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=assetworks
   storeFile=/Users/Victor/assetworks-release.keystore
   ```

3. Update `android/app/build.gradle.kts` for signing

### Step 3: Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Go to "Testing" → "Internal testing"
4. Create new release
5. Upload the `.aab` file from:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```
6. Add release notes
7. Save and review
8. Roll out to internal testers

## 📋 Distribution Checklist

### iOS TestFlight
- [ ] Archive built successfully
- [ ] Uploaded to App Store Connect
- [ ] Build processed (10-15 min wait)
- [ ] Testing notes added
- [ ] Internal testers added
- [ ] External testing submitted (if needed)
- [ ] Testing link shared
- [ ] Testing guide sent to testers

### Android Play Store
- [ ] App bundle built
- [ ] Signed with release key
- [ ] Uploaded to Play Console
- [ ] Release notes added
- [ ] Internal test track configured
- [ ] Testers added
- [ ] Release rolled out

## 🔍 Build Verification

After building, verify:

### iOS IPA
```bash
# Check IPA size
ls -lh build/ios/iphoneos/*.app

# Verify Info.plist
/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" \
  ios/Runner/Info.plist
# Should output: 1.0.0
```

### Android AAB
```bash
# Check bundle size
ls -lh build/app/outputs/bundle/release/

# Verify version
aapt dump badging build/app/outputs/bundle/release/app-release.aab | \
  grep versionName
# Should show: versionName='1.0.0'
```

## 📊 Post-Distribution

### Monitor Metrics
1. **TestFlight**:
   - Crash reports
   - Feedback from testers
   - Session statistics

2. **Firebase Crashlytics**:
   - Real-time crash reports
   - Performance metrics
   - User analytics

3. **User Feedback**:
   - In-app feedback
   - Email: support@assetworks.ai
   - Slack: #mobile-beta-testing

### Success Criteria
- [ ] No critical crashes
- [ ] Dashboard loads < 2 seconds
- [ ] All haptic feedback working
- [ ] Release notes displaying correctly
- [ ] Positive tester feedback

## 🚨 Troubleshooting

### Common Issues

1. **"No signing certificate iOS Distribution found"**
   - Open Xcode → Preferences → Accounts
   - Download manual profiles
   - Or use automatic signing

2. **Archive not appearing in Organizer**
   - Ensure scheme is set to "Release"
   - Clean build folder first
   - Check for build errors

3. **Upload fails with "Invalid Bundle"**
   - Increment build number in pubspec.yaml
   - Clean and rebuild
   - Check bundle ID matches App Store Connect

4. **Processing stuck in App Store Connect**
   - Wait up to 1 hour
   - If still stuck, rebuild and re-upload
   - Contact Apple support if persistent

## 📝 Release Notes Template

```markdown
## Version 1.0.0 (Build 4)
*Release Date: August 23, 2025*

### 🎯 What's New
• World-class performance - 5x faster loading
• Haptic feedback system throughout the app
• Interactive widget previews with long-press
• Smart caching for offline functionality
• In-app release notes

### 🚀 Improvements
• Dashboard loads instantly with cached data
• Parallel API calls for better performance
• Beautiful empty states for all screens
• Professional error handling
• Shimmer loading effects

### 🐛 Bug Fixes
• Fixed username display on widget cards
• Resolved UI overflow warnings
• Corrected history navigation
• Real-time notifications working
• App logo displays properly

### 📱 Requirements
• iOS 13.0 or later
• Android 5.0 or later
```

## ✅ Final Steps

1. **Send to Testers**:
   - TestFlight link
   - Testing guide (`TESTFLIGHT_v1.0.0_TESTING.md`)
   - Feedback form/channel

2. **Prepare for Production**:
   - Collect beta feedback
   - Fix critical issues
   - Plan production release
   - Prepare marketing materials

3. **Documentation**:
   - Update README
   - Update API documentation
   - Update user guides

---

**Support**: If you encounter any issues during distribution, contact:
- Technical: dev@assetworks.ai
- TestFlight Issues: support@assetworks.ai
- Urgent: Slack #mobile-release