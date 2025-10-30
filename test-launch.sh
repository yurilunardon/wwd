#!/bin/bash
set -e

echo "🧪 HandyShots - Test Launch Script"
echo "===================================="
echo ""

# Chiedi se fare reset completo
read -p "Reset app data for first launch test? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 Resetting app data..."
    
    # Termina eventuali istanze in esecuzione
    killall HandyShots 2>/dev/null || true
    
    # Resetta UserDefaults
    defaults delete com.handyshots.HandyShots 2>/dev/null || true
    
    # Reset TCC (Transparency, Consent, and Control) permissions
    echo "🔐 Resetting permissions (requires admin password)..."
    tccutil reset All com.handyshots.HandyShots 2>/dev/null || true
    
    echo "✅ App data and permissions reset complete"
    echo ""
fi

# Build
echo "🔨 Building HandyShots..."
xcodebuild -project HandyShots.xcodeproj \
           -scheme HandyShots \
           -configuration Debug \
           -derivedDataPath build \
           clean build > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "🚀 Launching HandyShots..."
open build/Build/Products/Debug/HandyShots.app

echo ""
echo "✅ HandyShots is running!"
echo ""
echo "📝 Test Checklist:"
echo "  1. Check permission screen appears (if first launch)"
echo "  2. Grant Full Disk Access in System Settings"
echo "  3. Verify Hello animation plays"
echo "  4. Confirm folder selection works"
echo "  5. Check screenshot grid loads"
echo "  6. Test Change button in grid"
echo "  7. Test folder change alert"
echo ""
echo "To check current settings:"
echo "  defaults read com.handyshots.HandyShots"
echo ""