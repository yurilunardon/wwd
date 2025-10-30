# HandyShots - MVP Technical Specification

## 🎯 Project Overview

**HandyShots** is an open-source macOS menu bar application that provides quick access to recent screenshots with a visual grid interface, hover-to-zoom functionality, and drag-and-drop support.

### Key Features
- Menu bar app (LSUIElement = true, no dock icon)
- Auto-detects system screenshot folder at first launch
- Animated welcome screen on first run
- Grid view of recent screenshots (configurable time window)
- Hover-to-zoom with smooth animations
- Drag-and-drop screenshots to other apps
- Real-time folder monitoring (event-driven, no polling)
- Settings to configure time filter

---

## 📋 Technical Requirements

### Platform
- **Target**: macOS 13.0+
- **Language**: Swift 5.0
- **Framework**: SwiftUI + AppKit
- **Architecture**: MVVM pattern
- **Distribution**: Open source (no App Store restrictions)

### Required Entitlements
```xml
<!-- HandyShots.entitlements -->
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
```

---

## 🏗️ Architecture & Components

### 1. App Structure

```
HandyShots/
├── HandyShotsApp.swift          # Main app + AppDelegate
├── Views/
│   ├── WelcomeView.swift        # First launch with animation
│   ├── PopoverView.swift        # Main grid view
│   ├── ScreenshotGridView.swift # Grid of screenshots
│   ├── ScreenshotItemView.swift # Single screenshot card
│   └── SettingsView.swift       # Settings window
├── Models/
│   ├── Screenshot.swift         # Screenshot data model
│   └── AppSettings.swift        # User preferences
├── Utilities/
│   ├── FolderDetector.swift     # Detects macOS screenshot folder
│   ├── FolderMonitor.swift      # Real-time folder monitoring
│   ├── ScreenshotLoader.swift   # Loads & filters screenshots
│   └── UIHelpers.swift          # Helper functions
└── Resources/
    ├── Info.plist
    ├── HandyShots.entitlements
    └── welcome_animation.mov    # Welcome video (placeholder)
```

---

## 🎨 UI/UX Flow

### First Launch Flow
```
1. App launches (menu bar icon appears)
2. Click icon → WelcomeView appears
3. Animated "Hello" plays (video or Lottie animation)
4. Shows detected screenshot folder
5. User confirms or changes folder
6. Folder preference saved → isFirstLaunch = false
7. Transitions to PopoverView
```

### Normal Usage Flow
```
1. Click menu bar icon → PopoverView opens
2. Grid shows recent screenshots (last X minutes)
3. Hover over screenshot → smooth zoom animation
4. Click & drag screenshot → drag to other app
5. Right-click menu bar icon → Context menu
   - Open/Close popover
   - Settings
   - Quit
```

---

## 🔧 Core Components Implementation

### 1. FolderDetector.swift
**Purpose**: Detect macOS screenshot save location

**Logic**:
```swift
static func detectSystemFolder() -> String {
    // 1. Check CFPreferences for com.apple.screencapture "location"
    // 2. Try defaults command: defaults read com.apple.screencapture location
    // 3. Fallback to ~/Desktop (macOS default)
    // 4. Verify folder exists
    // 5. Return valid path
}
```

**Key Points**:
- Always returns a valid folder (never nil)
- Resolves `~` to actual home directory
- Validates folder existence before returning

---

### 2. FolderMonitor.swift
**Purpose**: Monitor screenshot folder changes in real-time

**Implementation**:
```swift
class FolderMonitor: ObservableObject {
    @Published var systemScreenshotFolder: String
    @Published var showFolderChangeAlert: Bool
    
    init() {
        // 1. Detect initial folder
        // 2. Setup DistributedNotificationCenter observer
        // 3. Listen for "com.apple.screencapture.location" changes
    }
    
    private func setupNotificationObserver() {
        DistributedNotificationCenter.default().addObserver(
            forName: "com.apple.screencapture.location",
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkForFolderChange()
        }
    }
}
```

**Benefits**:
- Event-driven (no polling timer)
- Instant detection when user changes screenshot location
- Memory efficient

---

### 3. ScreenshotLoader.swift
**Purpose**: Load and filter screenshots from monitored folder

