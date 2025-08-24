# AssetWorks App Test Flow

## Test Account
Email: test@assetworks.ai

## Test Checklist

### 1. Authentication Flow ✅
- [x] App launches with splash screen
- [x] Login screen appears
- [x] Email input validation works
- [x] OTP sent successfully
- [x] OTP verification screen appears
- [x] OTP can be entered
- [ ] Login successful (needs valid OTP)

### 2. Main Features (After Login)
- [ ] Dashboard loads with widgets
- [ ] Can create new widget from prompt
- [ ] Widget preview works
- [ ] Like/Unlike widget works
- [ ] Save/Unsave widget works
- [ ] Profile screen loads
- [ ] Settings accessible

### 3. Issues Found
1. **Sign-in Fixed**: Changed import path for ApiService
2. **OTP Methods Fixed**: Updated to use correct sendOTP method
3. **Parameter Fix**: Fixed verifyOTP parameters

### 4. API Endpoints Status
- ✅ `/api/v1/auth/otp/send` - Working
- ✅ `/api/v1/auth/otp/verify` - Ready to test
- Base URL: https://api.assetworks.ai

## Next Steps
1. Need actual OTP from email to complete login test
2. Test all main features after login
3. Verify Dynamic Island mock functionality
4. Push to TestFlight after confirming core features work