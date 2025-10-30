import SwiftUI
import AppKit

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
                    let folder = UserDefaults.standard.string(forKey: "screenshotFolder") ?? folderMonitor.systemScreenshotFolder
                    let minutes = UserDefaults.standard.integer(forKey: "timeFilterMinutes")
                    let timeFilter = minutes == 0 ? 5 : minutes
                    
                    screenshotLoader.loadRecentScreenshots(
                        from: folder,
                        minutes: timeFilter
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
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
}
