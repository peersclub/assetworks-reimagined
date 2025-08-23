# TestFlight Deployment Guide for AssetWorks

## Prerequisites
- Apple Developer Account ($99/year)
- Xcode installed (version 14.0 or later)
- Valid Apple ID configured in Xcode

## Step-by-Step Deployment Process

### 1. Apple Developer Account Setup
1. Go to [developer.apple.com](https://developer.apple.com)
2. Sign in with your Apple ID
3. Enroll in the Apple Developer Program if not already enrolled

### 2. App Store Connect Setup
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click the "+" button and select "New App"
3. Fill in the details:
   - Platform: iOS
   - App Name: AssetWorks
   - Primary Language: English (U.S.)
   - Bundle ID: Select or create "com.assetworks.assetworksMobileNew"
   - SKU: assetworks-mobile-2025
   - User Access: Full Access

### 3. Configure Signing in Xcode
1. Open the project in Xcode:
   ```bash
   cd /Users/Victor/Projects/assetworks_mobile_new
   open ios/Runner.xcworkspace
   ```

2. Select the Runner project in the navigator
3. Go to "Signing & Capabilities" tab
4. Select your Team (your Apple Developer account)
5. Enable "Automatically manage signing"
6. Ensure bundle identifier is: com.assetworks.assetworksMobileNew

### 4. Build and Archive
1. In Terminal, clean and build:
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   ```

2. Build for release:
   ```bash
   flutter build ios --release
   ```

3. Open Xcode and Archive:
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Select "Any iOS Device (arm64)" as the build destination
   - Menu: Product → Archive
   - Wait for the archive to complete

### 5. Upload to TestFlight
1. In the Archives organizer window:
   - Select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Choose "Upload"
   - Select options:
     - ✓ Include bitcode for iOS content
     - ✓ Upload your app's symbols
   - Click "Next" and "Upload"

2. Wait for processing (usually 5-30 minutes)

### 6. Configure TestFlight
1. Go to App Store Connect
2. Select your app
3. Go to TestFlight tab
4. Once processing is complete:
   - Add build to a test group
   - Add internal testers (up to 100)
   - Add external testers (up to 10,000)

### 7. Test Information Required
Fill in the following for external testing:
- **Beta App Description**: What to test in this build
- **Email**: Support email
- **Marketing URL**: Optional
- **Privacy Policy URL**: Required for external testing

## Important Configuration Files

### Bundle Identifier
Location: `ios/Runner.xcodeproj/project.pbxproj`
Current: `com.assetworks.assetworksMobileNew`

### Version Info
Location: `pubspec.yaml`
Format: `version: 1.0.0+1` (version+buildNumber)

### Display Name
Location: `ios/Runner/Info.plist`
Current: `AssetWorks`

## Common Issues and Solutions

### Issue: "No suitable application records found"
**Solution**: Create the app in App Store Connect first

### Issue: "Bundle identifier not found"
**Solution**: Ensure the bundle ID in Xcode matches App Store Connect

### Issue: "Missing compliance"
**Solution**: Answer export compliance questions in App Store Connect

### Issue: "Invalid provisioning profile"
**Solution**: 
1. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
2. Clean build: `flutter clean`
3. Regenerate profiles in Xcode

## Build Commands Summary
```bash
# Clean and prepare
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Build release version
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace
```

## TestFlight Links
- [App Store Connect](https://appstoreconnect.apple.com)
- [TestFlight for Developers](https://developer.apple.com/testflight/)
- [TestFlight App](https://apps.apple.com/us/app/testflight/id899247664)

## Next Steps After Upload
1. Wait for build processing
2. Add test information
3. Add testers
4. Submit for beta review (for external testers)
5. Start testing!

## Version Management
- Internal Testing: Can use immediately after processing
- External Testing: Requires beta review (24-48 hours)
- Increment build number for each upload: `1.0.0+2`, `1.0.0+3`, etc.