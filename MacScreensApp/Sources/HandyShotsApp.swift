import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Nasconde l'icona dock
        NSApp.setActivationPolicy(.accessory)

        // Crea status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "Screenshots")
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Crea popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 600, height: 500)
        popover.behavior = .transient

        // Verifica stato app
        checkAppState()
    }

    func checkAppState() {
        let defaults = UserDefaults.standard
        let hasCompletedSetup = defaults.bool(forKey: "hasCompletedSetup")

        if !hasCompletedSetup {
            // Mostra onboarding
            showOnboarding()
        } else {
            // Verifica permessi
            if hasFullDiskAccess() {
                // Mostra griglia screenshot
                showMainView()
            } else {
                // Mostra richiesta permessi
                showPermissionRequest()
            }
        }
    }

    func hasFullDiskAccess() -> Bool {
        let screenshotPath = NSString(string: "~/Desktop").expandingTildeInPath
        let testPath = (screenshotPath as NSString).appendingPathComponent(".test_access")

        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }

    func showOnboarding() {
        if hasFullDiskAccess() {
            popover.contentViewController = NSHostingController(rootView: WelcomeView())
        } else {
            popover.contentViewController = NSHostingController(rootView: PermissionRequestView())
        }
    }

    func showPermissionRequest() {
        popover.contentViewController = NSHostingController(rootView: PermissionRequestView())
    }

    func showMainView() {
        popover.contentViewController = NSHostingController(rootView: MainScreenshotGridView())
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            let event = NSApp.currentEvent

            // Tasto destro -> mostra menu
            if event?.type == .rightMouseUp {
                showMenu()
                return
            }

            // Tasto sinistro -> toggle popover
            if popover.isShown {
                popover.performClose(nil)
            } else {
                // Ricontrolla stato prima di mostrare
                checkAppState()
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    func showMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit HandyShots", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "Settings"
            settingsWindow?.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            settingsWindow?.setContentSize(NSSize(width: 400, height: 300))
            settingsWindow?.center()
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
