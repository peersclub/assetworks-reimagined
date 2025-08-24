#!/bin/bash

echo "🔧 AssetWorks Build Fix Script"
echo "=============================="

# 1. Clean everything
echo "1️⃣ Cleaning build folders..."
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData

# 2. Get dependencies
echo "2️⃣ Getting Flutter dependencies..."
flutter pub get

# 3. Fix iOS platform
echo "3️⃣ Updating iOS platform..."
cd ios
pod repo update
pod install --repo-update
cd ..

# 4. Fix permissions
echo "4️⃣ Fixing permissions..."
chmod -R 755 ios

# 5. Build for simulator
echo "5️⃣ Building for simulator..."
flutter build ios --simulator --debug

echo "✅ Build fix complete!"
echo ""
echo "Now try running:"
echo "flutter run -d 'iPhone 16 Plus'"