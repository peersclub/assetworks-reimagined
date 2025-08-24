# TestFlight Deployment Guide for AssetWorks Reimagined

## Prerequisites
- Apple Developer Account
- Xcode installed
- App Store Connect access

## Steps to Deploy to TestFlight

### 1. Open Project in Xcode
```bash
open ios/Runner.xcworkspace
```

### 2. Configure Signing & Capabilities
1. Select the Runner target
2. Go to "Signing & Capabilities" tab
3. Enable "Automatically manage signing"
4. Select your Team from the dropdown
5. Bundle Identifier: `ai.assetworks.mobile`

### 3. Update Version & Build Number
In Xcode:
- Version: 1.0.0
- Build: 1

Or via command line:
```bash
cd ios
agvtool new-version -all 1.0.0
agvtool new-version 1
```

### 4. Select Device
- Choose "Any iOS Device (arm64)" from the device selector

### 5. Archive the App
1. Product → Archive
2. Wait for the archive to complete

### 6. Upload to App Store Connect
1. In the Organizer window that opens after archiving:
2. Select your archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Select "Upload"
6. Follow the prompts:
   - App Store Connect distribution
   - Upload your app's symbols
   - Automatically manage signing
7. Click "Upload"

### 7. Configure TestFlight in App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to TestFlight tab
4. Add internal testers
5. Submit for review (if adding external testers)

## Build Settings Already Configured

✅ **Info.plist** configured with:
- App name: AssetWorks Reimagined
- All iOS 18 permissions
- Background modes
- User activity types

✅ **ExportOptions.plist** configured with:
- Team ID: 866KFTNXC4
- Method: app-store
- Bundle ID: ai.assetworks.mobile

✅ **Capabilities** enabled:
- Push Notifications
- Background Modes
- Associated Domains
- App Groups
- HealthKit
- HomeKit
- Siri
- Wallet

## Features Ready for TestFlight

### iOS 18 Features
- ✅ Dynamic Island integration
- ✅ Home Screen Widgets (all sizes)
- ✅ Live Activities
- ✅ Interactive Widgets
- ✅ Lock Screen Widgets
- ✅ Control Center Widgets
- ✅ StandBy Mode
- ✅ Focus Filters

### Apple Ecosystem
- ✅ Handoff continuity
- ✅ SharePlay
- ✅ Siri Shortcuts
- ✅ iCloud sync
- ✅ Universal Links
- ✅ App Clips
- ✅ Apple Watch companion

### UI/UX
- ✅ 40+ iOS-native screens
- ✅ 30+ custom components
- ✅ Dark/Light mode support
- ✅ Custom animations
- ✅ Haptic feedback patterns

## Repository
GitHub: https://github.com/peersclub/assetworks-reimagined

## Next Steps After TestFlight
1. Gather feedback from beta testers
2. Fix any reported issues
3. Prepare App Store metadata
4. Create App Store screenshots
5. Submit for App Store review

## Troubleshooting

### If signing fails:
1. Ensure you're logged into Xcode with your Apple ID
2. Check that your Apple Developer account is active
3. Verify provisioning profiles in Xcode preferences

### If upload fails:
1. Check internet connection
2. Verify App Store Connect access
3. Ensure app bundle ID is registered in developer portal

## Support
For issues with deployment, check:
- [Apple Developer Forums](https://developer.apple.com/forums/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)