**Implementation**:
```swift
class ScreenshotLoader: ObservableObject {
    @Published var screenshots: [Screenshot] = []
    
    func loadRecentScreenshots(from folder: String, minutes: Int) {
        let fm = FileManager.default
        let now = Date()
        let cutoff = now.addingTimeInterval(-Double(minutes * 60))
        
        // 1. Get all files in folder
        guard let files = try? fm.contentsOfDirectory(atPath: folder) else { return }
        
        // 2. Filter image files (.png, .jpg, .jpeg)
        let imageFiles = files.filter { 
            $0.lowercased().hasSuffix(".png") || 
            $0.lowercased().hasSuffix(".jpg") ||
            $0.lowercased().hasSuffix(".jpeg")
        }
        
        // 3. Filter by modification date (last X minutes)
        let recentFiles = imageFiles.filter { filename in
            let path = (folder as NSString).appendingPathComponent(filename)
            guard let attrs = try? fm.attributesOfItem(atPath: path),
                  let date = attrs[.modificationDate] as? Date else { return false }
            return date >= cutoff
        }
        
        // 4. Sort by date (newest first)
        // 5. Create Screenshot models
        // 6. Load thumbnails asynchronously
    }
}
```

---

### 4. Screenshot Model
```swift
struct Screenshot: Identifiable {
    let id = UUID()
    let filename: String
    let path: String
    let modificationDate: Date
    var thumbnail: NSImage?
    
    var url: URL {
        URL(fileURLWithPath: path)
    }
}
```

---

### 5. ScreenshotGridView.swift
**Purpose**: Display screenshots in responsive grid with hover effects

**Layout**:
```swift
struct ScreenshotGridView: View {
    let screenshots: [Screenshot]
    @State private var hoveredID: UUID?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 12)
            ], spacing: 12) {
                ForEach(screenshots) { screenshot in
                    ScreenshotItemView(
                        screenshot: screenshot,
                        isHovered: hoveredID == screenshot.id
                    )
                    .onHover { isHovered in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            hoveredID = isHovered ? screenshot.id : nil
                        }
                    }
                }
            }
            .padding()
        }
    }
}
```

---

### 6. ScreenshotItemView.swift
**Purpose**: Single screenshot card with zoom animation and drag support

**Implementation**:
```swift
struct ScreenshotItemView: View {
    let screenshot: Screenshot
    let isHovered: Bool
    
    var body: some View {
        ZStack {
            if let image = screenshot.thumbnail {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: isHovered ? 200 : 160, 
                           height: isHovered ? 150 : 120)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(isHovered ? 0.3 : 0.1), 
                            radius: isHovered ? 12 : 4, 
                            x: 0, 
                            y: isHovered ? 6 : 2)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .zIndex(isHovered ? 1 : 0)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 160, height: 120)
            }
        }
        .onDrag {
            NSItemProvider(object: screenshot.url as NSURL)
        }
    }
}
```

**Key Features**:
- Smooth spring animation on hover
- Scale + shadow for depth effect
- z-index to bring hovered item to front
- NSItemProvider for drag-and-drop

---

### 7. WelcomeView.swift
**Purpose**: First launch experience with animation

**Implementation**:
```swift
struct WelcomeView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("screenshotFolder") private var screenshotFolder = ""
    @EnvironmentObject private var folderMonitor: FolderMonitor
    @State private var showFolderSelection = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated "Hello" 
            if !showFolderSelection {
                WelcomeAnimationView()
                    .frame(width: 400, height: 300)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showFolderSelection = true
                            }
                        }
                    }
            } else {
                Text("Welcome to HandyShots!")
                    .font(.title).bold()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detected screenshot folder:")
                        .font(.caption).foregroundColor(.secondary)
                    
                    Text(folderMonitor.systemScreenshotFolder)
                        .font(.callout)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                HStack(spacing: 16) {
                    Button("Use This Folder") {
                        screenshotFolder = folderMonitor.systemScreenshotFolder
                        isFirstLaunch = false
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Choose Different...") {
                        if let url = openFolderPanel() {
                            screenshotFolder = url.path
                            isFirstLaunch = false
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(24)
        .frame(width: 500, height: 400)
    }
}
```

---

### 8. WelcomeAnimationView.swift
**Purpose**: Animated hello screen (placeholder for video)

**Temporary Implementation**:
```swift
struct WelcomeAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        Text("Hello! 👋")
            .font(.system(size: 72, weight: .bold))
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    rotation = 5
                }
            }
    }
}
```

