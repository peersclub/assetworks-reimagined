#!/bin/bash

# AssetWorks Mobile - Physical Device Installation Script
# This script helps install the app on a physical iPhone

echo "========================================="
echo "AssetWorks Mobile - Device Installation"
echo "========================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

# Check if device is connected
echo ""
echo -e "${BLUE}1. Checking for connected devices...${NC}"
DEVICE_LIST=$(xcrun devicectl list devices | grep -E "iPhone|iPad" | grep -v "Simulator")

if [ -z "$DEVICE_LIST" ]; then
    echo -e "${RED}No physical devices found!${NC}"
    echo ""
    echo "Please ensure:"
    echo "  1. Your iPhone is connected via USB"
    echo "  2. You've trusted this computer on your device"
    echo "  3. Developer mode is enabled on your device (Settings > Privacy & Security > Developer Mode)"
    exit 1
else
    echo -e "${GREEN}Found connected device(s):${NC}"
    echo "$DEVICE_LIST"
fi

# Get device UDID
DEVICE_UDID=$(xcrun devicectl list devices | grep -E "iPhone|iPad" | grep -v "Simulator" | head -1 | awk '{print $NF}' | tr -d '()')

if [ -z "$DEVICE_UDID" ]; then
    echo -e "${RED}Could not get device UDID${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}2. Device UDID: $DEVICE_UDID${NC}"

# Build options
echo ""
echo -e "${YELLOW}Select installation method:${NC}"
echo "  1) Install via Xcode (Recommended - handles signing automatically)"
echo "  2) Install via xcrun devicectl (Requires manual signing)"
echo "  3) Build and archive for TestFlight"
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}Opening Xcode...${NC}"
        open /Users/Victor/Projects/assetworks_mobile_new/ios/Runner.xcworkspace
        
        echo ""
        echo -e "${GREEN}=========================================${NC}"
        echo -e "${GREEN}Xcode Installation Instructions:${NC}"
        echo -e "${GREEN}=========================================${NC}"
        echo ""
        echo "1. In Xcode, select your device from the device list (top bar)"
        echo "2. Select 'Runner' target"
        echo "3. Go to 'Signing & Capabilities' tab"
        echo "4. Select your Team (or add your Apple ID)"
        echo "5. Click the Play button (▶) to build and run"
        echo ""
        echo "If you see signing errors:"
        echo "  - Change Bundle Identifier to something unique"
        echo "  - Enable 'Automatically manage signing'"
        echo "  - Select your personal team or Apple Developer account"
        ;;
        
    2)
        echo ""
        echo -e "${BLUE}Building for device...${NC}"
        flutter build ios --release
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Build failed!${NC}"
            echo "Please fix build errors and try again"
            exit 1
        fi
        
        echo ""
        echo -e "${BLUE}Installing on device...${NC}"
        xcrun devicectl device install app --device "$DEVICE_UDID" /Users/Victor/Projects/assetworks_mobile_new/build/ios/iphoneos/Runner.app
        
        if [ $? -eq 0 ]; then
            print_status 0 "App installed successfully!"
            
            echo ""
            echo -e "${BLUE}Launching app...${NC}"
            xcrun devicectl device process launch --device "$DEVICE_UDID" com.assetworks.assetworksMobileNew
        else
            echo -e "${RED}Installation failed!${NC}"
            echo ""
            echo "This usually means the app needs to be signed."
            echo "Please use option 1 (Xcode) for automatic signing."
        fi
        ;;
        
    3)
        echo ""
        echo -e "${BLUE}Building for TestFlight...${NC}"
        
        # Clean build
        flutter clean
        flutter pub get
        cd ios && pod install && cd ..
        
        # Build archive
        flutter build ipa --export-options-plist=ios/ExportOptions.plist
        
        if [ $? -eq 0 ]; then
            print_status 0 "IPA built successfully!"
            echo ""
            echo "Archive location: build/ios/archive/Runner.xcarchive"
            echo "IPA location: build/ios/ipa/assetworks_mobile_new.ipa"
            echo ""
            echo "Next steps:"
            echo "  1. Open Xcode"
            echo "  2. Go to Window > Organizer"
            echo "  3. Select your archive"
            echo "  4. Click 'Distribute App'"
            echo "  5. Follow the TestFlight upload process"
        else
            echo -e "${RED}Archive build failed!${NC}"
            echo "Please ensure you have a valid provisioning profile and certificates"
        fi
        ;;
        
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Additional Information:${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "App Details:"
echo "  Bundle ID: com.assetworks.assetworksMobileNew"
echo "  Version: 2.0.0"
echo "  Build: 2000000"
echo ""
echo "Requirements for Physical Device:"
echo "  • iOS 13.0 or later"
echo "  • Developer Mode enabled (iOS 16+)"
echo "  • Trust this computer"
echo "  • Valid provisioning profile (for App Store distribution)"
echo ""
echo "For development testing:"
echo "  • Use your personal Apple ID"
echo "  • Free provisioning allows 7-day installation"
echo "  • Up to 3 devices can be registered"
echo ""
echo "For App Store distribution:"
echo "  • Requires Apple Developer Program membership (\$99/year)"
echo "  • Unlimited device testing via TestFlight"
echo "  • Production provisioning profiles"