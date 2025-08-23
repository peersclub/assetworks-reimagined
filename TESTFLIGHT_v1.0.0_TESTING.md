# AssetWorks Mobile v1.0.0 - TestFlight Testing Guide

## 🎯 Release Overview
**Version:** 1.0.0 (Build 4)  
**Type:** Production Release  
**Focus:** World-class performance, comprehensive error handling, exceptional UX

## 🔥 Critical Testing Areas

### 1. Performance Testing (HIGH PRIORITY)
**Expected:** Dashboard loads in <500ms (cached) or <2s (fresh)

#### Test Steps:
1. **Cold Start Performance**
   - Force quit app completely
   - Open app and time dashboard load
   - ✅ Should load within 2 seconds

2. **Warm Start Performance**
   - Background the app (don't force quit)
   - Reopen and time dashboard load
   - ✅ Should load instantly (<500ms)

3. **Scroll Performance**
   - Scroll through dashboard rapidly
   - Switch between tabs quickly
   - ✅ No lag, smooth 60fps

### 2. Haptic Feedback System (NEW)
**Test every interaction for tactile feedback:**

#### Areas to Test:
- [ ] Tab bar switches (light impact)
- [ ] Button taps (light impact)
- [ ] Widget card interactions (medium impact)
- [ ] Long press on widgets (heavy impact)
- [ ] Pull to refresh (medium impact)
- [ ] Error retry buttons (light impact)
- [ ] Toggle switches in settings (light impact)

### 3. Interactive Widget Cards (NEW)
**Long-press any widget for instant preview:**

#### Test Scenarios:
1. **Long Press Preview**
   - Long press any widget card (feel haptic)
   - ✅ Bottom sheet appears with HTML preview
   - ✅ Shows title, stats, and preview
   - ✅ Can copy widget code

2. **Widget Actions**
   - Tap heart to like/unlike
   - Tap bookmark to save/unsave
   - Tap share button
   - ✅ All actions have haptic feedback

### 4. Empty States Testing
**Test all empty state scenarios:**

#### Screens to Check:
1. **Dashboard** (new user)
   - Sign up with new account
   - ✅ Shows "No Widgets Yet" with CTA

2. **Notifications** 
   - Clear all notifications
   - ✅ Shows "No Notifications" state

3. **Discovery Search**
   - Search for "xyzabc123"
   - ✅ Shows "No Results Found"

4. **Profile Widgets Tab**
   - View profile with no widgets
   - ✅ Shows appropriate empty state

### 5. Error Handling & Recovery
**Test network and error scenarios:**

#### Test Cases:
1. **No Internet**
   - Turn on Airplane Mode
   - Try to load dashboard
   - ✅ Shows cached data with offline indicator
   - ✅ Retry button appears

2. **Slow Network**
   - Use Network Link Conditioner (3G)
   - Navigate through app
   - ✅ Shows shimmer loaders
   - ✅ No blank screens

3. **API Errors**
   - Wait for any API timeout
   - ✅ Shows specific error message
   - ✅ Retry mechanism works

### 6. Release Notes Feature (NEW)
**Navigate: Settings > What's New**

#### Test Points:
1. **Version Selector**
   - Tap version pills at top
   - ✅ Switches between v1.0.0, v0.9.0, v0.8.0
   - ✅ Current version has green indicator

2. **Feature Cards**
   - Tap any feature card
   - ✅ Opens detail bottom sheet
   - ✅ Shows full description
   - ✅ "NEW" badges visible

3. **Settings Integration**
   - Check Settings screen
   - ✅ Shows current version (1.0.0)
   - ✅ "LATEST" badge displayed
   - ✅ "What's New" has NEW indicator

### 7. Loading States & Transitions
**All loading should use shimmer effects:**

#### Areas to Verify:
- [ ] Dashboard initial load (shimmer cards)
- [ ] Discovery page load (shimmer grid)
- [ ] Profile load (shimmer skeleton)
- [ ] Notifications load (shimmer list)
- [ ] No jarring layout shifts
- [ ] Smooth fade transitions

### 8. Caching System
**Test intelligent cache behavior:**

#### Test Sequence:
1. Load dashboard (caches data)
2. Turn on Airplane Mode
3. Force quit and reopen app
4. ✅ Dashboard shows cached data
5. Turn off Airplane Mode
6. Pull to refresh
7. ✅ Fresh data loads

### 9. Dark Mode Support
**Toggle dark mode in Settings:**

#### Check These Screens:
- [ ] Dashboard (all cards themed)
- [ ] Release Notes (proper contrast)
- [ ] Settings (readable text)
- [ ] Create Widget (input fields)
- [ ] Empty states (proper colors)
- [ ] Error states (good visibility)

### 10. Authentication Flow
**Test login improvements:**

#### Verify:
- [ ] Font Awesome icons for Google/Apple login
- [ ] Face ID toggle persists
- [ ] Biometric login works
- [ ] Session persistence after app restart
- [ ] Logout clears all cached data

## 📋 Quick Regression Checklist

### Core Functionality
- [ ] Login with email/OTP works
- [ ] Dashboard loads with user widgets
- [ ] Create new widget works
- [ ] Discovery shows trending widgets
- [ ] Notifications display correctly
- [ ] Profile shows user stats
- [ ] Settings preferences persist
- [ ] Logout works properly

### UI/UX Polish
- [ ] No yellow/black overflow warnings
- [ ] All text is readable (light & dark)
- [ ] Icons display correctly
- [ ] Images load with placeholders
- [ ] Animations are smooth
- [ ] Pull-to-refresh works everywhere
- [ ] Keyboard dismisses properly

### Fixed Issues
- [ ] Widget cards show usernames (not IDs)
- [ ] History button navigates correctly
- [ ] Real notifications from API
- [ ] AssetWorks logo displays properly
- [ ] No setState() errors in console

## 🐛 Bug Reporting Template

If you find an issue, please report with:

```
Device: [iPhone model]
iOS Version: [version]
App Version: 1.0.0 (4)
Issue: [Brief description]
Steps to Reproduce:
1. [Step 1]
2. [Step 2]
Expected: [What should happen]
Actual: [What happened]
Screenshot/Video: [If applicable]
```

## 💡 Performance Metrics to Note

Please observe and report:
1. **Dashboard Load Time:** ___ seconds
2. **Widget Creation Time:** ___ seconds
3. **Discovery Page Load:** ___ seconds
4. **App Cold Start:** ___ seconds
5. **Memory Usage:** Normal/High
6. **Battery Impact:** Normal/High
7. **Data Usage:** Reasonable/Excessive

## 🎯 Priority Focus Areas

1. **Performance** - Is it noticeably faster?
2. **Haptic Feedback** - Does it feel premium?
3. **Error Handling** - Are errors graceful?
4. **Empty States** - Are they helpful?
5. **Release Notes** - Easy to understand?

## 📱 Device Coverage Needed

Please test on:
- [ ] iPhone 15 Pro/Pro Max
- [ ] iPhone 14/13 series
- [ ] iPhone 12 mini (small screen)
- [ ] iPhone SE (oldest supported)
- [ ] iPad (if universal app)

## 🎉 New Features to Explore

1. **Long-press any widget** for instant HTML preview
2. **Check Settings > What's New** for release notes
3. **Feel the haptic feedback** throughout the app
4. **Test offline mode** - app works without internet
5. **Notice the shimmer loaders** instead of blank screens

## 📝 Feedback We Need

1. Is the app noticeably faster?
2. Do the haptics enhance the experience?
3. Are error messages helpful?
4. Is the release notes feature useful?
5. Any crashes or freezes?
6. Any confusing UI elements?
7. Missing features you expected?

## 🚀 Thank You!

Your testing helps us deliver a world-class investment app. This release represents a massive performance and UX upgrade. Every piece of feedback matters!

**Report issues to:** support@assetworks.ai  
**Slack channel:** #mobile-beta-testing  

Happy Testing! 🎯