**Future Enhancement**:
Replace with AVPlayer for custom video:
```swift
import AVKit

struct WelcomeAnimationView: View {
    var body: some View {
        if let url = Bundle.main.url(forResource: "welcome_animation", withExtension: "mov") {
            VideoPlayer(player: AVPlayer(url: url))
                .disabled(true)
        }
    }
}
```

---

### 9. SettingsView.swift
**Purpose**: Configure time filter and preferences

```swift
struct SettingsView: View {
    @AppStorage("timeFilterMinutes") private var timeFilter = 5
    
    var body: some View {
        Form {
            Section("Display Settings") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Show screenshots from last:")
                        Spacer()
                        Text("\(timeFilter) minutes")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(timeFilter) },
                        set: { timeFilter = Int($0) }
                    ), in: 1...60, step: 1)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 300)
    }
}
```

---

### 10. HandyShotsApp.swift
**Purpose**: App entry point + menu bar setup

```swift
@main
struct HandyShotsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private var settingsWindow: NSWindow?
    private let folderMonitor = FolderMonitor()
    private let screenshotLoader = ScreenshotLoader()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "camera.fill", 
                                   accessibilityDescription: "HandyShots")
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Configure popover
        popover.contentSize = NSSize(width: 600, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverView()
                .environmentObject(folderMonitor)
                .environmentObject(screenshotLoader)
        )
        
        // Start monitoring
        folderMonitor.start()
    }
    
    @objc func togglePopover(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                if let button = statusItem.button {
                    popover.show(relativeTo: button.bounds, 
                                 of: button, 
                                 preferredEdge: .minY)
                    
                    // Reload screenshots when opening
                    screenshotLoader.loadRecentScreenshots(
                        from: UserDefaults.standard.string(forKey: "screenshotFolder") ?? "",
                        minutes: UserDefaults.standard.integer(forKey: "timeFilterMinutes")
                    )
                }
            }
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings...", 
                                action: #selector(openSettings), 
                                keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit HandyShots", 
                                action: #selector(quit), 
                                keyEquivalent: "q"))
        
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    @objc func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
    }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
}
```

---

## 🚀 Build & Run Instructions

### Prerequisites
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install XcodeGen (optional, for project.yml)
brew install xcodegen
```

### Option 1: Build with Xcode (Recommended)
```bash
# Clone/navigate to project
cd /path/to/HandyShots

# Open in Xcode
open HandyShots.xcodeproj

# Build and run (Cmd+R)
# Or from terminal:
xcodebuild -project HandyShots.xcodeproj \
           -scheme HandyShots \
           -configuration Debug \
           build
```

### Option 2: Build with xcodebuild (Command Line)
```bash
# Clean build folder
rm -rf build/

# Build
xcodebuild -project HandyShots.xcodeproj \
           -scheme HandyShots \
           -configuration Debug \
           -derivedDataPath build \
           clean build

# Run
open build/Build/Products/Debug/HandyShots.app
```

### Option 3: Generate project from YAML (if using XcodeGen)
```bash
# Generate Xcode project from project.yml
xcodegen generate

# Open generated project
open HandyShots.xcodeproj
```

### Quick Launch Script
Create `launch.sh`:
```bash
#!/bin/bash
set -e

echo "🔨 Building HandyShots..."
xcodebuild -project HandyShots.xcodeproj \
           -scheme HandyShots \
           -configuration Debug \
           -derivedDataPath build \
           clean build > /dev/null 2>&1

echo "🚀 Launching HandyShots..."
open build/Build/Products/Debug/HandyShots.app

echo "✅ HandyShots is running!"
```

Make executable and run:
```bash
chmod +x launch.sh
./launch.sh
```

---

## 🧪 Testing the App

### Test Screenshot Detection
```bash
# Change screenshot location to Downloads
defaults write com.apple.screencapture location ~/Downloads
killall SystemUIServer

