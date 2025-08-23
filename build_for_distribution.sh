#!/bin/bash

# AssetWorks Mobile - Build for Distribution Script
# Version 1.0.0 (Build 4)

echo "🚀 AssetWorks Mobile - Build for Distribution"
echo "============================================"
echo "Version: 1.0.0 (Build 4)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Error: pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

echo "Select build type:"
echo "1) iOS (TestFlight/App Store)"
echo "2) Android (Google Play)"
echo "3) Both"
read -p "Enter choice (1-3): " choice

# Clean previous builds
echo ""
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf build/
print_status "Clean complete"

# Get dependencies
echo ""
echo "📦 Getting dependencies..."
flutter pub get
print_status "Dependencies updated"

# iOS Build
build_ios() {
    echo ""
    echo "🍎 Building iOS..."
    
    # Install pods
    echo "Installing CocoaPods..."
    cd ios
    pod install
    cd ..
    print_status "Pods installed"
    
    # Build iOS
    echo "Building iOS release..."
    flutter build ios --release --no-codesign
    
    if [ $? -eq 0 ]; then
        print_status "iOS build successful!"
        echo ""
        echo "📱 Next steps for iOS:"
        echo "1. Open Xcode: open ios/Runner.xcworkspace"
        echo "2. Select 'Any iOS Device (arm64)' as target"
        echo "3. Product → Archive"
        echo "4. Distribute App → App Store Connect → Upload"
        echo ""
        echo "📝 TestFlight notes are in: TESTFLIGHT_SUBMISSION_NOTES.txt"
    else
        print_error "iOS build failed!"
        exit 1
    fi
}

# Android Build
build_android() {
    echo ""
    echo "🤖 Building Android..."
    
    echo "Select Android build type:"
    echo "1) App Bundle (AAB) - for Play Store"
    echo "2) APK - for direct distribution"
    read -p "Enter choice (1-2): " android_choice
    
    if [ "$android_choice" = "1" ]; then
        echo "Building App Bundle..."
        flutter build appbundle --release
        
        if [ $? -eq 0 ]; then
            print_status "Android App Bundle build successful!"
            echo ""
            echo "📦 AAB location: build/app/outputs/bundle/release/app-release.aab"
            echo ""
            echo "📱 Next steps for Android:"
            echo "1. Go to Google Play Console"
            echo "2. Upload AAB to Internal Testing track"
            echo "3. Add release notes and roll out"
        else
            print_error "Android build failed!"
            exit 1
        fi
    else
        echo "Building APK..."
        flutter build apk --release
        
        if [ $? -eq 0 ]; then
            print_status "Android APK build successful!"
            echo ""
            echo "📦 APK location: build/app/outputs/flutter-apk/app-release.apk"
            APK_SIZE=$(ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')
            echo "📊 APK size: $APK_SIZE"
        else
            print_error "Android build failed!"
            exit 1
        fi
    fi
}

# Execute based on choice
case $choice in
    1)
        build_ios
        ;;
    2)
        build_android
        ;;
    3)
        build_ios
        build_android
        ;;
    *)
        print_error "Invalid choice!"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
print_status "Build process complete!"
echo ""
echo "📋 Testing Guide: TESTFLIGHT_v1.0.0_TESTING.md"
echo "📝 Distribution Guide: DISTRIBUTION_GUIDE_v1.0.0.md"
echo "📱 Version: 1.0.0 (Build 4)"
echo ""
echo "🎯 Key Features to Test:"
echo "  • 5x faster loading"
echo "  • Haptic feedback"
echo "  • Long-press widget preview"
echo "  • Release notes in Settings"
echo "  • Smart offline caching"
echo ""
echo "Good luck with your release! 🚀"