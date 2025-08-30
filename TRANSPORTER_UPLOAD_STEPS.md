# Transporter Upload Steps

The archive has been opened in Xcode's Organizer. Follow these steps:

## In Xcode Organizer:
1. The archive should be selected (AssetWorks version 1.0.0 build 6)
2. Click **"Distribute App"** button on the right
3. Select **"App Store Connect"** → Click **"Next"**
4. Select **"Export"** (not Upload) → Click **"Next"**
5. Keep default options → Click **"Next"**
6. Select **"Automatically manage signing"** → Click **"Next"**
7. Review and click **"Export"**
8. Choose a location (e.g., Desktop) to save the IPA

## In Transporter:
1. Open **Transporter** app (if not installed, get it from Mac App Store)
2. Sign in with your Apple ID if needed
3. Click **"+"** or **"Add App"** button
4. Navigate to the exported IPA file
5. Select the IPA and click **"Open"**
6. Review the app information
7. Click **"Deliver"** button
8. Wait for upload to complete

## Verification:
- Once uploaded, you'll receive an email from App Store Connect
- The build will appear in TestFlight after processing (usually 5-10 minutes)
- Build number: 1.0.0 (6)

## Archive Location:
/Users/Victor/assetworks-reimagined/build/ios/Runner.xcarchive