# App should detect the change and show alert
```

### Test Screenshot Loading
```bash
# Take a screenshot (Cmd+Shift+3 or Cmd+Shift+4)
# Open HandyShots → should appear in grid
```

### Test Time Filter
```bash
# Take screenshots over 10 minutes
# Change time filter in settings (5 min → 15 min)
# Verify grid updates
```

---

## 📦 Project Structure Checklist

### Files to Create
- [x] HandyShotsApp.swift
- [x] PopoverView.swift
- [x] WelcomeView.swift
- [x] WelcomeAnimationView.swift
- [x] ScreenshotGridView.swift
- [x] ScreenshotItemView.swift
- [x] SettingsView.swift
- [x] FolderDetector.swift
- [x] FolderMonitor.swift
- [x] ScreenshotLoader.swift
- [x] Screenshot.swift (model)
- [x] UIHelpers.swift
- [x] Info.plist
- [x] HandyShots.entitlements

### Configuration Files
- [x] project.yml (XcodeGen, optional)
- [x] HandyShots.xcodeproj (Xcode project)
- [x] README.md
- [ ] LICENSE (MIT recommended for open source)

---

## 🎯 MVP Success Criteria

### Must Have (P0)
- ✅ Detects screenshot folder on first launch
- ✅ Shows welcome animation (basic)
- ✅ Displays grid of recent screenshots
- ✅ Hover-to-zoom with smooth animation
- ✅ Drag-and-drop screenshots
- ✅ Time filter setting (1-60 minutes)
- ✅ Real-time folder monitoring
- ✅ Menu bar icon + context menu

### Nice to Have (P1)
- 🔄 Video-based welcome animation
- 🔄 Screenshot preview on click
- 🔄 Quick actions (copy, delete, share)
- 🔄 Keyboard shortcuts
- 🔄 Dark mode optimization

### Future Enhancements (P2)
- 📋 Copy to clipboard
- 🗑️ Delete screenshots
- ✏️ Quick annotations
- 📤 Share to apps
- 🔍 Search/filter by name
- 📊 Screenshot analytics

---

## 🐛 Common Issues & Solutions

### Issue: Folder not detected
**Solution**: Check permissions, verify defaults command works:
```bash
defaults read com.apple.screencapture location
```

### Issue: Screenshots not loading
**Solution**: Verify folder permissions and file extensions:
```bash
ls -la ~/Desktop/*.png
```

### Issue: Popover not showing
**Solution**: Check LSUIElement is set to true in Info.plist

### Issue: Drag-and-drop not working
**Solution**: Ensure `NSItemProvider` uses correct URL format

---

## 📚 Key Dependencies

### Native Frameworks
- SwiftUI (UI framework)
- AppKit (Menu bar, NSStatusItem, NSPopover)
- Combine (Reactive data flow)
- Foundation (File management, UserDefaults)

### No External Dependencies Required
This app uses only native macOS frameworks - no CocoaPods, SPM, or Carthage needed!

---

## 🎨 Design Specifications

### Grid Layout
- **Columns**: Adaptive (120-200px per item)
- **Spacing**: 12px between items
- **Padding**: 16px around grid
- **Item Size**: 160x120px (default), 200x150px (hovered)

### Animations
- **Hover Scale**: 1.0 → 1.1
- **Spring Animation**: response 0.3, damping 0.7
- **Shadow**: radius 4 → 12, y-offset 2 → 6

### Colors
- **Primary**: System blue
- **Background**: System background
- **Hover overlay**: Black 10% opacity
- **Text**: System label colors (adapts to dark mode)

---

## 🔐 Privacy & Permissions

### Required Permissions
1. **File Access**: User-selected folder (handled by NSOpenPanel)
2. **Folder Monitoring**: Uses DistributedNotificationCenter (no special permission)

### Privacy Considerations
- App only accesses user-selected screenshot folder
- No network requests (unless future cloud sync)
- No analytics or tracking
- All data stored locally in UserDefaults

---

## ✅ Final Checklist Before Launch

- [ ] All views implemented
- [ ] Folder detection working
- [ ] Grid displays correctly
- [ ] Hover animation smooth
- [ ] Drag-and-drop functional
- [ ] Settings persist correctly
- [ ] Context menu working
- [ ] Welcome flow complete
- [ ] No memory leaks (test with Instruments)
- [ ] Works on macOS 13.0+
- [ ] README with screenshots
- [ ] LICENSE file added
- [ ] GitHub repository created

---

## 🎬 Next Steps After MVP

1. **User Testing**: Get feedback from 5-10 users
2. **Performance**: Profile with 1000+ screenshots
3. **Polish**: Add loading states, error handling
4. **Documentation**: Write user guide
5. **Distribution**: Create DMG installer or Homebrew formula
6. **Community**: Open source on GitHub, accept contributions

---

**This specification provides everything needed to build HandyShots MVP. Follow the structure, implement each component, and you'll have a fully functional screenshot manager app!** 🚀