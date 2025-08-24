# Xcode Setup & TestFlight Upload Steps

## Current Status
✅ Archive created successfully at: `build/ios/Runner.xcarchive`
✅ Xcode Organizer is open
❌ Need to configure Apple Developer account

## Step 1: Add Your Apple ID to Xcode

1. **In Xcode, go to Settings:**
   - Press `⌘,` (Command + Comma)
   - Or menu: Xcode → Settings

2. **Go to Accounts tab**

3. **Add your Apple ID:**
   - Click the "+" button at bottom left
   - Select "Apple ID"
   - Enter your Apple ID email (sureshvictor43@gmail.com)
   - Enter your password
   - Click "Sign In"

4. **Verify Team:**
   - You should see "Suresh Victor (Personal Team)" or your organization
   - Team ID should be: 866KFTNXC4

## Step 2: Download Certificates

1. **Still in Accounts tab:**
   - Select your Apple ID
   - Click "Manage Certificates..." button

2. **Create Distribution Certificate:**
   - Click "+" button
   - Select "Apple Distribution"
   - Wait for it to create

3. **Close Settings**

## Step 3: Upload to TestFlight from Organizer

1. **In the Organizer window:**
   - You should see "AssetWorks" archive
   - Version: 1.0.0
   - Build: 4

2. **Click "Distribute App" button** (blue button on the right)

3. **Select Distribution Method:**
   - Choose "App Store Connect"
   - Click "Next"

4. **Select Destination:**
   - Choose "Upload"
   - Click "Next"

5. **App Store Connect Options:**
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number (optional)
   - Click "Next"

6. **Signing Options:**
   - Select "Automatically manage signing"
   - Click "Next"

7. **Review AssetWorks.ipa Contents:**
   - Verify the details
   - Click "Upload"

## Step 4: Wait for Upload

- Progress bar will show upload status
- Takes 2-5 minutes typically
- You'll see "Upload Successful" when done

## Step 5: App Store Connect Configuration

Once uploaded, go to: https://appstoreconnect.apple.com

1. **Create App (if needed):**
   - My Apps → "+"
   - New App
   - Platform: iOS
   - Name: AssetWorks
   - Primary Language: English (U.S.)
   - Bundle ID: ai.assetworks.mobile
   - SKU: ASSETWORKS001

2. **TestFlight Tab:**
   - Processing takes 5-10 minutes
   - Status will change from "Processing" to "Ready to Test"

3. **Add Test Information:**
   - What to Test: "Create widgets from text prompts, test Dynamic Island features"
   - Email: victor@assetworks.ai
   - Beta App Description: "AssetWorks creates HTML/CSS/JS widgets from natural language"

4. **Add Internal Testers:**
   - No review required
   - Add yourself and team members
   - They'll receive TestFlight invitation

## Troubleshooting

### If "Distribute App" is grayed out:
- Make sure you're signed into Xcode with Apple ID
- Verify your Apple Developer membership is active

### If upload fails with "No account":
- Go back to Xcode Settings → Accounts
- Remove and re-add your Apple ID
- Make sure to download certificates

### If you see "No bundle ID":
1. Create app in App Store Connect first
2. Use bundle ID: `ai.assetworks.mobile`

## Quick Commands

Check if signed in:
```bash
xcrun xcodebuild -showBuildSettings | grep DEVELOPMENT_TEAM
```

List certificates:
```bash
security find-identity -p codesigning -v
```

## Next Steps After Upload

1. **TestFlight Processing** (5-10 min)
2. **Add Testers** (immediate)
3. **External Testing** (requires review, 24-48 hours)
4. **Monitor Feedback** in TestFlight
5. **Prepare for App Store** submission

---

**Your archive is ready!** Just need to:
1. Sign into Xcode with your Apple ID
2. Click "Distribute App" in Organizer
3. Follow the upload wizard