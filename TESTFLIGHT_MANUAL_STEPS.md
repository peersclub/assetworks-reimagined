# TestFlight Manual Deployment Steps

## ✅ Archive Created Successfully

Your app has been successfully archived and is ready for upload. Follow these steps to complete the TestFlight deployment:

## Step 1: Open Archive in Xcode

The archive was created at:
```
/Users/Victor/Projects/assetworks_mobile_new/build/ios/Runner.xcarchive
```

Open Xcode Organizer:
```bash
open -a Xcode
```

Then go to Window → Organizer (or press ⌘⇧2)

## Step 2: Configure Apple Developer Account

1. **Open Xcode Preferences**
   - Xcode → Settings (⌘,)
   - Go to "Accounts" tab
   - Click "+" to add your Apple ID
   - Sign in with your Apple Developer account

2. **Download Certificates**
   - Select your Apple ID
   - Click "Manage Certificates"
   - Click "+" → "Apple Distribution"
   - Wait for certificate to be created

## Step 3: Upload to TestFlight

1. **In Organizer Window**
   - Select your "AssetWorks" archive (should be the most recent)
   - Click "Distribute App" button

2. **Distribution Options**
   - Choose "App Store Connect"
   - Click "Next"

3. **Distribution Method**
   - Select "Upload"
   - Click "Next"

4. **App Store Connect Options**
   - ✅ Include bitcode for iOS content
   - ✅ Upload your app's symbols
   - Click "Next"

5. **Signing Options**
   - Select "Automatically manage signing"
   - Click "Next"

6. **Review**
   - Verify the details
   - Click "Upload"

## Step 4: Monitor Upload Progress

The upload will show progress in Xcode. Once complete, you'll see a success message.

## Step 5: Configure in App Store Connect

1. **Go to App Store Connect**
   ```
   https://appstoreconnect.apple.com
   ```

2. **Create App (if not exists)**
   - Click "+" → "New App"
   - Platform: iOS
   - Name: AssetWorks
   - Primary Language: English
   - Bundle ID: ai.assetworks.mobile
   - SKU: assetworks-mobile

3. **TestFlight Setup**
   - Go to TestFlight tab
   - Wait for processing (5-10 minutes)
   - Complete export compliance

4. **Add Test Information**
   - What to Test: "Widget creation from text prompts, Dynamic Island features, authentication flow"
   - Test Instructions: "1. Sign in with email OTP\n2. Create widgets from prompts\n3. Test Dynamic Island during widget creation\n4. Try all widget actions (like, save, share)"

5. **Add Testers**
   - Internal Testing: Add your team
   - External Testing: Submit for review first

## Alternative: Command Line Upload

If you have your certificates configured, you can also upload via command line:

```bash
# Store your App-Specific Password
xcrun altool --store-password-in-keychain-item "AC_PASSWORD" \
  --username "victor@assetworks.ai" \
  --password "your-app-specific-password"

# Upload the IPA
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/Runner.ipa \
  --username "victor@assetworks.ai" \
  --password "@keychain:AC_PASSWORD"
```

To generate an app-specific password:
1. Go to https://appleid.apple.com
2. Sign in
3. Go to "Sign-In and Security"
4. App-Specific Passwords → Generate

## Current Status

✅ **Completed:**
- Flutter app built successfully
- iOS archive created
- Export options configured
- Archive ready for upload

❌ **Needs Configuration:**
- Apple Developer account in Xcode
- Distribution certificate
- App Store Connect app creation

## Quick Checklist

- [ ] Apple Developer account signed in to Xcode
- [ ] Distribution certificate downloaded
- [ ] App created in App Store Connect
- [ ] Archive uploaded via Xcode
- [ ] TestFlight configured
- [ ] Internal testers added
- [ ] Test information provided

## Need Help?

1. **Certificate Issues**: Make sure you're signed into Xcode with an Apple ID that has Developer Program membership
2. **Upload Errors**: Check that bundle ID matches in App Store Connect
3. **Processing Delays**: TestFlight processing typically takes 5-10 minutes

## Next Steps After Upload

1. Monitor TestFlight for processing completion
2. Add internal testers immediately (no review needed)
3. Submit for external testing review (24-48 hours)
4. Share TestFlight link with beta testers
5. Monitor crash reports and feedback