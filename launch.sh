#!/bin/bash
set -e

echo "🧹 Resetting app data..."
# Kill any running instance
killall HandyShots 2>/dev/null || true

# Reset UserDefaults for HandyShots
defaults delete com.handyshots.HandyShots 2>/dev/null || true

echo "🔨 Building HandyShots..."
xcodebuild -project HandyShots.xcodeproj \
           -scheme HandyShots \
           -configuration Debug \
           -derivedDataPath build \
           clean build > /dev/null 2>&1

echo "🚀 Launching HandyShots..."
open build/Build/Products/Debug/HandyShots.app

echo "✅ HandyShots is running with fresh state!"
