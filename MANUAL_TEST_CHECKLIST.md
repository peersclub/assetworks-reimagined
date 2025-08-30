# Manual Testing Checklist - AssetWorks Reimagined

## 🚀 When App Launches on Your iPhone

### Initial Tests:

#### 1. **App Launch & Splash Screen**
- [ ] App opens without crashing
- [ ] Splash screen appears
- [ ] Smooth transition to main screen

#### 2. **Authentication (Priority)**
- [ ] Try Email OTP login:
  - Enter email
  - Receive OTP code
  - Verify it works
- [ ] Check if session persists after closing app
- [ ] Test logout functionality

#### 3. **Multi-AI Provider Feature (NEW - MUST TEST)**
- [ ] Navigate to Create Widget
- [ ] Look for AI Provider selection:
  - Should see Claude, OpenAI, Gemini, Perplexity options
  - Each provider should show pricing/credits
  - Try creating a widget with different providers
- [ ] Check if provider selection UI is smooth

#### 4. **API Integration Fixes (CRITICAL)**
- [ ] **Template Generation Test**:
  - Go to Create Widget
  - Look for template options
  - Try using a template
  - Check if templates load properly
  
- [ ] **Widget View by ID Test**:
  - Go to Prompt History
  - Tap on any previous widget
  - Should load and display properly
  
- [ ] **Error Handling**:
  - Try actions while offline
  - Check if error messages are user-friendly

#### 5. **Widget Creation & Management**
- [ ] Create a new widget:
  - Enter a prompt like "Create a stock price tracker"
  - Select an AI provider
  - Watch creation process
- [ ] Test widget actions:
  - Like/Unlike
  - Add to Dashboard
  - Share (should show copy options)
  - Delete (if it's your widget)

#### 6. **Dashboard Features**
- [ ] View main dashboard
- [ ] Check if widgets display correctly
- [ ] Test pull-to-refresh
- [ ] Navigate between tabs

#### 7. **iOS-Specific Features**
- [ ] **Dynamic Island** (if iPhone 14 Pro or newer):
  - Start creating a widget
  - Check if Dynamic Island shows progress
  - Long press Dynamic Island for expanded view
  
- [ ] **Haptic Feedback**:
  - Feel vibrations on button taps
  - Notice different haptic patterns
  
- [ ] **Dark/Light Mode**:
  - Toggle theme in settings
  - Check all screens adapt properly

#### 8. **Social Features**
- [ ] Tap on user avatars/names
- [ ] Navigate to user profiles
- [ ] Test follow/unfollow buttons
- [ ] Check if @ usernames display correctly

#### 9. **Performance Tests**
- [ ] Scroll through lists smoothly
- [ ] No lag when switching tabs
- [ ] Images load with placeholders
- [ ] Animations are smooth

#### 10. **Bug Checks**
- [ ] No yellow/red error screens
- [ ] No blank/empty screens
- [ ] All buttons are responsive
- [ ] Text is readable in both themes

---

## 🔴 Critical Issues to Watch For:

1. **Crashes** - Note which screen/action caused it
2. **API Errors** - Screenshot error messages
3. **UI Glitches** - Take screenshots
4. **Missing Features** - Note what's not working
5. **Performance Issues** - Note where lag occurs

---

## 📝 How to Report Issues:

For each issue found:
1. **Screen**: Where it happened
2. **Action**: What you were doing
3. **Expected**: What should happen
4. **Actual**: What happened
5. **Screenshot**: If possible

---

## ✅ Priority Testing Order:

1. **Authentication** - Must work for other features
2. **Multi-AI Providers** - New critical feature
3. **API Fixes** - Verify recent fixes work
4. **Widget Creation** - Core functionality
5. **iOS Features** - Platform-specific enhancements

---

## 📱 Device Info for Report:
- Device: Victor's iPhone
- iOS Version: 18.6.2
- Build Number: 1.0.0+5
- Test Date: August 25, 2025