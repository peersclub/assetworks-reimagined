# AssetWorks Mobile - TestFlight Testing Notes

## Version 1.0.0 (Build 4)
**Release Date:** August 23, 2025

## 🎯 What's New in This Build

### Enhanced User Experience
- **Haptic Feedback System**: Feel every interaction with sophisticated haptic patterns
  - Light taps for selections
  - Medium impacts for buttons
  - Special vibration patterns for notifications
  - Long-press feedback for widget previews

- **Smooth Loading States**: Beautiful shimmer effects while content loads
  - Dashboard widgets show elegant loading animations
  - Trending section loads with visual feedback
  - No more blank screens during data fetching

- **Interactive Widget Cards**: Revolutionary long-press preview system
  - Press and hold any widget card to see instant HTML preview
  - View stats, summary, and mini visualization without navigation
  - Quick actions: Like, Share, Open Full view

### Core Improvements
- **Real-time Data**: All content from live staging API (staging-api.assetworks.ai)
- **Optimized Performance**: Dashboard loads cached data instantly, then refreshes
- **Enhanced Authentication**: Improved Face ID/Touch ID with haptic confirmation
- **Professional UI**: Font Awesome icons for Google/Apple sign-in

## 📋 What to Test

### 1. Authentication Flow
- [ ] **Face ID/Touch ID Login**
  - Enable biometric login in Profile > Security
  - Log out and log back in using Face ID
  - Verify haptic feedback when toggling biometric switch
  
- [ ] **Social Login**
  - Test "Continue with Google" button
  - Test "Continue with Apple" button
  - Verify branded icons display correctly

- [ ] **OTP Login**
  - Request OTP code
  - Verify back button works on OTP screen
  - Test auto-verification when 6 digits entered

### 2. Haptic Feedback
- [ ] **Button Interactions**
  - Tap any primary button - should feel medium impact
  - Tap outline buttons - should feel light impact
  - Tap text buttons - should feel selection click

- [ ] **Switches & Toggles**
  - Toggle Dark Mode in Settings
  - Toggle Face ID in Security settings
  - Each toggle should provide light haptic feedback

- [ ] **Notifications**
  - Receive a new notification
  - Should feel unique triple-tap vibration pattern

### 3. Widget Discovery & Interaction
- [ ] **Long Press Preview** (NEW FEATURE!)
  - Find any widget card
  - Press and hold for 0.5 seconds
  - Verify preview dialog appears with:
    - Mini HTML preview
    - Widget statistics
    - Quick action buttons
  - Release to dismiss or tap X to close

- [ ] **Widget Loading**
  - Navigate to Dashboard
  - Observe shimmer loading effects
  - Verify smooth transition to actual content

- [ ] **Trending Widgets**
  - Check Discover tab
  - Verify trending widgets load from real API
  - No dummy data should appear

### 4. Dashboard Experience
- [ ] **Quick Actions**
  - Test all 4 quick action cards:
    - Create → Opens widget creator
    - Discover → Opens discovery
    - Analyse → Opens analysis
    - History → Opens prompt history

- [ ] **Data Loading**
  - Pull to refresh on dashboard
  - Verify instant cache display
  - Watch for background data update

### 5. Profile Features
- [ ] **Widget Management**
  - View your saved widgets
  - Test pagination (scroll to load more)
  - Verify widget count matches profile header

- [ ] **Social Features**
  - Check followers/following counts
  - Test follow/unfollow actions
  - Verify profile picture upload

### 6. Creation Flow
- [ ] **Suggested Prompts**
  - Tap "Create Widget"
  - Test new gradient suggestion chips
  - Tap "More" to refresh suggestions
  - Verify haptic feedback on selection

- [ ] **Widget Generation**
  - Create a new widget
  - Test attachment upload
  - Verify History button goes to /prompt-history

### 7. Performance & Stability
- [ ] **App Launch**
  - Verify AssetWorks logo on splash screen
  - No crashes on cold start
  - Smooth transition to main screen

- [ ] **Memory Management**
  - Navigate through all screens
  - No memory warnings
  - Smooth scrolling in lists

- [ ] **Network Handling**
  - Test with WiFi
  - Test with cellular data
  - Test offline mode (cached data should display)

## 🐛 Known Issues to Verify Fixed
- ✅ Widget cards showing user IDs instead of usernames
- ✅ Bottom overflow errors on profile screen
- ✅ Face ID not showing in Security tab
- ✅ History button navigation to wrong screen
- ✅ Splash screen showing wrong logo
- ✅ Dashboard loading with empty state initially
- ✅ Trending widgets loading delay
- ✅ Dummy notifications instead of real ones

## 📱 Device Testing Matrix
Please test on:
- [ ] iPhone 16 Pro Max
- [ ] iPhone 16 Pro
- [ ] iPhone 16
- [ ] iPhone 15 series
- [ ] iPhone 14 series
- [ ] iPhone 13 series
- [ ] iPhone SE (3rd gen)
- [ ] iPad (if universal app)

## 🎨 Theme Testing
- [ ] Test in Light Mode
- [ ] Test in Dark Mode
- [ ] Switch themes while app is running
- [ ] Verify all colors adapt correctly

## 🌐 Localization
- [ ] Test with device in English
- [ ] Test with different region settings
- [ ] Verify number/date formatting

## 📝 Feedback Requested

1. **Haptic Feedback**: Is it too much, too little, or just right?
2. **Long Press Preview**: Is the interaction intuitive?
3. **Loading States**: Do shimmer effects improve perceived performance?
4. **Widget Discovery**: Is finding new widgets easy?
5. **Overall Performance**: Any lag or stuttering?

## 🚨 How to Report Issues

When reporting bugs, please include:
1. Device model and iOS version
2. Steps to reproduce
3. Expected vs actual behavior
4. Screenshots if applicable
5. Crash logs (if app crashes)

## 📧 Contact

For urgent issues or questions:
- Email: support@assetworks.ai
- In-app: Profile → Settings → Help & Support

## 🔄 Version History

### Build 4 (Current)
- Added comprehensive haptic feedback
- Implemented shimmer loaders
- Added long-press widget preview
- Fixed all UI/UX issues
- Connected to real API

### Build 3
- Initial TestFlight release
- Basic functionality

---

**Thank you for testing AssetWorks Mobile!** Your feedback helps us build a better investment intelligence platform. 🚀