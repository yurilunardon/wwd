# HandyShots 📸

**HandyShots** is an open-source macOS menu bar application that provides quick access to recent screenshots with a visual grid interface, hover-to-zoom functionality, and drag-and-drop support.

## ✨ Features

- 🎯 **Menu Bar App** - Lives in your menu bar, no dock icon
- 🔍 **Auto-Detection** - Automatically finds your screenshot folder
- 👋 **Welcome Animation** - Animated greeting on first launch
- 🖼️ **Grid View** - Beautiful grid display of recent screenshots
- 🔎 **Hover to Zoom** - Smooth zoom animation when hovering
- 📤 **Drag & Drop** - Easily drag screenshots to other apps
- ⚡ **Real-time Monitoring** - Detects system screenshot folder changes
- ⚙️ **Customizable** - Configure time filter (1-60 minutes)

## 🚀 Getting Started

### Prerequisites

- macOS 13.0 or later
- Xcode 14.0 or later

### Building from Source

1. **Open the project in Xcode:**
   ```bash
   cd HandyShots
   open HandyShots.xcodeproj
   ```

2. **Build and run:**
   - Press `Cmd+R` in Xcode, or
   - Use the build script:
     ```bash
     chmod +x launch.sh
     ./launch.sh
     ```

### Quick Build Script

The included `launch.sh` script will build and launch the app:

```bash
./launch.sh
```

## 🎯 Usage

### First Launch

1. Click the camera icon in your menu bar
2. Watch the welcome animation 👋
3. Confirm or change your screenshot folder
4. Start using HandyShots!

### Daily Use

- **Click menu bar icon** - Opens the popover with recent screenshots
- **Hover over screenshot** - Smooth zoom animation
- **Drag screenshot** - Drag to other apps (Messages, Mail, etc.)
- **Right-click icon** - Access settings and quit option

### Settings

- **Time Filter**: Show screenshots from the last 1-60 minutes
- **Screenshot Folder**: Change the folder to monitor

## 📁 Project Structure

```
HandyShots/
├── HandyShots/
│   ├── HandyShotsApp.swift          # Main app entry point
│   ├── Views/
│   │   ├── WelcomeView.swift        # First launch experience
│   │   ├── WelcomeAnimationView.swift # Hello animation
│   │   ├── PopoverView.swift        # Main popover container
│   │   ├── ScreenshotGridView.swift # Grid layout
│   │   ├── ScreenshotItemView.swift # Single screenshot card
│   │   └── SettingsView.swift       # Settings panel
│   ├── Models/
│   │   ├── Screenshot.swift         # Screenshot data model
│   │   └── AppSettings.swift        # User preferences
│   ├── Utilities/
│   │   ├── FolderDetector.swift     # Detects screenshot folder
│   │   ├── FolderMonitor.swift      # Real-time folder monitoring
│   │   ├── ScreenshotLoader.swift   # Loads & filters screenshots
│   │   └── UIHelpers.swift          # Helper functions
│   └── Resources/
│       ├── Info.plist
│       └── HandyShots.entitlements
├── README.md
├── launch.sh                        # Build & launch script
└── handyshots-mvp-spec.md          # Technical specification
```

## 🔧 Technical Details

### Architecture

- **Language**: Swift 5.0
- **Framework**: SwiftUI + AppKit
- **Pattern**: MVVM
- **Target**: macOS 13.0+

### Key Technologies

- `NSStatusItem` - Menu bar integration
- `NSPopover` - Popover UI
- `DistributedNotificationCenter` - System screenshot location monitoring
- `FileManager` - File system operations
- `NSImage` - Image loading and thumbnail generation

## 🛠️ Development

### Testing Screenshot Detection

```bash
# Change screenshot location to Downloads
defaults write com.apple.screencapture location ~/Downloads
killall SystemUIServer

# App should detect the change automatically
```

### Testing Time Filter

1. Take several screenshots over 10 minutes
2. Open HandyShots
3. Adjust time filter in settings (e.g., 5 min → 15 min)
4. Watch the grid update in real-time

## 🐛 Troubleshooting

### "Containers" path detected or limited access
If you see a path with "Containers" or the app has limited access:

1. **Option 1 (Recommended)**: Click "Choose Different..." and manually select your Desktop folder
2. **Option 2**: Grant Full Disk Access:
   - Open **System Settings** → **Privacy & Security** → **Full Disk Access**
   - Click the **+** button and add HandyShots.app
   - Restart HandyShots

### Folder not detected
Check permissions and verify the defaults command works:
```bash
defaults read com.apple.screencapture location
```

### Screenshots not loading
Verify folder permissions and file extensions:
```bash
ls -la ~/Desktop/*.png
```

### Popover not showing
Ensure `LSUIElement` is set to `true` in Info.plist

## 📝 License

This project is open source. Feel free to use, modify, and distribute as needed.

## 🙏 Acknowledgments

Built following the MVP specification in `handyshots-mvp-spec.md`.

## 🚀 Roadmap

- [ ] Video-based welcome animation
- [ ] Screenshot preview on click
- [ ] Quick actions (copy, delete, share)
- [ ] Keyboard shortcuts
- [ ] Dark mode optimization
- [ ] Copy to clipboard
- [ ] Quick annotations

---

**Enjoy HandyShots!** 📸
