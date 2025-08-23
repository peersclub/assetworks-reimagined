#!/bin/bash

# Archive and Upload to TestFlight Script
# Build version 1.0.0+3

echo "🚀 Starting TestFlight upload process for AssetWorks AI (1.0.0+3)"
echo "================================================"

# Clean build folder
echo "📧 Cleaning build folder..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build iOS release
echo "🔨 Building iOS release..."
flutter build ios --release

# Archive using xcodebuild
echo "📦 Creating archive..."
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/ios/archive/Runner.xcarchive \
  archive

# Export archive
echo "📤 Exporting archive..."
xcodebuild -exportArchive \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportPath build/ios/ipa \
  -exportOptionsPlist ios/ExportOptions.plist

echo "✅ Archive created successfully!"
echo ""
echo "📱 Next steps to upload to TestFlight:"
echo "1. Open Xcode"
echo "2. Go to Window → Organizer"
echo "3. Select the latest archive (version 1.0.0+3)"
echo "4. Click 'Distribute App'"
echo "5. Select 'App Store Connect' → Next"
echo "6. Select 'Upload' → Next"
echo "7. Follow the prompts to upload"
echo ""
echo "Or use Transporter app for direct upload of the .ipa file"