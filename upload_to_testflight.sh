#!/bin/bash

# AssetWorks Reimagined - TestFlight Upload Script
# This script helps upload your app to TestFlight

echo "========================================="
echo "AssetWorks Reimagined - TestFlight Upload"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if archive exists
if [ ! -d "build/AssetWorks.xcarchive" ]; then
    echo -e "${RED}Error: Archive not found at build/AssetWorks.xcarchive${NC}"
    echo "Please run the build process first."
    exit 1
fi

echo -e "${GREEN}✓ Archive found${NC}"
echo ""

# Function to export archive
export_archive() {
    echo "Step 1: Exporting archive for App Store..."
    echo "----------------------------------------"
    
    xcodebuild -exportArchive \
        -archivePath build/AssetWorks.xcarchive \
        -exportPath build/export \
        -exportOptionsPlist ExportOptions.plist \
        -allowProvisioningUpdates
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Archive exported successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Export failed${NC}"
        return 1
    fi
}

# Function to upload with xcrun altool
upload_with_altool() {
    echo ""
    echo "Step 2: Uploading to App Store Connect..."
    echo "----------------------------------------"
    echo ""
    echo "You'll need your Apple ID credentials:"
    echo "  • Apple ID email"
    echo "  • App-specific password (create at appleid.apple.com)"
    echo ""
    
    read -p "Enter your Apple ID email: " APPLE_ID
    read -s -p "Enter your app-specific password: " APP_PASSWORD
    echo ""
    echo ""
    
    echo "Validating and uploading IPA..."
    
    xcrun altool --upload-app \
        -f build/export/Runner.ipa \
        -t ios \
        -u "$APPLE_ID" \
        -p "$APP_PASSWORD" \
        --verbose
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Upload successful!${NC}"
        return 0
    else
        echo -e "${RED}✗ Upload failed${NC}"
        return 1
    fi
}

# Function to upload with Transporter
upload_with_transporter() {
    echo ""
    echo "Alternative: Upload with Transporter app"
    echo "----------------------------------------"
    echo ""
    echo "1. Open Transporter app (download from Mac App Store if needed)"
    echo "2. Sign in with your Apple ID"
    echo "3. Drag the IPA file from: build/export/Runner.ipa"
    echo "4. Click 'Deliver'"
    echo ""
    echo "IPA location: $(pwd)/build/export/Runner.ipa"
    echo ""
    open -a Transporter 2>/dev/null || echo "Transporter not installed. Download from Mac App Store."
    open build/export/ 2>/dev/null
}

# Main flow
echo "Choose upload method:"
echo "1) Automatic (xcrun altool)"
echo "2) Manual (Xcode Organizer)"
echo "3) Transporter app"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        export_archive
        if [ $? -eq 0 ]; then
            upload_with_altool
            if [ $? -eq 0 ]; then
                echo ""
                echo -e "${GREEN}=========================================${NC}"
                echo -e "${GREEN}Success! Your app is uploading to TestFlight${NC}"
                echo -e "${GREEN}=========================================${NC}"
                echo ""
                echo "Next steps:"
                echo "1. Go to App Store Connect: https://appstoreconnect.apple.com"
                echo "2. Select your app"
                echo "3. Go to TestFlight tab"
                echo "4. Wait for processing (usually 5-10 minutes)"
                echo "5. Add testers and start testing!"
            fi
        fi
        ;;
    2)
        echo ""
        echo "Opening Xcode Organizer..."
        echo "----------------------------------------"
        echo ""
        echo "Steps in Xcode:"
        echo "1. Window → Organizer (or ⌥⌘⇧O)"
        echo "2. Select 'AssetWorks' archive"
        echo "3. Click 'Distribute App'"
        echo "4. Choose 'App Store Connect'"
        echo "5. Follow the upload wizard"
        echo ""
        open -a Xcode
        xcodebuild -exportArchive -exportOptionsPlist ExportOptions.plist -archivePath build/AssetWorks.xcarchive -exportPath build/export -allowProvisioningUpdates
        ;;
    3)
        export_archive
        if [ $? -eq 0 ]; then
            upload_with_transporter
        fi
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo "GitHub Repository: https://github.com/peersclub/assetworks-reimagined"
echo "Support: https://developer.apple.com/testflight/"