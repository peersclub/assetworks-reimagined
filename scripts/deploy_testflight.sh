#!/bin/bash

echo "🚀 AssetWorks TestFlight Deployment Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="AssetWorks"
SCHEME="Runner"
CONFIGURATION="Release"
EXPORT_PATH="build/ios/ipa"

echo ""
echo "📱 Step 1: Cleaning previous builds..."
flutter clean
rm -rf $EXPORT_PATH

echo ""
echo "📦 Step 2: Getting dependencies..."
flutter pub get

echo ""
echo "🔨 Step 3: Building iOS release..."
flutter build ios --release --no-codesign

echo ""
echo "🏗️ Step 4: Archiving with Xcode..."
cd ios

# Archive the app
xcodebuild -workspace Runner.xcworkspace \
  -scheme $SCHEME \
  -configuration $CONFIGURATION \
  -archivePath ../build/ios/Runner.xcarchive \
  archive \
  -allowProvisioningUpdates

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Archive failed${NC}"
    exit 1
fi

echo ""
echo "📤 Step 5: Exporting for App Store..."

# Create ExportOptions.plist
cat > ../build/ios/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>97U2KB248P</string>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

# Export the archive
xcodebuild -exportArchive \
  -archivePath ../build/ios/Runner.xcarchive \
  -exportPath ../$EXPORT_PATH \
  -exportOptionsPlist ../build/ios/ExportOptions.plist \
  -allowProvisioningUpdates

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Export failed${NC}"
    exit 1
fi

cd ..

echo ""
echo "📱 Step 6: Uploading to App Store Connect..."

# Upload to App Store Connect
xcrun altool --upload-app \
  --type ios \
  --file "$EXPORT_PATH/Runner.ipa" \
  --username "victor@assetworks.ai" \
  --password "@keychain:AC_PASSWORD"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Success! App uploaded to TestFlight${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Go to App Store Connect"
    echo "2. Wait for processing (usually 5-10 minutes)"
    echo "3. Submit for TestFlight review"
    echo "4. Once approved, share TestFlight link with testers"
else
    echo -e "${RED}❌ Upload failed${NC}"
    echo "Please check your credentials and try again"
fi

echo ""
echo "📊 Build Info:"
echo "  Version: 1.0.0"
echo "  Build: 4"
echo "  Bundle ID: ai.assetworks.mobile"
echo ""