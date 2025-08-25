# Xcode Configuration Steps for iOS Features

## 1. Add Swift Files to Project

In Xcode, you need to add the following files to the Runner target:

1. **Right-click on "Runner" folder** in the project navigator
2. Select **"Add Files to Runner..."**
3. Navigate to `ios/Runner/` and select:
   - `DynamicIslandManager.swift`
   - `LiveActivityManager.swift`
   - `NotificationService.swift`
4. Make sure **"Copy items if needed"** is unchecked
5. Make sure **"Runner"** target is checked
6. Click **"Add"**

## 2. Add Shared Folder

1. Right-click on "Runner" project (top level)
2. Select **"Add Files to Runner..."**
3. Navigate to `ios/` and select the `Shared` folder
4. Make sure **"Create groups"** is selected
5. Make sure both **"Runner"** and **"AssetWorksWidgetExtension"** targets are checked
6. Click **"Add"**

## 3. Configure Capabilities

In the project settings, select the **Runner** target:

### Signing & Capabilities tab:

1. **+ Capability** → **Push Notifications**
2. **+ Capability** → **App Groups**
   - Add group: `group.com.assetworks.widgets`
3. **+ Capability** → **Background Modes**
   - Check: Remote notifications
   - Check: Background fetch (optional)

## 4. Widget Extension Target

Make sure the **AssetWorksWidgetExtension** target:

1. Has the same **App Group** (`group.com.assetworks.widgets`)
2. Has the correct **Bundle Identifier**: `ai.assetworks.mobile.AssetWorksWidgetExtension`
3. Has the same **Team** as the main app

## 5. Info.plist Updates

Add to `ios/Runner/Info.plist`:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

## 6. Build Settings

For both targets (Runner and AssetWorksWidgetExtension):

1. **iOS Deployment Target**: 16.1 (for Dynamic Island)
2. **Swift Language Version**: Swift 5
3. **Build Active Architecture Only**: No (for Release)

## 7. Code Signing

1. Select proper **Team**
2. **Provisioning Profile**: Automatic
3. **Code Signing Identity**: Apple Development

## After Configuration

Once these steps are complete, run:

```bash
cd /Users/Victor/assetworks-reimagined
flutter clean
cd ios && pod install
flutter build ios --release
```

Then you can archive and upload to TestFlight.